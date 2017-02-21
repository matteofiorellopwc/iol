trigger afterUpdateProdottoSottoContratto on ProdottoSottoContratto__c (after update) {

    Map<id,list<rigalistino__c>> listiniMap =new Map<id,list<rigalistino__c>>(); //id prod -> listini
    Map<id,product2> prodottiMap = new Map<id,product2>([select id,Trial__c,Azione_fine_trial__c,Prodotto_Full_post_trial__c from product2 where recordTypeId =: UtilItNet.itNetProductRecordTypeId]);
    for(Product2 p : prodottiMap.values()){
        listiniMap.put(p.id,new list<rigalistino__c>());
    }
    for(rigalistino__c l : [select id,listino__r.canale_di_vendita__c,Data_inizio_validita__c,Data_fine_validita__c,Product__c from RigaListino__c where Product__c in : listiniMap.keySet()] ){
        listiniMap.get(l.Product__c).add(l);
    }

    Set<Id> clientiPscChiusi = new Set<Id>();
    
    list<ProdottoSottoContratto__c> prodToInsert = new list<ProdottoSottoContratto__c>();
    for(ProdottoSottoContratto__c psc : Trigger.new){
        if(psc.Chiuso__c && !trigger.oldMap.get(psc.Id).Chiuso__c) {
            clientiPscChiusi.add(psc.Cliente__c);       
        }
        
        if(canItemBeFull(psc)){
           system.debug('check listini '+psc.Prodotto__c);
           prodToInsert.add(
               new ProdottoSottoContratto__c(
                   Data_decorrenza__c = date.today(),
                   rigalistino__c = UtilItNet.checkListini(psc.canale_di_vendita__c,Date.today(),listiniMap.get(prodottiMap.get(psc.Prodotto__c).Prodotto_Full_post_trial__c)),
                   prodotto__c = prodottiMap.get(psc.Prodotto__c).Prodotto_Full_post_trial__c,
                   Prodotto_Sotto_Contratto_Trial__c = psc.id,
                   quantita__c = psc.quantita__c,
                   sottoContratto__c = psc.sottoContratto__c                   
               )
           );
        }
    }
                        
    //Faccio partire il sistema di pagamento se ho switchato dei prodotti da trial a full                        
    if(!prodToInsert.isEmpty()) {       
        insert prodToInsert;
        ItNetPagamenti.generaImportiRigheSottoContratto(prodToInsert, Date.today(), true);      
        PagamentoAria__c[] pagamenti = ItNetPagamenti.generaPagamenti(Date.today(), prodToInsert);
        Database.executeBatch(new BatchableInviaPagamenti(pagamenti), 10);
    }
        
    //Controllo se gli account dei psc chiusi hanno altri psc aperti. Se non ne hanno neanche uno,
    //Disabilito l'account      
    for(ProdottoSottoContratto__c psc : [SELECT
        SottoContratto__r.Contratto__r.Cliente__c
        FROM ProdottoSottoContratto__c
        WHERE SottoContratto__r.Contratto__r.Cliente__c IN :clientiPscChiusi
        AND Chiuso__c <> true
        AND Trial_Concluso__c <> true
    ]) {        
        System.debug('CLIENTE!!! ' + psc.SottoContratto__r.Contratto__r.Cliente__c);
        clientiPscChiusi.remove(psc.SottoContratto__r.Contratto__r.Cliente__c);
    }
    
    //Disabilito gli account se isUpselling diverso da true)
    System.debug('CLIENTIPSCCHIUSI!!! ' + clientiPscChiusi);
    if(!clientiPscChiusi.isEmpty() && !AccountTriggerHandler.isUpselling) {
        Database.executeBatch(new BatchableDisableTempItNet(clientiPscChiusi), 10);
    }
    
    //Controlla se un ProdottoSottoContratto può diventare full
    private Boolean canItemBeFull(ProdottoSottoContratto__c psc) {
        return
		psc.CreateFullAfterEndTrial__c &&
        psc.Trial_concluso__c &&
        !Trigger.oldMap.get(psc.id).Trial_concluso__c && 
        !psc.sospeso__c &&
        prodottiMap.get(psc.Prodotto__c).Trial__c &&
        prodottiMap.get(psc.Prodotto__c).Azione_fine_trial__c == 'Change' &&
        prodottiMap.get(psc.Prodotto__c).Prodotto_Full_post_trial__c != null; 
    }
}