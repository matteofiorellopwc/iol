public with sharing class ExtensionDeleteFromDfp {
    public Boolean hasErrors {get;set;}
    private SObject record; //Può essere Opportunity, LineItem o Pacchetto
    private Boolean isOpportunity;
    private Boolean isPacchetto;
    private Boolean isLineItem;
    private Boolean oneItemSynch;
    
    public ExtensionDeleteFromDfp(ApexPages.StandardController controller) {
        this.record = controller.getRecord();
        this.hasErrors = false;
        
        //Controlla se il record da eliminare è un Opportunity
        this.isOpportunity = ((Id) controller.getId()).getSObjectType() == Opportunity.SObjectType;
        
        //Controlla se il record da eliminare è un Pacchetto
        this.isPacchetto = ((Id) controller.getId()).getSObjectType() == Pacchetto_Combo_Opportunity__c.SObjectType;

        //Controlla se il record da eliminare è un LineItem
        this.isLineItem = ((Id) controller.getId()).getSObjectType() == LineItem__c.SObjectType;
    }
	
	/* Metodo che viene invocato al caricamento della pagina */
    public PageReference init() {
    	//Viene controllato che l'utenta abbia i permessi per cancellare il Line-Item
        Boolean canDelete = [SELECT RecordId, HasDeleteAccess FROM UserRecordAccess 
        					 WHERE UserId =: UserInfo.getUserId() AND RecordId =: record.Id
        					].HasDeleteAccess;
        
        //Se non si hanno i permessi apparirà un messaggio d'errore a video
        if(!canDelete) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lei non ha i diritti per effettuare questa operazione'));
            hasErrors = true;
            return null;
        }

        if(isOpportunity){
            return initOpportunity();
        }else if(isPacchetto){
            return initPacchetto();
        }else if(isLineItem){
            return initLineItem();
        }

        return null;
    
    }

    public PageReference initOpportunity(){
        System.SavePoint sp = Database.setSavePoint();
        PageReference pr = null;
        try{
            pr = deleteSfdcObj('physical');
        }catch(Exception e){
            ApexPages.addMessages(e);
            hasErrors = true;
        }finally{
            if(isSync(record)){
                Database.rollback(sp);
            }else{
                return pr;
            }
        }
        return null;
    }

    public PageReference initLineItem(){
        PageReference pr = null;
        if(isSync(record)){
            Boolean erogato = getErogatoLineItem() > 0;
            Boolean lineItemSuMesiChiusi = !ControllerRicavi.isLineItemSoloSuMesiAperti( (LineItem__c) record );
            if(erogato || lineItemSuMesiChiusi){ // se ha erogato, o ha ricavi su mesi chiusi non può essere cancellato
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Questo line item non può essere cancellato. Possono essere cancellati solo line items che non hanno erogato impressions e che non hanno ricavi su mesi chiusi.'));
                hasErrors = true;
                return pr;
            }
        }
        System.SavePoint sp = Database.setSavePoint();
        try{
            pr = deleteSfdcObj('physical');
            if(isClosedWonAtLeastOnce(record)){
                Database.rollback(sp);
                sp = Database.setSavePoint();
                pr = deleteSfdcObj('logical');
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
            hasErrors = true;
        }finally{
            if(isSync(record)){
                Database.rollback(sp);
            }else{
                return pr;
            }
        }
        return null;
    }



    private Decimal getErogatoLineItem(){
        Decimal erogato = null;
        LineItem__c lineItem = (LineItem__c) record;
        if(!Test.isRunningTest()){
            if(lineItem.Id_DFP__c != null){
                DfpLineItemService.LineItemPage dfpResult = UtilityLineItemIntegration.getLineItemsByIds(new List<Decimal>{lineItem.Id_DFP__c});
                for (DfpLineItemService.LineItem result : dfpResult.results) {
                    if(result.id == lineItem.Id_DFP__c){
                        erogato = result.stats != null ? result.stats.impressionsDelivered : 0;
                        break;
                    }
                }
            }else if(lineItem.Id_oas__c != null){
                OasIntegration oas = new OasIntegration();
                for(oasIntegration.campaignClass c : oas.getCampaignClass(oas.listCampaignsByOrderId(lineItem.Opportunity__r.Id_oas__c),false)){ //use string methods instead of regex 
                    if(c.id == lineItem.Id_oas__c){
                        erogato = decimal.valueOf(c.ImpDelivered != null && c.ImpDelivered != '' ? c.ImpDelivered : '0') ;
                        break;
                    }
                }
            }
        }else{
            erogato = 0;
        }
        return erogato;
    }

    public PageReference initPacchetto(){
        if(Test.isRunningTest() && record.get('Cancellato__c')==null){
            record.put('Cancellato__c',false);
        }
        System.SavePoint sp = Database.setSavePoint();
        PageReference pr = null;
        try{
            oneItemSynch = false;
            pr = deleteSfdcObj('physical');
            if(isClosedWonAtLeastOnce(record)){
                Database.rollback(sp);
                pr = deleteSfdcObj('logical');
                Id pacchettoId = (Id) record.get('Id');
                List<LineItem__c> lineItemsOfPacchetto = [SELECT Name, id_DFP__c, Id_oas__c FROM LineItem__c WHERE Pacchetto_Combo_Opportunity__c = :pacchettoId];
                for(LineItem__c li : lineItemsOfPacchetto) {
                    li.Cancellato__c = true;
                    if(isSync(li)){
                        oneItemSynch = true;
                    }
                }   
                update lineItemsOfPacchetto;
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
            hasErrors = true;
        }finally{
            if(oneItemSynch){
                Database.rollback(sp);
            }else{
                return pr;
            }
        }
        return null;
    }

    public boolean isClosedWonAtLeastOnce(SObject record){
        Datetime dataPrimaChiusaVinta = null;
        if(record.getSObjectType().getDescribe().getName() == 'LineItem__c'){
            LineItem__c li = (LineItem__c) record;
            dataPrimaChiusaVinta = li.Opportunity__r.DataPrimaChiusaVinta__c;
        }else if(record.getSObjectType().getDescribe().getName() == 'Pacchetto_Combo_Opportunity__c'){
            Pacchetto_Combo_Opportunity__c pa = (Pacchetto_Combo_Opportunity__c) record;
            dataPrimaChiusaVinta = pa.Opportunity__r.DataPrimaChiusaVinta__c;
        } 
        return dataPrimaChiusaVinta != null;
    }

    public boolean isSync(SObject record){
        return record.get('id_DFP__c') != null || (record.get('Id_oas__c') != null && ! ((string)record.get('Id_oas__c')).contains('_nosincro'));
    }


    public PageReference deleteOpportunity(){
        //Se integrato con dfp cancello da dfp, se integrato con oas cancello da oas poi cancello su sfdc
        try{
            if(record.get('id_DFP__c') != null) {
                //Cancello l'opportunity da DFP
                if(!Test.isRunningTest()) UtilityOrderIntegration.deleteOrders(new List<Decimal>{ (Decimal) record.get('id_DFP__c') });
            }
            if(record.get('Id_Oas__c') != null && !((string)record.get('Id_oas__c')).contains('_nosincro')) {
                //Cancello l'opportunity da OAS                    
                if(!Test.isRunningTest()) {
                    OasIntegration oas = new OasIntegration();
                    oas.deleteOrder((string)record.get('Id_Oas__c'));
                }
            }
            //Cancello l'oggetto sfdc                
            return deleteSfdcObj('physical');  
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la cancellazione su DFP: ' + UtilExceptionIntegration.getFriendlyMessage(e.getMessage())[0].message));
            hasErrors = true;
        }
        return null;
    }

    public PageReference deletePacchetto(){
        try{
            if(isClosedWonAtLeastOnce(record)){ // cancellazione logica
                deletePacchettoLineItems('logical');
                return deleteSfdcObj('logical');
            }else{  // cancellazione fisica
                deletePacchettoLineItems('physical');
                return deleteSfdcObj('physical');
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
            hasErrors = true;
        }
        return null;
    }
    
    /**
    * Se il line item è sincronizzato con l'ad server, allora viene cancellato logicamente, al chiudi vinci viene anche archiviato sull'ad server.
    * Se il line item non è sincronizzato con l'ad server, viene cancellato direttamente da Salesforce
    * La differenza tra dfp e oas è che se il line item è su dfp qui viene solo cancellato logicamente (flag su record), se è su oas viene anche sospeso
    * al chiudi vinci i line item cancellati logicamente vengono archiviati sull'ad server, quelli su oas vengono cancellati dall'ad server.
    */
    public PageReference deleteLineItem(){
        PageReference pr = null;
        try{
            LineItem__c li = (LineItem__c) record;
            if(li.Opportunity__r.DataPrimaChiusaVinta__c != null && isSync(li)){
                try{
                    if(!Test.isRunningTest() && li.Id_Oas__c != null){ // line item su OAS
                        OasIntegration oas = new OasIntegration();
                        oas.updateCampaignsStatus(new String[]{(String)li.Id_Oas__c},OasIntegration.OAS_STATUS.get('Suspended')); 
                    }
                }catch(Exception e){}
                pr = deleteSfdcObj('logical');
            }else{
                if(record.get('Id_Oas__c') != null && !((string)record.get('Id_oas__c')).contains('_nosincro')) { //Cancello il lineitem da OAS
                    OasIntegration oas = new OasIntegration();
                    oas.deleteCampaign((string)record.get('Id_Oas__c'));    
                }
                pr = deleteSfdcObj('physical');
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la cancellazione del line item: ' + UtilExceptionIntegration.getFriendlyMessage(e.getMessage())[0].message));
            hasErrors = true;
        }            
        return pr;
    }

    public PageReference deleteSfdcAndDfpObj() {
        
        if(isOpportunity){
            return deleteOpportunity();
        }else if(isPacchetto){
            return deletePacchetto();
        }else if(isLineItem){
            return deleteLineItem();
        }
        return null;                            
    }
    
    
    public PageReference deleteSfdcObj(String deletionType) {        
        if(deletionType == 'physical'){
            delete record;
        }else if(deletionType == 'logical'){
            record.put('Cancellato__c',true);
            update record;
        }
        return new PageReference(ApexPages.CurrentPage().getParameters().get('retURL'));        
    }
    
    public PageReference back() {   
        if(isOpportunity) {             
            return new PageReference('/' + record.Id);
        } else {
            return new PageReference('/' + record.get('Opportunity__c'));
        }
    }
    
    private void deletePacchettoLineItems(String deletionType) { 
        System.debug(LoggingLevel.WARN,'Chiamato deletePacchettoLineItems() con deletionType: '+deletionType);
        Id pacchettoId = (Id) record.get('Id');
        List<LineItem__c> lineItemsPacchetto = new List<LineItem__c>(); //Lista line-items del Pacchetto
        List<Decimal> lineItemsPacchettoDfp = new List<Decimal>(); //Lista line-items DFP del Pacchetto
        List<String> lineItemsPacchettoOas = new List<String>(); //Lista line-items OAS del Pacchetto
        lineItemsPacchetto = [SELECT Name, id_DFP__c, Id_oas__c FROM LineItem__c WHERE Pacchetto_Combo_Opportunity__c = :pacchettoId];
        for(LineItem__c li:lineItemsPacchetto) {
            if(li.Id_DFP__c != null) {
                lineItemsPacchettoDfp.add(li.id_DFP__c);
            }
            if(li.Id_oas__c != null && !(li.Id_oas__c.contains('_nosincro'))) {
                lineItemsPacchettoOas.add(li.Id_oas__c);    
            }       
        }
        if(deletionType == 'physical'){
        	
        	//Cancello i line-items da DFP
            if(!Test.isRunningTest()) {
            	UtilityLineItemIntegration.deleteLineItems(lineItemsPacchettoDfp);
            }
            
            //Cancello il line-items da OAS
            OasIntegration oas = new OasIntegration();
            oas.deleteCampaigns(lineItemsPacchettoOas); 

        }else if(deletionType == 'logical'){
            System.debug(LoggingLevel.WARN,'LOGICAL');
            if(!Test.isRunningTest()) {
                UtilityLineItemIntegration.pauseLineItems(lineItemsPacchettoDfp);
            }
            
            OasIntegration oas = new OasIntegration();
            oas.updateCampaignsStatus(lineItemsPacchettoOas,OasIntegration.OAS_STATUS.get('Suspended'));   

            for(LineItem__c li : lineItemsPacchetto){
                li.Cancellato__c = true;
            }
            System.debug(LoggingLevel.WARN,'PRE-UPDATE');
            update lineItemsPacchetto;
            System.debug(LoggingLevel.WARN,'UPDATE');

        }
    }
    
    //************* TEST *************//

    
    @isTest
    static void testDeleteOpportunity() {

        Opportunity o = new Opportunity(Name = 'Test', Stagename = '0%', CloseDate = Date.Today(), id_DFP__c = 123456);
        insert o;

        Test.setCurrentPage(new PageReference('/apex/DeleteOpportunity?id=' + o.Id + '&retURL=/apex/DeleteOpportunity'));
        ExtensionDeleteFromDfp ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(o));
        PageReference pr = ext.init();
        System.assertEquals(null, pr);
        
        pr = ext.back();        
        
        ext.deleteSfdcAndDfpObj();
        List<Opportunity> oL = [SELECT Id FROM Opportunity];
        System.assertEquals(true, oL.isEmpty());

        o = new Opportunity(Name = 'Test', Stagename = '0%', CloseDate = Date.Today());
        insert o;
        Test.setCurrentPage(new PageReference('/apex/DeleteOpportunity?id=' + o.Id + '&retURL=/apex/DeleteOpportunity'));
        ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(o));
        pr = ext.init();
        System.assertNotEquals(null, pr);
    }
    
    @isTest
    static void testDeleteLineItem() {

        Date dataOdierna = Date.today();
        Date dataChiusuraRicavi = Date.newInstance(dataOdierna.year(), dataOdierna.month(), 1).addMonths(-7);
        dataChiusuraRicavi = dataChiusuraRicavi.addMonths(-10);
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c(
                                Name = 'nazionale',
                                data__c = dataChiusuraRicavi 
        );
        insert dataChiusuraRicavo;
        
        // La data di chiusura dei ricavi local è creata qui solo per correttezza, non utilizzata nel test ma va in errore se tolta perché ci sono controlli su questa data
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c(
                                Name = 'local',
                                data__c = dataChiusuraRicavi 
        );
        insert dataChiusuraRicavoLocal;

        Opportunity o = new Opportunity(Name = 'Test', Stagename = 'Chiusa Vinta – in modifica', CloseDate = Date.Today(), id_DFP__c = 123456, DataPrimaChiusaVinta__c = Date.today());
        insert o;
        LineItem__c li = new LineItem__c(Opportunity__r = o, Opportunity__c = o.Id, id_DFP__c = 123456);
        insert li;

        Test.setCurrentPage(new PageReference('/apex/DeleteLineItem?id=' + li.Id + '&retURL=/apex/DeleteLineItem'));
        ExtensionDeleteFromDfp ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(li));
        PageReference pr = ext.init();
        
        System.assertEquals(null, pr); 
        System.assertEquals(false,[SELECT Cancellato__c FROM LineItem__c WHERE Id =:li.Id].Cancellato__c);   

        ext.deleteSfdcAndDfpObj();
        System.assertEquals(true,li.Cancellato__c);              

        Opportunity o1 = new Opportunity(Name = 'Test', Stagename = '0%', CloseDate = Date.Today());
        insert o1;
        LineItem__c li1 = new LineItem__c(Opportunity__r = o1, Opportunity__c = o1.Id);
        insert li1;

        ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(li1));
        pr = ext.init();
        System.assertNotEquals(null, pr);  
        System.assertEquals(true,[SELECT Id FROM LineItem__c WHERE Id = :li1.Id].isEmpty());
    
    }    

    @isTest
    static void testDeletePacchetto(){

        System.debug(LoggingLevel.WARN,'TEST: testDeletePacchetto()');
        Opportunity opp = new Opportunity(Name = 'Opportunità Test', Stagename = '0%', CloseDate = Date.Today());
        insert opp;

        Pacchetto_Combo_Opportunity__c pacchetto = new Pacchetto_Combo_Opportunity__c(Name = 'Pacchetto Test', Opportunity__c = opp.Id, Opportunity__r = opp);
        insert pacchetto;

        LineItem__c li1 = new LineItem__c(Opportunity__r = opp, Opportunity__c = opp.Id, Pacchetto_Combo_Opportunity__c = pacchetto.Id, Pacchetto_Combo_Opportunity__r = pacchetto);
        insert li1;

        LineItem__c li2 = new LineItem__c(Opportunity__r = opp, Opportunity__c = opp.Id, Pacchetto_Combo_Opportunity__c = pacchetto.Id, Pacchetto_Combo_Opportunity__r = pacchetto);
        insert li2;

        Test.setCurrentPage(new PageReference('/apex/DeletePacchetto?id=' + pacchetto.Id + '&retURL=/apex/DeletePacchetto'));
        ExtensionDeleteFromDfp ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(pacchetto));
        PageReference pr = ext.init();

        System.assertNotEquals(null,pr);
        System.assertEquals(true,[SELECT Id FROM Pacchetto_Combo_Opportunity__c WHERE Id = :pacchetto.Id].isEmpty());
        System.assertEquals(true,[SELECT Id FROM LineItem__c WHERE Pacchetto_Combo_Opportunity__c = :pacchetto.Id].isEmpty());

        
        

    }
    @isTest
    static void testDeletePacchetto2(){
    	System.debug(LoggingLevel.WARN,'TEST: testDeletePacchetto()');
        Opportunity opp = new Opportunity(Name = 'Opportunità Test', Stagename = '0%', CloseDate = Date.Today());
        insert opp;    	
    	Pacchetto_Combo_Opportunity__c pacchetto = new Pacchetto_Combo_Opportunity__c(Name = 'Pacchetto Test', Opportunity__c = opp.Id, Opportunity__r = opp);
        insert pacchetto;
    	
    	ExtensionDeleteFromDfp ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(pacchetto));
    	PageReference pr = ext.init();
    Opportunity oppChiusa = new Opportunity(Name = 'Opportunità Chiusa Test', Stagename = 'Chiusa Vinta – in modifica', CloseDate = Date.Today(), id_DFP__c = 123456, DataPrimaChiusaVinta__c = Date.today());
        insert oppChiusa;

        Pacchetto_Combo_Opportunity__c pacchettoChiuso = new Pacchetto_Combo_Opportunity__c(Name = 'Pacchetto Chiuso Test', Opportunity__c = oppChiusa.Id, Opportunity__r = oppChiusa, Cancellato__c = false);
        insert pacchettoChiuso;

        LineItem__c li3 = new LineItem__c(Opportunity__r = oppChiusa, Opportunity__c = oppChiusa.Id, Pacchetto_Combo_Opportunity__c = pacchettoChiuso.Id, Pacchetto_Combo_Opportunity__r = pacchettoChiuso, id_DFP__c = 123456);
        insert li3;

        LineItem__c li4 = new LineItem__c(Opportunity__r = oppChiusa, Opportunity__c = oppChiusa.Id, Pacchetto_Combo_Opportunity__c = pacchettoChiuso.Id, Pacchetto_Combo_Opportunity__r = pacchettoChiuso, id_DFP__c = 123456);
        insert li4;        

        Test.setCurrentPage(new PageReference('/apex/DeletePacchetto?id='+pacchettoChiuso.Id+'&retURL=/apex/DeletePacchetto'));
        ext = new ExtensionDeleteFromDfp(new ApexPages.StandardController(pacchettoChiuso));

        System.debug(LoggingLevel.WARN,'PACCHETTO: '+pacchettoChiuso+', Cancellato__c: '+pacchettoChiuso.Cancellato__c);
        pr = ext.init();
        System.debug(LoggingLevel.WARN,'Post init(). PACCHETTO: '+pacchettoChiuso+', Cancellato__c: '+pacchettoChiuso.Cancellato__c);

        System.assertEquals(null, pr);
        System.assertEquals(false,li3.Cancellato__c);
        System.assertEquals(false, li4.Cancellato__c);

        ext.deletePacchetto();
    }
}