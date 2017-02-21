/**
 *  Date:   2017/01/16
 *  Description:    This batchable deletes the rows from ricavo__c that resolve the where clause
 *                  (a sort of workaround to overcome a bug that creates null rows in some circumstances) 
 *  Author: Claudio Arado
 */


global class BatchableDeleteRicaviNulli implements Database.Batchable<SObject>, Database.stateful {
	
	public integer totalrec_deleted = 0;
	private static final String baseQuery = 'SELECT id, mese__c, anno__c FROM ricavo__c WHERE ';
	private String whereClause ='Valore__c =0 and MinorRicavo__c = false and Percentuale_applicata__c = 0 and Is_FineComp_sup_LiEndDate__c = true ';
	
	public string query;
	
	global BatchableDeleteRicaviNulli() {
           
           query = baseQuery + whereClause;
           system.debug('BatchableDeleteRicaviNulli query'+query);
    }
 
     global BatchableDeleteRicaviNulli(string datainizio, string datafine) {
           if (datainizio=='') 
           query = baseQuery + whereClause + ' and Data_ultimo_mese__c <= ' + datafine;
           else if (datafine=='')
           query = baseQuery + whereClause + 'and Data_ultimo_mese__c > ' + datainizio;
           else
           query = baseQuery + whereClause + ' and Data_ultimo_mese__c <= ' + datafine + ' and Data_ultimo_mese__c > ' + datainizio;
           system.debug('BatchableDeleteRicaviNulli query'+query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
    		system.debug('start');
    	    return Database.getQueryLocator(query);
    	   }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
	       system.debug('Inizio execute');
	       
	       for(SObject s : scope){
	       	Ricavo__c r = (Ricavo__c)s;
			system.debug('RicaviID = '+ r.id + ' ' + r.mese__c + ' ' + r.anno__c);        
    	    }
    	    UtilSkipTrigger.skipCheckIfRicaviSuMesiAperti= true;
    	    try{
           		LineItemTriggerHandler.skipLineItemTrigger = true;
           		delete scope;
           		totalrec_deleted += scope.size();
        	}catch(DMLException e){
        	UtilExceptionIntegration.sendEmailToCustomEmailLog('Batchable Delete Ricavi Nulli Exception',e.getmessage(),'AmministratoriSistema');	
            }
    	   system.debug('Size dello scope: '+scope.size());
	       system.debug('Totale record cancellati: '+totalrec_deleted);
    }

	       
	global void finish(Database.BatchableContext BC){
		 system.debug('Size recDeleted finish:'+totalrec_deleted);
		 UtilExceptionIntegration.sendEmailToCustomEmailLog('Batchable Delete Ricavi Nulli completed','Sono stati eliminati record ' + totalrec_deleted + ' con ricavo nullo.','AmministratoriSistema');
	}
	      
}