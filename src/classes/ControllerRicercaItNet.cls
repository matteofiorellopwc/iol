public with sharing class ControllerRicercaItNet{
    
    Public List<Account> accountResults {get;set;}
    Public List<Contratto__c> contrattoResults {get;set;}
    Public List<SottoContratto__c> sottoContrattoResults {get;set;}
    public String searchString {get;set;}
    public Boolean showNoResult {get;set;}
  
    public ControllerRicercaItNet(){
        accountResults = new List<Account>();
        contrattoResults = new List<Contratto__c>();
        sottoContrattoResults = new List<SottoContratto__c>();
        showNoResult = false;
        
    }
    public void find(){
        accountResults = [SELECT RecordTypeId, Name, Account_Accesso__c, Chiave_per_legame_accesso_esterni__c, Ragione_sociale__c, Nome_persona_fisica__c, cognome_persona_fisica__c, Email_principale__c
                          FROM Account 
                          WHERE (Account_Accesso__c LIKE :searchString+'%' OR
                          Chiave_per_legame_accesso_esterni__c LIKE :searchString+'%') AND
                          RecordTypeId = : UtilItNet.itNetAccountRecordTypeId];
        contrattoResults = [SELECT Name, Cliente__c, Descrizione__c, SottocontrattiConProdottiAperti__c, Data_Chiusura__c, ID_anagrafica_Fatturazione__c, Propaga_data_chiusura__c,  Propaga_sospensione__c
                            FROM Contratto__c 
                            WHERE Id =: searchString];
        sottoContrattoResults = [SELECT Name, Contratto__c, Descrizione__c, ProdottiSottoContrattoAperti__c, Propaga_data_chiusura__c, Propaga_sospensione__c 
                           		 FROM SottoContratto__c 
                           		 WHERE Id =: searchString];
        
        if(accountResults.size() == 0 && contrattoResults.size() == 0 && sottoContrattoResults.size() == 0){
        	showNoResult = true;    
        }
        else{
        	showNoResult = false;	    
        } 
        
    }
	
    @isTest static void testControllerRicercaItNet(){
    	Account a = UtilTestApritisito.insertClienteTest('Attivo');
        Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
        
        ControllerRicercaItNet cont = New ControllerRicercaItNet();
		
		cont.searchString = a.Chiave_per_legame_accesso_esterni__c;       
        cont.find();
        System.assertEquals(a.Chiave_per_legame_accesso_esterni__c, cont.accountResults.get(0).Chiave_per_legame_accesso_esterni__c);       
    }
}