public without sharing class OpportunityNewExtension {
    //Input Parameters
    public String pIva {get; set;}
    public Map<Id, Account> mapAccountFound {get; private set;}
    public Boolean isAccountFound {get; private set;}
    public LocalUser localU {get; set;} //Force it for test or override
    private final Opportunity opp;

    //Static
    private static final String NEW_OPTY_URL = '/006/e';
    public static Set<String> setRTToExlude = new Set<String>{'Cliente_ItNet'};

    //Constructor
    public OpportunityNewExtension(ApexPages.StandardController stdController) {
        this.opp = (Opportunity) stdController.getRecord();
        mapAccountFound = new Map<Id, Account>();
        localU = new LocalUser();
        if (!localU.isLocalAdminUser) { //Default ownership association
            opp.OwnerId = UserInfo.getUserId();
        }
    }

    /*
    * Search the account based on P.IVA in input
    */
    public PageReference searchAccount() {
        PageReference pageRef = null;
        if (pIva == null || pIva == '') { //Value check
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'E\' necessario valorizzare il campo Partita IVA'));
            return pageRef;
        }
        String checkPIVA = checkPIVAFormat(pIva);
        if (checkPIVA != null) { //Format Check
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, checkPIVA));
            return pageRef;
        }

        //Getting the record type
        Map<Id, RecordType> mapRT = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName IN :setRTToExlude]);
        System.Debug('PuntoDebug - mapRT: '+mapRT);

        List<User> currentUser = [SELECT Id,Contact.Account.Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account> accountsToExcludeFromSearch = new List<Account>();
        accountsToExcludeFromSearch.addAll([SELECT Id FROM Account WHERE Id = :currentUser[0].Contact.Account.Id]);
        accountsToExcludeFromSearch.addAll([SELECT Id FROM Account WHERE OwnerId = :UserInfo.getUserId()]);

        mapAccountFound = new Map<Id, Account>(
            [SELECT Id, Name, Partita_Iva__c
            FROM Account
            WHERE Partita_IVA_Number__c = :pIva
            AND RecordTypeId NOT IN :mapRT.keySet()
            AND Id NOT IN :accountsToExcludeFromSearch]
        );
        System.Debug('PuntoDebug - mapAccountFound: '+mapAccountFound);

        isAccountFound = (mapAccountFound.size() > 0);
        if (isAccountFound) {
            traceSearchWithAccount();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Sono stati trovati clienti con la P. IVA inserita. E\' necessario inserire un valore non presente.'));
        } else {
            Id idOpp = createNewOpportunity();
            if (idOpp != null) { pageRef = new PageReference('/'+idOpp); }
        }

        return pageRef;
    }

    /*
    * This function create a new Opportunity and a new Quote [Object: a14]
    */
    public Id createNewOpportunity() {
        Id idOpp = null;

        List<Account> listAcc;
        
        User owner = [select email from User where id =: opp.OwnerId];
        //Cheking for brand
        Id idBrand;
        listAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Brand' AND OwnerId = :opp.OwnerId];
        System.Debug('PuntoDebug - listAcc (brand): '+listAcc);
        if (listAcc.isEmpty()) { //No account found
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Non è stata trovata l\'anagrafica per il Brand. Non è possibile continuare.'));
            System.Debug('PuntoDebug - : Nessun brand trovato');
            return null;
        } else if (listAcc.size() > 1) { //Multiple acocunts found
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Sono state trovate più anagrafiche Brand. Non è possibile continuare.'));
            System.Debug('PuntoDebug - : Più di un brand trovato ('+listAcc.size()+'): '+listAcc);
            return null;
        } else {
            idBrand = listAcc.get(0).Id;
        }

        //Checking for Anagrafica Fatturazione
        Id idFatt;
        listAcc = [
            SELECT Id, Metodo_di_pagamento__c, toLabel(Termini_di_pagamento__c), toLabel(Codice_IVA__c)
            FROM Account
            WHERE RecordType.DeveloperName = 'Anagrafica_di_Fatturazione' 
            AND OwnerId = :opp.OwnerId
        ];

        Account anagraficaFatt;
        System.Debug('PuntoDebug - anagraficaFatt: '+anagraficaFatt);
        if (listAcc.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Non è stata trovata l\'anagrafica di fatturazione. Non è possibile continuare.'));
            System.Debug('PuntoDebug - : Nessuna anagrafica di fatturazione trovata');
            return null;
        } else if (listAcc.size() > 1) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Sono state trovate più anagrafiche di fatturazione. Non è possibile continuare.'));
            System.Debug('PuntoDebug - : Più anagrafiche di fatturazione trovate ('+listAcc.size()+'): '+listAcc);
            return null;
        }else {
            anagraficaFatt = listAcc.get(0);
            idFatt = anagraficaFatt.Id;
        }

        // Apex soql non permette di estrarre sia la traduzione che il codice di un campo, devo fare 2 volte la stessa query per prendere le 2 informazioni. Fa schifo, ma non è colpa mia.
        Account anagraficaFatt2 = [
            SELECT Id, Metodo_di_pagamento__c, Termini_di_pagamento__c, Codice_IVA__c
            FROM Account
            WHERE RecordType.DeveloperName = 'Anagrafica_di_Fatturazione' 
            AND OwnerId = :opp.OwnerId
        ];

        //Populate the Opportunity fields
        opp.Partita_IVA_cliente_Local__c = pIva;
        opp.Note_fattura__c = pIva;
        opp.Canale_di_vendita__c = 'DIRETTA';
        opp.CloseDate = System.today() + 10; //TO CHECK
        opp.StageName = '0 %';
        opp.Commissione_Agenzia__c = 0;
        opp.Check_amministrativo__c = false;
        opp.AccountId = idBrand;
        opp.Anagrafica_di_Fatturazione__c = idFatt;
        opp.Tipo_Opportunity__c = 'Campagna';
        opp.Email_agenzia_creativa__c = owner.email;

        Savepoint sp = Database.setSavepoint(); //Savepoint used in case of error
        opp.Id = null; //For Next search
        System.Debug('PuntoDebug - opp to insert: '+opp);
        insert opp;

        //Creating the Quote, based on the Opprotunity
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = opp.Name;
        q.Metodo_di_pagamento__c = anagraficaFatt.Metodo_di_pagamento__c;
        q.Descrizione_Termini_pagamento__c = anagraficaFatt.Termini_di_pagamento__c;
        q.Termini_di_pagamento__c = anagraficaFatt2.Termini_di_pagamento__c;
        q.Lingua_template_fattura__c = 'ITA';
        q.Modalita_di_spedizione__c = 'PDF/EMAIL'; //anagraficaFatt.Tipo_spedizione__c
        q.Descrizione_IVA__c = anagraficaFatt.Codice_IVA__c;
        q.Codice_IVA__c = anagraficaFatt2.Codice_IVA__c;
        System.Debug('PuntoDebug - Quote to insert: '+q);
        insert q;

        //Cheking the quote
        Map<Id, List<ApexPages.Message>> mapOptyErrors = ControllerCheckAdm.checkAdm(new List<Id>{opp.Id});
        List<ApexPages.Message> listMsg = mapOptyErrors.get(opp.Id);
        System.Debug('PuntoDebug - mapOptyErrors: '+mapOptyErrors);
        if (listMsg.isEmpty()) { //Check OK
            idOpp = opp.Id;
            opp.Check_amministrativo__c = true;
            update opp;
        } else { //Check KO - Errors and rollback
            Database.rollback(sp);
            for (ApexPages.Message am : listMsg) {
                ApexPages.addMessage(am);
            }
        }

        return idOpp;
    }

    /*
    * This function trace if one or more account are found from the P.IVA in input,
    * by writing on LocalOpportunitySearch__c object
    */
    public void traceSearchWithAccount() {
        List<LocalOpportunitySearch__c> listLOS = new List<LocalOpportunitySearch__c>();
        for (Id idAcc : mapAccountFound.keySet()) {
            listLOS.add(new LocalOpportunitySearch__c(
                    Name=opp.Name,
                    Account__c = idAcc,
                    Partita_Iva__c=pIva
                )
            );
        }

        System.Debug('PuntoDebug - listLOS: '+listLOS);
        insert listLOS;
    }

    /*
    * This function returns the URL redirect:
    *
    * - If the user is Local, the page is refreshed
    * - If the user is not local, it returns the opportunity new standard page
    */
    public PageReference doRedirect() {
        PageReference pageRef = null;
        //Override of value from parameter for test
        String localParameterOverride = ApexPages.currentPage().getParameters().get('local');
        if (localParameterOverride == '1') {
            localU.isLocalUser = true;
        } else if (localParameterOverride == '0') {
            localU.isLocalUser = false;
        } 
        if (!localU.isLocalUser) {
            pageRef = new PageReference(NEW_OPTY_URL+'?nooverride=1');
        }

        return pageRef;
    }

    /*
    * Check on P.IVA. If result is ok, the function returns null
    */
    public static String checkPIVAFormat(String piva) {
        String error = null;
        
        Pattern patternPIVA = Pattern.compile('^[0-9]{11}$'); //11 digits
        Matcher matchPIVA = patternPIVA.matcher(piva);
        if (!matchPIVA.matches()) { //Error
            error = 'Il valore della Partita IVA inserito non ha il formato corretto.';
        }

        return error;
    }

}