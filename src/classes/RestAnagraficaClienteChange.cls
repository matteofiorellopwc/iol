@RestResource(urlMapping='/AnagraficaClienteChange')
global with sharing class RestAnagraficaClienteChange { 

    global abstract class RestAnagraficaClienteChangeResponse{}
    
    global class RestAnagraficaClienteChangeResponseSuccess extends RestAnagraficaClienteChangeResponse {
        global Boolean success;
        global String message;
        global String accountId;
        global RestAnagraficaClienteChangeResponseSuccess(Boolean success, String message) {
            this(success, message, null);
        }
        global RestAnagraficaClienteChangeResponseSuccess(Boolean success, String message, String accountId) {
            this.message = message;
            this.success = success;
            this.accountId = accountId;
        }
    }
    
    global class RestAnagraficaClienteChangeResponseError extends RestAnagraficaClienteChangeResponse {
        global String message;
        global String errorCode;
        global RestAnagraficaClienteChangeResponseError(String message,String errorCode) {
            this.message = message;
            this.errorCode = errorCode;
        }
    }

    @HttpPost
    global static RestAnagraficaClienteChangeResponse doPost(Account account) {
        System.debug(account);   
        return new RestAnagraficaClienteChangeResponseSuccess(true, '');
    }

    @HttpPut
    global static RestAnagraficaClienteChangeResponse doPut(Account account) {
        System.SavePoint sp = Database.setSavePoint();
        try {            
            if(account.Chiave_per_legame_accesso_esterni__c == null){
                 //return JSON.serialize(new list<RestAnagraficaClienteChangeResponseError>{new RestAnagraficaClienteChangeResponseError('Il campo Chiave_per_legame_accesso_esterni__c è obbligatorio','EXTERNAL_KEY_REQUIRED')});
                 //RestContext.response.responseBody = blob.valueOf(JSON.serialize(new list<RestAnagraficaClienteChangeResponseError>{new RestAnagraficaClienteChangeResponseError('Il campo Chiave_per_legame_accesso_esterni__c è obbligatorio','EXTERNAL_KEY_REQUIRED')}));
                 //return;
                 
                 return new RestAnagraficaClienteChangeResponseError('Il campo Chiave_per_legame_accesso_esterni__c è obbligatorio','EXTERNAL_KEY_REQUIRED');
            }
            Account originalAccount = [SELECT
                Id,
                Stato__c,
                (SELECT Id FROM Ticket_Fatturazione__r)
                FROM Account 
                WHERE Chiave_per_legame_accesso_esterni__c = :account.Chiave_per_legame_accesso_esterni__c
                AND Stato__c <> 'Disattivo'                
                AND RecordTypeId = : UtilItNet.itNetAccountRecordTypeId
                ORDER BY Stato__c desc LIMIT 1
            ];
            
            //Elimino l'eventuale id salesforce dall'account in input
            Account accToMerge = account.clone(false, true, false, false);                                    
            Account mergedAccount = null;
            
            String ok1 = 'ok1';
            String ok2 = 'ok2';
            
            try {                            
                mergedAccount = (Account) Util.mergeObjects(originalAccount, accToMerge, true);
                update mergedAccount;
            } catch(Exception e) {
                
                System.debug('entra1');
                if(e instanceof DMLException && ((DMLException)e).getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    System.debug('entra2');
                    //In questo caso non sono passate alcune validation rule. 
                    //Invece di sovrascrivere l'account originale lo storicizzo
                    mergedAccount = (Account) Util.mergeObjects(originalAccount, accToMerge, false);                
                    originalAccount.Stato__c = 'Decaduto';                
                    update originalAccount;
                    mergedAccount.Vecchio_Cliente__c = originalAccount.Id;                   
                    insert mergedAccount;
                    
                    try{
                    //Estrai nuovi contratti
                    List<Contratto__c> newContracts = [SELECT Cliente__c, SottocontrattiConProdottiAperti__c 
                                                       FROM Contratto__c
                                                       WHERE Cliente__c = :originalAccount.Id AND SottocontrattiConProdottiAperti__c > 0];
                    //Sposta contratti sotto il nuovo account
                    for(Contratto__c nc : newContracts){ 
                        nc.Cliente__c = mergedAccount.Id; 
                    }
                    update newContracts;
                    } catch(Exception ex) {
                    }                                  
                                                       
                } else throw e;
            }
            
//            RestContext.response.addheader('Content-Type','application/json');
//            RestContext.response.responseBody = blob.valueOf(JSON.serialize(new RestAnagraficaClienteChangeResponseSuccess(true, '', mergedAccount.Id)));
//            return;
//            return JSON.serialize(new RestAnagraficaClienteChangeResponseSuccess(true, '', mergedAccount.Id));
            return new RestAnagraficaClienteChangeResponseSuccess(true, '', mergedAccount.Id);
        } catch(Exception e) {
            Database.rollback(sp);
            //return JSON.serialize(new list<RestAnagraficaClienteChangeResponseError>{new RestAnagraficaClienteChangeResponseError(e.getMessage(),e.getTypeName())});
            //RestContext.response.responseBody = blob.valueOf(JSON.serialize(new list<RestAnagraficaClienteChangeResponseError>{new RestAnagraficaClienteChangeResponseError(e.getMessage(),e.getTypeName())}));
            //return;
            return new RestAnagraficaClienteChangeResponseError(e.getMessage(),e.getTypeName());
        }
    }
    
    static Account createAccount(String stato) {
        return new Account(
            Tipo_anagrafica__c = 'Fisica',
            Codice_fiscale__c = 'TRMHDS21C32C234K',
            Nome_persona_fisica__c = 'Nome',
            Cognome_persona_fisica__c = 'Cognome',
            Stato__c = stato,
            Phone = '0343212121',
            RecordTypeId = UtilItNet.itNetAccountRecordTypeId,
            BillingPostalCode = '1234',
            BillingStreet = 'test',
            BillingCity = 'test',
            BillingState = 'test',
            BillingCountry = 'test',
            luogo_di_nascita__c = 'test',
            Account_Accesso__c = '12345',
            email_principale__c = 'test@test.com'
        );
    }
        
    @isTest
    static void testOverwriteTemp() {
        Account a = createAccount('Attivo');
        insert a;
        a = [select Chiave_per_legame_accesso_esterni__c from account where id =: a.id];
        Test.startTest();
        a.Phone = '0343123456';
        doPut(a);
        Test.stopTest();
        
        List<Account> accList = [SELECT Phone FROM Account];
        System.assertEquals(1, accList.size());
        //System.assertEquals('0343123456', accList[0].Phone);
    }    
    
    @isTest
    static void testOverwriteAttivo() {       
        Account a = createAccount('Attivo');
        insert a;
        a = [select Chiave_per_legame_accesso_esterni__c from account where id =: a.id];
        Test.startTest();
        a.Codice_fiscale__c = 'TFFDSE12C12C765K';
        doPut(a);
        Test.stopTest();
        
        List<Account> accList = [SELECT Codice_fiscale__c, Stato__c FROM Account ORDER BY CreatedDate desc];
        System.assertEquals(1, accList.size());

        //System.assertEquals('TFFDSE12C12C765K', accList[0].Codice_fiscale__c);
        System.assertEquals('Attivo', accList[0].Stato__c);
    }    

    @isTest
    static void testStoricizzazione() {       
        Account a = createAccount('Attivo');
        insert a;
        
        Contratto__c c1 = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc1 = UtilTestApritisito.insertSottoContratto(c1);
        Listino__c listino = UtilTestApritisito.insertListino();
        List<Product2> products = UtilTestApritisito.insertProdottiItNet(3);
        List<RigaListino__c> rls = UtilTestApritisito.insertRigheListino(listino, products);
        List<ProdottoSottoContratto__c> psc1 = UtilTestApritisito.insertProdottiSottoContratto(sc1, products);
        system.debug([select chiuso__c,trial_concluso__c from prodottosottocontratto__c where id =: psc1[0].id]);
        
        Contratto__c c2 = UtilTestApritisito.insertContrattoTest(a);
        
        
        a = [select Chiave_per_legame_accesso_esterni__c from account where id =: a.id];
        Ticket_Fatturazione__c ticket = new Ticket_fatturazione__c(
            Account__c = a.Id
        );
        insert ticket;
        Test.startTest();
        a.Codice_fiscale__c = 'TFFDSE12C12C765K';
        doPut(a);
        Test.stopTest();
        
        List<Account> accList = [SELECT Codice_fiscale__c, Stato__c, Vecchio_Cliente__c,ContrattiConProdottiAperti__c,
                                (SELECT SottocontrattiConProdottiAperti__c FROM Contratti__r)
                                 FROM Account ORDER BY Codice_fiscale__c desc];
        /*
        Contratto__c con1 = accList[0].Contratti__r[0];
        System.debug('contratti = '+accList[0].Contratti__r);
        Contratto__c con2 = accList[1].Contratti__r[0];
        */
        
        System.debug('MioDebug: '+accList);
        //System.assertEquals(2, accList.size());

        System.assertEquals('TRMHDS21C32C234K', accList[0].Codice_fiscale__c);
        /*System.assertEquals('Decaduto', accList[0].Stato__c);
        
        System.assertEquals('TFFDSE12C12C765K', accList[1].Codice_fiscale__c);
        System.assertEquals('Attivo', accList[1].Stato__c);
        System.assertEquals(accList[0].Id, accList[1].Vecchio_Cliente__c);
        
        System.assertEquals(1,accList[0].contratti__r.size());
        System.assertEquals(1,accList[1].contratti__r.size());
        System.assertEquals(0,accList[0].ContrattiConProdottiAperti__c);
        System.assertEquals(1,accList[1].ContrattiConProdottiAperti__c);
        */

        //Test sui contratti            
    }    


    @isTest
    static void testErrore() {               
        Account a = createAccount('Attivo');
        insert a;
        a = [select Chiave_per_legame_accesso_esterni__c from account where id =: a.id];
        Ticket_Fatturazione__c ticket = new Ticket_fatturazione__c(
            Account__c = a.Id
        );
        insert ticket;
        Test.startTest();
        a.ParentId = '006R0000007k96R';
        a.Codice_fiscale__c = 'TFFDSE12C12C765K';       
                                     
        doPut(a);
        Test.stopTest();
    }   

}