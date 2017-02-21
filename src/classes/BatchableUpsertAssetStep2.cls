global class BatchableUpsertAssetStep2 implements Database.Batchable<sObject>,Database.Stateful{
    
    list<lineitem__c> lineItems;
    string month;
    string year;
    
    public BatchableUpsertAssetStep2(list<lineitem__c> lineItems,string month,string year){
        this.lineItems = lineItems;
        this.month = month;
        this.year = year;
    }

    global Iterable<sObject> start(Database.BatchableContext BC){
        return lineItems;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<lineitem__c> lis = (list<lineitem__c>) scope;
        map<string,list<asset>> assetMap = new map<string,list<asset>>(); //idlineitem_adUnitView -> list<asset>
        list<asset> assetToUpdate = [select adUnitView__c,line_item__c,SommaClickLineItem__c,SommaImpressionLineItem__c from asset where line_item__c in : lis];
        for(asset a : assetToUpdate){
            if(assetMap.get(a.line_item__c+'_'+a.adUnitView__c) == null){
                assetMap.put(a.line_item__c+'_'+a.adUnitView__c,new list<asset>());
            }
            assetMap.get(a.line_item__c+'_'+a.adUnitView__c).add(a);
        }
        
        list<aggregateResult> aggr = [select sum(Impressions__c) totImpr, sum(clicks__c) totClicks,Line_Item__c li,adUnitView__c adUnitView
                                      from Asset
                                      where line_item__c in : lis 
                                      and month__c =: month
                                      and year__c =: year
                                      group by Line_Item__c,adUnitView__c,month__c,year__c];
        for(aggregateResult ag : aggr){
            if(assetMap.get((string)ag.get('li')+'_'+(string)ag.get('adUnitView')) != null){
                for(asset a : assetMap.get((string)ag.get('li')+'_'+(string)ag.get('adUnitView'))){
                    a.SommaClickLineitem__c = (Decimal) ag.get('totClicks');
                    a.SommaImpressionLineItem__c = (Decimal) ag.get('totImpr');
                }
            }
        }
        update assetToUpdate;
    }

    global void finish(Database.BatchableContext BC){
        
    }
}