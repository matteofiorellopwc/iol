public class ControllerCheckAdm {
    private Id optyID;
    
    public Opportunity o {get;set;}
    public Quote q {get;set;}
    public boolean checkButton {get;set;}
    
    public ControllerCheckAdm(ApexPages.StandardController stdController){
        this.optyID = stdController.getId();
        checkButton = false;
        
        o = [SELECT Id, Name, Anagrafica_di_Fatturazione__c, SyncedQuoteId, Anagrafica_di_Fatturazione__r.BillingCity, Anagrafica_di_Fatturazione__r.BillingStreet, Anagrafica_di_Fatturazione__r.BillingState, Anagrafica_di_Fatturazione__r.BillingPostalCode, Anagrafica_di_Fatturazione__r.BillingCountry, Anagrafica_di_Fatturazione__r.Email_principale__c,
             Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c, Check_amministrativo__c, isWon, StageName, Escludi_da_fatt_auto__c,
                (SELECT Id, Name, Modalita_di_spedizione__c, Codice_IVA__c, Metodo_di_pagamento__c, Termini_di_pagamento__c, Lingua_template_fattura__c, Email_aggiuntive__c, Indirizzo_Spedizione_Alternativo__c, Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c,
                 Indirizzo_Spedizione_Alternativo__r.Via__c, Indirizzo_Spedizione_Alternativo__r.Citta__c, Indirizzo_Spedizione_Alternativo__r.Provincia__c, Indirizzo_Spedizione_Alternativo__r.CAP__c, Indirizzo_Spedizione_Alternativo__r.Stato__c
                 FROM Quotes)
             FROM Opportunity
             WHERE Id = : optyID];
    
        if(o.Quotes.size() == 1){
            q = o.Quotes.get(0);
        }else if(o.SyncedQuoteId != null){
            q = (new map<id,quote>(o.quotes)).get(o.SyncedQuoteId);
        }
        
        if(!o.IsWon)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Non è possibile procedere con il check amministrativo se la campagna non è chiusa/vinta.'));
        else{
            if(o.Escludi_da_fatt_auto__c)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Si è scelto di escludere la seguente campagna dalla fatturazione automatica.'));
            if(o.Check_amministrativo__c)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Il check amministrativo è stato eseguito per la seguente campagna.'));
            else{
	            Map<Id, List<ApexPages.Message>> errorsPerOptyID = checkAdm(new Id[]{o.Id});
	            if(errorsPerOptyID.get(o.Id).size() <> 0)
	                for(ApexPages.Message msg: errorsPerOptyID.get(o.Id)){
	                    ApexPages.addMessage(msg);
	                }
	            else{
	                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'È possibile procedere con l\'autorizzazione alla fatturazione.'));
	                checkButton = true;
	            }
            }
        }
    }
    
    public PageReference includeFatt(){
        PageReference p = new PageReference('/apex/CheckAdm?Id='+optyID);
        o.Escludi_da_fatt_auto__c = false;
        update o;
        p.setRedirect(true);
        return p;
    }
    
    public PageReference excludeFatt(){
        PageReference p = new PageReference('/apex/CheckAdm?Id='+optyID);
        o.Escludi_da_fatt_auto__c = true;
        update o;
        p.setRedirect(true);
        return p;
    }   
    
    public PageReference resetCheckAdm(){
        PageReference p = new PageReference('/apex/CheckAdm?Id='+optyID);
        o.Check_amministrativo__c = false;
        update o;
        p.setRedirect(true);
        return p;
    }
    
    public PageReference back(){
        PageReference optyPage = new PageReference('/'+optyID);
        //new ApexPages.StandardController(o).view();
        optyPage.setRedirect(true);
        return optyPage;
    }
    
    public PageReference checkFlag(){
        PageReference p = new PageReference('/apex/CheckAdm?Id='+optyID);
        o.Check_amministrativo__c = true;
        update o;
        p.setRedirect(true);
        return p;
    }
    
    public static Map<Id, List<ApexPages.Message>> checkAdm(List<Id> OptyIDs){
        Map<Id, List<ApexPages.Message>> errorsPerOptyID = new Map<Id, List<ApexPages.Message>>();
        Quote q;
        
        List<Opportunity> vOpty = [SELECT Id, Name, Anagrafica_di_Fatturazione__c, SyncedQuoteId, Anagrafica_di_Fatturazione__r.BillingCity, Anagrafica_di_Fatturazione__r.BillingStreet, Anagrafica_di_Fatturazione__r.BillingState, Anagrafica_di_Fatturazione__r.BillingPostalCode, Anagrafica_di_Fatturazione__r.BillingCountry, Anagrafica_di_Fatturazione__r.Email_principale__c,
             Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c, Check_amministrativo__c, isWon, StageName, Escludi_da_fatt_auto__c,
                (SELECT Id, Name, Modalita_di_spedizione__c, Codice_IVA__c, Metodo_di_pagamento__c, Termini_di_pagamento__c, Lingua_template_fattura__c, Indirizzo_Spedizione_Alternativo__c, Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c,
                 Indirizzo_Spedizione_Alternativo__r.Via__c, Indirizzo_Spedizione_Alternativo__r.Citta__c, Indirizzo_Spedizione_Alternativo__r.Provincia__c, Indirizzo_Spedizione_Alternativo__r.CAP__c, Indirizzo_Spedizione_Alternativo__r.Stato__c
                 FROM Quotes)
             FROM Opportunity
             WHERE Id IN : optyIDs];
        
        for(Opportunity o : vOpty){
            List<ApexPages.Message> errors = new List<ApexPages.Message>();
            //Check existing the Anagrafica di Fatturazione
            if(o.Anagrafica_di_Fatturazione__c == null)
                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna Anagrafica di fatturazione associata a questa campagna.'));
            else
                if(o.Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c == null || o.Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c == '')
                    errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna ragione sociale in fattura.'));
            //Check existing Quote
            if(o.Quotes.size() == 0)
                    errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessun preventivo associato a questa campagna.'));
            else
                if(o.Quotes.size() == 1)
                    q = o.Quotes.get(0);
                else
                    if(o.Quotes.size() > 1 && o.SyncedQuoteId != null)
                        q = (new map<id,quote>(o.quotes)).get(o.SyncedQuoteId);
                    else
                        errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessun preventivo sincronizzato con questa campagna. Sincronizzare almeno un preventivo.'));
            
            if(q != null){
                if(q.Metodo_di_pagamento__c == null || q.Metodo_di_pagamento__c == '')
                    errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessun metodo di pagamento selezionato sul preventivo.'));
                if(q.Termini_di_pagamento__c == null || q.Termini_di_pagamento__c == '')
                    errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessun termine di pagamento selezionato sul preventivo.'));
                if(q.Lingua_template_fattura__c == null || q.Lingua_template_fattura__c == '')
                    errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna lingua per il template della fattura selezionata sul preventivo.'));
                if(q.Modalita_di_spedizione__c != null){
                    if(q.Modalita_di_spedizione__c.toUpperCase() == 'PDF')
                        if(q.Indirizzo_Spedizione_Alternativo__c == null && o.Anagrafica_di_Fatturazione__c != null){
                            if(o.Anagrafica_di_Fatturazione__r.BillingCity == null || o.Anagrafica_di_Fatturazione__r.BillingCity == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna città presente sull\'anagrafica di fatturazione.'));
                            if(o.Anagrafica_di_Fatturazione__r.BillingStreet == null || o.Anagrafica_di_Fatturazione__r.BillingStreet == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna via presente sull\'anagrafica di fatturazione.'));
                            if(o.Anagrafica_di_Fatturazione__r.BillingPostalCode == null || o.Anagrafica_di_Fatturazione__r.BillingPostalCode == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessun CAP presente sull\'anagrafica di fatturazione.'));
                            if(o.Anagrafica_di_Fatturazione__r.BillingState == null || o.Anagrafica_di_Fatturazione__r.BillingState == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna provincia presente sull\'anagrafica di fatturazione.'));
                            if(o.Anagrafica_di_Fatturazione__r.BillingCountry == null || o.Anagrafica_di_Fatturazione__r.BillingCountry == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna paese presente sull\'anagrafica di fatturazione.'));
                        }
                    if(q.Modalita_di_spedizione__c.toUpperCase() == 'PDF/EMAIL')
                        if(q.Indirizzo_Spedizione_Alternativo__c == null && o.Anagrafica_di_Fatturazione__c != null){
                            if(o.Anagrafica_di_Fatturazione__r.Email_principale__c == null || o.Anagrafica_di_Fatturazione__r.Email_principale__c == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna email presente sull\'anagrafica di fatturazione.'));
                        }
                        else{
                            if(q.Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c == null || q.Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c == '')
                                errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna email presente sull\'indirizzo di spedizione alternativo.'));
                        }
                }
                else
                    errors.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nessuna modalità di spedizione selezionata sul preventivo.'));
            }               
            
            errorsPerOptyID.put(o.Id, errors);
        }
        return errorsPerOptyID;
    }
    
    
}