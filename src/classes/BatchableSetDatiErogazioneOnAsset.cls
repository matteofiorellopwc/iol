global class BatchableSetDatiErogazioneOnAsset implements Database.Batchable<sObject>,Database.Stateful {
    private String query = 'SELECT adUnitView__c, line_item__c, Day__c,Month__c,Year__c,SommaClickLineItem__c, SommaImpressionLineItem__c,group_by_key__c FROM Asset ';
    private boolean onlyErogazioniTotali;
    
    public BatchableSetDatiErogazioneOnAsset(){
        onlyErogazioniTotali = true;
    }
    
    public BatchableSetDatiErogazioneOnAsset(boolean onlyErogazioniTotali){
        this.onlyErogazioniTotali = onlyErogazioniTotali;
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(onlyErogazioniTotali){
            query += ' WHERE hasDatiErogazioneTotali__c = false order by year__c,month__c,day__c';        
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){        
        Map<String, List<Asset>> assetMap = new Map<String, List<Asset>>(); //idlineitem_adUnitView(_G|'') -> list<asset>        
        Set<Id> lineItemIds = new Set<Id>();
        set<string> groupKeys = new set<string>();
        for(SObject aO : scope) {
            Asset a = (Asset) aO;
            lineItemIds.add(a.Line_Item__c);
            String assetKey = a.line_item__c+'_'+a.adUnitView__c+'_'+a.Day__c+'_'+a.Month__c+'_'+a.Year__c;
            groupKeys.add(a.group_by_key__c);
            if(assetMap.get(assetKey) == null) {
                assetMap.put(assetKey, new List<Asset>());
            }
            assetMap.get(assetKey).add(a);
        }
        
        
        List<AggregateResult> aggr = [SELECT
            SUM(Impressions__c) totImpr,
            SUM(clicks__c) totClicks,
            Line_Item__c li,
            adUnitView__c adUnitView,
            Day__c d,Month__c m,Year__c y
            FROM Asset
            WHERE line_item__c in : lineItemIds 
            AND group_by_key__c in :  groupKeys
            GROUP BY Line_Item__c, adUnitView__c, month__c, year__c, day__c
        ];
        

        for(AggregateResult ag : aggr) {
            String assetKey = (string)ag.get('li')+'_'+(string)ag.get('adUnitView')+'_'+(date)ag.get('d')+'_'+(string)ag.get('m')+'_'+(string)ag.get('y');
            if(assetMap.get(assetKey) != null){
                for(Asset a : assetMap.get(assetKey)) {
                    a.SommaClickLineItem__c = (Decimal) ag.get('totClicks');
                    a.SommaImpressionLineItem__c = (Decimal) ag.get('totImpr');
                    a.hasDatiErogazioneTotali__c = true;
                }
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {}
    
    public static testMethod void testBatchableSetDatiErogazioneOnAsset(){
        Account acc = new Account(Name='test');
        insert acc;
        Asset a = new Asset(Name='test',AccountId=acc.id);
        insert a;
        Test.startTest();
        Database.executeBatch(new BatchableSetDatiErogazioneOnAsset(false),1);
        Test.stopTest();
    }
}