global class BatchableUpsertAsset implements Database.Batchable<sObject>,Database.Stateful{

    list<asset> assets;
    map<long,lineitem__c> lineItemMap = new map<long,lineitem__c>();
    date d;
    
    public BatchableUpsertAsset(list<asset> assets,set<long> lineItemIds,date d){
        this.d = d;
        this.assets = assets;
        for(LineItem__c li : [select id,id_dfp__c,product__c,opportunity__r.accountid,start_date__c,end_date__c,totale__c
                              from lineitem__c 
                              where id_dfp__c in : lineItemIds]){
            lineItemMap.put((long) li.id_dfp__c,li);
        }
    }

    global Iterable<sObject> start(Database.BatchableContext BC){
        list<asset> res = assets;
        assets = null;
        return res;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            list<asset> assetToUpsert = new list<asset>();
            for(Asset a : (list<asset>) scope){
                if(lineItemMap.get(long.valueOf(a.SerialNumber)) != null){
                    lineitem__c li = lineItemMap.get(long.valueOf(a.SerialNumber));
                    a.line_item__c = li.id;
                    a.accountId = li.opportunity__r.accountid;
                    a.SerialNumber = '';
                    a.Product2Id = li.Product__c;
                    a.Percentuale_mese__c = getPercentualeMese(li.start_date__c,li.end_date__c,integer.valueOf(a.month__c),integer.valueOf(a.year__c));
                    assetToUpsert.add(a);
                }
            }
        
            upsert assetToUpsert Asset.Fields.external_key__c;
        }catch(exception e){
            UtilExceptionIntegration.sendEmail('error generating asset', e.getMessage() , 'giovanni.oregioni@telnext.com');
        }
    }

    global void finish(Database.BatchableContext BC){
        id sfdcJobID = Database.executeBatch(new BatchableUpsertAssetStep2(lineItemMap.values(),d.month()+'',d.year()+''),100);
    }
    
    public static double getPercentualeMese(date startDate,date endDate,integer month,integer year){
        if(startDate.month() == month && endDate.month() == month){
            return 100;
        }
        if((endDate.month() < month) || (startDate.month() > month)){
            return 0; //non dovrebbe mai succedere
        }
        
        integer durata = startDate.daysBetween(endDate)+1; //durata lineitem
        integer durataInMonth = 0;                       //durata lineitem nel mese

        date initDate = startDate;
        if(initDate.month() < month){
            initDate = date.newInstance(year,month,1);
        }
        date stopDate = initDate.addMonths(1).toStartOfMonth().addDays(-1);
        if(endDate < stopDate) stopDate = endDate;
        
        durataInMonth = initDate.daysBetween(stopDate)+1;
        /*
        system.debug('startDate :'+startDate);
        system.debug('endDate :'+endDate);
        system.debug('durata :'+durata);
        system.debug('durataInMonth :'+durataInMonth);
        */
        return ((double)durataInMonth/durata) * 100;
    }
    
    public static testMethod void testGetPercentualeMese(){
        date startDate = date.newInstance(2012,11,10);
        date endDate = date.newInstance(2012,11,20);
        double perc = BatchableUpsertAsset.getPercentualeMese(startDate,endDate,11,2012);
        integer durata = 11;
        integer durataInMonth = 11;
        system.assertEquals(perc,((double)durataInMonth/durata) * 100);
        
        startDate = date.newInstance(2012,11,29);
        endDate = date.newInstance(2012,12,2);
        perc = BatchableUpsertAsset.getPercentualeMese(startDate,endDate,11,2012);
        durata = 4;
        durataInMonth = 2;
        system.assertEquals(perc,((double)durataInMonth/durata) * 100);
        
        
    }
}