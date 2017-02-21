global class BatchableDisableTempItNet implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private static final Datetime filterDate = Datetime.now().addHours(-1);    
    private static final Id rtId = UtilItNet.itNetAccountRecordTypeId;
    private static final String baseQuery = 'SELECT Id, Stato__c, Chiave_univoca_Aria__c FROM Account WHERE ';
    private String query = ' (Stato__c = \'Temp\' OR (Stato__c = \'Attivo\' AND ContrattiConProdottiAperti__c = 0)) AND RecordTypeId = :rtId AND CreatedDate < :filterDate';
    
    private Set<Id> filterIds;
    
    global BatchableDisableTempItNet() {
        this.query = baseQuery + query;
    }
    global BatchableDisableTempItNet(String whereClause) {
        this.query = baseQuery + whereClause;
    }

    global BatchableDisableTempItNet(Set<Id> filterIds) {
        this.filterIds = filterIds;
        this.query = baseQuery + ' RecordTypeId = :rtId AND Id IN :filterIds';
    }
    
    public class BatchableDisableTempItNetException extends Exception {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Integer errorCount = 0;
        List<Account> filteredScope = new List<Account>();
        list<string> emailErrors = new list<string>(); //errori da mandare via mail
        
        for(SObject s : scope) {
            Account a = (Account) s;
            
            //Disabilitazione utente su aria
            if(a.Chiave_univoca_aria__c != null && a.Chiave_univoca_aria__c != '') {
                Map<String, Object> res = AriaIntegration.changeAccountStatus(a.Id, a.Chiave_univoca_aria__c);
                //Se non c'è un errore o l'errore è "utente non trovato"
                Decimal code = (Decimal) res.get('cod');
                if(code == 0 || code == -107) {
                    a.Stato__c = 'Disattivo';
                    filteredScope.add(a);
                } else{
                    System.debug('ERRORE!!! ' + String.valueOf(code) + ' ' + (String) res.get('desc'));
                    emailErrors.add('ERRORE!!! ' + String.valueOf(code) + ' ' + (String) res.get('desc') + ' Id Salesforce: '+a.id);
                }
            }else{
                a.Stato__c = 'Disattivo';
                filteredScope.add(a);
            }
        }
        List<Database.SaveResult> res = Database.update(filteredScope, false);
        if(emailErrors.size() > 0){
	        UtilExceptionIntegration.sendEmailToCustomEmailLog('Error in BatchableDisableTempItNet',string.join(emailErrors,'\n\n'),'ApritiSitoLog');
        }
        list<string> errors = new list<string>();
        for(Database.SaveResult sr : res) {
            if(!sr.isSuccess()){
                errorCount++;                                            
                errors.add(sr.getId() + ' -> ' + sr.GetErrors());
            }
        }
        if(errorCount > 0){
            throw new BatchableDisableTempItNetException('Alcuni record non sono stati disattivati: numero record: ' + filteredScope.size() + '; numero errori: ' + errorCount + '\n errori: '+errors);
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}