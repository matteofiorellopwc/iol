@RestResource(urlMapping='/getListOfProducts')
global class RestGetListOfProducts {
    
    global abstract class RestGetListOfProductsResponse {}
    
    
    
    @HttpGet
    global static RestGetListOfProductsResponse doGet() {
        try {
            //Parametri: ExternalId dell'Account - Id del SottoContratto
            Id accountExtId = RestContext.request.params.get('accountExtId');
            Id sottoContrattoId = RestContext.request.params.get('sottoContrattoId');
            
            //Lista dei SottoContratti di una dato Account
            List<SottoContratto__c> scL;
            
            //Viene passato solo l'externalId dell'Account
            if(accountExtId != null && sottoContrattoId == null) {
                scL= [SELECT Name, Contratto__r.Cliente__c, Contratto__r.Cliente__r.Chiave_per_legame_accesso_esterni__c,
                      (SELECT Prodotto__r.Name, RigaListino__r.Listino__r.Metodo_di_pagamento__c, Chiuso__c, Trial_concluso__c FROM Righe_Prodotti__r)
                      FROM SottoContratto__c WHERE Contratto__r.Cliente__r.Chiave_per_legame_accesso_esterni__c = :accountExtId];               
            }
            //Viene passato anche l'Id del SottoContratto
            else if(accountExtId != null && sottoContrattoId != null) {
                scL = [SELECT Name, Contratto__r.Cliente__c, Contratto__r.Cliente__r.Chiave_per_legame_accesso_esterni__c,
                       (SELECT Prodotto__r.Name, RigaListino__r.Listino__r.Metodo_di_pagamento__c, Chiuso__c, Trial_concluso__c FROM Righe_Prodotti__r)
                       FROM SottoContratto__c WHERE Contratto__r.Cliente__r.Chiave_per_legame_accesso_esterni__c = :accountExtId 
                       AND Id =:sottoContrattoId];
            }
            
            return new Success(true, 'ok', scL);
        }
        catch(Exception e) {
            return new Error(e.getMessage(), e.getTypeName());
        }
    }
    
    //ERROR
    global class Error extends RestGetListOfProductsResponse  {
        public String message;
        public String errorCode;
        Error(String message, String errorCode) {
            this.message = message;
            this.errorCode = errorCode;
        }
    }
    
    //SUCCESS
    global class Success extends RestGetListOfProductsResponse  {
        public Boolean success;
        public String message;
        //Lista di SottoContratti wrapper
        public List<SottoContratto> SottoContratti = new List<SottoContratto>();
        
        //Costruttore
        Success (Boolean success, String message, List<SottoContratto__c> scL){
            this.message = message;
        	this.success = success;
            //Set con gli Id dei ProdottiSottoContratto
            Set<Id> productIdSet = new Set<Id>();
            for(SottoContratto__c sc : scL) {
                for(ProdottoSottoContratto__c psc : sc.Righe_Prodotti__r) {
                    productIdSet.add(psc.Id);
                }
            }
            //Lista delle RigheSottoContratto associate al sottoinsieme dei ProdottiSottoContratto
            List<RigaSottoContratto__c> rscL = [SELECT Name, Prezzo_scontato__c, Importo_da_fatturare__c, ProdottoSottoContratto__c,
                                                (SELECT Name, Codice_IVA__c , Importo_netto_iva__c, PagamentoAria__c FROM ImportiRigaSottoContratto__r)
                                                FROM RigaSottoContratto__c 
                                                WHERE ProdottoSottoContratto__c IN :productIdSet];
            
            //Mappa di RigheSottoContratto. Key: Prodotto Sotto Contratto
            Map<String, RigaSottoContratto__c> rscM = new Map<String, RigaSottoContratto__c>();
            for(RigaSottoContratto__c rsc : rscL) {
                rscM.put(rsc.ProdottoSottoContratto__c,rsc);
            }
            
            //Mappa PagamentiAria per un dato Account
            Map<String, PagamentoAria__c> paM = new Map<String, PagamentoAria__c>(
                [SELECT Id, Name, Cliente__c, Ticket_Fatturazione__r.Codice_fatturazione__c, Ticket_Fatturazione__r.Name,
                    (SELECT ORDER_NO__c, PROC_PAYMENT_ID__c, INVOICE_NO__c, TRANSACTION_ID__c, TYPE_CREDIT_CARD__c, TYPE_PAYMENT__c, CodiceRisposta__c, DataPagamento__c
                    FROM TransazioniAria__r WHERE CodiceRisposta__c = 0)
                FROM PagamentoAria__c WHERE Cliente__c = :scL[0].Contratto__r.Cliente__c]
            );
                      
            //Genera la lista di SottoContratti
            for(SottoContratto__c s : scL){
                SottoContratto sc = new SottoContratto(s, s.Righe_Prodotti__r, rscM, paM);
                SottoContratti.add(sc);
            }      
        }    
    }
    
    //Wrapper SottoContratto
    global class SottoContratto {
        Id id;
        String name;
        List<Prodotto> Prodotti = new List<Prodotto>();
        
        SottoContratto(SottoContratto__c sc, List<ProdottoSottoContratto__c> pscL, Map<String, RigaSottoContratto__c> rscM, Map<String, PagamentoAria__c> paM) {
            this.id = sc.Id;
            this.name = sc.name;
            
            for(ProdottoSottoContratto__c psc : pscL) {
                Prodotto p = new Prodotto(psc, rscM, paM);
                Prodotti.add(p);
            }               
        }       
    }
    
    //Wrapper ProdottoSottoContratto
    global class Prodotto {
        String name;
        Boolean chiuso;
        Boolean trialConcluso;
        RigaSottoContratto RigaSottoContratto;
        Pagamento Pagamenti;
        
        Prodotto(ProdottoSottoContratto__c psc, Map<String, RigaSottoContratto__c> rscM,  Map<String, PagamentoAria__c> paM) {
            this.name = psc.Prodotto__r.Name;
            this.chiuso = psc.Chiuso__c;
            this.trialConcluso = psc.Trial_concluso__c;
            this.RigaSottoContratto = new RigaSottoContratto(psc, rscM, paM);
        }
    }
    
    //Wrapper RigaSottoContratto
    global class RigaSottoContratto {
        String name;
        Decimal costoMensile;
        Decimal costoTotale;
        List<Pagamento> Pagamenti; 
       
        RigaSottoContratto(ProdottoSottoContratto__c psc, Map<String, RigaSottoContratto__c> rscM, Map<String, PagamentoAria__c> paM){
            this.name = rscM.get(psc.Id).name;
            this.costoMensile = rscM.get(psc.Id).Prezzo_scontato__c;
            this.costoTotale = rscM.get(psc.Id).Importo_da_fatturare__c;
            this.Pagamenti = new List<Pagamento>();
            
            for(ImportoRigaSottoContratto__c i : rscM.get(psc.Id).ImportiRigaSottoContratto__r) {
                Pagamento p = new Pagamento(i, psc, paM);
                Pagamenti.add(p);
            }         
        }
    }
    
    //Wrapper Pagamento
    global class Pagamento {
        //ImportoRigaSottoContratto
        String name;
        Decimal importoNettoIva;
        //Listino
        String metodoDiPagamento;
        //TransazioneAria
        String invoiceNo;
        String orderNo;
        String procPaymentId;
        String transactionId;
        String typeCreditCard;
        String typePayment;
        Date dataPagamento;
        //TicketDiFatturazione
        String codiceFatturazione;

        Pagamento(ImportoRigaSottoContratto__c irsc, ProdottoSottoContratto__c psc, Map<String, PagamentoAria__c> paM){
            this.name = irsc.Name;
            this.importoNettoIva = irsc.Importo_netto_iva__c;
            this.metodoDiPagamento = psc.RigaListino__r.Listino__r.Metodo_di_pagamento__c;
            try {
                this.codiceFatturazione = paM.get(irsc.PagamentoAria__c).Ticket_Fatturazione__r.Codice_fatturazione__c;              
                this.invoiceNo = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].INVOICE_NO__c;
                this.orderNo = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].ORDER_NO__c;
                this.procPaymentId = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].PROC_PAYMENT_ID__c;
                this.transactionId = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].TRANSACTION_ID__c;
                this.typeCreditCard = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].TYPE_CREDIT_CARD__c;
                this.typePayment = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].TYPE_PAYMENT__c;
                this.dataPagamento = paM.get(irsc.PagamentoAria__c).TransazioniAria__r[0].DataPagamento__c; 
            }
            catch(Exception e) {
                this.invoiceNo = null;
                this.orderNo = null;
                this.procPaymentId = null;
                this.transactionId = null;
                this.typeCreditCard = null;
                this.typePayment = null;
                this.dataPagamento = null;
            }
        }
    }
}