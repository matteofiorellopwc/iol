/*
    Custom web service for upselling a trial product
    http get /services/apexrest/upsellingTrial?currentProdId=XXXXXXXXX&newProdId=XXXXXXXXX to check if upselling is allowed
    http post /services/apexrest/upsellingTrial?currentProdId=XXXXXXXXX&newProdId=XXXXXXXXX to performe upselling
*/

@RestResource(urlMapping='/upsellingTrial')

global class RestUpsellingTrial {
        
    @HttpGet
    global static RestUpsellingTrialResponse doGet() {
        try{
            ProdottoSottoContratto__c currentProd = getCurrentProd();
            Product2 newProd = getNewProd();
            checkParam(currentProd,newProd);
        }catch(exception e){
            return new error(e.getMessage(),e.getTypeName());                
        }
        return new success();
    }
       
    @HttpPost
    global static RestUpsellingTrialResponse doPost() {
        System.SavePoint sp = Database.setSavePoint();
        try{
            ProdottoSottoContratto__c currentProd = getCurrentProd();
            Product2 newProd = getNewProd();
            checkParam(currentProd,newProd);
            
            AccountTriggerHandler.isUpselling = true;
            
            ProdottoSottoContratto__c prodToInsert = new ProdottoSottoContratto__c(
                Data_decorrenza__c = date.today(),
                Data_chiusura__c = currentProd.Data_chiusura__c,
                Data_fine_trial__c = currentProd.Data_fine_trial__c,
                Rigalistino__c = UtilItNet.checkListini(currentProd.Canale_di_vendita__c, currentProd.Data_decorrenza__c, newProd.Listini__r),
                Prodotto__c = newProd.Id,
                Prodotto_Sotto_Contratto_Pre_Upselling__c = currentProd.Id,
                Quantita__c = currentProd.Quantita__c,
                SottoContratto__c = currentProd.SottoContratto__c                     
            );
            
            insert prodToInsert;
            
            currentProd.Data_chiusura__c = Date.today();
            currentProd.Rinnovo_automatico__c = false;
            currentProd.Trial_upselled__c = true;
            update currentProd;
            
        }catch(exception e){
            Database.rollback(sp);
            return new error(e.getMessage(),e.getTypeName());
        }
        return new success();
    }
    
    global abstract class RestUpsellingTrialResponse {}
    
    public class RestUpsellingTrialException extends Exception{}
    
    //POST SUCCESS
    global class Success extends RestUpsellingTrialResponse  {
        public Boolean success = true;
    }
    
    //ERROR
    global class Error extends RestUpsellingTrialResponse  {
        public String message;
        public String errorCode;
        Error(String message, String errorCode) {
            this.message = message;
            this.errorCode = errorCode;
        }
    }
    
    public static ProdottoSottoContratto__c getCurrentProd(){
        Id currentProdId = RestContext.request.params.get('currentProdId');
        return [SELECT Name, Prodotto__r.Name, Prodotto__r.Prodotto_Full_post_trial__c, Prodotto__r.Trial__c, Prodotto__r.Id, 
                       Chiuso__c, Sospeso__c, Trial_Concluso__c, Quantita__c, SottoContratto__c,
                       Data_chiusura__c, Data_decorrenza__c, Data_fine_trial__c, Canale_di_vendita__c
                FROM ProdottoSottoContratto__c
                WHERE Id = :currentProdId];		
    }
    
    public static Product2 getNewProd(){
        Id newProdId = RestContext.request.params.get('newProdId');
        return [SELECT Name, Trial__c, Prodotto_Full_post_trial__c,
                       (SELECT Id, Listino__r.Canale_di_vendita__c, Data_inizio_validita__c, Data_fine_validita__c, Product__c FROM Listini__r)
                FROM Product2
                WHERE Id = :newProdId];
    }
    
    public static RestUpsellingTrialResponse checkParam(ProdottoSottoContratto__c  psc, Product2 prod){
        if(psc.chiuso__c){
            throw new RestUpsellingTrialException('Non è possibile effettuare l\'upgrade di un trial chiuso');
        }
        if(psc.trial_concluso__c){
            throw new RestUpsellingTrialException('Non è possibile effettuare l\'upgrade di un trial concluso');
        }
        if(!psc.prodotto__r.trial__c || !prod.trial__c){
            throw new RestUpsellingTrialException('Il prodotto non è un trial');
        }
        // Impossibilità d'effettuare upselling da plus a base
        Decimal cp_PrezzoSenzaIVA = [SELECT Prezzo_esente_IVA__c, Riga_Listino__r.Product__r.Name, Riga_Listino__r.Product__r.Id, Riga_Listino__r.Stato__c, Elemento_Contrattuale__c
									 FROM RigaListinoElementoContrattuale__c
									 WHERE Riga_Listino__r.Product__r.Id = :psc.Prodotto__r.Prodotto_Full_post_trial__c AND
									 Riga_Listino__r.Stato__c = 'Attivo' AND
                             		 Elemento_Contrattuale__c = 'Canone Servizio'
                             		 LIMIT 1].Prezzo_esente_IVA__c;
        Decimal np_PrezzoSenzaIVA = [SELECT Prezzo_esente_IVA__c, Riga_Listino__r.Product__r.Name, Riga_Listino__r.Product__r.Id, Riga_Listino__r.Stato__c, Elemento_Contrattuale__c
                             		 FROM RigaListinoElementoContrattuale__c
                             		 WHERE Riga_Listino__r.Product__r.Id = :prod.Prodotto_Full_post_trial__c AND
                             		 Riga_Listino__r.Stato__c = 'Attivo' AND
                             		 Elemento_Contrattuale__c = 'Canone Servizio'
                             		 LIMIT 1].Prezzo_esente_IVA__c;
        
        if(np_PrezzoSenzaIVA <= cp_PrezzoSenzaIVA){
            throw new RestUpsellingTrialException('Non è possibile effettuare l\'upgrade da '+psc.Prodotto__r.Name+' a '+ prod.Name);
        }

        return new success();
    }

}