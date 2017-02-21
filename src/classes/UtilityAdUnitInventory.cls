public class UtilityAdUnitInventory {

    public Map<id,AdUnit__c> allAdUnitMap {get;set;}
    public Map<String,AdUnit__c> dfpAdUnitMap {get;set;}
    public Map<id,list<id>> adUnitTree {get;set;}

    public UtilityAdUnitInventory() {
        allAdUnitMap = new Map<id,Adunit__c>([select id,ParentAdUnit__c,explicitlyTargeted__c,Sizes__c,Status__c,idDfp__c,
                                                     Area_editoriale__c,Brand__c,Delivery_Channel__c
                                            from AdUnit__c 
                                    ]);
        dfpAdUnitMap = new Map<String,AdUnit__c>();
        adUnitTree = new Map<id,list<id>>();
        for(id i : allAdUnitMap.keySet()){
            if(!adUnitTree.containsKey(i)){
                adUnitTree.put(i,new list<id>());    
            }
            if(allAdUnitMap.get(i).parentAdUnit__c != null && !adUnitTree.containsKey(allAdUnitMap.get(i).parentAdUnit__c)){
                adUnitTree.put(allAdUnitMap.get(i).parentAdUnit__c,new list<id>());    
            }
            if(allAdUnitMap.get(i).parentAdUnit__c != null){
                adUnitTree.get(allAdUnitMap.get(i).parentAdUnit__c).add(i);             
            }
            if(allAdUnitMap.get(i).idDfp__c != null){
                dfpAdUnitMap.put(allAdUnitMap.get(i).idDfp__c,allAdUnitMap.get(i));
            }
        }
    }

    public static set<id> getAdUnitLineItemOas(LineItem__c li){
        set<string> pages = new set<string>();
        set<string> excluded = new set<string>();

        for(Inventory_Target__c it : li.Inventory_Target__r){
            if(it.InventoryTargetingType__c == 'targeted'){
                pages.add(it.ad_unit__r.pageOas__c);
            }else{
                excluded.add(it.ad_unit__r.pageOas__c);
            }
        }
        for(SectionOasTargeted__c s : li.SectionsOasTargeted__r){
            if(!String.isBlank(s.SectionOas__c)){
                pages.addAll(s.SectionOas__r.Pages__c.split('\n'));
            }
        } 

        pages.removeAll(excluded);


        Map<id,adUnit__c> adUnitMap = new Map<id,adUnit__c>([select id from adUnit__c where Ad_Server__c = 'OAS' and pageOas__c in : pages]);
        return adUnitMap.keySet();
    }


    public set<id> getAdUnitLineItem(PlacementTargeting__c[] placementTargeting,String sizesLineItem){
        
        set<id> adUnitIncluded = new set<id>();
        set<id> adUnitExcluded = new set<id>();

        for(PlacementTargeting__c pt : placementTargeting){
            if(pt.Placement__r.targetedAdUnitIds__c != null){
                for(String s : pt.Placement__r.targetedAdUnitIds__c.split(',')){
                    if(dfpAdUnitMap.get(s) != null){
                        adUnitIncluded.add(dfpAdUnitMap.get(s).id);
                    }
                }
            }
        }

        return getAdUnitLineItemRecursive(adUnitIncluded,adUnitExcluded,sizesLineItem.replace(' ','').split(';'));
    }

    public set<id> getAdUnitLineItem(Inventory_Target__c[] inventoryTargeting,String sizesLineItem){

        set<id> adUnitIncluded = new set<id>();
        set<id> adUnitExcluded = new set<id>();

        for(Inventory_Target__c iv : inventoryTargeting){
            if(iv.InventoryTargetingType__c == 'targeted'){
                adUnitIncluded.add(iv.Ad_Unit__c);
            }else{
                adUnitExcluded.add(iv.Ad_Unit__c);
            }
        }
        return getAdUnitLineItemRecursive(adUnitIncluded,adUnitExcluded,sizesLineItem.replace(' ','').split(';'));
    }
 
    private set<id> getAdUnitLineItemRecursive(set<Id> adUnitIncluded,Set<Id> adUnitExcluded,list<String> sizesLineItem){
        system.debug('adUnitIncluded = '+adUnitIncluded);
        set<id> adUnitLineItem = new set<id>();

        Boolean allSizes = sizesLineItem == new list<String>{'0x0'} || sizesLineItem == new list<String>{'1x1'};

        for(id i : adUnitIncluded){
            Adunit__c adu = allAdUnitMap.get(i);
            if(adu.Status__c == 'ACTIVE' && !adUnitExcluded.contains(adu.id)){

                set<String> adUnitSizes = new set<String>();
                if(!String.isBlank(adu.Sizes__c)){
                    adUnitSizes.addAll(adu.Sizes__c.replace(' ','').split(','));

                    system.debug('adUnitSizes'+adUnitSizes);

                    adUnitSizes.retainAll(sizesLineItem);
                    if(!adUnitSizes.isEmpty() || allSizes){
                        adUnitLineItem.add(adu.id);                 
                    }
                }

                set<id> children = new set<id>();
                for(id c : adUnitTree.get(i)){
                    if(!allAdUnitMap.get(c).explicitlyTargeted__c){
                        children.add(c);
                    }
                }
                adUnitLineItem.addAll(getAdUnitLineItemRecursive(children,adUnitExcluded,sizesLineItem));
            }
        }
        return adUnitLineItem;
    }

    public static map<id,decimal> getEstimateImpressionAdUnit(set<id> adunit,date dataPrimoMese){
        list<aggregateResult> assets = [select sum(Impressions__c) sumImpr,AdUnit__c adunit
                                        from asset 
                                        where AdUnit__c in : adunit 
                                        and Data_primo_mese__c =: dataPrimoMese //posso usare asset mensili perchè le stime sono sempre dei mesi passati
                                        and (adUnitView__c = 'FLAT' OR AdServer__c = 'OAS')
                                        group by AdUnit__c];
        return getImpressionMap(assets);
    }

    public static map<id,decimal> getDeliveredImpressionAdUnit(Id lineitem,date dataPrimoMeseGiornaliero){
        list<aggregateResult> assets = [select sum(Impressions__c) sumImpr,AdUnit__c adunit
                                        from asset 
                                        where Line_Item__c =: lineitem
                                        and Data_primo_mese_giornaliero__c =: dataPrimoMeseGiornaliero //devo usare asset giornalieri perchè potrei essere nel mese corrente
                                        and (adUnitView__c = 'FLAT' OR AdServer__c = 'OAS')
                                        group by AdUnit__c];

        if(assets.isEmpty()){ //se non ho asset giornalieri, provo con gli asset mensili
            assets = [select sum(Impressions__c) sumImpr,AdUnit__c adunit
                      from asset 
                      where Line_Item__c =: lineitem
                      and Data_primo_mese__c =: dataPrimoMeseGiornaliero
                      and (adUnitView__c = 'FLAT' OR AdServer__c = 'OAS')
                      group by AdUnit__c];
        }
        return getImpressionMap(assets);
    }

    public static map<id,decimal> getDeliveredImpressionAdUnitPrevious(Id lineitem,date dataPrimoMese){
        list<aggregateResult> assets = [select sum(Impressions__c) sumImpr,AdUnit__c adunit
                                        from asset 
                                        where Line_Item__c =: lineitem
                                        and Data_primo_mese__c <: dataPrimoMese //posso usare asset mensili perchè sono mesi passati
                                        and (adUnitView__c = 'FLAT' OR AdServer__c = 'OAS')
                                        group by AdUnit__c];
        return getImpressionMap(assets);        
    }

    private static map<id,decimal> getImpressionMap(aggregateResult[] assets){
        map<id,decimal> imprMap =  new map<id,decimal>();
        for(aggregateResult ar : assets){
            if((decimal) ar.get('sumImpr') > 0){
                imprMap.put((String) ar.get('adunit'), (decimal) ar.get('sumImpr'));                
            }
        }
        return imprMap;
    }

}