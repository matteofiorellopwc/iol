@RestResource(urlMapping='/FineTrial/*')
global with sharing class RestInfoFineTrial { 

    global abstract class ResetInfoFineTrialResponse {}

    global class RestInfoFineTrialResponseSuccess extends ResetInfoFineTrialResponse{
        global Boolean success;
        global String message;
        global Decimal aliquota;
        global Decimal importoProdottoFull;
        global RigaListino__c rigaListinoProdottoFull;
        global RestInfoFineTrialResponseSuccess(Boolean success, String message,Decimal aliquota,Decimal importoProdottoFull,RigaListino__c rigaListino) {
            this.message = message;
            this.success = success;
            this.aliquota = aliquota;
            this.importoProdottoFull = importoProdottoFull;
            this.rigaListinoProdottoFull = rigaListino;
        }
    }
    
    global class RestInfoFineTrialResponseError extends ResetInfoFineTrialResponse{
        global String message;
        global String errorCode;
        global RestInfoFineTrialResponseError(String message,String errorCode) {
            this.message = message;
            this.errorCode = errorCode;
        }
    }
    
    @HttpGet
    global static ResetInfoFineTrialResponse doGet() {
        try{
            String trialId = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);
            trialId = trialId.substringBefore('.');
            System.debug('TRIALID!!! ' + trialId);
            ProdottoSottoContratto__c trial = [select id,quantita__c,canale_di_vendita__c,data_decorrenza__c,Prodotto__r.Prodotto_Full_post_trial__c from ProdottoSottoContratto__c where id =: trialId];
            List<RigaListino__c> righeListini = [select id,listino__r.canale_di_vendita__c,Product__c,Data_inizio_validita__c,Data_fine_validita__c,(Select Id, Elemento_Contrattuale__c, Prezzo_esente_IVA__c, Sconto__c, Periodico__c, Unita_di_misura_periodo__c, Numero_unita_di_misura_periodo__c, Condizione_di_fatturazione__c From elementi_contrattuali__r) from rigalistino__c where Product__c =: trial.Prodotto__r.Prodotto_Full_post_trial__c];
            id rigaId = UtilItNet.checkListini(trial.canale_di_vendita__c,Date.today(),righeListini);
            RigaListino__c rigaListino = [Select Unita_di_misura_periodo__c, Rinnovo_automatico__c, Numero_unita_di_misura_periodo__c, 
                                                (Select Elemento_Contrattuale__c, Importo_da_fatturare__c,Prezzo_esente_IVA__c, Sconto__c, Periodico__c, 
                                                        Condizione_di_fatturazione__r.Name,Condizione_di_fatturazione__r.Numero_mesi__c,
                                                        Condizione_di_fatturazione__r.Numero_unita_periodo__c,Condizione_di_fatturazione__r.Tipo__c,
                                                        Condizione_di_fatturazione__r.Unita_di_misura_periodo__c,
                                                        Unita_di_misura_periodo__c, Numero_unita_di_misura_periodo__c
                                                 From elementi_contrattuali__r)
                                          From RigaListino__c 
                                          where id =: rigaId];
            String codiceIva = [select Codice_IVA__c from Storico_IVA__c 
                                where Data_inizio_validita__c <=: Date.today() 
                                and Product__c =: trial.Prodotto__r.Prodotto_Full_post_trial__c
                                and (data_fine_validita__c >=: Date.today() OR data_fine_validita__c = null)].Codice_IVA__c;
            double aliquota = [select aliquota__c from CodiceIVA__c where name =: codiceIva].aliquota__c;
            
            decimal tot = 0;
            for(RigaListinoElementoContrattuale__c el : rigaListino.elementi_contrattuali__r){
                if(el.Condizione_di_fatturazione__r.Tipo__c == 'Anticipata'){
                    tot += el.Importo_da_fatturare__c*trial.quantita__c;
                }
            }
            tot *= 1+aliquota/100;
            tot = tot.setScale(2,RoundingMode.HALF_UP);
            return new RestInfoFineTrialResponseSuccess(true,'ok',aliquota,tot, rigaListino);
        }catch(Exception e){
            try{
                String errorMsg = UtilExceptionIntegration.getExceptionMessage(e);
                UtilExceptionIntegration.sendEmailToCustomEmailLog('Error in RestInfoFineTrial',errorMsg,'ApritiSitoLog');
            }catch(exception ex){}
            return new RestInfoFineTrialResponseError(e.getMessage(),e.getTypeName());
        }
    }
    
    @HttpPost
    global static void endTrial(Map<String, String> transactionData) {
        System.SavePoint sp = Database.setSavePoint();
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        try {       
            if(
            	!transactionData.containsKey('importo') ||
    			!transactionData.containsKey('cod') ||
        		!transactionData.containsKey('desc') ||
        		!transactionData.containsKey('order_no') ||
        		!transactionData.containsKey('proc_payment_id') ||
        		!transactionData.containsKey('transaction_id') ||
        		!transactionData.containsKey('type_payment')
    		) throw new RestInfoTrialException('Mancano campi obbligatori');     
        
            //Recupero l'id del prodotto sotto contratto trial
            String url = RestContext.request.requestURI;
            Id prodottoSottoContrattoId = url.substring(url.lastIndexOf('/')+1).substringBefore('.');
            
            //Recupero l'id del cliente                                       
            ProdottoSottoContratto__c psc = [SELECT Id, SottoContratto__r.Contratto__r.Cliente__c,Trial_concluso__c,Pagamento_aria_fine_trial__c FROM ProdottoSottoContratto__c WHERE Id = :prodottoSottoContrattoId];                     
            transactionData.put('accountId', psc.SottoContratto__r.Contratto__r.Cliente__c);
            
            if(psc.Trial_concluso__c || psc.Pagamento_aria_fine_trial__c != null){
                throw new RestInfoTrialException('Trial già concluso');
            }else{
                //Genero il pagamento aria
                PagamentoAria__c pagamento = ItNetPagamenti.creaPagamento(transactionData);            
            	
                //Collego il pagamento al prodotto trial. In questo modo il trigger non genererà un pagamento in maniera automatica         
                psc.Data_fine_trial__c = Date.today();
                psc.Pagamento_Aria_fine_trial__c = pagamento.Id;
                psc.CreateFullAfterEndTrial__c = true;
                
                //Chiudo il trial. Un trigger inserirà il relativo prodotto full e genererà le righe pagamento anticipate, collegandole al pagamento Aria
                update psc;
                                                 
                RestContext.response.responseBody = Blob.valueOf('{ "success" : true }');       
            }
        }catch(Exception e) {
            Database.rollback(sp);
            RestContext.response.statusCode = 500;          
            RestContext.response.responseBody = Blob.valueOf(
                '[{ "message" : ' + JSON.serialize(e.getMessage()) +
                ', "errorCode" : ' + JSON.serialize(e.getTypeName()) + ' }]'
            );
        }               
    }
    
    public class RestInfoTrialException extends Exception{ }
    
}