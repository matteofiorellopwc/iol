public class ItNetPagamenti {
    
    /**
     *  Crea un pagamento aria e una transazione sulla base dei dati in arrivo dal billing
     *  Usato per lo switch anticipato (comandato dal billing) dai prodotti trial a full
     */
    public static PagamentoAria__c creaPagamento(Map<String,String> transactionData) {
        PagamentoAria__c pagamento = new PagamentoAria__c(
            Cliente__c = transactionData.get('accountId'),
            Importo__c = Decimal.valueOf(transactionData.get('importo'))
        );
        insert pagamento;
        
        TransazioneAria__c transazione = new TransazioneAria__c(
            CodiceRisposta__c = Decimal.valueOf(transactionData.get('cod')),
            DescrizioneRisposta__c = transactionData.get('desc'),
            PagamentoAria__c = pagamento.Id,
            DataPagamento__c = Date.today(),
            ORDER_NO__c = transactionData.get('order_no'),
            PROC_PAYMENT_ID__c = transactionData.get('proc_payment_id'),
            TRANSACTION_ID__c = transactionData.get('transaction_id'),
            TYPE_PAYMENT__c = transactionData.get('type_payment'),
            INVOICE_NO__c = transactionData.get('invoice_no'),
            TYPE_CREDIT_CARD__c = transactionData.get('type_credit_card')
            
        );
        insert transazione;
        
        return [SELECT Id, Importo__c, NumeroSuccessi__c, DataPagamento__c,
               (SELECT TYPE_PAYMENT__c,TYPE_CREDIT_CARD__c,TRANSACTION_ID__c,PROC_PAYMENT_ID__c,ORDER_NO__c,INVOICE_NO__c FROM TransazioniAria__r)
                FROM PagamentoAria__c WHERE Id = :pagamento.id];
    }      

     private static Map<Id, double> generaAliquotaMap(ProdottoSottoContratto__c[] pscL, Date dataDiRiferimento) {
        Set<Id> productIds = new Set<Id>();
        for(ProdottoSottoContratto__c psc : pscL) {
            productIds.add(psc.Prodotto__c);    
        }
        return generaAliquotaMap(productIds, dataDiRiferimento);        
    }

     private static Map<Id, double> generaAliquotaMap(Set<Id> productIds, Date dataDiRiferimento) {
        Map<String, double> codiciIVAMap = new Map<String, double>();
        for(CodiceIVA__c codiceIVA : [
            SELECT
            Name,
            aliquota__c
            FROM CodiceIVA__c           
        ]) {
            codiciIVAMap.put(codiceIVA.Name, codiceIVA.aliquota__c);
        }

        Map<Id, double> aliquotaMap = new Map<Id, double>();
        for(Storico_IVA__c si : [SELECT
            Codice_IVA__c,
            Product__c
            FROM Storico_IVA__c 
            WHERE Product__c IN :productIds 
            AND Data_inizio_validita__c <=: dataDiRiferimento
            AND (data_fine_validita__c >=: dataDiRiferimento OR data_fine_validita__c = null)
        ]) {
            aliquotaMap.put(si.Product__c, codiciIVAMap.get(si.Codice_IVA__c));
        }                   
                    
        return aliquotaMap;     
    } 
    
    /**
     * Chiave: Id del prodotto sotto contratto 
     * Valore: Record Storico Iva
     */
    private static Map<Id, Storico_IVA__c> generaStoricoIvaMap(ProdottoSottoContratto__c[] pscL, Date dataDiRiferimento) {
        Set<Id> productIds = new Set<Id>();
        for(ProdottoSottoContratto__c psc : pscL) {
            productIds.add(psc.Prodotto__c);    
        }
        return generaStoricoIvaMap(productIds, dataDiRiferimento);        
    }

    private static Map<Id, Storico_IVA__c> generaStoricoIvaMap(Set<Id> productIds, Date dataDiRiferimento) {
        Map<Id, Storico_IVA__c> storicoIVAMap = new Map<Id, Storico_IVA__c>();
        for(Storico_IVA__c si : [SELECT
            Codice_IVA__c,
            Data_inizio_validita__c,
            data_fine_validita__c,
            Product__c
            FROM Storico_IVA__c 
            WHERE Product__c IN :productIds 
            AND Data_inizio_validita__c <=: dataDiRiferimento
            AND (data_fine_validita__c >=: dataDiRiferimento OR data_fine_validita__c = null)
        ]) {
            storicoIVAMap.put(si.Product__c, si);
        }                        
                    
        return storicoIvaMap;     
    }

    /**
     *  Genera tutte le righe pagamento associate ad una lista di prodottisottocontratto
     *  relative a pagamenti da effettuarsi alla "dataDiRiferimento"
     */     
    public static void generaImportiRigheSottoContratto(List<ProdottoSottoContratto__c> pscL, Date dataDiRiferimento) {
        generaImportiRigheSottoContratto(pscL, dataDiRiferimento, false);
    }

    /**
     *  Genera tutte le righe pagamento associate ad una lista di prodottisottocontratto
     *  relative a pagamenti da effettuarsi alla "dataDiRiferimento"
     */     
    public static void generaImportiRigheSottoContratto(List<ProdottoSottoContratto__c> pscL, Date dataDiRiferimento, Boolean tryToAssociatePagamento) {
        ImportoRigaSottoContratto__c[] irscL = new ImportoRigaSottoContratto__c[]{}; 
                
        Map<Id, double> aliquotaMap = generaAliquotaMap(pscL, dataDiRiferimento);
        Map<Id, Storico_IVA__c> storicoIvaMap = generaStoricoIvaMap(pscL, dataDiRiferimento);                
        
        for(RigaSottoContratto__c rsc : [SELECT 
            Id,
            Data_prossimo_billing__c,
            Importo_da_fatturare__c,
            Ultima_Data_Billing__c,
            Ultima_Data_Fatturazione__c,
            Ultima_data_non_vuota__c,
            ProdottoSottoContratto__r.Prodotto__c,
            ProdottoSottoContratto__r.Prodotto_sotto_contratto_trial__r.Pagamento_Aria_fine_trial__c,
            ProdottoSottoContratto__r.Prodotto_sotto_contratto_trial__r.Pagamento_Aria_fine_trial__r.datapagamento__c,
            ProdottoSottoContratto__r.Prodotto_sotto_contratto_pre_upselling__r.Pagamento_Aria_upselling__c,
            ProdottoSottoContratto__r.Prodotto_sotto_contratto_pre_upselling__r.Pagamento_Aria_upselling__r.datapagamento__c            
            FROM RigaSottoContratto__c
            WHERE Data_prossimo_billing__c <= :dataDiRiferimento
            AND Id NOT IN (SELECT RigaSottoContratto__c FROM ImportoRigaSottoContratto__c WHERE DataBilling__c = :dataDiRiferimento)
            AND ProdottoSottoContratto__c IN :pscL
            AND importo_da_fatturare__c > 0      
            AND ProdottoSottoContratto__r.Chiuso__c <> true   
        ]) {
            ImportoRigaSottoContratto__c irs = new ImportoRigaSottoContratto__c(
                RigaSottoContratto__c = rsc.Id,
                Importo_netto_iva__c = rsc.Importo_da_fatturare__c,
                Codice_IVA__c = storicoIvaMap.get(rsc.ProdottoSottoContratto__r.Prodotto__c).Codice_IVA__c,
                Aliquota_iva__c = aliquotaMap.get(rsc.ProdottoSottoContratto__r.Prodotto__c)
            );
            if(tryToAssociatePagamento){
            	if(rsc.ProdottoSottoContratto__r.Prodotto_sotto_contratto_trial__r.Pagamento_Aria_fine_trial__c != null){
            		irs.PagamentoAria__c =  rsc.ProdottoSottoContratto__r.Prodotto_sotto_contratto_trial__r.Pagamento_Aria_fine_trial__c;
                	irs.Data_Pagamento__c = rsc.ProdottoSottoContratto__r.Prodotto_sotto_contratto_trial__r.Pagamento_Aria_fine_trial__r.datapagamento__c;
            	}else{
            		irs.PagamentoAria__c =  rsc.ProdottoSottoContratto__r.Prodotto_sotto_contratto_pre_upselling__r.Pagamento_Aria_upselling__c;
                	irs.Data_Pagamento__c = rsc.ProdottoSottoContratto__r.Prodotto_sotto_contratto_pre_upselling__r.Pagamento_Aria_upselling__r.datapagamento__c;            	
            	}
            	 
            }
            
            irscL.add(irs);
        }
        
        insert irscL;               
    }

    /**
     *  Genera tutte le righe pagamento associate a tutti i prodotto sotto contratto
     *  relativi a pagamenti da effettuarsi alla "dataDiRiferimento"
     */             
    public static void generaImportiRigheSottoContratto(Date dataDiRiferimento) {
        Map<Id, ProdottoSottoContratto__c> prodottiSottoContrattoMap = new Map<Id, ProdottoSottoContratto__c>();
        for(RigaSottoContratto__c rsc : [SELECT             
            ProdottoSottoContratto__r.Id,
            ProdottoSottoContratto__r.Prodotto__c,
            //Devo filtrare le righe sotto contratto relative a importi il cui pagamento è fallito e non è stato gestito
            (SELECT Data_Pagamento__c FROM ImportiRigaSottoContratto__r WHERE Data_Pagamento__c = NULL LIMIT 1)
            FROM RigaSottoContratto__c
            WHERE Data_prossimo_billing__c <= :dataDiRiferimento
            AND ProdottoSottoContratto__r.Chiuso__c <> true
        ]) {
            if(rsc.ImportiRigaSottoContratto__r.isEmpty()) {
                prodottiSottoContrattoMap.put(rsc.ProdottoSottoContratto__r.Id, rsc.ProdottoSottoContratto__r);
            }           
        }
        
        generaImportiRigheSottoContratto(prodottiSottoContrattoMap.values(), dataDiRiferimento);                
    }   

    /**
     *  Genera tutti i pagamenti aria raggruppando gli "importi prodotti sotto contratto" secondo i criteri
     *  previsti (Cliente - metodo di pagamento - termini di pagamento - canale di vendita ).
     *  Per effettuare il raggruppamento, generiamo una mappa che ha come chiave il campo raggruppamentoPagamento. 
     *  Tale campo è una formula che contiene la concatenazione dei criteri di raggruppamento. 
     *  La procedura raggruppa gli importi sulla base dell'aliquota e applica la stessa
     */
    public static PagamentoAria__c[] generaPagamenti(Date dataDiRiferimento, List<ProdottoSottoContratto__c> filterList) {
        
        //Chiave: raggruppamentoPagamento
        Map<String, ImportoRigaSottoContratto__c[]> importiMap = new Map<String, ImportoRigaSottoContratto__c[]>();
        
        //Chiave: raggruppamentoPagamento -> Valore: aliquota
        Map<String, Decimal> totaliMap = new Map<String, Decimal>();
        
        //Chiave: raggruppamentoPagamento senza aliquota -> Valore: massimo numero di tentativi presi tra i vari prodotti che compongono il pagamento
        Map<String, Decimal> numeroTentativiMap = new Map<String, Decimal>();
        
        /*
            Calcolo IVA: si sommano le basi imponibili degli elementi contrattuali con stessa aliquota IVA e sul totale
            si applica l’aliquota (questo genera un totale per aliquota IVA che deve essere arrotondato seguendo
            le logiche previste). La base imponibile e l'imposta devono essere arrotondate al secondo decimale 
            (quindi al centesimo di Euro). Gli importi vanno arrotondati al centesimo di euro superiore, nel caso
            che il terzo decimale sia maggiore o uguale a 5, o inferiore, se il terzo decimale è minore di 5                
        */      
        String query = 'SELECT '                                                                            +
            'RaggruppamentoPagamento__c, '                                                                  +
            'Importo_netto_iva__c, '                                                                        +
            'aliquota_iva__c, '                                                                             +
            'RigaSottoContratto__r.ProdottoSottoContratto__r.SottoContratto__r.Contratto__r.Cliente__c, '   +
            'RigaSottoContratto__r.ProdottoSottoContratto__r.Prodotto__r.NumeroMassimoTentativi__c '        +               
            'FROM ImportoRigaSottoContratto__c '                                                            +
            'WHERE PagamentoAria__c = NULL '                                                                ;
        if(filterList != null) {
            query += 'AND RigaSottoContratto__r.ProdottoSottoContratto__c IN : filterList';
        }
        
        system.debug('query: ' + query);
                
        for(ImportoRigaSottoContratto__c irsc : Database.query(query)) {            
            if(importiMap.get(irsc.RaggruppamentoPagamento__c) == null) importiMap.put(irsc.RaggruppamentoPagamento__c, new ImportoRigaSottoContratto__c[]{});
            importiMap.get(irsc.RaggruppamentoPagamento__c).add(irsc);      
                        
            String key = irsc.RaggruppamentoPagamento__c;       
            String subKey = key.subString(0, key.lastIndexOf('_'));

            Decimal oldTentativiValue = numeroTentativiMap.get(subKey);
            numeroTentativiMap.put(subKey, Math.max(oldTentativiValue == null ? 0 : oldTentativiValue, irsc.RigaSottoContratto__r.ProdottoSottoContratto__r.Prodotto__r.NumeroMassimoTentativi__c));            
            
            Decimal value = totaliMap.get(key) == null ? 0 : totaliMap.get(key);
            Decimal value2 = irsc.Importo_netto_iva__c; 
            value2 *= 1+(irsc.aliquota_iva__c)/100;            
            totaliMap.put(key, value + value2);                                                 
        }
        
        //Chiave : raggruppamentoPagamento senza il raggruppamento per aliquota
        Map<String, PagamentoAria__c> pagamentiMap = new Map<String, PagamentoAria__c>();
        
        for(String key : importiMap.keySet()) {
            String subKey = key.subString(0, key.lastIndexOf('_'));
            
            PagamentoAria__c pagamento = pagamentiMap.get(subKey);
            if(pagamento == null) {
                pagamento = new PagamentoAria__c(
                    Cliente__c = importiMap.get(key)[0].RigaSottoContratto__r.ProdottoSottoContratto__r.SottoContratto__r.Contratto__r.Cliente__c,
                    Importo__c = 0
                );
                pagamentiMap.put(subKey, pagamento);
            }

            pagamento.NumeroMassimoTentativi__c = numeroTentativiMap.get(subKey);                                   
            pagamento.Importo__c += totaliMap.get(key).setScale(2,RoundingMode.HALF_UP);                    
        }               
                
        for(PagamentoAria__c pagamento : pagamentiMap.values()) {
            pagamento.importo__c = pagamento.importo__c.setScale(2,RoundingMode.HALF_UP);
        }
        
        insert pagamentiMap.values();
        
        //Associo i pagamentiAria appena creati agli importi
        ImportoRigaSottoContratto__c[] importi = new ImportoRigaSottoCOntratto__c[]{};
        for(String key : importiMap.keySet()) {
            String subKey = key.subString(0, key.lastIndexOf('_'));
            for(ImportoRigaSottoContratto__c irsc : importiMap.get(key)) {
                irsc.PagamentoAria__c = pagamentiMap.get(subKey).Id;
                importi.add(irsc);
            }                   
        }                           
        
        update importi;
        
        return pagamentiMap.values();
    }   
    
    public static PagamentoAria__c[] generaPagamenti(Date dataDiRiferimento) {
        return generaPagamenti(dataDiRiferimento, null);
    }
    
}