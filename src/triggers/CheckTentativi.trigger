/**
 * Questo trigger controlla se sono stati superati N tentativi falliti di pagamento. In tal caso,
 * i prodottisottocontratto collegati a questo pagamento vengono sospesi per T giorni. Superato tale periodo, se 
 * non si interviene manualmente, i prodotti vengono chiusi. I prodotti che arrivano da un prodotto trial, invece, vengono sospesi
 * al primo tentativo fallito. Il trigger, inoltre, riabilita i prodotti che arrivano da un prodotto trial ed erano stati disabilitati
 * al primo tentativo, se prima degli N tentativi arriva un pagamento con successo.
 * Per tutti i pagamenti con successo, infine, vengono propagate le date di pagamento sugli importi associati al pagamento stesso
 */
trigger CheckTentativi on PagamentoAria__c (after update) {
    //Mappa id prod sotto contratto -> prod sotto contratto
    //Ci metto dentro tutti i prod sotto contratto da sospendere 
    Map<Id, ProdottoSottoContratto__c> prodSottoContrattoDaSospendere = new Map<Id, ProdottoSottoContratto__c>();

    //Mappa id prod sotto contratto -> prod sotto contratto
    //Prodotti post trial con almeno un pagamento fallito che non hanno superato il numero massimo di tentativi falliti        
    Map<Id, ProdottoSottoContratto__c> pscPotenzialmenteDaSospendere = new Map<Id, ProdottoSottoContratto__c>();
    
    //pagamenti con errori >= N (numero massimo tentativi). I psc associati a questi pagamenti vanno sicuramente sospesi
    Set<Id> pagamentiDaSospendere = new Set<Id>();
   
    //pagamenti con 0 < errori < N, per questi devo sospendere tutti i prodotti full post trial che non sono
    //stati mai pagati
    Set<Id> pagamentiConAlmenoUnErrore = new Set<Id>();
    
    //Pagamenti che hanno avuto successo. Per questi pagamenti devo propagare la data di pagamento sugli importi
    //E riabilitare eventualmente i prodotti full che erano stati disabilitati per insuccesso precedentemente
    Set<Id> pagamentiConSuccesso = new Set<Id>();
    
    //Popolo i set
    for(PagamentoAria__c p : trigger.new) {
		//Controllo se è cambiato il numero dei successi
    	Decimal numeroSuccessiOld = trigger.oldMap.get(p.Id).NumeroSuccessi__c;
    	Decimal numeroSuccessiNew = p.NumeroSuccessi__c;
    	Boolean isChangedNumeroSuccessi = numeroSuccessiOld != numeroSuccessiNew;
    	
    	//Controllo se è cambiato il numero degli errori
    	Decimal numeroErroriOld = trigger.oldMap.get(p.Id).NumeroErrori__c;
    	Decimal numeroErroriNew = p.NumeroErrori__c;
    	Boolean isChangedNumeroErrori = numeroErroriOld != numeroErroriNew;
    	
        if(isChangedNumeroSuccessi || isChangedNumeroErrori) {
	        if(p.NumeroSuccessi__c > 0 || p.NumeroErrori__c > 0) {
	            if(p.NumeroSuccessi__c > 0) {
	                pagamentiConSuccesso.add(p.Id);
	            } else if(p.NumeroErrori__c >= p.NumeroMassimoTentativi__c) {
	                pagamentiDaSospendere.add(p.Id);
	            } else {
	                pagamentiConAlmenoUnErrore.add(p.Id);
	            }
	        }
    	}
    }    

    System.debug('PAG CON SUCCESSO!!! ' + pagamentiConSuccesso);
    System.debug('PAG DA SOSPENDERE!!! ' + pagamentiDaSospendere);
    System.debug('PAG POTENZ. DA SOSPENDERE!!! ' + pagamentiConAlmenoUnErrore);

    ImportoRigaSottoContratto__c[] importiRiusciti = new ImportoRigaSottoContratto__c[]{};
    ProdottoSottoContratto__c[] pscDaRiabilitare = new ProdottoSottoContratto__c[]{};
    
    //Recupero tutti i prodotti sotto contratto che sono o scaduti o post trial con almeno un errore di pagamento
    //e anche i prodotti sotto contratto associati a pagamenti riusciti        
    for(ImportoRigaSottoContratto__c irsc : [SELECT
        Id,
        RigaSottoContratto__r.ProdottoSottoContratto__r.Id,
        RigaSottoContratto__r.ProdottoSottoContratto__r.Prodotto__r.NumeroGiorniSospensione__c,
        RigaSottoContratto__r.ProdottoSottoContratto__r.Sospeso__c,
        RigaSottoContratto__r.ProdottoSottoContratto__r.Prodotto_Sotto_Contratto_Trial__c,
        RigaSottoContratto__r.ProdottoSottoContratto__r.Chiuso__c,
        PagamentoAria__c
        FROM
        ImportoRigaSottoContratto__c
        WHERE (
            PagamentoAria__c IN :pagamentiDaSospendere
            OR PagamentoAria__c IN :pagamentiConSuccesso
            OR (
                PagamentoAria__c IN :pagamentiConAlmenoUnErrore
                AND RigaSottoContratto__r.ProdottoSottoContratto__r.Prodotto_Sotto_Contratto_Trial__c <> NULL               
            )
        )
    ]) {   
        ProdottoSottoContratto__c psc = irsc.RigaSottoContratto__r.ProdottoSottoContratto__r;            
        //Se il pagamento associato è riuscito, riabilito il psc e setto la data di pagamento dell'importo
        if(pagamentiConSuccesso.contains(irsc.PagamentoAria__c)) {
            if(psc.Sospeso__c) {            
                psc.Sospeso__c = false;
                pscDaRiabilitare.add(psc);
            }
            irsc.Data_Pagamento__c = Date.today();
            importiRiusciti.add(irsc);
        } else {
            if(!psc.Sospeso__c && !psc.Chiuso__c) {
                psc.Sospeso__c = true;
                psc.DataChiusuraDefinitiva__c = Date.today().addDays(Integer.valueOf(psc.Prodotto__r.NumeroGiorniSospensione__c));       
                
                //Popolo le mappe controllando se è un psc associato a un pagamento con errori > N
                //o a un pagamento di un prodotto full post trial con 0 < errori < N
                if(!pagamentiDaSospendere.contains(irsc.PagamentoAria__c)) pscPotenzialmenteDaSospendere.put(psc.Id, psc);
                else prodSottoContrattoDaSospendere.put(psc.Id, psc);                
            }             
        }                                       
    }
        
    System.debug('PSC POTENZ. DA SOSPENDERE!!! ' + pscPotenzialmenteDaSospendere);
    System.debug('PSC DA SOSPENDERE!!! ' + prodSottoContrattoDaSospendere);
    
    //Elimino dalla mappa dei prodotti da sospendere tutti i prodotti post trial che sono già stati pagati
    //almeno una volta (ma solo se non è stato superato il numero massimo di tentativi)
    for(ImportoRigaSottoContratto__c irsc : [SELECT
        RigaSottoContratto__r.ProdottoSottoContratto__c
        FROM ImportoRigaSottoContratto__c
        WHERE RigaSottoContratto__r.ProdottoSottoContratto__c IN :pscPotenzialmenteDaSospendere.keySet()    
        AND PagamentoAria__r.NumeroSuccessi__c > 0  
    ]) {
        Id pscId = irsc.RigaSottoContratto__r.ProdottoSottoContratto__c;
        if(!prodSottoContrattoDaSospendere.containsKey(pscId)) {        
            System.debug('RIMUOVO PSC IN QUANTO GIA STATO PAGATO!!! ' + pscId);
            pscPotenzialmenteDaSospendere.remove(pscId);
        }
    }
    
    prodSottoContrattoDaSospendere.putAll(pscPotenzialmenteDaSospendere);  
    
    System.debug('PSC DA SOSPENDERE DEF!!! ' + prodSottoContrattoDaSospendere);              
    update prodSottoContrattoDaSospendere.values();    
    
    update pscDaRiabilitare;
    update importiRiusciti;
}