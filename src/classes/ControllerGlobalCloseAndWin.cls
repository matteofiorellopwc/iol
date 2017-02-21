global without sharing class ControllerGlobalCloseAndWin {
    
    public Id Id {get;set;}
    public Opportunity o {get;set;}

    
    global class stepResponse{
        global boolean isError {get;set;}
        global string message {get;set;}
        global stepResponse(){
            isError = false;
            message = '';
        }
        global stepResponse(boolean isError,string message){
            this.isError = isError;
            this.message = message;
        }
    }
    
    /*
    * 
    */
    public ControllerGlobalCloseAndWin(){
        Id = ApexPages.currentPage().getParameters().get('id');
        //For showing flag in page
        o = [SELECT Id, SkipDispoCpd__c FROM Opportunity WHERE Id =: Id];
    }

    
    /*
    
    */
    public PageReference saveAndReload(){
        update o;
        return null;
    }
    
    /**
    * This is the first step called. Ad Server DFP require the opportunity must be approved even if at least one line item must be approved. 
    * Checks over the existence of line items not approved will be made in next steps, this step simply ensure that at the time of closing the opportunity, 
    * all line items for this opportunity have updated values related to overbooking. 
    * For each line item, we get the updated forecast from dfp and update the related field in salesforce, for future overbook checks.
    */
    @RemoteAction
    global static stepResponse chiudiEVinciStep0(String arg){
        StepResponse stepResponse= new StepResponse();
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep0 - START *******');  

        // CLAUDIO ARADO 09/01/2017 B
        //Opportunity opportunity = [SELECT StageName,HiddenValidation__c,Profili_conferma_dfp__c,isWon,skipDispoCpd__c
        Opportunity opportunity = [SELECT StageName,HiddenValidation__c,Profili_conferma_dfp__c,isWon,skipDispoCpd__c, Account.id_dfp__c, Account.Anagrafica_per_Test__c
                         From Opportunity 
                         WHERE Id=:arg];

        if((opportunity.Account.id_dfp__c == null) && (opportunity.Account.Anagrafica_per_Test__c == FALSE))
        	return new stepResponse(true,'E\' necessario sincronizzare il brand con DFP, prima di procedere');
        // 09/01/2017 E
       
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile where Id =:id1].Name;
        
        boolean canEdit = [select RecordId,HasEditAccess from UserRecordAccess where UserId =: UserInfo.getUserId() and RecordId =: opportunity.id].HasEditAccess;
        
        if(opportunity.isWon){
            return new stepResponse(true,'L\'Opportunità è già in stato chiusa vinta');
        }else if(!canEdit){
            return new stepResponse(true,'Non si ha il permesso di modificare questa Opportunità');             
        }else if(opportunity.Profili_conferma_dfp__c==null || !opportunity.Profili_conferma_dfp__c.contains(profileName)){            
            return new stepResponse(true,'Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportunità'); 
        }
              
		
        // Aggiorno i dati di forecast solo per i line items che hanno un overbook non approvato o non hanno un bacino riservato da un precedente close&win
        List<LineItem__c> lineItems = [ SELECT Id,Name,Id_dfp__c,Opportunity__r.Id_DFP__c,Delivery_Model__c,DisableSameAdvertiserCompetitiveExclusio__c,Target_platform__c,
                                                Bacino_impressions__c,BacinoImpressionsDisponibile__c,Bacino_modificato__c,ShareOfVoice__c,Quantita__c,PercentualeBacinoDisponibileOccupato__c,
                                                Prezzo_net_net__c,RoadblockingType__c,CreativeRotationType__c,DeliveryRateType__c,AutoExtensionDays__c,Type_DFP__c,Notes_dfp__c,Priority_formula__c,
                                                Start_Date__c,Start_Hour__c,Start_Minute__c,End_Date__c,End_Hour__c,End_Minute__c,Name_Dfp__c,Width__c,Height__c,Multisize__c,Product__r.IsAspectRatio__c,
                                                IsFasciaOrariaEdit__c,Fascia_oraria__c,TimeZoneDay__c
                                        FROM LineItem__c 
                                        WHERE Opportunity__c = :opportunity.Id 
                                        AND CheckUtilizzoSOV__c = true
                                        AND OverbookApprovato__c = false
                                        AND BacinoRiservato__c = false]; 
        Savepoint sp = null;
        DfpIntegration dfp = new DfpIntegration();
        try{
            for(LineItem__c lineItem : lineItems){
                ControllerForecast.Forecast forecast = null;
                if(!Test.isRunningTest()){
                    forecast = ControllerForecast.staticCheckAvailability(dfp,lineItem);
                }else{
                    forecast = new ControllerForecast.Forecast();
                    //forecast.matchedUnits = 1000000 + Math.roundToLong((1000000 * Math.random()));
                    forecast.matchedUnits = 1000000;
                    forecast.availableUnits = (Long) (forecast.matchedUnits * 0.6);
                }
                if(forecast != null){
                    lineItem.Bacino_impressions__c = forecast.matchedUnits; 
                    if(lineItem.Bacino_impressions__c == null){
                        lineItem.Bacino_impressions__c = 0;
                    }
                    lineItem.BacinoImpressionsDisponibile__c = forecast.availableUnits;
                    if(lineItem.BacinoImpressionsDisponibile__c == null){
                        lineItem.BacinoImpressionsDisponibile__c = 0;
                    }
                    lineItem.Bacino_modificato__c = false;
                    if(lineItem.ShareOfVoice__c == null){
                        lineItem.ShareOfVoice__c = 0;
                    }
                    lineItem.Quantita__c = (Integer) (lineItem.Bacino_impressions__c * lineItem.ShareOfVoice__c / 100);
                    if(lineItem.BacinoImpressionsDisponibile__c > 0){
                        lineItem.PercentualeBacinoDisponibileOccupato__c = (lineItem.Quantita__c / lineItem.BacinoImpressionsDisponibile__c) * 100;
                    }else{
                        lineItem.PercentualeBacinoDisponibileOccupato__c = 0;
                    }
                }else{
                    stepResponse.isError = true;
                    stepResponse.message = 'Errore durante il calcolo del bacino CPM per il line item '+lineItem.Name;
                    break;
                }

            }
            sp = Database.setSavepoint();
            if(lineItems.size() > 0 && !stepResponse.isError){
                update lineItems;
                update opportunity;

            }              
        }catch(Exception e){
            if(sp != null){
                Database.rollback(sp);
            }
            stepResponse.isError = true;
            stepResponse.message = e.getMessage();
            System.debug(e.getStackTraceString());
        }
        
      
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep0 - STOP *******');  
        //return stepResponse;
        return new StepResponse();
    }

    /**
    * Purpouse of the first step is to try and save the opportunity, if all is successful
    * roll back and continue, else, throw exception so that on the javascript side we'll have
    * event.status == false
    */
    @RemoteAction
    global static stepResponse chiudiEVinciStep1(String arg){
        stepResponse stepResponse = new stepResponse();
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep1 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        //Notice also that I don't try/catch because I want exception to be thrown.
        //the excpetion message will be put in the event.message javascript component
        
        //save db status
        Savepoint sp = Database.setSavepoint();
        Opportunity o = [SELECT StageName,HiddenValidation__c,Profili_conferma_dfp__c,isWon,skipDispoCpd__c
                         From Opportunity 
                         WHERE Id=:arg];
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile where Id =:id1].Name;
        
        boolean canEdit = [select RecordId,HasEditAccess from UserRecordAccess where UserId =: UserInfo.getUserId() and RecordId =: o.id].HasEditAccess;
        



        if(!canEdit){
            return new stepResponse(true,'Non si ha il permesso di modificare questa Opportunità');             



        }else {
            //Check revenue, Check ricavi
            //add pagemessage if there are issues            
            String lineItemsString = '';                
            LineItem__c[] liL = [SELECT Id, Incoerenze_revenue_application__c, IncoerenzeRicavi__c, 
                                        isCustomCriteriaEdit__c,product__r.CanalePrimario__c,
                                        Nome_DFP__c,SpecificazioneProdottoVuotoCheck__c,Line_Item_Ripianificato__c,
                                    (SELECT Id FROM Ricavi__r),
                                    (SELECT Id FROM Revenue_Applications__r) 
                                FROM LineItem__c 
                                WHERE Opportunity__c = :o.Id];
            
            Map<Id,Boolean> audienceSegmentErrorMap = UtilityCustomTargeting.checkErrorAudienceSegment(liL);
            
            Boolean foundError = false;
            for(LineItem__c li : liL) {
                /*
                    ho errore se:
                    - incoerenze revenue non è vuoto
                    - non ho revenue e non è un line item di ripianificazione
                */
                if(
                    ((li.Line_Item_Ripianificato__c == null && li.Revenue_Applications__r.isEmpty()) || !String.isBlank(li.Incoerenze_revenue_application__c)) 
                    ||
                    (li.Ricavi__r.isEmpty() || (li.IncoerenzeRicavi__c != '' && li.IncoerenzeRicavi__c != null)) 
                ) {
                    foundError = true;  
                    if(lineItemsString != '') lineItemsString += ', ';
                    lineItemsString += li.Nome_DFP__c;
                }
            }
            if(foundError) {
                return new stepResponse(true,'I seguenti lineitems presentano errori su ricavi o '+System.Label.RevenueApplications+': ' + lineItemsString);
            } 

            //Check obbligatorietà del campo "Specificazione prodotto"
            lineItemsString = '';
            for(LineItem__c li : liL) {
                if(li.SpecificazioneProdottoVuotoCheck__c) {
                    foundError = true;  
                    if(lineItemsString != '') lineItemsString += '<br />';
                    lineItemsString += li.Nome_DFP__c;
                }
            }
            if(foundError) {
                return new stepResponse(true,'I seguenti lineitems non hanno compilato il campo Specificazione prodotto:<br />' + lineItemsString);     
            }
            
            //Check obbligatorietà dei Custom Criteria
            lineItemsString = '';            
            for(LineItem__c li : liL){
                if(audienceSegmentErrorMap.get(li.id)){
                    foundError = true;  
                    if(lineItemsString != '') lineItemsString += '<br />';
                    lineItemsString += li.Nome_DFP__c;
                }
            }
            if(foundError) {
                return new stepResponse(true,'I seguenti lineitems non hanno custom criteria associati:<br />' + lineItemsString);     
            }
            

            /*
            if(!o.skipDispoCpd__c){
                ControllerCpdAvailability.checkAvailabilityLineItems(UtilityLineItemIntegration.getLineItemsByOppId(o.id,false));
    
                if(ApexPages.getMessages()!=null && ApexPages.getMessages().size()!=0){
                    String errors = '';  
                    for(ApexPages.Message m : ApexPages.getMessages()){
                        errors+=m.getSummary(); 
                    }
                    return new stepResponse(true,errors);
                }
            }
            */

            List<Pacchetto_Combo_Opportunity__c> pacchettiToCancel = [SELECT Id FROM Pacchetto_Combo_Opportunity__c WHERE Cancellato__c = true AND Opportunity__c=:arg ]; 
            delete pacchettiToCancel;
            List<LineItem__c> lineItemsToDelete = new List<LineItem__c>();
            List<LineItem__c> lineItemsToDeleteRipianificati = new List<LineItem__c>();
            
            //Non posso cancellare un line item se ha ripianificazioni non cancellate
            lineItemsString = '';
            for(LineItem__c li : [SELECT Id,Line_Item_Ripianificato__c,Line_Item_Ripianificato__r.Cancellato__c,Line_Item_Ripianificato__r.Nome_DFP__c,(select id from line_items__r where Cancellato__c = false) FROM LineItem__c WHERE Cancellato__c = true AND Opportunity__c=:arg]){
                if(!li.line_items__r.isEmpty()){
                    if(lineItemsString != '') lineItemsString += '<br />';
                    lineItemsString += li.Nome_DFP__c;
                    foundError = true; 
                }
                
                if(li.Line_Item_Ripianificato__c != null){
                    if(li.Line_Item_Ripianificato__r.Cancellato__c){
                        lineItemsToDeleteRipianificati.add(li);
                    }else{
                        if(lineItemsString != '') lineItemsString += '<br />';
                        lineItemsString += li.Line_Item_Ripianificato__r.Nome_DFP__c;
                        foundError = true; 
                    }
                }else{
                    lineItemsToDelete.add(li);
                }
            }
            
            if(foundError) {
                return new stepResponse(true,'I seguenti lineitems non possono essere cancellati perchè sono stati ripianificati:<br />' + lineItemsString);     
            }
                        
            delete lineItemsToDeleteRipianificati;
            delete lineItemsToDelete;
            

            o.StageName = 'Chiusa vinta'; 
            o.HiddenValidation__c=true;
            try{
                update o;
            }catch(DMLException e){
                //for validation rule show only message
                Database.rollback(sp);      
                return new stepResponse(true,e.getDmlMessage(0));          
            }
        }
        //rollback        
        Database.rollback(sp);      
        
        
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep1 - STOP *******');  
        return stepResponse;   
    } 
    
    /**
    * Step 2 DFP:
    * This methods decides whether to approve or just upsert an Opportunity to remote DFP server
    */
    @RemoteAction
    global static stepResponse chiudiEVinciStep2(String arg){
        UtilSkipTrigger.skipCheckNotificheOAS = true;
        stepResponse stepResponse = new stepResponse();
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep2 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        
        Opportunity o = [SELECT Id, status__c, Profili_conferma_dfp__c,id_dfp__c FROM Opportunity WHERE id=:arg ];
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();       
        String profileName = [Select Name from Profile where Id =:id1].Name;
        if(o.Profili_conferma_dfp__c==null || !o.Profili_conferma_dfp__c.contains(profileName)){            
            return new stepResponse(true,'Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportunità'); 
        } else {        
            
            List<LineItem__c> lineItemsToCancel = [SELECT Id, Id_DFP__c FROM LineItem__c WHERE Cancellato__c = true AND Id_DFP__c != NULL AND Opportunity__c=:arg];
            List<decimal> lineItemsToDelete = new list<decimal>();
            for(LineItem__c lineItemToCancel : lineItemsToCancel){
                lineItemsToDelete.add(lineItemToCancel.Id_DFP__c);
            }
            DfpIntegration dfp = new DfpIntegration();
            if(lineItemsToDelete.size()>0){
                UtilityLineItemIntegration.pauseLineItems(lineItemsToDelete,dfp);
                UtilityLineItemIntegration.archiveLineItems(lineItemsToDelete,dfp);
            }
            ExtensionOpportunityIntegration eoi = new ExtensionOpportunityIntegration(arg,dfp);

            //I don't try to sync opp if it hasn't line items for DFP
            System.debug(LoggingLevel.WARN,'sfdcLineItems: '+eoi.sfdcLineItems.size());
            if(o.id_dfp__c > 0 || eoi.sfdcLineItems.size() > 0 ){
                eoi.upsertOrderSfdcToDfp(true);
              
                //Friendly error messages ---->
                //the methods called add userfriendly messages in ApesPages.Messages.
                //in order for the VF remoting to read this messages I need to put them into an 
                //exception and throw it. The message of the exception will be written into the
                //javascript component event.message
                if(ApexPages.getMessages()!=null && ApexPages.getMessages().size()!=0){
                    String errors = '';  
                    for(ApexPages.Message m : ApexPages.getMessages()){
                        errors+=m.getSummary(); 
                    }
                    return new stepResponse(true,errors);
                }
            }
        }
     
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep2 - STOP *******');  
        return stepResponse;        
    }
    
    /**
    * Step 3 OAS:
    * This methods decides whether to approve or just upsert an Opportunity to remote OAS server
    */
    @RemoteAction
    global static stepResponse chiudiEVinciStep3(String arg){
        stepResponse stepResponse = new stepResponse();
        return new stepResponse(false,'');
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep3 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        
        Opportunity o = [SELECT Id, status__c, Profili_conferma_dfp__c,id_oas__c FROM Opportunity WHERE id=:arg ];
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();       
        String profileName = [Select Name from Profile where Id =:id1].Name;
        if(o.Profili_conferma_dfp__c==null || !o.Profili_conferma_dfp__c.contains(profileName)){            
            return new stepResponse(true,'Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportunità'); 
        } else {        

            OasIntegration oasInt = new OasIntegration();
            List<LineItem__c> lineItemsToCancel = [SELECT Id, Id_Oas__c FROM LineItem__c WHERE Cancellato__c = true AND Id_Oas__c != NULL AND Opportunity__c=:arg];
            List<String> idsOasToCancel = new List<String>();
            for(LineItem__c lineItemToCancel : lineItemsToCancel){
                idsOasToCancel.add((String)lineItemToCancel.Id_Oas__c);
            }
            if(idsOasToCancel.size()>0){
                oasInt.deleteCampaigns(idsOasToCancel);    
            }
            
            ExtensionOpportunityOasIntegration oas = new ExtensionOpportunityOasIntegration(arg);
            //I don't try to sync opp if it hasn't line items for OAS
            if(o.id_oas__c!= null || oas.sfdcLineItems.size() > 0 ){
                oas.upsertOrderSfdcToOas(oasInt);
                  
                //Friendly error messages ---->
                //the methods called add userfriendly messages in ApesPages.Messages.
                //in order for the VF remoting to read this messages I need to put them into an 
                //exception and throw it. The message of the exception will be written into the
                //javascript component event.message
                if(ApexPages.getMessages()!=null && ApexPages.getMessages().size()!=0){
                    String errors = '';  
                    for(ApexPages.Message m : ApexPages.getMessages()){
                        errors+=m.getSummary(); 
                    }
                    return new stepResponse(true,errors);
                }
            }
        }

        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep3 - STOP *******');  
        return stepResponse;        
    }
  
    /**
    * This is the last invoked method, it set the StageName to "Chiusa Vinta" and sets true the boolean
    * isWon
    */
    @RemoteAction
    global static stepResponse chiudiEVinciStep4(String arg){
        stepResponse stepResponse = new stepResponse();
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep4 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        //Notice also that I don't try/catch because I want exception to be thrown.
        //the excpetion message will be put in the event.message javascript component
        system.debug('Limits.getQueries() 1: '+Limits.getQueries());    
        Opportunity o = [SELECT Id, status__c, StageName, isWon, Profili_conferma_dfp__c, id_dfp__c, id_oas__c,status_oas__c,DataPrimaChiusaVinta__c,CreatedDate,Local__c,
            (SELECT Id FROM Line_Items__r WHERE Product__r.Vetrina__c = true)
            FROM Opportunity WHERE id=:arg
        ];
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();       
        String profileName = [Select Name from Profile where Id =:id1].Name;
        if(o.Profili_conferma_dfp__c==null || !o.Profili_conferma_dfp__c.contains(profileName)){            
            return new stepResponse(true,'Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportunità'); 
        } else {
        
            system.debug('Limits.getQueries() 2: '+Limits.getQueries());
            //ExtensionOpportunityOasIntegration oas = new ExtensionOpportunityOasIntegration(o.id);
            //confirm order without do DML
            //if(o.id_oas__c != null){
            //    oas.confirmOrder(false);
            //}
     
            system.debug('Limits.getQueries() 3: '+Limits.getQueries());
            ExtensionOpportunityIntegration eoi = new ExtensionOpportunityIntegration(arg);
            if(o.id_dfp__c > 0 && o.status__c != 'APPROVED' && eoi.sfdcLineItems.size() > 0){
                //approve order without upsert before
                eoi.approveOrderAndUpsert(false); 
                o.status__c = eoi.o.status__c;
            }      
            
            if(ApexPages.getMessages()!=null && ApexPages.getMessages().size()!=0){
                String errors = '';  
                for(ApexPages.Message m : ApexPages.getMessages()){
                    errors+=m.getSummary(); 
                }
                return new stepResponse(true,errors);
            }
            
            system.debug('Limits.getQueries() 4: '+Limits.getQueries());
            //if(o.id_oas__c != null){
            //    o.status_oas__c = 'A';
            //    update oas.sfdcLineItems; //TODO try catch this in step 1
            //}
    
         
            if(o.id_dfp__c > 0){
                o.Ultima_sincronizzazione_DFP__c = system.now();
            }
  
 
            List<Pacchetto_Combo_Opportunity__c> pacchettiToCancel = [SELECT Id FROM Pacchetto_Combo_Opportunity__c WHERE Cancellato__c = true AND Opportunity__c=:arg ]; 
            delete pacchettiToCancel;
            
            List<LineItem__c> lineItemsToDelete = new List<LineItem__c>();
            List<LineItem__c> lineItemsToDeleteRipianificati = new List<LineItem__c>();

            
            for(LineItem__c li : [SELECT Id,Line_Item_Ripianificato__c,(select id from line_items__r where Cancellato__c = false) FROM LineItem__c WHERE Cancellato__c = true AND Opportunity__c=:arg]){
                if(li.Line_Item_Ripianificato__c != null){
                    lineItemsToDeleteRipianificati.add(li);
                }else{
                    lineItemsToDelete.add(li);
                }
            }
            delete lineItemsToDeleteRipianificati;
            delete lineItemsToDelete;

            system.debug('Limits.getQueries() 5: '+Limits.getQueries());
            o.StageName = 'Chiusa vinta'; 
            o.HiddenValidation__c=true;
            
            Savepoint sp = Database.setSavepoint();  
            update o;
         
            try{   
                if(!o.Local__c){
                    sendEmails(o);
                }
                sendEmailForProductVetrina(o);
            }
            catch(Exception e){
                Database.rollback(sp);         
                return new stepResponse(true,e.getMessage());           
            }
        }

        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep4 - STOP *******');  
        return stepResponse;        
    }

   //This function sends an email if at least one product from Line Items has Vetrina__c = true
    public static void sendEmailForProductVetrina(Opportunity opp) {
        if (opp != null && opp.Line_Items__r != null && !opp.Line_Items__r.isEmpty()) { //At least 1 LI with Product Vetrina__c=true

            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE developerName = 'Notifica_Opty_Chiusa_Vinta_Local'];
            TargetIdListEmail te = getTargetIdForEmail('Notifiche prodotti vetrina local');
            Id targetObjectId = te.targetId;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(targetObjectId);
            mail.setCcAddresses(te.ccEmails);
            mail.setTemplateId(template.Id);
            mail.setWhatId(opp.Id);
            mail.saveAsActivity = false;
            
             Messaging.SendEmailResult [] res = null;
            if(!Test.isRunningTest()){
                res = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
            System.debug('PuntoDebug - Risultato invio email opportunità chiusa vinta con almeno un prodotto vetrina: '+res);
        }
    }

   
    /**
    * Notifica modifica ricavi se almeno una modifica è presente
    */
    private static void sendEmails(Opportunity o){
        Datetime d = o.DataPrimaChiusaVinta__c ;
        Datetime dataRilascio = Datetime.newInstance(2014,08,04,15,0,0);
        if(d == null){
            d = o.CreatedDate;
        }
        if(d < dataRilascio){
            d = dataRilascio;
        }
        if([SELECT Field 
            FROM Ricavo__History 
            WHERE (Field = 'Modificato__c' OR  Parent.Modificato__c = TRUE)
            AND CreatedDate >= :d 
            AND Parent.Line_Item__r.Opportunity__r.Id = :o.Id
            AND Parent.Mese__c <> 'Totale'].size() > 0){

            EmailTemplate template = [SELECT id, DeveloperName FROM EmailTemplate WHERE developerName = 'Notifica_modifiche_Ricavi'];
            
            TargetIdListEmail te = getTargetIdForEmail('Notifiche modifiche ricavi');
            Id targetObjectId = te.targetId;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(TargetObjectId);

            mail.setCcAddresses(te.ccEmails);
            
            mail.setTemplateId(template.Id);
            mail.setWhatId(o.Id);
            mail.saveAsActivity = false;
            
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

            }
        }
    }

    /*
    * This functions return for a contact id (or user) the list of email to send
    * Contact Id -> Email-cc
    */
    public static TargetIdListEmail getTargetIdForEmail(String contactName) {
        TargetIdListEmail te = new TargetIdListEmail(); //Usually size 1
        String emailUserAlternative = 'libero@telnext.com'; //Used if contact is missing

        List<Contact> listContacts = [SELECT Id,Email_in_cc__c,Email FROM Contact WHERE Name = :contactName];
        if (contactName == null || contactName == '' || listContacts.isEmpty()) { //Taking from user
            List<User> listUsers = [SELECT Id FROM User WHERE email = :emailUserAlternative];
            if (listUsers.isEmpty()) {
                System.Debug('PuntoDebug - No user found with email '+contactName);
            } else {
                te.targetId = listUsers.get(0).Id;
            }
        } else { //Taking from Contact
            for (Contact c : listContacts) {
                String[] ccEmails = new String[]{};
                if (c.Email_in_cc__c != null) { ccEmails = c.Email_in_cc__c.split(','); }
                te.targetId = c.Id;
                te.ccEmails = ccEmails;
            }
        }

        return te;
    }

    public class TargetIdListEmail {
        public Id targetId {get; set;}
        public String[] ccEmails {get; set;}

        public TargetIdListEmail() {
            targetId = null;
            ccEmails = new String[]{};
        }
        public TargetIdListEmail(Id targetId, String[] ccEmails) {
            this.targetId = targetId;
            this.ccEmails = ccEmails;
        }
    }

}