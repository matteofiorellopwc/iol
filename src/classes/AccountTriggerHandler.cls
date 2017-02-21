public with sharing class AccountTriggerHandler {
    
    
    public static Boolean isUpselling = false;
    
    public static void doFieldUpdates(Account[] accs) {
        for(Account a : accs){
            a.ownerlookup__c = a.ownerid;
            //CLAUDIO 21/09/2016 B
            a.AgenziaTerritorialeText__c = a.Agenzia_territoriale__c;
            // E
        }       
    }
    
    public static void setupProvinciaAndAgenziaTerritoriale(Account[] accs) {
        Map<String, Id> provinciaAgenziaMap = new Map<String,Id>();
        Map<String, Id> regioneAgenziaMap = new Map<String, Id>();
        Map<String, String> mappaProvincia = new Map<String, String>();
    
        for(Provincia__c p : [SELECT sigla__c, agenzia_territoriale__c, Regione__c FROM provincia__c]) {
            mappaProvincia.put(p.sigla__c,p.regione__c);
            provinciaAgenziaMap.put(p.sigla__c,p.agenzia_territoriale__c);
        }
        for(Regione__c r : [SELECT name, agenzia_territoriale__c FROM regione__c]) {
            regioneAgenziaMap.put(r.name,r.agenzia_territoriale__c);
        }

        // check provincia    
        for(Account a : accs){
            if(a.recordTypeId != UtilItNet.itNetAccountRecordTypeId) {
                if(!isBlank(a.billingState)){
                    if(mappaProvincia.containsKey(a.billingState)) {
                        a.regione_billing__c = mappaProvincia.get(a.billingState);
                    } else {
                        a.billingState.addError('Provincia non trovata, inserire la sigla oppure EE se stato estero');            
                    }
                }
                if(!isBlank(a.shippingState)){
                    if(mappaProvincia.containsKey(a.shippingState)) {
                        a.regione_shipping__c = mappaProvincia.get(a.shippingState);
                    } else {
                        a.shippingState.addError('Provincia non trovata, inserire la sigla oppure EE se stato estero');
                    }
                }
            }            
        }
        
        // check agezia territoriale    
        Id brandRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Brand').getRecordTypeId();    
        for(Account a : accs){
            if(!a.Competenza_indipendente_da_indirizzi__c && a.recordTypeId == brandRecordTypeId) {
                String regionecompetenza = !isBlank(a.Regione_shipping__c) ? a.Regione_shipping__c : (!isBlank(a.Regione_billing__c) ? a.Regione_billing__c : '');                              
                String provinciacompetenza = !isBlank(a.shippingstate) ? a.shippingstate : (!isBlank(a.billingstate) ? a.billingstate : '');
                                                
                a.agenzia_territoriale__c = (
                    provinciaAgenziaMap.get(provinciacompetenza) != null ?
                    provinciaAgenziaMap.get(provinciacompetenza) :
                    regioneAgenziaMap.get(regionecompetenza)
                );
            }
        }
    }
    
    public static void updateEmailOnProdottiSottoContratto(Account[] accs) {        
        Set<Id> accounts = new Set<Id>();
        for(Account a : accs) {
            if(
                a.RecordTypeId == UtilItNet.itNetAccountRecordTypeId &&
                a.email_principale__c != trigger.oldMap.get(a.id).get('email_principale__c')
            ){
                accounts.add(a.id);
            }
        }
        
        if(!accounts.isEmpty()) {
            ProdottoSottoContratto__c[] prodsToUpdate = [SELECT
                Id,
                email__c,sottocontratto__r.contratto__r.cliente__c
                FROM ProdottoSottoContratto__c
                WHERE sottocontratto__r.contratto__r.cliente__c IN :accounts
                AND Trial_concluso__c <> true
                AND Chiuso__c <> true
            ];
            for(ProdottoSottoContratto__c psc : prodsToUpdate){
                psc.email__c = (String) trigger.newMap.get(psc.sottocontratto__r.contratto__r.cliente__c).get('email_principale__c');
            }
            Database.update(prodsToUpdate, false);
        }       
    }
    
    public static void updateEmailOnPagamentiAria(Account[] accs) {        
        Set<Id> accounts = new Set<Id>();
        for(Account a : accs) {
            if(
                a.RecordTypeId == UtilItNet.itNetAccountRecordTypeId &&
                a.email_principale__c != trigger.oldMap.get(a.id).get('email_principale__c')
            ){
                accounts.add(a.id);
            }
        }
        
        if(!accounts.isEmpty()) {
            PagamentoAria__c[] pagAriasToUpdate = [SELECT
                Id,
                emailCliente__c,Cliente__c
                FROM PagamentoAria__c
                WHERE Cliente__c IN :accounts
            ];
            for(PagamentoAria__c pa : pagAriasToUpdate){
                pa.emailCliente__c = (String) trigger.newMap.get(pa.Cliente__c).get('email_principale__c');
            }
            Database.update(pagAriasToUpdate, false);
        }       
    }
    
    public static void validateItNetAccount(Account[] accs) {                
        for(Account a : accs) {
            if(a.RecordTypeId == UtilItNet.itNetAccountRecordTypeId) {
                //Check obbligatorietà tipo anagrafica
                /*
                if(a.tipo_anagrafica__c == null) {
                    a.addError('Il campo tipo anagrafica è obbligatorio per i clienti ItNet');
                }
                */
                if(a.email_principale__c == null) {
                    a.addError('Il campo email è obbligatorio per i clienti ItNet');
                }
                if(a.Account_Accesso__c == null) {
                    a.addError('Il campo Account accesso portale è obbligatorio per i clienti ItNet');
                }                
                
                //Autocomplete account name if tipoanagrafica = fisica
                if(a.tipo_anagrafica__c == 'Fisica') {
                   a.Name = a.nome_persona_fisica__c + ' ' + a.cognome_persona_fisica__c; 
                } else if(a.tipo_anagrafica__c == 'Giuridica') {
                   a.Name = a.Ragione_sociale__c;
                } else{
                   a.Name = a.email_principale__c;
                }
                 
                //Controllo dati modificati
                if(a.Stato__c == 'Attivo') {
                    //Controllo dati modificati
                    if(trigger.isUpdate) {
                        Account old = (Account) trigger.oldMap.get(a.Id);
                        if(old.Stato__c == a.Stato__c) {                        
                            if(old.partita_IVA__c != a.partita_IVA__c || old.Codice_fiscale__c != a.Codice_fiscale__c || old.Ragione_sociale__c != a.Ragione_sociale__c || old.Nome_persona_fisica__c != a.Nome_persona_fisica__c || old.cognome_persona_fisica__c != a.cognome_persona_fisica__c) {
                                List<Ticket_fatturazione__c> ticketList = [SELECT Id FROM TIcket_Fatturazione__c WHERE Account__c = :a.Id];
                                if(!ticketList.isEmpty()) {
                                    a.addError('I dati dell\'anagrafica cliente non possono essere cambiati per un cliente ItNet attivo');   
                                }
                            }                    
                        }
                    }
                }
                
                //Controllo duplicati
                if(a.Stato__c == 'Attivo' || a.Stato__c == 'Temp'){
                    if(a.tipo_anagrafica__c == 'Fisica') {
                        List<Account> aCheck = [SELECT Id 
                                                FROM Account 
                                                WHERE codice_fiscale__c =:a.Codice_fiscale__c 
                                                AND codice_fiscale__c <> null
                                                AND Id <> :a.Id AND RecordTypeId = :UtilItNet.itNetAccountRecordTypeId 
                                                AND Stato__c = 'Attivo'];
                        if(!aCheck.isEmpty()) {
                            a.addError('Esiste già un\'anagrafica itNet con lo stesso codice fiscale');
                        }
                    } else if(a.tipo_anagrafica__c == 'Giuridica') {
                        List<Account> aCheck = [SELECT Id 
                                                FROM Account 
                                                WHERE ( 
                                                        (Ragione_sociale__c = :a.ragione_sociale__c and Ragione_sociale__c <> null )  OR 
                                                        ( partita_iva__c =:a.partita_iva__c and partita_iva__c <> null) 
                                                    )
                                                    AND Id <> :a.Id 
                                                    AND RecordTypeId = :UtilItNet.itNetAccountRecordTypeId 
                                                    AND Stato__c = 'Attivo'
                                               ];
                        if(!aCheck.isEmpty()) {
                            a.addError('Esiste già un\'anagrafica itNet con la stessa ragione sociale/partita IVA');                
                        }
                    }
                }
            }
        }       
    }
    
    public static void manageSharing(Account[] triggerNew, Map<Id, Account> triggerOldMap) {
        Opportunity[] oppToUpdate = new Opportunity[]{};
        Opportunity[] oppWithOwnerAccountChanged = new Opportunity[]{};
        Account[] accChanged = new Account[]{};
        
        for(Account a : triggerNew) {
            Account oldA = triggerOldMap.get(a.Id);
            if(oldA == null || oldA.OwnerId != a.OwnerId) {
                accChanged.add(a);                                              
            }
        }
        
        oppToUpdate = [SELECT Id,OwnerCentroMediaId__c,Centro_Media__c FROM Opportunity WHERE Centro_Media__c IN :accChanged];
        oppWithOwnerAccountChanged = [SELECT Id FROM Opportunity WHERE AccountId IN :accChanged];
        
        Map<Id, Id> oldOwnerCentroMediaMap = new Map<Id, Id>();
        if(!oppToUpdate.isEmpty()) {
            for(Opportunity o : oppToUpdate) {
                oldOwnerCentroMediaMap.put(o.Id, triggerOldMap.get(o.Centro_Media__c).OwnerId);
            }
        }
        
        if(!oppWithOwnerAccountChanged.isEmpty()) oppToUpdate.addAll(oppWithOwnerAccountChanged);
        if(!oppToUpdate.isEmpty()) {
            Database.executeBatch(new BatchableManageSharing(accChanged, oldOwnerCentroMediaMap), 10);
        }   
    }   
  
    public static Boolean isBlank(String s){
        return s == null || s == '';
    }   
}