global class ItnetRiprovaPagamenti {
    WebService static void riprova(String id) {
        PagamentoAria__c[] pa = [SELECT Id, Name FROM PagamentoAria__c WHERE Id = :id];
        Database.executeBatch(new BatchableInviaPagamenti(pa), 10);    
    }
    
    @isTest
    static void testRiprovaPagamenti(){
        Account a = UtilTestApritisito.insertClienteTest(null);
        PagamentoAria__c p = new PagamentoAria__c(Cliente__c = a.Id, Importo__c = 0);
        insert p;   
    
        ItnetRiprovaPagamenti.riprova(p.Id);
    }
}