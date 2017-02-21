global class BatchableInviaPagamenti implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public String query = 'SELECT '                                  +
        'Id, '                                                              +
        'Importo__c, '                                                      +
        'Cliente__r.Chiave_univoca_Aria__c, '                               +
        'Cliente__r.Chiave_per_legame_accesso_esterni__c '                  +
        'FROM PagamentoAria__c '                                            +
        'WHERE StatoPagamento__c = \'In corso\' '                           ;       
    
    private PagamentoAria__c[] pagamentiFilter;
    
    global BatchableInviaPagamenti() {
        query += ' AND (Giorni_ultima_transazione__c >= 3 OR Data_ultima_transazione__c = null) ';
    }
    global BatchableInviaPagamenti(PagamentoAria__c[] pagamentiFilter) {
        this.pagamentiFilter = pagamentiFilter;
        query += ' AND Id IN :pagamentiFilter';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);     
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        TransazioneAria__c[] taL = new TransazioneAria__c[]{};
        String[] errorMessages = new String[]{};
        
        for(SObject obj : scope) {
            PagamentoAria__c p = (PagamentoAria__c) obj;
            
            try {
                Map<String, Object> response = AriaIntegration.createOrder(
                    p.Cliente__r.Chiave_per_legame_accesso_esterni__c.toLowerCase(),
                    p.Importo__c,
                    p.Cliente__r.Chiave_univoca_Aria__c,
                    null                
                );
            
                Map<String,Object> orderData = (Map<String, Object>) response.get('data');
                if(orderData == null) orderData = new Map<String, String>();
                                        
                taL.add(new TransazioneAria__c(
                    CodiceRisposta__c = (Decimal) response.get('cod'),
                    DescrizioneRisposta__c = (String) response.get('desc'),
                    TRANSACTION_ID__c = String.valueOf((Decimal) orderData.get('transaction_id')),
                    ORDER_NO__c = String.valueOf((Decimal) orderData.get('order_no')),
                    PROC_PAYMENT_ID__c = (String) orderData.get('proc_payment_id'),
                    TYPE_PAYMENT__c = (String) orderData.get('type_payment'),                    
                    INVOICE_NO__c = String.valueOf((Decimal) orderData.get('invoice_no')),
                    TYPE_CREDIT_CARD__c = (String) orderData.get('type_credit_card'),                    
                    PagamentoAria__c = p.Id,
                    DataPagamento__c = Date.today()
                ));

            } catch(AriaIntegration.AriaIntegrationException e) {
                errorMessages.add(e.getMessage());      
            }   
        }

        if(!errorMessages.isEmpty()) {
            for(String error : errorMessages) {
                UtilExceptionIntegration.sendEmailToCustomEmailLog('Error in createOrder', error,'ApritiSitoLog');              
            }
        }       
        insert taL;
    }
    
    global void finish(Database.BatchableContext BC) {}
}