@isTest
private class RestInfoFineTrialTest {
	static ProdottoSottoContratto__c prodSottoContrattoTrial;

	static void createTestData() {
		//Creo un listino con 10 prodotti full, condizione di fatturazione anticipata e 1 elemento contrattuale a prodotto
		Product2 prodFull = UtilTestApritisito.insertProdottiItNet(1)[0];
		Product2 prodTrial = UtilTestApritisito.insertProdottiItNet(1, new Map<String, Object>{
			'Trial__c' => true,
			'Prodotto_full_post_trial__c' => prodFull.Id
		})[0];
		
		Product2[] pL = new Product2[]{
			prodFull,
			prodTrial
		};
		
		Listino__c l = UtilTestApritisito.insertListino();
		RigaListino__c[] rlL = UtilTestApritisito.insertRigheListino(l, pL);
		CondizioneDiFatturazione__c cdf = UtilTestApritisito.insertCondizioneDiFatturazione();
		RigaListinoElementoContrattuale__c[] ecL = UtilTestApritisito.insertElementiContrattuali(rlL, cdf);

		//Creo un codiceIVA attivo e lo applico ai prodotti
		CodiceIVA__c ci = UtilTestApritisito.insertCodiceIva('21', 21);
		Storico_IVA__c[] siL = UtilTestApritisito.insertStoriciIva(ci, pL);		

		//Creo un account con un contratto/sottocontratto contenente i 10 prodotti appena creati
		Account a = UtilTestApritisito.insertClienteTest(null);
		Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
		SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
		
		//All'inserimento dei prodottisottocontratto un trigger dovrebbe collegarli automaticamente alle righe listino
		//e dovrebbe inserire le righe sottocontratto clonandole dagli elementi contrattuali. Mi aspetto data di prossimo
		//billing = oggi in quanto le condizioni di fatturazione sono "pagamento anticipato"
		ProdottoSottoContratto__c[] pscL = UtilTestApritisito.insertProdottiSottoContratto(sc, pL);
		prodSottoContrattoTrial = pscL[1];
		
		//Controllo il corretto funzionamento del trigger
		System.assertEquals(2, ([SELECT Id FROM RigaSottoContratto__c]).size()); 						
	}

	@isTest
	static void testDoGet() {		
		
		//Test error
		RestInfoFineTrial.RestInfoFineTrialResponseError error = (RestInfoFineTrial.RestInfoFineTrialResponseError) RestInfoFineTrial.doGet();
		System.assertEquals('System.NullPointerException', error.errorCode);
				
		createTestData();

		RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();

    	// pass the req and resp objects to the method		 
    	req.requestURI = 'https://cs9.salesforce.com/services/apexrest/FineTrial/' + prodSottoContrattoTrial.Id;  
    	req.httpMethod = 'GET';				
		RestContext.request = req;
		RestContext.response = res;
		
		RestInfoFineTrial.RestInfoFineTrialResponseSuccess res2 = (RestInfoFineTrial.RestInfoFineTrialResponseSuccess) RestInfoFineTrial.doGet();
		System.debug(res2);
		System.assertEquals('ok', res2.message);
		System.assertEquals(true, res2.success);
		System.assertEquals(100 * 12 * 1.21, res2.importoProdottoFull);
		
	}
	
	@isTest
	static void testEndTrial() {		
		
		createTestData();

		RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();

    	// pass the req and resp objects to the method		 
    	req.requestURI = 'https://cs9.salesforce.com/services/apexrest/FineTrial/' + prodSottoContrattoTrial.Id;  
    	req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		//Test error		
		RestInfoFineTrial.endTrial(new Map<String,String>{});    		
		System.debug(RestContext.response.responseBody.toString());				

		req = new RestRequest(); 
    	res = new RestResponse();

    	// pass the req and resp objects to the method		 
    	req.requestURI = 'https://cs9.salesforce.com/services/apexrest/FineTrial/' + prodSottoContrattoTrial.Id;  
    	req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;

		RestInfoFineTrial.endTrial(new Map<String,String>{    		
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
		System.debug(res.responseBody.toString());	
		
		PagamentoAria__c p = [SELECT
			Id,
			NumeroSuccessi__c,
			DataPagamento__c,
			(SELECT Id, CodiceRisposta__c, PROC_PAYMENT_ID__c, INVOICE_NO__c, TYPE_CREDIT_CARD__c FROM TransazioniAria__r)
			FROM PagamentoAria__c
		];
		System.assertEquals(1, p.NumeroSuccessi__c);
		System.assertEquals(1, p.TransazioniAria__r.size());
		System.assertEquals(0, p.TransazioniAria__r[0].CodiceRisposta__c);
		System.assertEquals('test', p.TransazioniAria__r[0].PROC_PAYMENT_ID__c);
        System.assertEquals(p.TransazioniAria__r[0].INVOICE_NO__c, '1');
        System.assertEquals(p.TransazioniAria__r[0].TYPE_CREDIT_CARD__c, 'Visa');  
	}	
}