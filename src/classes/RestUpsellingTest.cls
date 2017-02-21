@isTest
private class RestUpsellingTest {
    static Id currentProdId;
    static Id baseProdId;
    static Id plusProdId;
    
    static void createTestData() {
        //Crea dati
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
        
        List<Product2> pL = new List<Product2>{p1, p2};
        
        Listino__c l = UtilTestApritisito.insertListino();
		List<RigaListino__c> rlL = UtilTestApritisito.insertRigheListino(l, pL);
        
        
        CondizioneDiFatturazione__c cdf = UtilTestApritisito.insertCondizioneDiFatturazione();
		
        List<RigaListinoElementoContrattuale__c> ecL = new List<RigaListinoElementoContrattuale__c>();
        Decimal prezzoEsenteIva = 10;
        for(RigaListino__c rl : rlL) {
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
        insert ecL;    
        
        CodiceIVA__c ci = UtilTestApritisito.insertCodiceIva('21', 21);
        Storico_IVA__c[] siL = UtilTestApritisito.insertStoriciIva(ci, pL);     
        Account a = UtilTestApritisito.insertClienteTest(null);
        Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
        ProdottoSottoContratto__c[] pscL = UtilTestApritisito.insertProdottiSottoContratto(sc, pL);
        ItNetPagamenti.generaImportiRigheSottoContratto(Date.today());
        PagamentoAria__c[] paRes = ItNetPagamenti.generaPagamenti(Date.today());
        a.Chiave_per_legame_accesso_esterni__c = a.Id;
        update a;
        
        currentProdId = pscL[0].Id;
        baseProdId = p1.Id;
        plusProdId = p2.Id;      
    }
    
    static testMethod void testDoGet() {  
        createTestData();
        
        //Test success
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/upselling';
        req1.addParameter('currentProdId', currentProdId);
        req1.addParameter('newProdId', plusProdId);
        req1.httpMethod = 'GET';
        RestContext.request = req1;
        RestContext.response = res1;
        
        RestUpselling.GetSuccess results1 = (RestUpselling.GetSuccess)RestUpselling.doGet();
		System.assertEquals(true, results1.success);
        
        //Test Error
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/upselling';
        req2.addParameter('currentProdId', currentProdId);
        req2.addParameter('newProdId', baseProdId);
        req2.httpMethod = 'GET';
        RestContext.request = req2;
        RestContext.response = res2;
        
        RestUpselling.Error results2 = (RestUpselling.Error)RestUpselling.doGet();
		System.assertEquals('Non è possibile effettuare il downgrade di un prodotto', results2.message); 
    }
    
    static testMethod void testDoPost() {  
        createTestData();
        
        //Test success
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/upselling';
        req1.addParameter('currentProdId', currentProdId);
        req1.addParameter('newProdId', plusProdId);
        req1.httpMethod = 'POST';
        RestContext.request = req1;
        RestContext.response = res1;
        
        RestUpselling.PostSuccess results1 = (RestUpselling.PostSuccess)RestUpselling.doPost(new Map<String,String>{    		
			'importo' => '1452',
			'cod' => '0',
			'desc' => 'ok',
			'proc_payment_id' => 'test',			
			'order_no' => 'aaa',
        	'transaction_id' => 'bbb',
        	'type_payment' => 'Paypal',
            'invoice_no' => '1',
            'type_credit_card' => 'Visa'
		});
		System.assertEquals(true, results1.success);        
    }
}