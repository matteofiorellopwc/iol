@isTest
private class RestGetListOfProductsTest {
    static testMethod void testDoGet() {
        //Crea dati
        Product2[] pL = UtilTestApritisito.insertProdottiItNet(10);
        Listino__c l = UtilTestApritisito.insertListino();
        RigaListino__c[] rlL = UtilTestApritisito.insertRigheListino(l, pL);
        CondizioneDiFatturazione__c cdf = UtilTestApritisito.insertCondizioneDiFatturazione();
        RigaListinoElementoContrattuale__c[] ecL = UtilTestApritisito.insertElementiContrattuali(rlL, cdf);
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
        
        //Test success
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/getListOfProducts';
        req1.addParameter('accountExtId', a.Chiave_per_legame_accesso_esterni__c);
        req1.httpMethod = 'GET';
        RestContext.request = req1;
        RestContext.response = res1;
        
        RestGetListOfProducts.Success results1 = (RestGetListOfProducts.Success)RestGetListOfProducts.doGet();
        System.assertEquals('ok', results1.message);
		System.assertEquals(true, results1.success);
        System.assertEquals(results1.SottoContratti.size(), 1);
        
        //Test error
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/getListOfProducts';
        req2.addParameter('accountExtId', '');
        req2.httpMethod = 'GET';
        RestContext.request = req2;
        RestContext.response = res2;
        
        RestGetListOfProducts.Error results2 = (RestGetListOfProducts.Error)RestGetListOfProducts.doGet();
        System.assertEquals('Invalid id: ', results2.message);
		System.assertEquals('System.StringException', results2.errorCode);
    }
}