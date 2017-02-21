global class BatchableSplitRigheFatturazione implements Database.Batchable<sObject> {
    
    Riga_Fatturazione__c[] righe;
    
    global BatchableSplitRigheFatturazione(Riga_Fatturazione__c[] righe) {
        this.righe = righe;
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC) {
        return [Select id,Prezzo_unitario__c,Stato__c,Ticket_fatturazione__c,Ticket_fatturazione__r.Data_primo_mese__c,
                            Ticket_fatturazione__r.Ticket_manuale__c,
                            Line_Item__c,Line_Item__r.Width__c,Line_Item__r.Height__c,Line_Item__r.MultiSize__c,
                            Line_Item__r.ProductFamily__c,
                        (Select Data_primo_mese__c,Line_Item__c,Line_Item__r.Width__c,
                            Line_Item__r.Height__c,Line_Item__r.MultiSize__c,
                            Line_Item__r.ProductFamily__c
                        from Revenue_applications__r)
                From Riga_Fatturazione__c 
                Where id in : righe];
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        UtilityAdUnitInventory util = new UtilityAdUnitInventory();
        Spaccato_Riga_Fatturazione__c[] spaccati = new Spaccato_Riga_Fatturazione__c[]{};
        for(Riga_Fatturazione__c r : (Riga_Fatturazione__c[]) scope){
            
            LineItem__c li = [select Id,Product__r.UtilizzaDimensioniProdotto__c,Product__r.Area_editoriale__c,
                                     Product__r.Brand__c,Product__r.Delivery_Channel__c 
                              from LineItem__c 
                              where id =: r.Line_Item__c];

            if(li.Product__r.UtilizzaDimensioniProdotto__c){
                Spaccato_Riga_Fatturazione__c s = new Spaccato_Riga_Fatturazione__c(
                                                        Area_editoriale__c = li.Product__r.Area_editoriale__c,
                                                        Brand__c = li.Product__r.Brand__c,
                                                        Delivery_Channel__c = li.Product__r.Delivery_Channel__c,
                                                        Riga_Fatturazione__c = r.id,
                                                        Impression__c = 0,
                                                        Stato__c = 'Da inviare',
                                                        Spaccato_prezzo_unitario__c = r.Prezzo_unitario__c
                                                    );
                spaccati.add(s);
                continue;
            }

            Map<String,Spaccato_Riga_Fatturazione__c> spaccatiMap = new Map<String,Spaccato_Riga_Fatturazione__c>();
            map<id,decimal> globalImpressionAdUnit = new map<id,decimal>();
            decimal globalImpr = 0;

            Revenue_application__c[] revenues = r.Revenue_applications__r;
            if(r.Ticket_fatturazione__r.Ticket_manuale__c && revenues.isEmpty()){
                if(r.Line_Item__c != null){
                    revenues.add(
                        new Revenue_application__c(
                            Line_Item__c = r.Line_Item__c,
                            Line_Item__r = r.Line_Item__r
                        )
                    );
                }
            }

            for(Revenue_application__c ra : revenues){
                if(ra.line_Item__r.ProductFamily__c != 'Banner'){
                    continue;
                }

                Date dataPrimoMese = ra.Data_primo_mese__c != null ? ra.Data_primo_mese__c : r.Ticket_Fatturazione__r.Data_primo_mese__c;


                map<id,decimal> impressionAdUnit = UtilityAdUnitInventory.getDeliveredImpressionAdUnit(ra.Line_Item__c,dataPrimoMese);
                
                if(impressionAdUnit.isEmpty()){
                    impressionAdUnit = UtilityAdUnitInventory.getDeliveredImpressionAdUnitPrevious(ra.Line_Item__c,dataPrimoMese);  
                }

                if(impressionAdUnit.isEmpty()){
 
                    li = [select Ad_Server__c,
                                             (Select Ad_Unit__c,InventoryTargetingType__c,ad_unit__r.pageOas__c from Inventory_Target__r),
                                             (Select Placement__r.targetedAdUnitIds__c From PlacementTargeting__r),
                                             (Select SectionOas__r.Pages__c,SectionOas__c from SectionsOasTargeted__r)
                                      from LineItem__c
                                      where Id =: ra.Line_Item__c
                                     ];

                    set<Id> adunits;

                    if(li.Ad_Server__c == 'OAS'){
                        adunits = UtilityAdUnitInventory.getAdUnitLineItemOas(li);
                    }else{
                        String sizes = ra.Line_Item__r.Width__c+'x'+ra.Line_Item__r.Height__c;
                        if(!String.isBlank(ra.Line_Item__r.MultiSize__c)){
                            sizes += ';'+ra.Line_Item__r.MultiSize__c;
                        }
                        sizes = sizes.replace('.00','');
                        adunits = util.getAdUnitLineItem(li.Inventory_Target__r,sizes);
                        adunits.addAll(util.getAdUnitLineItem(li.PlacementTargeting__r,sizes));
                    }

                    system.debug('adunits = '+adunits);

                    
                    if(dataPrimoMese >= date.today().toStartOfMonth()){
                        dataPrimoMese = date.today().addMonths(-1).toStartOfMonth();
                    }
                    impressionAdUnit = UtilityAdUnitInventory.getEstimateImpressionAdUnit(adunits,dataPrimoMese);

                    
                    if(impressionAdUnit.isEmpty()){
                        impressionAdUnit = UtilityAdUnitInventory.getEstimateImpressionAdUnit(adunits,dataPrimoMese.addMonths(-1));
                    }

                    if(impressionAdUnit.isEmpty()){
                        for(id i : adunits){
                            impressionAdUnit.put(i,1);
                        }
                    }
                    
                }

                for(id i : impressionAdUnit.keySet()){
                    decimal actualImpr = globalImpressionAdUnit.get(i);
                    actualImpr = actualImpr == null ? 0 : actualImpr;
                    globalImpressionAdUnit.put(i,actualImpr+impressionAdUnit.get(i));
                    globalImpr += impressionAdUnit.get(i);
                }

            }

            
            for(id i : globalImpressionAdUnit.keySet()){
                AdUnit__c adu = util.allAdUnitMap.get(i);
                String key = adu.Area_editoriale__c+adu.Brand__c+adu.Delivery_Channel__c;
                if(!spaccatiMap.containsKey(key)){
                    spaccatiMap.put(
                            key,
                            new Spaccato_Riga_Fatturazione__c(
                                Area_editoriale__c = adu.Area_editoriale__c,
                                Brand__c = adu.Brand__c,
                                Delivery_Channel__c = adu.Delivery_Channel__c,
                                Riga_Fatturazione__c = r.id,
                                Impression__c = 0,
                                Stato__c = 'Da inviare'
                            )
                        );
                }
                spaccatiMap.get(key).Impression__c += globalImpressionAdUnit.get(i);
            }

            decimal totRiga = r.Prezzo_unitario__c;
            decimal actual = 0;

            System.debug('totRiga = '+totRiga);
            System.debug('totImpression = '+globalImpr);


            for(Integer i=0;i<spaccatiMap.values().size();i++){
                Spaccato_Riga_Fatturazione__c s = spaccatiMap.values().get(i);
                s.Spaccato_prezzo_unitario__c = totRiga * (s.Impression__c/globalImpr);
                s.Spaccato_prezzo_unitario__c = s.Spaccato_prezzo_unitario__c.setScale(2,ROUNDINGMODE.HALF_DOWN);
                actual += s.Spaccato_prezzo_unitario__c;
                System.debug('actual = '+actual);
                if(i==spaccatiMap.values().size()-1 && totRiga != actual){
                    s.Spaccato_prezzo_unitario__c += totRiga-actual;
                }
                spaccati.add(s);
                System.debug('Impression = '+s.Impression__c+' -> Prezzo_unitario =' +s.Spaccato_prezzo_unitario__c);
            }  

            r.Stato__c = 'Da inviare';
        }
        insert spaccati;
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        set<id> ticketIds = new set<id>();
        for(Riga_Fatturazione__c r : righe){
            ticketIds.add(r.Ticket_fatturazione__c);
        }
        Ticket_fatturazione__c[] ticketsToUpdate = new Ticket_fatturazione__c[]{};
        for(Ticket_fatturazione__c t : [select id,Stato__c,Numero_righe_da_inviare__c,Numero_totale_righe__c
                                            from Ticket_fatturazione__c 
                                            where id in : ticketIds
                                            ]){
            if(t.Numero_righe_da_inviare__c == t.Numero_totale_righe__c){ // && t.Stato__c == '' ??
                t.Stato__c = 'Draft';
                ticketsToUpdate.add(t);
            }
        }
        update ticketsToUpdate;
    }
    
}