trigger TriggerUpdatePercentualiMese on Asset (before insert, before update) {
    
    //Costruisco una mappa id -> LineItem e prendo solo gli asset relativi ai report    
    Set<Id> lineItemIds = new Set<Id>();
    List<Asset> filteredAsset = new List<Asset>();
    for(Asset a : trigger.new) {
    	if(a.line_item__c != null){
            lineItemIds.add(a.line_item__c);
            filteredAsset.add(a);
    	}
    }

    Map<Id,Lineitem__c> lineItemMap = new Map<Id,Lineitem__c>([SELECT
        Id,
        Id_dfp__c,
        Start_date__c,
        End_date__c,
        Totale__c,
        (select id,mese_numero__c,anno_numero__c,Data_primo_mese__c from Revenue_applications__r),
        (select id,mese_numero__c,anno_numero__c,Data_primo_mese__c from Ricavi__r where MinorRicavo__c = false)
        FROM lineitem__c 
        WHERE Id in : lineItemIds    
    ]);
    
    //Aggiorno le percentuali degli asset
    for(Asset a : filteredAsset) {
        Lineitem__c li = lineItemMap.get(a.line_item__c);
        if(a.Tipo__c == 'Erogato DFP Mensile') {
	        a.Percentuale_mese__c = BatchableUpsertAsset.getPercentualeMese(
	            li.start_date__c,
	            li.end_date__c,
	            integer.valueOf(a.month__c),
	            integer.valueOf(a.year__c)
	        );
        }
        a.Revenue_application__c = null;
        for(revenue_application__c ra : li.Revenue_applications__r){
            if(ra.Data_primo_mese__c != null && (ra.Data_primo_mese__c == a.data_primo_mese__c || ra.Data_primo_mese__c == a.Data_primo_mese_giornaliero__c)){
                a.revenue_application__c = ra.id;
            }
        }
        a.Ricavo__c = null;
        for(Ricavo__c ri : li.Ricavi__r){
            if(ri.Data_primo_mese__c != null && (ri.Data_primo_mese__c == a.data_primo_mese__c || ri.Data_primo_mese__c == a.Data_primo_mese_giornaliero__c)){
                a.Ricavo__c = ri.id;   
            }
        }
    }
}