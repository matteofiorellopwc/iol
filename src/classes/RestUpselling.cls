@RestResource(urlMapping='/upselling')
global class RestUpselling {
    
    global abstract class RestUpsellingResponse {}   
    
    @HttpGet
    global static RestUpsellingResponse doGet() {
    	try {
    		Id currentProdId = RestContext.request.params.get('currentProdId');
    		Id newProdId = RestContext.request.params.get('newProdId');
    		ProdottoSottoContratto__c currentProd; //Prodotto che si vuole aggiornare (Prodotto Sotto Contratto)
    		Product2 newProd; //Prodotto nel quale il prodotto corrente dev'essere aggiornato (Prodotto)
    		Decimal cp_PrezzoSenzaIVA; //Prezzo (netto IVA) di currentProd
    		Decimal np_PrezzoSenzaIVA; //Prezzo (netto IVA) di newProd
    		Integer mesiAlTermine; //Mesi che mancano alla data di chiusura
    		String np_codiceIva; //Codice Iva di newProd
    		Double np_aliquota; //Aliquota IVA di newProd
    		Date dataChiusura; //Data chiusura
    		Date dataDecorrenza; //Data data di decorrenza
    		
    		Decimal importoSenzaIva = 0;
    		Decimal importoConIva = 0;
    		
			currentProd = [SELECT Name, Prodotto__r.Name, Prodotto__r.Trial__c, Prodotto__r.Id, Chiuso__c, Sospeso__c, Data_chiusura__c, Data_decorrenza__c,
						   (SELECT Prezzo_scontato__c FROM ProdottiSottoContratti__r) 
				   		   FROM ProdottoSottoContratto__c
				   		   WHERE Id = :currentProdId];
			newProd = [SELECT Name, Trial__c
				   	   FROM Product2
				       WHERE Id = :newProdId];			
			
			//Controlli vari
			if(currentProd.Chiuso__c) {
				throw new RestUpsellingException('Non è possibile effettuare l\'upgrade di un prodotto in stato chiuso');	
			}
			else if(currentProd.Sospeso__c) {
				throw new RestUpsellingException('Non è possibile effettuare l\'upgrade di un prodotto in stato sospeso');	
			}
			else if(currentProd.Prodotto__r.Trial__c) {
				throw new RestUpsellingException('Non è possibile effettuare l\'upgrade di un prodotto in fase trial');
			}
			else {
				cp_PrezzoSenzaIVA = [SELECT Prezzo_esente_IVA__c, Riga_Listino__r.Product__r.Name, Riga_Listino__r.Product__r.Id, Riga_Listino__r.Stato__c, Elemento_Contrattuale__c
									 FROM RigaListinoElementoContrattuale__c
									 WHERE Riga_Listino__r.Product__r.Id = :currentProd.Prodotto__r.Id AND
									 Riga_Listino__r.Stato__c = 'Attivo' AND
                             		 Elemento_Contrattuale__c = 'Canone Servizio'
                             		 LIMIT 1].Prezzo_esente_IVA__c;
				np_PrezzoSenzaIVA = [SELECT Prezzo_esente_IVA__c, Riga_Listino__r.Product__r.Name, Riga_Listino__r.Product__r.Id, Riga_Listino__r.Stato__c, Elemento_Contrattuale__c
									 FROM RigaListinoElementoContrattuale__c
									 WHERE Riga_Listino__r.Product__r.Id = :newProd.Id AND
									 Riga_Listino__r.Stato__c = 'Attivo' AND
                             		 Elemento_Contrattuale__c = 'Canone Servizio'
                             		 LIMIT 1].Prezzo_esente_IVA__c;
				
				//Controllo sul downgrade					 
				if(np_PrezzoSenzaIVA <= cp_PrezzoSenzaIVA) {
					throw new RestUpsellingException('Non è possibile effettuare il downgrade di un prodotto');
				}
				
				//Calcolo il numero di mesi
				dataChiusura = currentProd.Data_chiusura__c;		
				mesiAlTermine = calcMonthsNumber(currentProd);

				//Prendo dallo storico IVA del nuovo prodotto il codice IVA e ricavo l'aliquota;
				np_codiceIva = [SELECT Codice_IVA__c, Data_fine_validita__c, Data_inizio_validita__c, Product__c 
								FROM Storico_IVA__c
								WHERE Product__c = :newProd.Id 
								AND(Data_fine_validita__c >= :Date.today() OR Data_fine_validita__c = null) LIMIT 1].Codice_IVA__c;
            	np_aliquota = [SELECT Aliquota__c FROM CodiceIVA__c WHERE Name = :np_codiceIva].aliquota__c;
            	
            	//Calcolo gli importi
            	importoSenzaIva = (np_PrezzoSenzaIVA - cp_PrezzoSenzaIVA) * mesiAlTermine;
            	importoConIva = importoSenzaIva * (1 + np_aliquota/100);
            	importoConIva = importoConIva.setScale(2, RoundingMode.HALF_UP);
            										   
				return new GetSuccess(cp_PrezzoSenzaIVA, np_PrezzoSenzaIVA, mesiAlTermine, importoSenzaIva, importoConIVA, np_aliquota, dataChiusura);
				
			}		 
    	}
    	catch(Exception e) {
    		return new Error(e.getMessage(), e.getTypeName());	
    	}	   	
    }
    
       
    @HttpPost
    global static RestUpsellingResponse doPost(Map<String, String> transactionData) {
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
    		) throw new RestUpsellingException('Mancano campi obbligatori');
    		
    		ProdottoSottoContratto__c currentProd; //Prodotto che si vuole aggiornare (Prodotto Sotto Contratto)
    		Product2 newProd; //Prodotto nel quale il prodotto corrente dev'essere aggiornato (Prodotto)
            Id currentProdId = RestContext.request.params.get('currentProdId');
            Id newProdId = RestContext.request.params.get('newProdId');
            Decimal cp_PrezzoSenzaIVA; //Prezzo (netto IVA) di currentProd
    		Decimal np_PrezzoSenzaIVA; //Prezzo (netto IVA) di newProd
            
            //Recupero l'id del cliente                                       
            ProdottoSottoContratto__c psc = [SELECT Id, SottoContratto__r.Contratto__r.Cliente__c,Trial_concluso__c,Pagamento_aria_fine_trial__c FROM ProdottoSottoContratto__c WHERE Id = :currentProdId];                     
            transactionData.put('accountId', psc.SottoContratto__r.Contratto__r.Cliente__c);
            
            currentProd = [SELECT Name, Prodotto__r.Name, Prodotto__r.Trial__c, Prodotto__r.Id, Chiuso__c, Sospeso__c, Data_chiusura__c, Quantita__c, SottoContratto__c, Canale_di_vendita__c, Data_decorrenza__c,
						   (SELECT Prezzo_scontato__c FROM ProdottiSottoContratti__r) 
				   		   FROM ProdottoSottoContratto__c
				   		   WHERE Id = :currentProdId];
			newProd = [SELECT Name, Trial__c,
					   (SELECT Id, Listino__r.Canale_di_vendita__c, Data_inizio_validita__c, Data_fine_validita__c, Product__c FROM Listini__r)
				   	   FROM Product2
				       WHERE Id = :newProdId];
				       
			//Controlli vari
			if(currentProd.Chiuso__c) {
				throw new RestUpsellingException('Non è possibile effettuare l\'upgrade di un prodotto in stato chiuso');	
			}
			else if(currentProd.Sospeso__c) {
				throw new RestUpsellingException('Non è possibile effettuare l\'upgrade di un prodotto in stato sospeso');	
			}
			else if(currentProd.Prodotto__r.Trial__c) {
				throw new RestUpsellingException('Non è possibile effettuare l\'upgrade di un prodotto in fase trial');
			}
			else {
				cp_PrezzoSenzaIVA = [SELECT Prezzo_esente_IVA__c, Riga_Listino__r.Product__r.Name, Riga_Listino__r.Product__r.Id, Riga_Listino__r.Stato__c, Elemento_Contrattuale__c
									 FROM RigaListinoElementoContrattuale__c
									 WHERE Riga_Listino__r.Product__r.Id = :currentProd.Prodotto__r.Id AND
									 Riga_Listino__r.Stato__c = 'Attivo' AND
                             		 Elemento_Contrattuale__c = 'Canone Servizio'
                             		 LIMIT 1].Prezzo_esente_IVA__c;
				np_PrezzoSenzaIVA = [SELECT Prezzo_esente_IVA__c, Riga_Listino__r.Product__r.Name, Riga_Listino__r.Product__r.Id, Riga_Listino__r.Stato__c, Elemento_Contrattuale__c
									 FROM RigaListinoElementoContrattuale__c
									 WHERE Riga_Listino__r.Product__r.Id = :newProd.Id AND
									 Riga_Listino__r.Stato__c = 'Attivo' AND
                             		 Elemento_Contrattuale__c = 'Canone Servizio'
                             		 LIMIT 1].Prezzo_esente_IVA__c;
				
				//Controllo sul downgrade					 
				if(np_PrezzoSenzaIVA <= cp_PrezzoSenzaIVA) {
					throw new RestUpsellingException('Non è possibile effettuare il downgrade di un prodotto');
				}
				
				//Genero il pagamento aria
                PagamentoAria__c pagamento = ItNetPagamenti.creaPagamento(transactionData);            
            
                //Collego il pagamento al prodotto trial. In questo modo il trigger non genererà un pagamento in maniera automatica         
                currentProd.Data_chiusura__c = Date.today();
                currentProd.Rinnovo_automatico__c = false;
                currentProd.Pagamento_Aria_Upselling__c = pagamento.id;
                
                AccountTriggerHandler.isUpselling = true;
                update currentProd;
				
				ProdottoSottoContratto__c prodToInsert = new ProdottoSottoContratto__c(
					Data_decorrenza__c = date.today(),
					Rigalistino__c = UtilItNet.checkListini(currentProd.Canale_di_vendita__c, currentProd.Data_decorrenza__c, newProd.Listini__r),
					Prodotto__c = newProd.Id,
					Prodotto_Sotto_Contratto_Pre_Upselling__c = currentProd.Id,
					Quantita__c = currentProd.Quantita__c,
					SottoContratto__c = currentProd.SottoContratto__c                   
				);
               
				insert prodToInsert;
				AccountTriggerHandler.isUpselling = false;
				ItNetPagamenti.generaImportiRigheSottoContratto(new List<ProdottoSottoContratto__c>{prodToInsert}, Date.today(), true);
               				
				return new PostSuccess(true);	
			}			                       
        }catch(Exception e) {
            Database.rollback(sp);
            return new Error(e.getMessage(), e.getTypeName());
        }
    }  
    
    //GET SUCCESS
    global class GetSuccess extends RestUpsellingResponse  {
        public Decimal prodottoCorrente_prezzoSenzaIVA;
        public Decimal nuovoProdotto_prezzoSenzaIVA;
        public Integer mesiAlTermine;
        public Decimal importoSenzaIva;
        public Decimal importoConIva;
        public Date dataChiusura;
        public Date dataOggi;         
        public Double nuovoProdotto_aliquota;
        public Boolean success;
        GetSuccess(Decimal cp_PrezzoSenzaIVA, Decimal np_PrezzoSenzaIVA, Integer mesiAlTermine, Decimal importoSenzaIva, Decimal importoConIva, Double np_aliquota, Date dataChiusura) {
            this.prodottoCorrente_prezzoSenzaIVA = cp_PrezzoSenzaIVA;
            this.nuovoProdotto_prezzoSenzaIVA = np_PrezzoSenzaIVA;
            this.mesiAlTermine = mesiAlTermine;
            this.importoSenzaIva = importoSenzaIva;
            this.importoConIva = importoConIva;
            this.nuovoProdotto_aliquota = np_aliquota;
            this.dataChiusura = dataChiusura;
            this.dataOggi = date.today();
            this.success = true;
        }
    }
    
    //POST SUCCESS
    global class PostSuccess extends RestUpsellingResponse  {
        public Boolean success;
        PostSuccess(Boolean success) {
            this.success = success;
        }
    }
    
    //ERROR
    global class Error extends RestUpsellingResponse  {
        public String message;
        public String errorCode;
        Error(String message, String errorCode) {
            this.message = message;
            this.errorCode = errorCode;
        }
    }
    
    //EXCEPTION
    public class RestUpsellingException extends Exception{ }
    
    
    /**
     * Metodo che calcola il numero di mesi che mancano alla data di chiusura
     */	
	public static Integer calcMonthsNumber(ProdottoSottoContratto__c currentProd) {
		Integer mesiAlTermine; //Mesi che mancano alla data di chiusura
		Date dataDecorrenza = currentProd.Data_decorrenza__c;
		Integer dayDataDecorrenza = dataDecorrenza.day();
		Integer dayToday = date.today().day();
		Date dataChiusura = currentProd.Data_chiusura__c;
		
		Date startDate; //Data d'inizio utilizzata nel calcolo del numero di mesi
		
		if (dayToday > dayDataDecorrenza) {
			startDate = date.newInstance(date.today().year(), date.today().addMonths(1).month(), dayDataDecorrenza);
			mesiAlTermine = startDate.monthsBetween(dataChiusura);
			
		}
		if (dayToday <= dayDataDecorrenza) {
			startDate = date.newInstance(date.today().year(), date.today().month(), dayDataDecorrenza);
			mesiAlTermine = startDate.monthsBetween(dataChiusura);		
		}
		
		return mesiAlTermine;   		
	}
}