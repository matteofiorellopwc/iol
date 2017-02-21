public class ExtensionEditLineItem {

    public LocalUser localU {get; set;}
    private Boolean mustUpdateDfpLiBeforeSave = false;
    
    public Boolean lineItemRipianificabile {
        get{
            return ApexPages.currentPage().getParameters().get('parentLineItem') == null && 
            ApexPages.currentPage().getParameters().get('firstTime') == null; 
        }
        set;
    }
    

    //Componentino per fast switch dei lineitem
    List<LineItem__c> liL {get; set;}
    public Integer actualLineItem {get; set;}
    public Integer totalLineItems {get {
        return liL == null ? 0 : liL.size();
    }} 
    public PageReference gotoNext() {    
        Id nextId = liL.get(actualLineItem == totalLineItems ? 0 : actualLineItem).Id;
        PageReference pr = new PageReference('/' + nextId);
        pr.setRedirect(true);
        return pr;        
    }
    public PageReference gotoPrevious() {
        Id prevId = liL.get(actualLineItem == 1 ? totalLineItems - 1 : actualLineItem - 2).Id;
        PageReference pr = new PageReference('/' + prevId);
        pr.setRedirect(true);
        return pr;                
    }
    
    //Save & New   
    private Boolean saveHasErrors = false;
    public PageReference saveAndNew() {
        saveHasErrors = false;
        customSave();
        if(saveHasErrors) return null;
        return new PageReference('/apex/addProduct?id=' + li.Opportunity__c);                           
    }
           
    public ApexPages.StandardController controller {get;set;}
    public lineitem__c li {get;set;}
    public string liNameDfp {get;set;} //per visualizzarlo nella pagina, voglio vedere il nuovo valore (che dipende da inventory target) senza fare query
    public ControllerOptionalLineItem ControllerOptionalLineItem {get;set;}
    public ControllerForecast ControllerForecast {get;set;}
    
    //Tab visibility
    public boolean isVisibleDayPartTab {get;set;}
    public boolean isVisibleFrequencyCapTab {get;set;}
    public boolean isVisibleInventoryTargetTab {get;set;}
    public boolean isVisibleTechnologyTargetTab {get;set;}
    public boolean isVisibleCustomCriteriaTab {get;set;}
    public boolean isVisibleCookiesTab {get;set;}
    public boolean isVisiblePagesSectionsTab {get;set;}
    public boolean isVisibleGeographyTab {get;set;}
    
    public boolean esistonoRicaviCustom {get;set;}
    
    //Visibility of product Searh
    public boolean isSearchProduct {get;set;}
    
    public boolean showOptionals {get;set;}
    
    public string fieldEdited {get;set;}
    
    public integer indexRevenueToDelete {get;set;}
    
    public list<selectoption> TypeDfpOptions{
        get{
            list<selectoption> so = new list<selectoption>();
            if(li.delivery_model__c == 'CPD'){
                so.add(new selectoption('SPONSORSHIP','SPONSORSHIP'));
                so.add(new selectoption('NETWORK','NETWORK'));
            }
            if(li.delivery_model__c == 'CPC'){
                so.add(new selectoption('SPONSORSHIP','SPONSORSHIP'));
                so.add(new selectoption('NETWORK','NETWORK'));
                so.add(new selectoption('STANDARD','STANDARD'));
                so.add(new selectoption('BULK','BULK'));
                so.add(new selectoption('PRICE_PRIORITY','PRICE_PRIORITY'));
                so.add(new selectoption('HOUSE','HOUSE'));
            }
            if(li.delivery_model__c == 'CPM'){
                so.add(new selectoption('SPONSORSHIP','SPONSORSHIP'));
                so.add(new selectoption('NETWORK','NETWORK'));
                so.add(new selectoption('STANDARD','STANDARD'));
                so.add(new selectoption('BULK','BULK'));
                so.add(new selectoption('PRICE_PRIORITY','PRICE_PRIORITY'));
                so.add(new selectoption('HOUSE','HOUSE'));
                so.add(new selectoption('ADSENSE','ADSENSE'));
                so.add(new selectoption('AD_EXCHANGE','AD_EXCHANGE'));
            }
            return so;
        }
    }
    
    
    public boolean canEditOpportunity {get;set;}
    
    public ControllerRevenueApplication ControllerRevenueApplication {get;set;}
    
    public ControllerRicavi ControllerRicaviCtrl {get;set;}
    public ControllerRicavi controllerRicaviLineItemRipianificato {get;set;}
    
    
    public Id lineItemIdDaRipianificare {get;set;}
    public LineItem__c lineItemDaRipianificare {get;set;}
    public boolean ripianificazioneLineItem {get;set;}
    public Boolean lineItemSoloSuMesiAperti {get;set;}
    public Boolean removeSave {get;set;} //TODO
    public Decimal valoreRipianificabile {get;set;}
    
    public ExtensionEditLineItem(ApexPages.StandardController controller) { 
        li = (lineitem__c) controller.getRecord();

        localU = new LocalUser();
        
        liNameDfp = li.Name_Dfp__c;
        
        Boolean lineItemOriginaleSoloSuMesiAperti = true;
        

        if(li.Line_Item_Ripianificato__c != null){ 
            lineItemOriginaleSoloSuMesiAperti = ControllerRicavi.isLineItemSoloSuMesiApertiStorno(li); 
        }
        
        if(li.Product__r.consentiModificaSeMesiChiusi__c){
            lineItemSoloSuMesiAperti = true;
        }else{
            lineItemSoloSuMesiAperti = ControllerRicavi.isLineItemSoloSuMesiAperti(li) && lineItemOriginaleSoloSuMesiAperti;
        }
        
        canEditOpportunity = [select RecordId,HasEditAccess from UserRecordAccess where UserId =: UserInfo.getUserId() and RecordId =: li.opportunity__c].HasEditAccess;
        
        
        //Recupero gli id dei lineitem per mostrare la barretta per andare da uno all'altro
        liL = [SELECT Id FROM LineItem__c WHERE Opportunity__c = : li.Opportunity__c ORDER BY Start_Date__c asc];
        for(Integer i = 0; i < liL.size(); i++) {
            if(liL.get(i).Id == li.Id) {
                actualLineItem = i + 1;
            }
        }
               
        system.debug('***ExtensionEditLineItem***');
        
        showOptionals = !([select id from optional__c where product__c =: li.product__c].isEmpty());
        system.debug('showOptionals = ' + showOptionals);
        
        isVisibleDayPartTab = !li.Day_Part_Targeting__r.isEmpty();
        isVisibleFrequencyCapTab = !li.Frequency_Caps__r.isEmpty();
        isVisibleInventoryTargetTab = !(li.Inventory_Target__r.isEmpty() && li.PlacementTargeting__r.isEmpty());
        isVisibleTechnologyTargetTab = false;
        for(TechnologyTargeting__c tech : [SELECT Id,valueIds__c FROM TechnologyTargeting__c WHERE Id in :li.Technology_Targeting__r]){
            if(tech.valueIds__c != null && tech.valueIds__c.trim().length()>0){
                isVisibleTechnologyTargetTab = true;
                break;
            }
        }

        isVisibleCustomCriteriaTab = !li.Custom_Criteria_Set__r.isEmpty();
        isVisibleCookiesTab = !li.CookieSearchTermsOASTargeted__r.isEmpty();
        isVisiblePagesSectionsTab = !(li.Inventory_Target__r.isEmpty() && li.SectionsOasTargeted__r.isEmpty());
        isVisibleGeographyTab = !li.Geography__r.isEmpty();
        this.controller = controller;
        ControllerOptionalLineItem = new ControllerOptionalLineItem();
        
        if(li.Ultima_modifica_prezzo__c == null || li.Ultima_modifica_prezzo__c == ''){
            li.Ultima_modifica_prezzo__c = 'sconto';
        }
        
        fieldEdited = li.Ultima_modifica_prezzo__c;
        
        //Per i categoria libero = Network il default è valore
        if(li.modalitaEditRevenue__c == null){
            if(li.product__r.categoria_libero__c != 'Network'){
                li.modalitaEditRevenue__c = 'Percentuale';
            }else{
                li.modalitaEditRevenue__c = 'Valore';
            }
        }
        if(li.ModalitaEditRicavo__c == null){
            if(li.product__r.categoria_libero__c != 'Network'){
                li.ModalitaEditRicavo__c = 'Percentuale';
            }else{
                li.ModalitaEditRicavo__c = 'Valore';
            }
        }
        
        
        ripianificazioneLineItem = false;
        lineItemIdDaRipianificare = ApexPages.currentPage().getParameters().get('parentLineItem');
        if(lineItemIdDaRipianificare != null || li.Line_Item_Ripianificato__c != null){
            ripianificazioneLineItem = true;
        }
        
        if(!ripianificazioneLineItem){
            ControllerRevenueApplication = new ControllerRevenueApplication(li);
            ControllerRevenueApplication.setParentValues(li);
            //Se ho fatturato almeno una revenue la modalità diventa valore
            if(ControllerRevenueApplication.isFatturato){
                li.modalitaEditRevenue__c = 'Valore';
            }
        }
        ControllerRicaviCtrl = new controllerRicavi(li);
        ControllerRicaviCtrl.setParentValues(li);
        ControllerRicaviCtrl.ripianificazioneLineItem = ripianificazioneLineItem;  
        
        
        setMustUpdateLiBeforeSave(li);        
        ControllerForecast = new ControllerForecast(li.id);
        
        // calcolo del massimo ripianificabile
        
        if(lineItemIdDaRipianificare != null){ 
            lineItemDaRipianificare = [SELECT Id, Ripianificato__c, totaleRipianificabile__c, Totale__c,Start_Date__c,End_Date__c,Data_sospensione_erogazione__c,
                                        ValoreRipianificabileApprovato__c,ValoreRipianificabileApprovatoFormula__c,TotaleRipianificabileApprovato__c,Id_DFP__c,Id_oas__c,RimozioneParteNonErogata__c,End_Hour__c,End_minute__c,Nome_DFP__c, Opportunity__r.Local__c,
                                            (SELECT Id, Data_primo_mese__c, Data_ultimo_mese__c
                                            FROM Ricavi__r 
                                            WHERE Data_primo_mese__c > :RicavoTriggerHandler.getDataChiusuraRicavo(li.Opportunity__r.Local__c)
                                            //:DataChiusuraRicavo__c.getValues('data').data__c 
                                            AND Valore__c > 0
                                            ORDER BY Data_primo_mese__c ASC) 
                                        FROM LineItem__c 
                                        WHERE Id = :lineItemIdDaRipianificare ];
            System.debug(LoggingLevel.WARN,'Trovato lineitem da ripianificare: '+lineItemDaRipianificare);
            controllerRicaviLineItemRipianificato = new ControllerRicavi();
            //mi servono i ricavi negativi del lineitem da ripianificare che sono collegati al line item ripianificato
            controllerRicaviLineItemRipianificato.getRicaviNegativi(lineItemDaRipianificare.id,li.id);
        }
        valoreRipianificabile = getValoreRipianificabile();

    }
    
    /**
    * Restituisce il massimo valore ripianificabile nel caso di un Line Item di ripianificazione
    */
    private Decimal getValoreRipianificabile(){
        Decimal totaleRipianificabile;
        if(lineItemDaRipianificare != null){ // se sto ripianificando in questo momento
            totaleRipianificabile = lineItemDaRipianificare.ValoreRipianificabileApprovatoFormula__c;
        }else if(li.Line_Item_Ripianificato__c != null){
            totaleRipianificabile = li.Totale__c + 

                                    [SELECT ValoreRipianificabileApprovatoFormula__c
                                    FROM LineItem__c 
                                    WHERE Id = :li.Line_Item_Ripianificato__c].ValoreRipianificabileApprovatoFormula__c;
        }
        return totaleRipianificabile;
    }
    
    private void setMustUpdateLiBeforeSave(LineItem__c li) {
        try {
            datetime startDt = DateTime.newInstance(li.start_date__c,Time.newInstance(integer.valueOf(li.start_hour__c),integer.valueOf(li.start_minute__c),0,0));
            mustUpdateDfpLiBeforeSave = startDt < System.now() && !UtilityLineItemIntegration.statiNonModificabili.contains(li.status__c);
        } catch(Exception e) {
            mustUpdateDfpLiBeforeSave = false;
        }
    }

    public static void printLimits(){
        printLimits('');
    }
    public static void printLimits(String message){
        system.debug(message + ' -> queries = '+Limits.getQueries());
    }
    
    /*
        ultima data/ora in cui si è controllato il bacino
    */
    DateTime lastCheckModificaBacino = null;

    public pageReference customSave(){
        printLimits('Before save');
        if(li.Ripianificato__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Non è possibile modificare un line item ripianificato.'));
            return null;
        }
        
        saveHasErrors = true;
        
        //Controlli su vari dati per il salvataggio
        LineItem__c liUpdated = getLineItemUpdated();

        if( li.end_date__c >= date.today() &&
            li.CheckUtilizzoSOV__c 
            &&
            (
                ((lastCheckModificaBacino == null || liUpdated.lastModifiedDate > lastCheckModificaBacino) && liUpdated.Bacino_modificato__c == true)
                ||
                li.Bacino_modificato__c == true
            )
        ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'extension editli  Aggiornare il bacino per avere i valori corretti'));
            return null;
        }

        printLimits('After getLineItemUpdated');

        system.debug('OPTIONALS!!!'+controlleroptionallineitem.optionals);
        updatecalc();
        
        boolean noWarn = true;        
        
        /*
            - per i prodotti vetrina local, revenue e ricavi vengono aggiornati in automatico
            - i commerciali local non possono modificare le revenue
            - dopo la prima chiusa vinta i commerciali non possono più modifcare l'opportunità
        */
        if(li.isVetrinaLocal__c && !ControllerRevenueApplication.isFatturato){
            ControllerRevenueApplication.creaRevenueApplicationDaDateVetrina();
        }else if(localU.isLocalUser && !localU.isLocalAdminUser && !ControllerRevenueApplication.isFatturato){
            ControllerRevenueApplication.creaRevenueApplicationDaDate();
        }

        if(!ripianificazioneLineItem && ControllerRevenueApplication.revenueApplications.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire almeno una riga di "Revenue Application"'));
            return null;
        }
        
        if(li.isVetrinaLocal__c && lineItemSoloSuMesiAperti){
            ControllerRicaviCtrl.creaRicaviDaDateVetrina(80); 
        }else if(localU.isLocalUser && !localU.isLocalAdminUser && lineItemSoloSuMesiAperti){
            ControllerRicaviCtrl.creaRicaviDaDate();
        }

        System.debug(LoggingLevel.WARN,'Ricavi crea da date: '+ControllerRicaviCtrl.ricavi);
        esistonoRicaviCustom = ControllerRicaviCtrl.esistonoRicaviCustom2(); 
        System.debug(LoggingLevel.WARN,'esistonoRicaviCustom: '+esistonoRicaviCustom);
        System.debug(LoggingLevel.WARN,'ripianificazioneLineItem: '+ripianificazioneLineItem);
        System.debug(LoggingLevel.WARN,'li.isVetrinaLocal__c: '+li.isVetrinaLocal__c);        
        if((ripianificazioneLineItem || !esistonoRicaviCustom) && !li.isVetrinaLocal__c){ //il vetrina local ha il suo crea da date personalizzato
            ControllerRicaviCtrl.creaRicaviDaDate();
        } 
        System.debug(LoggingLevel.WARN,'Ricavi crea da date: '+ControllerRicaviCtrl.ricavi);
        if(ControllerRicaviCtrl.ricavi.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire almeno una riga di "Ricavo"'));
            System.debug(LoggingLevel.WARN,'Inserire almeno una riga di "Ricavo"');
            return null;
        }

        if(UtilityCustomTargeting.checkErrorAudienceSegment(liUpdated)){ return null; }
        if(
            [select Id from Inventory_Target__c where lineItem__c =: li.id].isEmpty() && 
            [select Id from PlacementTargeting__c where line_Item__c =: li.id].isEmpty() &&
            li.Integrato_con_DFP_formula__c == 'true'
        ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire inventory target'));
            return null;
        }

    //AN - 20140424
        String adxDuplicated = checkADXPlacementUnivocity();
        if (adxDuplicated != null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il valore di ADX Placement ID non è univoco. Il valore inserito è già presente nel/nei setuente/i Line Item: '+adxDuplicated));
            return null;
        }
    
        if(mustUpdateDfpLiBeforeSave) {
            //li.status__c = 'AAA';
            UtilityLineItemIntegration.syncDfpToSfdcLineItems(new LineItem__c[]{li});
            System.debug('LI STATUS AFTER SYNC: ' + li.status__c);

        }
        Boolean isIgnore= [select Product__r.IgnoraCPD__c from LineItem__c where id =: li.id][0].Product__r.IgnoraCPD__c;
        system.debug('isIgnore '+isIgnore);
        if(li.ProductFamily__c == 'Banner' && (li.type_dfp__c == 'STANDARD' || li.type_dfp__c == 'SPONSORSHIP')){
            if((li.delivery_model__c == 'CPM' || li.delivery_model__c == 'CPC') && li.end_date__c >= date.today() && li.Integrato_con_DFP_formula__c == 'true'){
                
                ControllerForecast.Forecast forecast = ControllerForecast.checkAvailabilitySave(liUpdated);
                printLimits('After check availability');
                if(forecast == null){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Errore durante la richiesta disponibilità CPM: '+ControllerForecast.error +'<br/>Le modifiche verranno comunque salvate.'));
                   noWarn = false;
                }else if(forecast.availableUnits < li.Quantita__c){
                   system.debug('Visualizza messaggio di warning');
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Unità disponibili non sufficienti. Le modifiche verranno comunque salvate.'));               
                   noWarn = false;
                }
            }
            
            if(li.delivery_model__c == 'CPD' && !li.skipDispoCPD__c  && !isIgnore && li.end_date__c >= date.today()  && (li.Import_Ext_ID__c == '' || li.Import_Ext_ID__c == null)){
               ControllerCpdAvailability checkCpd = new ControllerCpdAvailability();
               if(li.Fascia_oraria__c != null && li.Fascia_oraria__c != '') {
                    checkCpd.fasciaOraria = li.Fascia_oraria__c;
               }
               Map<String,boolean> checkedCPD = checkCpd.checkAvailabilityLineItem(liUpdated);
               if(checkedCPD.get('block')){               
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,checkCpd.conflictMessage));               
                   return null;
               }
               if(checkedCPD.get('conflict')){
                   system.debug('Visualizza messaggio di warning');
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Possibile conflitto con altro lineItem. Le modifiche verranno comunque salvate'));               
                   nowarn = false;
               }
            }
        }
        
        printLimits('Before main save');
        if(li.pacchetto_combo_opportunity__c == null) {  
            if(!ripianificazioneLineItem){          
                ControllerRevenueApplication.saveTmpRevenueApplications();
            }
            ControllerRicaviCtrl.saveTmpRicavi(); 
            printLimits('Saved temp revenue apps'); // -> 2 query
            Savepoint sp = Database.setSavepoint();            
            boolean personalizzato = li.personalizzato__c;
            
            try{
                //Per la validazione delle revenue e degli optionals non mi serve aggiornare il lineitem
                LineItemTriggerHandler.skipUpdateLineItem = true;
                LineItemTriggerHandler.skipLineItemTrigger = true;
                //Validazione revenue. Non si possono modificare/eliminare revenue già fatturate
                LineItemTriggerHandler.skipValidationTotali = true; //Salvo le revenue  senza fare la validazione sui totali
                
                //Se in modificabile in line item del prodotto posso modificare la fascia oraria, vale il campo fascia oraria sul line item per il day part targeting
                checkFasciaDayPart();
                
                ControllerOptionalLineItem.customSave();
                system.debug('totale li dopo optionals'+li.totale__c);
                li.personalizzato__c = true;                
                
                if(!ripianificazioneLineItem){
                    ControllerRevenueApplication.customSave();
                    system.debug('totale li dopo revenue '+li.totale__c);
                } 
                ControllerRicaviCtrl.customSave();
                ControllerRicaviCtrl.controllaSeEsistonoRicaviPersonalizzati();
                system.debug('totale li dopo ricavi'+li.totale__c);
                
                if(lineItemDaRipianificare != null){
                    
                    li.Line_Item_Ripianificato__c = lineItemIdDaRipianificare;
                    
                    Decimal valoreRipianificato = 0;
                    for(Ricavo__c ricavo : ControllerRicaviCtrl.ricavi){
                        if(ricavo.Mese__c == 'Totale'){
                            valoreRipianificato = ricavo.Valore__c;
                            break;
                        }
                    }
                    controllerRicaviLineItemRipianificato.calcolaRicavi(lineItemDaRipianificare,li);                    
                } 
                
                /*
                 * Validazione e salvataggio lineitem:
                 * 1. Vengono calcolati i rollup su optionals e revenue, e confrontati con il totale del lineitem
                 * 2. Vengono aggiornate le revenue se sono cambiati i valori relativi agli obiettivi.
                 * 3. Se vengono cambiate le date di inizio/fine, vengono aggiornati gli asset
                 * 4. Viene fatto partire il trigger sull'opportunità
                 */         
                LineItemTriggerHandler.skipValidationTotali = false;
                LineItemTriggerHandler.skipLineItemTrigger = false;
                update li;
                printLimits('updated li');
                                
            }catch(Exception e){
                li.personalizzato__c = personalizzato;
                Database.rollback(sp);
                
                if(!ripianificazioneLineItem){
                    //Faccio il restore delle revenue prima del salvataggio per sbiancare eventuali id (che non vengono tolti dal rollback)
                    ControllerRevenueApplication.restoreFromTmpRevenueApplication();
                }
                ControllerRicaviCtrl.restoreFromTmpRicavi(); 
                
                if(e instanceof DMLException) ApexPages.addMessages(e);
                else ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore:<br />'+e.getMessage()+'<br/>'+e.getStackTraceString()));                   
                return null;
            } 
            
            if(!ripianificazioneLineItem){
                ControllerRevenueApplication.resetRevenueApplicationToDelete(li); //così se ritorno qui non da eccezione
            }
            ControllerRicaviCtrl.resetRicaviToDelete(li); 
        }else{
            boolean personalizzato = li.personalizzato__c;
            try{
                li.personalizzato__c = true;
                system.debug('update li');
                update li;
            }catch(Exception e){
                li.personalizzato__c = personalizzato;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore:<br />'+e.getMessage()));                   
                return null;
            }
        }
       
        system.debug('personalizzato = '+li.personalizzato__c);
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'LineItem salvato correttamente'));
        liNameDfp = [select name_dfp__c from lineitem__c where id =: li.id].name_dfp__c; //formula che dipende da inventory target, voglio vederlo nella pagina senza rifare la query               
        
        saveHasErrors = false;
        setMustUpdateLiBeforeSave(li);
        return null;
    }









    public pageReference customCancel(){
        system.debug('custom cancel');
        PageReference p = new PageReference('/'+li.Opportunity__c);
        /*
        if(li.personalizzato__c == false){
            list<lineitem__c> olis = [select id from lineitem__c where id =: li.id];
            delete olis;
        }
        */
        return p;
    }      
    
    public PageReference minorRicavoAction(){
        PageReference pr = null;
        if(li.ProductFamily__c == 'Placeholder' && li.Product__r.PermettiMinorRicavoParziale__c){
            pr = new PageReference('/apex/MinorRicavoParziale?id='+li.Id);   
        }else{
            pr = new PageReference('/apex/MinorRicavo?id='+li.Id);
        }
        return pr;
    }

    public void aggiornaBacino(ControllerForecast.Forecast forecast){
        //fake forecast for testing DEPLOY, rimuovere prima deploy LUCA
       // forecast = new ControllerForecast.Forecast();
       // forecast.matchedUnits = 100*1000000 + Math.roundToLong((1000000 * Math.random()));
       // forecast.availableUnits = (Long) (forecast.matchedUnits * 0.6);
       // system.debug('aggiornaBacino fake');
       
        if(li.CheckUtilizzoSOV__c){
            if(forecast != null){
                li.Bacino_impressions__c = forecast.matchedUnits; //.possibleUnits
                li.BacinoImpressionsDisponibile__c = forecast.availableUnits;
                li.Bacino_modificato__c = false;
                lastCheckModificaBacino = system.now();
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Errore durante il calcolo del bacino CPM: '+ControllerForecast.error));
                //.addError('Errore durante la richiesta disponibilità CPM: '+ControllerForecast.error.replace('<br />','\n'));
                li.Bacino_impressions__c = null;
                li.BacinoImpressionsDisponibile__c = null;
            }
        }
        fieldEdited = '';
        updatecalc();
    }
    
    public void CheckAvailability(){
        system.debug('checkAvailability ControllerForecast '+ControllerForecast);
        ControllerForecast.CheckAvailability(getLineItemUpdated());
        system.debug('dopo ControllerForecast.CheckAvailability ');
        if(li.CheckUtilizzoSOV__c){
            system.debug('prima CheckUtilizzoSOV__c. ');
            aggiornaBacino(ControllerForecast.f);
            system.debug('prima CheckUtilizzoSOV__c. ');
        }
    }
        
    public void updatecalc(){
        if(!(li.Type_DFP__c == 'SPONSORSHIP' && li.Delivery_model__c == 'CPM')){
            if(fieldEdited == 'shareOfVoice'){
                li.ultima_modifica_quantita__c = 'shareOfVoice';
            }else if(fieldEdited == 'quantita' || li.ultima_modifica_quantita__c == null){
                li.ultima_modifica_quantita__c = 'quantita';
            }
    
            if(
                fieldEdited == 'startdate' ||
                fieldEdited == 'starthour' ||
                fieldEdited == 'startminute' ||
                fieldEdited == 'enddate' ||
                fieldEdited == 'endhour' ||
                fieldEdited == 'endminute' ||
                fieldEdited == 'fasciaOraria'
            ){
                li.bacino_modificato__c = true;
            }
    
    
            if(li.CheckUtilizzoSOV__c){
                if(li.ultima_modifica_quantita__c == 'quantita'){
                    li.shareOfVoice__c = li.Bacino_impressions__c > 0 ? (integer) li.quantita__c / li.Bacino_impressions__c * 100 : 0;
                }else{
                    li.Bacino_impressions__c = li.Bacino_impressions__c == null ? 0 : li.Bacino_impressions__c;
                    li.BacinoImpressionsDisponibile__c = li.BacinoImpressionsDisponibile__c == null ? 0 : li.BacinoImpressionsDisponibile__c;
                    li.shareOfVoice__c = li.shareOfVoice__c == null ? 0 : li.shareOfVoice__c; 
                    li.quantita__c = (integer) (li.Bacino_impressions__c * li.shareOfVoice__c / 100);
                }
                if(li.Id_DFP__c != null && !Test.isRunningTest()){
                    DfpLineItemService.LineItemPage dfpResult = UtilityLineItemIntegration.getLineItemsByIds(new List<Decimal>{li.Id_DFP__c});
                    for (DfpLineItemService.LineItem result : dfpResult.results) {
                        if(result.id == li.Id_DFP__c){
                            li.ImpressionErogateMinorRicavo__c = 0;
                            if(result.stats != null && result.stats.impressionsDelivered != null){
                                li.ImpressionErogateMinorRicavo__c = result.stats.impressionsDelivered;
                            }
                            break;
                        }
                    }
                }
                System.debug(li.BacinoImpressionsDisponibile__c);
                System.debug(li.Opportunity__r.DataPrimaChiusaVinta__c);
                System.debug(li.Quantita__c);
                System.debug(li.ImpressionErogateMinorRicavo__c);

                if(li.BacinoImpressionsDisponibile__c > 0){
                    if(li.Opportunity__r.DataPrimaChiusaVinta__c == null){
                        li.PercentualeBacinoDisponibileOccupato__c = (li.Quantita__c / li.BacinoImpressionsDisponibile__c)*100;                
                    }else{
                        if(li.ImpressionErogateMinorRicavo__c == null){
                            li.PercentualeBacinoDisponibileOccupato__c = (li.Quantita__c / li.BacinoImpressionsDisponibile__c)*100;                
                        }else{
                           li.PercentualeBacinoDisponibileOccupato__c = ((li.Quantita__c - li.ImpressionErogateMinorRicavo__c)  / li.BacinoImpressionsDisponibile__c)*100;                
                       }
                    }
                }else{
                    if(li.Opportunity__r.DataPrimaChiusaVinta__c == null){
                        if(li.Bacino_impressions__c > 0){
                            li.PercentualeBacinoDisponibileOccupato__c = 100 + (li.Quantita__c / li.Bacino_impressions__c)*100;
                        }else{
                            li.PercentualeBacinoDisponibileOccupato__c = 0;
                        }
                    }else{
                        if(li.Bacino_impressions__c > 0){
                            if(li.ImpressionErogateMinorRicavo__c == null){
                                li.PercentualeBacinoDisponibileOccupato__c = 100 + (li.Quantita__c / li.Bacino_impressions__c)*100;                
                            }else{
                                li.PercentualeBacinoDisponibileOccupato__c = 100 + ((li.Quantita__c - li.ImpressionErogateMinorRicavo__c) / li.Bacino_impressions__c)*100;                
                            }
                        }else{
                            li.PercentualeBacinoDisponibileOccupato__c = 0;
                        }
                    }
                }
                System.debug(li.PercentualeBacinoDisponibileOccupato__c);
            }
    
            Decimal totaleRipianificabile = null;
            UtilLineItem.updatecalc(li,fieldEdited,ControllerOptionalLineItem,valoreRipianificabile);
            if(!ripianificazioneLineItem){
                ControllerRevenueApplication.setParentValues(li);
                ControllerRevenueApplication.updateRevenueApplication();
            }
            ControllerRicaviCtrl.setParentValues(li);
            ControllerRicaviCtrl.updateRicavi();
        }
    }

    public void checkFasciaDayPart(){
        system.debug('checkFasciaDayPart');
        
        if(li.isFasciaOrariaEdit__c){
            system.debug('is fascia edit');
            li.Day_Part_Targeting_Type__c = 'Bands';
            
            DayPartTargeting__c[] dptList = [select dayOfWeek__c,Start_Hour__c,End_Hour__c from DayPartTargeting__c where LineItem__c =: li.id];
            Set<String> dptSet = new Set<String>();
            for(DayPartTargeting__c d : dptList){
                dptSet.add(d.dayOfWeek__c+d.Start_Hour__c+d.End_Hour__c);
            }
            
            if(li.Fascia_oraria__c == null || li.Fascia_oraria__c == ''){
                delete dptList;
            }else{
                DayPartTargeting__c[] dptNew = new DayPartTargeting__c[]{}; 
                Set<String> dptNewSet = new Set<String>();
                getDayPartBand(li,dptNewSet,dptNew);
                
                if(dptNewSet.size() != dptSet.size() || !dptNewSet.containsAll(dptSet)){
                    delete dptList;
                    insert dptNew;
                }
                
            }
        }
    }
    
    /*
        Usato anche in UtilityLineItemIntegration per creare day part targeting quando non ho salvato
    */
    public static void getDayPartBand(Lineitem__c li,Set<String> dptNewSet,DayPartTargeting__c[] dptNew){
        if(li.Fascia_oraria__c == null || li.Fascia_oraria__c == ''){
            return;
        }
        string startH = li.Fascia_oraria__c.split('-').get(0).trim();
        string endH = li.Fascia_oraria__c.split('-').get(1).trim();
        
        for(Schema.PicklistEntry pl : DayPartTargeting__c.dayOfWeek__c.getDescribe().getPicklistValues()){
            DayPartTargeting__c dpt = new DayPartTargeting__c();
            dpt.dayOfWeek__c = pl.getValue();
            dpt.Start_Minute__c = 'ZERO';
            dpt.Start_Hour__c = startH;
            dpt.End_Minute__c = 'ZERO';
            dpt.End_Hour__c = endH;
            dpt.LineItem__c = li.Id;
            dptNew.add(dpt); 
            dptNewSet.add(dpt.dayOfWeek__c+dpt.Start_Hour__c+dpt.End_Hour__c);
        }
        system.debug('dptNewSet: '+dptNewSet);
    }
    
    public lineItem__c getLineItemUpdated(){
        LineItem__c l = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
        l.sconto__c = li.sconto__c;
        l.Quantita__c = li.Quantita__c;
        l.Start_Minute__c = li.Start_Minute__c;
        l.Start_Hour__c = li.Start_Hour__c;
        l.Start_Date__c = li.Start_Date__c;
        l.Prezzo_net_net__c = li.Prezzo_net_net__c;
        l.Notes_dfp__c = li.Notes_dfp__c;
        l.End_Minute__c = li.End_Minute__c;
        l.End_Hour__c = li.End_Hour__c;
        l.End_Date__c = li.End_Date__c;
        l.totale__c = li.totale__c;
        l.Quantita_calcolata__c = li.Quantita_calcolata__c;
        l.goal__c = li.goal__c;
        l.goal_delivery__c = li.goal_delivery__c;
        l.Fascia_oraria__c = li.Fascia_oraria__c;
        l.Bacino_impressions__c = li.Bacino_impressions__c;
        l.BacinoImpressionsDisponibile__c = li.BacinoImpressionsDisponibile__c;
        l.PercentualeBacinoDisponibileOccupato__c = li.PercentualeBacinoDisponibileOccupato__c;
        l.ShareOfVoice__c = li.ShareOfVoice__c;
        /* NON POSSONO ESSERE MODIFICATI NELLA PAGINA
            l.Name_Dfp__c = li.Name_Dfp__c;        
            l.Height__c = li.Height__c;
            l.Width__c = li.Width__c;
            l.TimeZoneDay__c = li.TimeZoneDay__c;        
            l.Discount_Type__c = li.Discount_Type__c;
            l.Quantita_calcolata__c = li.Quantita_calcolata__c;
        */
        
        return l;
    }
    
    public boolean isBlank(String s){
        return (s == '' || s == null);
    }

    /*
    * Check if the value of LineItem__c.ADX_Placement_ID__c is unique among all the LineItems with the same date
    */
     public String checkADXPlacementUnivocity() {
        String result = null;
        if (li.ADX_Placement_ID__c == null) { return result; }
        List<LineItem__c> listLI = [SELECT Id, Name FROM LineItem__c WHERE ADX_Placement_ID__c = :li.ADX_Placement_ID__c AND Start_Date__c = :li.Start_Date__c AND Id != :li.Id];

        if (!listLI.isEmpty()) { //Duplicated value found
            result = '';
            for (LineItem__c itemLI : listLI) {
                result += itemLI.Name + ' (' + itemLI.Id + '), ';
            }
            result = result.substring(0, result.length()-2); //Removing last ", " characters
        }
        return result; //Null if OK
     }

//---TEST---
    @isTest
    static void testController() {
        
        Product2 p = new Product2(
            Name = 'Test',
            Family = 'Banner',
            BasePrice__c = 0,
            Breakeven_cost__c = 0       
        );
        insert p;
        
        Account a = utilityTest.insertBrand();
        
        Opportunity opp = new Opportunity(
            Name = 'Test opp',
            AccountId = a.id,
            StageName = 'Closed',
            CloseDate = System.today(),
            Commissione_Agenzia__c = 0
        );
        insert opp;          
        
        LineItem__c li = new LineItem__c(
            Product__c = p.Id,
            Opportunity__c = opp.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addMonths(2),  
            quantita__c = 1,      
            Ultima_modifica_prezzo__c='Totale',
            Type_dfp__c = 'STANDARD'
        );
        insert li;                   
        
        Date dataOdierna = Date.today();
        
        Date dataChiusuraRicavi = Date.newInstance(dataOdierna.year(),dataOdierna.month(),1);
        dataChiusuraRicavi = dataChiusuraRicavi.addMonths(-4).addDays(-1);
        
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = dataChiusuraRicavi;
        insert dataChiusuraRicavo;
        
        Test.startTest();    
        
        ApexPages.StandardController sc = new ApexPages.standardController(li);
        
        System.currentPageReference().getParameters().put('id', li.id);
        
        ExtensionEditLineItem ep = new ExtensionEditLineItem(sc);
        ep.li.delivery_model__c = 'CPD';
        SelectOption[] opts = ep.TypeDfpOptions;
        ep.li.delivery_model__c = 'CPM';
        opts = ep.TypeDfpOptions;
        ep.li.delivery_model__c = 'CPC';
        opts = ep.TypeDfpOptions;
        
        ep.gotoNext();
        ep.gotoPrevious(); 
        ExtensionEditLineItem.printLimits();
        ep.customSave();  
        ep.ControllerRevenueApplication.creaRevenueApplicationDaDate(); 
        ep.customSave();  
        ep.isBlank('test');
        ep.saveAndNew();
        ep.customCancel();      
        
        ep.ControllerRevenueApplication.revenueApplications.get(1).percentuale_applicata__c = 99;
        ep.ControllerRevenueApplication.updateRevenueApplication();
        ep.customSave();  
        System.debug('REVENES!!! ' + [SELECT Id, Line_Item__c, Valore__c, Mese__c, Percentuale_applicata__c FROM Revenue_Application__c]);      
        SYstem.debug(ep.ControllerRevenueApplication.revenueApplications);
        Test.stopTest();
        //ep.li.type_dfp__c = 'STANDARD';
        //ep.li.Delivery_Model__c = 'CPD';
     } 

     public PageReference undeleteLineItem(){
        li.Cancellato__c = false;
        update li;
        
        Id actualLineItemId = li.Id;
        PageReference pr = new PageReference('/' + actualLineItemId);
        pr.setRedirect(true);
        return pr;  
     } 

     public Static Datetime getDataFineLineItem(LineItem__c li){
        if(li.Id_DFP__c != null){
            DfpLineItemService.LineItemPage dfpResult = UtilityLineItemIntegration.getLineItemsByIds(new List<Decimal>{li.Id_DFP__c});
            for (DfpLineItemService.LineItem result : dfpResult.results) {
                if(result.id == li.Id_DFP__c){
                    return Datetime.newInstance(result.endDateTime.date_x.year,result.endDateTime.date_x.month,result.endDateTime.date_x.day,result.endDateTime.hour,result.endDateTime.minute,result.endDateTime.second);
                }
            }
        }else if(li.Id_oas__c != null){
            OasIntegration oas = new OasIntegration();
            for(oasIntegration.campaignClass c : oas.getCampaignClass(oas.readCampaignById(li.Id_oas__c),false)){ //use string methods instead of regex 
                if(c.id == li.Id_oas__c){
                    Integer year = Integer.valueOf(c.EndDate.split('-')[0]);
                    Integer month = Integer.valueOf(c.EndDate.split('-')[1]);
                    Integer day = Integer.valueOf(c.EndDate.split('-')[2]);
                    return Datetime.newInstance(year,month,day,Integer.valueOf(li.End_Hour__c),Integer.valueOf(li.End_Minute__c),0);
                    
                }
            }
        }
        return null;
    }
     
     public class LineItemException extends Exception{}
}