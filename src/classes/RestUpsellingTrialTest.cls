@isTest
private class RestUpsellingTrialTest {
    static Id currentTrialProdId;
    static Id baseTrialProdId;
    static Id plusTrialProdId;
    
    @isTest
    static void createTestData() {
        //Crea prodotti full
		Product2 p1 = new Product2(
            recordTypeId = UtilItNet.itNetProductRecordTypeId,
            Name = 'Base',
            IsActive = true,                
            NumeroMassimoTentativi__c = 3
        );
        Product2 p2 = new Product2(
            recordTypeId = UtilItNet.itNetProductRecordTypeId,
            Name = 'Plus',
            IsActive = true,                
            NumeroMassimoTentativi__c = 3
        );
        insert p1;
        insert p2;

        //Crea prodotti trial
        Product2 p1Trial = new Product2(
            recordTypeId = UtilItNet.itNetProductRecordTypeId,
            Name = 'Base',
            IsActive = true,                
            NumeroMassimoTentativi__c = 3,
            Trial__c = true,
            Prodotto_Full_post_trial__c = p1.Id
        );
        Product2 p2Trial = new Product2(
            recordTypeId = UtilItNet.itNetProductRecordTypeId,
            Name = 'Plus',
            IsActive = true,                
            NumeroMassimoTentativi__c = 3,
            Trial__c = true,
            Prodotto_Full_post_trial__c = p2.Id
        );
        insert p1Trial;
        insert p2Trial;
        
        List<Product2> pL = new List<Product2> {p1, p2, p1Trial, p2Trial};
        
        Listino__c l = UtilTestApritisito.insertListino();
		List<RigaListino__c> rlL = UtilTestApritisito.insertRigheListino(l, pL);
        
        CondizioneDiFatturazione__c cdf = UtilTestApritisito.insertCondizioneDiFatturazione();
		
        List<RigaListinoElementoContrattuale__c> ecL = new List<RigaListinoElementoContrattuale__c>();
        Decimal prezzoEsenteIva = 10;
        for(RigaListino__c rl : [SELECT Product__r.Trial__c FROM RigaListino__c]) {
            if(!rl.Product__r.Trial__c) {
                ecL.add(new RigaListinoElementoContrattuale__c(
                    Elemento_Contrattuale__c = 'Canone Servizio',
                    Periodico__c = 'Si',
                    Prezzo_esente_IVA__c = prezzoEsenteIva,
                    Numero_unita_di_misura_periodo__c = 1,
                    Riga_Listino__c = rl.Id,
                    Condizione_Di_Fatturazione__c = cdf.Id
                ));
                prezzoEsenteIva = prezzoEsenteIva + 10;
            }
            else {
                ecL.add(new RigaListinoElementoContrattuale__c(
                    Elemento_Contrattuale__c = 'Canone Servizio',
                    Periodico__c = 'Si',
                    Prezzo_esente_IVA__c = 0,
                    Numero_unita_di_misura_periodo__c = 1,
                    Riga_Listino__c = rl.Id,
                    Condizione_Di_Fatturazione__c = cdf.Id
                ));
            }
        }
        insert ecL;
        
        CodiceIVA__c ci = UtilTestApritisito.insertCodiceIva('21', 21);
        Storico_IVA__c[] siL = UtilTestApritisito.insertStoriciIva(ci, pL);    
        Account a = UtilTestApritisito.insertClienteTest(null);
        Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
        ProdottoSottoContratto__c[] pscL = UtilTestApritisito.insertProdottiSottoContratto(sc, new List<Product2> {p1Trial});
        ItNetPagamenti.generaImportiRigheSottoContratto(Date.today());
        PagamentoAria__c[] paRes = ItNetPagamenti.generaPagamenti(Date.today());
        a.Chiave_per_legame_accesso_esterni__c = a.Id;
        update a;

        System.debug('MioDebug: '+ pscL[0]);
        currentTrialProdId = pscL[0].Id;
        baseTrialProdId = p1Trial.Id; 
        plusTrialProdId = p2Trial.Id;     
    }
    
    static testMethod void testDoGet() {  
        createTestData();
        
        //Test success
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/upsellingTrial';
        req1.addParameter('currentProdId', currentTrialProdId);
        req1.addParameter('newProdId', plusTrialProdId);
        req1.httpMethod = 'GET';
        RestContext.request = req1;
        RestContext.response = res1;
        
        RestUpsellingTrial.Success results1 = (RestUpsellingTrial.Success)RestUpsellingTrial.doGet();
		System.assertEquals(true, results1.success);
        
        //Test Error
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/upselling';
        req2.addParameter('currentProdId', currentTrialProdId);
        req2.addParameter('newProdId', baseTrialProdId);
        req2.httpMethod = 'GET';
        RestContext.request = req2;
        RestContext.response = res2;
        
        RestUpsellingTrial.Error results2 = (RestUpsellingTrial.Error)RestUpsellingTrial.doGet();
		System.assertEquals('Non è possibile effettuare l\'upgrade da Base a Base', results2.message);
    }
    
    static testMethod void testDoPost() {  
        createTestData();
        
        //Test success
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/upsellingTrial';
        req1.addParameter('currentProdId', currentTrialProdId);
        req1.addParameter('newProdId', plusTrialProdId);
        req1.httpMethod = 'POST';
        RestContext.request = req1;
        RestContext.response = res1;
        
        RestUpsellingTrial.Success results1 = (RestUpsellingTrial.Success)RestUpsellingTrial.doPost();
		System.assertEquals(true, results1.success);        
    }
}