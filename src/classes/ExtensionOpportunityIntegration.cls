public class ExtensionOpportunityIntegration{

    Id oppId;

    DfpIntegration dfp;
    
    public Opportunity o {get;set;}
    public List<LineItem__c> sfdcLineItems {get;set;}

    public boolean autdfp {get;set;}
    
    public orderWithLineItems initialStatus; //to reset status after error
    public class orderWithLineItems{
        public opportunity o;
        public map<id,lineitem__c> lineitems;
    }
    
    public ExtensionOpportunityIntegration(ApexPages.StandardController controller) {
        try{
            autdfp = false;
            oppId = controller.getId();
            o = (opportunity) controller.getRecord();
            init();
            
            saveStatus();
            autdfp = true;
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }    
     
    public void saveStatus(){
        initialStatus = new orderWithLineItems();
        initialStatus.o = o.clone();
        initialStatus.lineitems = new map<id,lineitem__c>();
        for(lineitem__c li : sfdcLineItems){
            initialStatus.lineitems.put(li.id,li.clone());
        }
    }
    
    public void init(){
        if(dfp == null){
            dfp = new DfpIntegration();
        }
        /*
        o = [Select id_dfp__c, OrderAutoNumber__c, Name, Id, Centro_Media__c, 
                                Centro_Media_Id_DFP__c, Account.Id_DFP__c, AccountId 
                             From Opportunity where id =: oppId];
        */
        sfdcLineItems = UtilityLineItemIntegration.getLineItemsByOppId(oppId);
    } 
    
    public PageReference upsertOrderDfpToSfdc(){
        LineItemTriggerHandler.skipValidationTotali = true;
        
        UtilityOrderIntegration.syncDfpToSfdcOrders(new list<opportunity>{o},dfp);
        UtilityLineItemIntegration.syncDfpToSfdcLineItems(sfdcLineItems,dfp);
        
        try{
            update sfdcLineItems;
            if(o.Tempo_ultima_sincronizzazione__c == 0){
                o.Ultima_sincronizzazione_DFP__c = system.now();  
            }
            update o;
        }catch(Exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message;
                error +='<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione dell\'opportunità:<br />'+error));
            return null;
        }
        
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;
    }

    public PageReference upsertOrderSfdcToDfp(){
        return upsertOrderSfdcToDfp(true); //set false if needs to do callouts after
    }

    public PageReference upsertOrderSfdcToDfp(boolean doDml){
        LineItemTriggerHandler.skipValidationTotali = true;
        sfdcLineItems = UtilityLineItemIntegration.getLineItemsByOppId(oppId,true,true);

        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        try{
            System.debug(dfp);
            DfporderService.orderServiceInterfacePort orderService = dfp.orderService;  
            DfporderService.order order = new DfporderService.order();
            if(o.id_dfp__c > 0){
                order = UtilityOrderIntegration.getOrdersByIds(new decimal[]{(long)o.id_dfp__c},dfp).results[0];
            }
    
            order.Name = o.Name;
            order.externalOrderId = Integer.valueOf(o.OrderAutoNumber__c);


            order.salespersonId = (long) [select DfpUserId__c from User where id =: o.ownerid].DfpUserId__c;
            if(order.salespersonId == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il titolare dell\'opportunità deve essere collegato con dfp'));
                return null;
            }
            
            try{
                system.debug('traffickerid sfdfc: '+ o.planner__c);
                order.traffickerid = (long) [select DfpUserId__c from User where id =: o.planner__c].DfpUserId__c;
            }catch(exception e){
                order.traffickerid = (long) dfp.currentUserId; //id utente
            }
            
            order.appliedTeamIds = new list<long>();
            for(TeamTargeted__c tt : o.teamsTargeted__r){
                order.appliedTeamIds.add((long) tt.idDfp__c);
            }

            if(o.Account.id_dfp__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il brand deve essere mappato su dfp'));
                return null;
            }
            order.advertiserId = (long) o.Account.id_dfp__c;
            
            order.agencyId = null;
            if(o.Centro_Media__c != null){
                if(o.Centro_Media_Id_DFP__c == null || o.Centro_Media_Id_DFP__c == 0){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il centro media deve essere mappato su dfp'));
                    return null;
                }             
                order.agencyId = (long)o.Centro_Media_Id_DFP__c;
            }
            
            if(order.id != null){
                order = orderService.updateorders(new DfpOrderService.Order[]{order})[0];
            }else{
                order = orderService.createorders(new DfpOrderService.Order[]{order})[0];
            }
            
            o.id_dfp__c = order.id;
    
            Map<Decimal,LineItem__c> sfdcLiMap = new Map<Decimal,LineItem__c>();    //line item già sincronizzati
            List<LineItem__c> sfdcLiToInsert = new List<LineItem__c>();             //lista line item da sincronizzare
            Map<Id,LineItem__c> sfdcLiToInsertMap = new Map<Id,LineItem__c>();      //mappa line item da sincronizzare
            
            for(LineItem__c li : sfdcLineItems){
                if(o.allowOverbook__c){
                    li.allowOverbook__c = true;
                }
                if(li.id_dfp__c > 0){
                    sfdcLiMap.put(li.id_dfp__c,li);
                }else{
                    sfdcLiToInsert.add(li);
                    sfdcLiToInsertMap.put(li.id,li);
                }
            }
            
            List<DfpLineItemService.LineItem> lineItemsToInsert = new List<DfpLineItemService.LineItem>();
            List<DfpLineItemService.LineItem> lineItemsToUpdate = new List<DfpLineItemService.LineItem>();
            List<decimal> lineItemsToDelete = new list<decimal>();
            string exceptionOperation = ''; //operazione che ha dato eccezione
            try{
                DfpLineItemService.lineItemServiceInterfacePort lineItemService = dfp.lineItemService;
                
                DfpLineItemService.Statement lineItemFilterStatement = new DfpLineItemService.Statement();
                lineItemFilterStatement.query = 'WHERE orderId = '+o.id_dfp__c+' LIMIT 500 OFFSET 0';
                exceptionOperation = 'getLineItemsByStatement';
                DfpLineItemService.LineItemPage lineItemPage = lineItemService.getLineItemsByStatement(lineItemFilterStatement);
                set<decimal> dfpLiIds = new set<decimal>(); //lineitem che sono su dfp
                Map<Id,List<CustomCriteriaSet__c>> customCriteriaSet = UtilityLineItemIntegration.getCustomCriteriaMap(o.id);
                System.debug(customCriteriaSet);
                if(lineItemPage.totalResultSetSize > 0){
                    for(DfpLineItemService.lineItem lineItem : lineItemPage.results){
                        dfpLiIds.add(lineItem.id);
                        if(sfdcLiMap.get(lineItem.id) != null){
                            UtilityLineItemIntegration.syncSfdcToDfpLineItem(sfdcLiMap.get(lineItem.id),lineItem,order.id,customCriteriaSet.get(sfdcLiMap.get(lineItem.id).id));
                            lineItemsToUpdate.add(lineItem);
                        }else{
                            lineItemsToDelete.add(lineItem.id);
                        }   
                    }
                    if(lineItemsToUpdate.size() > 0){
                        exceptionOperation = 'updateLineItems';
                        DfpLineItemService.LineItem[] lineItemsUpdated = lineItemService.updateLineItems(lineItemsToUpdate);
                    }
                    if(lineItemsToDelete.size() > 0){
                        exceptionOperation = 'deleteLineItems';
                        //UtilityLineItemIntegration.deleteLineItems(lineItemsToDelete,dfp);
                    }
                }
                
                for(LineItem__c li : sfdcLineItems){
                    if(li.id_dfp__c > 0 && !dfpLiIds.contains(li.id_dfp__c)){ //se ho cancellato un lineite su dfp lo devo ricreare
                        li.id_dfp__c = 0; 
                        sfdcLiToInsert.add(li);
                        sfdcLiToInsertMap.put(li.id,li);
                    }
                }
                
                if(sfdcLiToInsert.Size() > 0){
                    for(LineItem__c sfdcLi : sfdcLiToInsert){
                        DfpLineItemService.LineItem dfpLi = new DfpLineItemService.LineItem();
                        system.debug(dfpLi);
                        System.debug(customCriteriaSet.get(sfdcLi.id));
                        UtilityLineItemIntegration.syncSfdcToDfpLineItem(sfdcLi,dfpLi,order.id,customCriteriaSet.get(sfdcLi.id));
                        system.debug(dfpLi);
                        lineItemsToInsert.add(dfpLi);
                    }
                    
                    exceptionOperation = 'createLineItems';
                    lineItemsToInsert = lineItemService.createLineItems(lineItemsToInsert);
                    sfdcLiToInsert = new List<LineItem__c>();
                    for(DfpLineItemService.LineItem dfpLi : lineItemsToInsert){
                        LineItem__c sfdcLi = sfdcLiToInsertMap.get(dfpLi.externalId);
                        sfdcLi.Id_DFP__c = dfpLi.id;
                        sfdcLiToInsert.add(sfdcLi);
                    }
                    
                    if(doDml){
                        exceptionOperation = 'updateSfdcLineItems';
                        update sfdcLiToInsert;
                    }
                }
            }catch(exception e){
                system.debug('exceptionOperation : '+exceptionOperation+'\nerror : '+e.getMessage());
                string error = '';
                if(exceptionOperation == 'getLineItemsByStatement' || exceptionOperation == 'deleteLineItems' || exceptionOperation == 'updateSfdcLineItems'){
                    error = e.getMessage();
                }else{
                    for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                        error += fm.message;
                        system.debug('index: '+fm.index);
                        if(fm.index >= 0){
                            error += ' ';
                            if(exceptionOperation == 'createLineItems'){
                                error += lineItemsToInsert[fm.index].name;
                            }
                            if(exceptionOperation == 'updateLineItems'){
                                error += lineItemsToUpdate[fm.index].name;
                            }
                        }
                        error +='<br />';
                    }
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione dei lineitem:<br />'+error));
                p = null;                
            }
            if(p != null){ //se == null ha dato errore
                o.Ultima_sincronizzazione_DFP__c = system.now();
            }
            //force update -> if we had an error in updating lineitems, the opportunity must updated anyway
            //in order to save id_dfp__c
            if(doDml || p == null){
                update o;
            }
        }catch(exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message;
                error +='<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione: '+error));
            return null;
        }
        return p;
    }
    
    
    /*
        upsert order sfdc to dfp and approve
    */
    public PageReference approveOrder(){
        return approveOrderAndUpsert(true);
    }
    
    
    /*
        Approve order. If it's called from ControllerGlobalCloseAndWin, it doesn't performe upsert
    */
    public PageReference approveOrderAndUpsert(boolean doUpsert){
        LineItemTriggerHandler.skipValidationTotali = true;
        
        if(doUpsert){
            PageReference prUpsert = upsertOrderSfdcToDfp(false);
            if(prUpsert == null){         
                return prUpsert;
            }
        }
        
        try{
            /*
            String cpdMessage = '';
            set<lineitem__c> liToRelease = new set<lineitem__c>(); //lineitem da rilasciare
            for(lineitem__c li : sfdcLineItems){
                if(li.delivery_model__c == 'CPD' && !o.skipDispoCPD__c && !li.skipDispoCPD__c){
                    ControllerCpdAvailability checkCpd = new ControllerCpdAvailability();
                    Map<String,boolean> checkedCPD = checkCpd.checkAvailabilityLineItem(li);
                    if(checkedCPD.get('block')){
                        cpdMessage += '<a href="/'+li.id+'">'+li.name_dfp__c+'</a><br />';
                    }
                    liToRelease.addAll(checkCpd.liToRelease);
                }
                li.status__c = 'NEEDS_CREATIVES';
                li.reservationStatus__c = 'RESERVED';
            }
            if(cpdMessage != ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'LineItem CPD in conflitto:<br />'+cpdMessage));               
                resetStatus();                
                return null;
            }
            
            for(lineitem__c li : liToRelease){
                system.debug('release li '+li.name_dfp__c);
                li.reservationStatus__c = 'UNRESERVED';
            }
            */
            o.status__c = 'APPROVED';   
            
            if(!o.allowOverbook__c){
                UtilityOrderIntegration.approveOrders(new list<decimal>{o.id_dfp__c});
            }else{
                UtilityOrderIntegration.performeOrderAction(new list<decimal>{o.id_dfp__c},'ApproveAndOverbookOrders');
            }

            //rilascio prenotazione per lineitem in conflitto
            /*
            try{
                list<lineitem__c> listLiToRelease = new list<lineitem__c>();
                set<id> liIds = new set<id>();
                for(LineItem__c li : liToRelease){
                    if(! liIds.contains(li.id)){
                        listLiToRelease.add(li);
                        liIds.add(li.id);
                    }
                }
        
                update listLiToRelease;
            }catch(DmlException e){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                List<String> toAddresses = new List<String>(); 
                toAddresses.add('libero@telnext.com');
                email.setToAddresses(toAddresses);
                email.setPlainTextBody(''+e);
                email.setSubject('Errore durante il rilascio di CPD lineitem in conflitto per l\'opportunità '+ o.name);
                try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }catch(Exception ex){
    
                }
            }
            */
            update sfdcLineItems;
            o.Ultima_sincronizzazione_DFP__c = system.now();
            update o;
        }catch(Exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message;
                error +='<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante l\'approvazione:<br/> '+error));
            
            System.debug('#### WARNING: '+o.id_dfp__c);  
            Decimal idDfp;
            if(o.id_dfp__c!=null)
                idDfp=o.id_dfp__c;
                
            resetStatus();
            System.debug('#### WARNING AFTER RESET: '+o.id_dfp__c+ ' - '+idDfp); 
            if(idDfp!=null){
                o.id_dfp__c=idDfp;
                update o;
                System.debug('#### WARNING AFTER UPDATE: '+o.id_dfp__c+ ' - '+idDfp); 
                Opportunity k = [SELECT ID_DFP__c FROM Opportunity WHERE Id =:o.id LIMIT 1];
                System.debug('#### WARNING FROM SELECT: '+k.id_dfp__c); 
            }
                
            return null;
        }
    
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;    
    }
    
    public void resetStatus(){
        o.status__c = initialStatus.o.status__c;
        for(lineitem__c li : sfdcLineItems){
            li.reservationStatus__c = initialStatus.lineitems.get(li.id).reservationStatus__c;
            li.status__c = initialStatus.lineitems.get(li.id).status__c;            
        }
    }
    
    public PageReference pauseOrder(){
        LineItemTriggerHandler.skipValidationTotali = true;
        
        PageReference pr = upsertOrderSfdcToDfp(false);
        try{
            for(lineitem__c li : sfdcLineItems){
                li.status__c = 'PAUSED';
            }
            o.status__c = 'PAUSED';     
            UtilityOrderIntegration.PauseOrders(new list<decimal>{o.id_dfp__c},dfp);
            o.Ultima_sincronizzazione_DFP__c = system.now();
            update o;
            update sfdcLineItems;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore: '+e.getMessage()));
            return null;
        }
    
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;    
    }    
    

    list<decimal> idToReserve;
    list<decimal> idToReserveAndOverbook;
    public PageReference reserveOrder(){
        return reserveOrder(true);
    }
    public PageReference reserveOrder(boolean doUpsertBefore){
        LineItemTriggerHandler.skipValidationTotali = true;
        saveStatus();
        idToReserve = new list<decimal>();
        idToReserveAndOverbook = new list<decimal>();
        if(doUpsertBefore){
            PageReference pr = upsertOrderSfdcToDfp(false);
            if(pr == null){
                return pr;
            }
        }
        
        for(lineitem__c li : sfdcLineItems){
            if(o.allowOverbook__c){
                li.allowOverbook__c = true;
            }
            if(reserveLineItem(false,li) == null){
                return null;
            }
        }
        
        try{
            if(idToReserve.size() > 0){
                UtilityLineItemIntegration.reserveLineItems(idToReserve);  
            }
            
            if(idToReserveAndOverbook.size() > 0){
                UtilityLineItemIntegration.performeLineItemAction(idToReserveAndOverbook,'ReserveAndOverbookLineItems');  
            }
            
            update sfdcLineItems;
            o.Ultima_sincronizzazione_DFP__c = system.now();
            update o;
        }catch(exception e){
            resetStatus();
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message;
                if(fm.index >= 0){
                    error += ' '+sfdcLineItems[fm.index].name;
                }
                error +='<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore: '+error));
            return null;
        }
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;
    }
    public pageReference reserveLineItem(){
        return reserveLineItem(true,UtilityLineItemIntegration.getLineItemBySfdcId(lineItemId));
    }
    public id lineItemId {get;set;}
    public pageReference reserveLineItem(boolean doDmlAndCallOut,LineItem__c li){
        LineItemTriggerHandler.skipValidationTotali = true;
        try{
            
            /* //Fa già controllo dfp quando si prenota
            if(li.delivery_model__c == 'CPM' && (li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'STANDARD')){
               ControllerForecast ControllerForecast = new ControllerForecast(li.id);
               ControllerForecast.Forecast forecast = ControllerForecast.checkAvailabilitySave(li);
               if(forecast != null && forecast.availableUnits < li.Quantita__c && !li.allowOverbook__c){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Impressions non sufficienti.'));               
                   return null;
               }
            }
            */
            /*
            String cpdMessage = '';       
            if(li.delivery_model__c == 'CPD'){
               ControllerCpdAvailability checkCpd = new ControllerCpdAvailability();
               Map<String,boolean> checkedCPD = checkCpd.checkAvailabilityLineItem(li);
               if(checkedCPD.get('block')){  
                   cpdMessage += '<a href="/'+li.id+'">'+li.name_dfp__c+'</a><br />';             
               }
            }
            
            if(cpdMessage != ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'CPD in conflitto con altro lineItem.<br />'+cpdMessage));               
                return null;
            }
            */
            if(li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'STANDARD'){
                if(!li.allowOverbook__c){
                    if(doDmlAndCallOut){
                        UtilityLineItemIntegration.reserveLineItems(new list<decimal>{li.id_dfp__c});  
                    }else{
                        idToReserve.add(li.id_dfp__c);
                    }
                }else{
                    if(doDmlAndCallOut){
                        UtilityLineItemIntegration.performeLineItemAction(new list<decimal>{li.id_dfp__c},'ReserveAndOverbookLineItems');  
                    }else{
                        idToReserveAndOverBook.add(li.id_dfp__c);
                    }
                }
            }
            
            li.reservationStatus__c = 'RESERVED';     
            if(doDmlAndCallOut){
                update li;        
                o.Ultima_sincronizzazione_DFP__c = system.now();
                update o;
            }
        }catch(exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message + '<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore: '+error));
            return null;
        }
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;
    }
    
    list<decimal> idToRelease;
    public pageReference releaseOrder(){
        LineItemTriggerHandler.skipValidationTotali = true;
        idToRelease = new list<decimal>();
    
        PageReference pr = upsertOrderSfdcToDfp(false);
        if(pr == null){
            return pr;
        }
        
        for(lineitem__c li : sfdcLineItems){
            if(releaseLineItem(false,li) == null){
                return null;
            }
        }
        
        try{
            if(idToRelease.size() > 0){
                UtilityLineItemIntegration.releaseLineItems(idToRelease);  
            }

 
            update sfdcLineItems;
            o.Ultima_sincronizzazione_DFP__c = system.now();            
            update o;
        }catch(exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message;
                if(fm.index >= 0){
                    error += ' '+sfdcLineItems[fm.index].name;
                }
                error +='<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore: '+error));
            return null;
        }
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;
    }
    
    public pageReference releaseLineItem(){
        return releaseLineItem(true,UtilityLineItemIntegration.getLineItemBySfdcId(lineItemId));
    }
    
    public pageReference releaseLineItem(boolean doDmlAndCallOut,LineItem__c li){
        LineItemTriggerHandler.skipValidationTotali = true;
        try{
            system.debug('lineItemId: '+lineitemid);        
            if(li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'STANDARD'){
                if(doDmlAndCallOut){
                    UtilityLineItemIntegration.releaseLineItems(new list<decimal>{li.id_dfp__c});                        
                }
            }
            li.reservationStatus__c = 'UNRESERVED';        
            if(doDmlAndCallOut){
                update li;       
                o.Ultima_sincronizzazione_DFP__c = system.now();
                update o; 
            }
        }catch(exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message + '<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore: '+error));
            return null;
        }
        PageReference p = new PageReference('/apex/OpportunityIntegration?id='+oppId);
        p.setRedirect(true);
        return p;
    }   
    
    public ExtensionOpportunityIntegration(String arg){
        this(arg,null);
    }
    
    //constructor for remote methods, takes as input only OppId
    public ExtensionOpportunityIntegration(String arg,DfpIntegration dfp){
        System.debug('****** ExtensionOpportunityIntegration(String arg) Constructor - START *******');  
        this.oppId = arg; 
        this.dfp = dfp;
        this.o = [SELECT o.skipDispoCPD__c, o.numeroRevenueFatturate__c, o.id_dfp__c, o.allowOverbook__c, o.Venditore__c, o.Ultimo_step_rifiutato__c, 
                        o.Ultimo_step_approvato__c, o.Ultimo_commento_approvativo__c, o.Ultima_sincronizzazione_DFP__c, o.Type, o.Totale_senza_sconto__c, 
                        o.Totale_omaggi__c, o.Totale_breakeven__c, o.Totale_Totale_Breakeven__c, o.Tipo_spedizione_anagrafica_di_fatt__c, 
                        o.Ticket_emessi__c, o.Termini_di_pagamento_anagrafica_di_fatt__c, 
                        o.Tempo_ultima_sincronizzazione__c, o.Tempo_ultima_modifica__c, o.SystemModstamp, o.SyncedQuoteId, o.Status__c, 
                        o.Stato_sincronizzazione_DFP__c, o.Stato_Apertura__c, o.StageName, o.Somma_totali__c, o.Sconto_medio__c, 
                        o.Riferimento_centro_media_formula__c, o.Riferimento_centro_media__c, 
                        o.Riferimenti_agenzia_creativa__c, o.ReservationStatus__c, o.ReservationStatusFormula__c, o.Referente_Ad_Europe__c, 
                        o.Profili_senza_permesso_aggiunta_prodotto__c, o.Profili_conferma_e_gestione_post_conferm__c, 
                        o.Profili_conferma_dfp__c, o.Probability, o.Pricebook2Id, o.Planner__c, o.Percentuale_agenzia_su_brand__c, o.Partnership__c, 
                        o.Partita_IVA_in_anagrafica__c, o.OwnerId, o.OwnerCentroMedia__c, o.OwnerCentroMediaId__c, o.OwnerAgenzia__c, o.OwnerAccount__c, 
                        o.OrderAutoNumber__c, o.OrderAutoNumberLong__c, o.Numero_lineitem_non_omaggio__c, o.Numero_lineitem_non_breakeven__c, 
                        o.Numero_lineitem_in_omaggio__c, o.Numero_lineitem_breakeven__c, o.Numero_di_lineitem__c, o.Note_fattura__c, o.Nome_venditore__c, 
                        o.Nome_centro_media__c, o.Nome_brand__c, o.NextStep, o.Name,
                        o.Metodo_di_pagamento_anagrafica_fatt__c, o.Limite_unica_approvazione__c, o.Limite_percentuale_omaggi__c, 
                        o.Limite_nessuna_approvazione__c, o.LeadSource, o.LastModifiedDate, o.LastModifiedById, o.LastActivityDate, o.IsWon, o.IsDeleted, 
                        o.IsClosed, o.In_corso__c, o.In_corso_Val__c, o.In_approvazione__c, o.Import_Ext_ID__c, o.Identificativo_Campagna__c,  o.Id, 
                        o.HasOpportunityLineItem, o.ForecastCategoryName, o.ForecastCategory, o.FiscalYear, o.FiscalQuarter, o.Fiscal, 
                        o.Escludi_da_fatt_auto__c, o.Email_agenzia_creativa__c, o.Description, o.Data_ultima_riapertura__c, o.Data_inizio__c, 
                        o.Data_fine__c, o.Data_annullamento_prenotazione__c, o.DFP_url__c, o.CreatedDate, o.CreatedById, o.Conto_risconto__c, 
                        o.Conto_ricavo__c, o.Commissione_Agenzia__c, o.Codice_iva_anagrafica_fatt__c, o.Codice_fatturazione__c, o.CloseDate, 
                        o.Chiuse_Vinte__c, o.Chiuse_Vinte_Val__c, o.Chiuse_Perse__c, o.Chiuse_Perse_Val__c, o.Check_amministrativo__c, o.Centro_Media__c, 
                        o.Centro_Media_Id_DFP__c, o.Canale_di_vendita__c, o.CampaignId, o.Budget_Rimanente__c, o.Budget_Campagna__c, 
                        o.Approvazione_richiesta__c, o.Approvazione_commerciale__c, o.Approvata_commercialmente__c, o.Anno_chiusura_num__c, 
                        o.Anno_chiusura__c, o.Anagrafica_di_Fatturazione__c, o.Amount_Libero__c, o.Amount, o.Agenzia_di_riferimento_txt__c, 
                        o.Agenzia_di_riferimento__c, o.Agenzia_creativa__c, o.Account_Industry__c, o.AccountId, o.Account.id_dfp__c,
                        (select idDfp__c from TeamsTargeted__r) 
                    From Opportunity o WHERE Id=:arg];                     
        init();
        //save statues wastes a lot of space in my use case, I think it's only needed
        //to retrieve the opportunity status...!
        saveStatus();   
        System.debug('****** ExtensionOpportunityIntegration(String arg) Constructor - STOP *******');  
    }


    
    
/*****TEST AND REMOVE THIS CODE. NOW ControllerGlobalCloseAndWin IS USED************    
    
    /**
    * These following methods are used to perform in sequence
    * -save and rollback of an opportunity to see if all checks on sfdc side are ok
    * -upsert or approve (send the opportunity to remote dfp server, approve if it's not already approved)
    * -finally save and set status "chiusa vinta"
    *
    * I want to use RemoteAction because the javascript implementation allows to call a method
    * and handle the result asynchronoously at a client level. Exception thrown by the invoked
    * method are put into the event.message javascript component, e.g.:
    *
    * Visualforce.remoting.Manager.invokeAction(
    *    '{!$RemoteAction.MyController.method}', 
    *    parameter, 
    *    function(result, event){
    *        //handle result, if no errors, call next method!
    *        if(event.status==true){
    *           //go on to next step! -> call next remove VF function
    *        } else {
    *           //stop, there was an error
                alert(event.message)
    *        }
    *    }, 
    *    {escape: true}
    * );
    *
    *
    */
/*    
    /**
    * Purpouse of the first step is to try and save the opportunity, if all is successful
    * roll back and continue, else, throw exception so that on the javascript side we'll have
    * event.status == false
    *
    
    @RemoteAction
    public static PageReference chiudiEVinciStep1(String arg){
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep1 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        //Notice also that I don't try/catch because I want exception to be thrown.
        //the excpetion message will be put in the event.message javascript component
        
        //save db status
        Savepoint sp = Database.setSavepoint();
        Opportunity o = [SELECT o.skipDispoCPD__c, o.numeroRevenueFatturate__c, o.id_dfp__c, o.allowOverbook__c, o.Venditore__c, o.Ultimo_step_rifiutato__c, o.Ultimo_step_approvato__c, o.Ultimo_commento_approvativo__c, o.Ultima_sincronizzazione_DFP__c, o.Type, o.Totale_senza_sconto__c, o.Totale_omaggi__c, o.Totale_breakeven__c, o.Totale_Totale_Breakeven__c, o.Tipo_spedizione_anagrafica_di_fatt__c, o.Ticket_emessi__c, o.Termini_di_pagamento_syncQuote__c, o.Termini_di_pagamento_anagrafica_di_fatt__c, o.Tempo_ultima_sincronizzazione__c, o.Tempo_ultima_modifica__c, o.SystemModstamp, o.SyncedQuoteId, o.Status__c, o.Stato_sincronizzazione_DFP__c, o.Stato_Apertura__c, o.StageName, o.Somma_totali__c, o.Sconto_medio__c, o.Riferimento_cliente_syncQuote__c, o.Riferimento_centro_media_formula__c, o.Riferimento_centro_media__c, o.Riferimenti_agenzia_creativa__c, o.ReservationStatus__c, o.ReservationStatusFormula__c, o.Referente_Ad_Europe__c, o.Quote_Description_syncQuote__c, o.Profili_senza_permesso_aggiunta_prodotto__c, o.Profili_conferma_e_gestione_post_conferm__c, o.Profili_conferma_dfp__c, o.Probability, o.Pricebook2Id, o.Planner__c, o.Percentuale_agenzia_su_brand__c, o.Partnership__c, o.Partita_IVA_in_anagrafica__c, o.OwnerId, o.OwnerCentroMedia__c, o.OwnerCentroMediaId__c, o.OwnerAgenzia__c, o.OwnerAccount__c, o.OrderAutoNumber__c, o.OrderAutoNumberLong__c, o.Numero_lineitem_non_omaggio__c, o.Numero_lineitem_non_breakeven__c, o.Numero_lineitem_in_omaggio__c, o.Numero_lineitem_breakeven__c, o.Numero_di_lineitem__c, o.Note_fattura__c, o.Nome_venditore__c, o.Nome_centro_media__c, o.Nome_brand__c, o.NextStep, o.Name, o.Metodo_di_pagamento_syncQuote__c, o.Metodo_di_pagamento_anagrafica_fatt__c, o.Limite_unica_approvazione__c, o.Limite_percentuale_omaggi__c, o.Limite_nessuna_approvazione__c, o.LeadSource, o.LastModifiedDate, o.LastModifiedById, o.LastActivityDate, o.IsWon, o.IsDeleted, o.IsClosed, o.In_corso__c, o.In_corso_Val__c, o.In_approvazione__c, o.Import_Ext_ID__c, o.Identificativo_Campagna__c,  o.Id, o.HasOpportunityLineItem, o.ForecastCategoryName, o.ForecastCategory, o.FiscalYear, o.FiscalQuarter, o.Fiscal, o.Escludi_da_fatt_auto__c, o.Email_agenzia_creativa__c, o.Description, o.Data_ultima_riapertura__c, o.Data_inizio__c, o.Data_fine__c, o.Data_annullamento_prenotazione__c, o.DFP_url__c, o.CreatedDate, o.CreatedById, o.Conto_risconto__c, o.Conto_ricavo__c, o.Commissione_Agenzia__c, o.Codice_iva_anagrafica_fatt__c, o.Codice_fatturazione__c, o.CloseDate, o.Chiuse_Vinte__c, o.Chiuse_Vinte_Val__c, o.Chiuse_Perse__c, o.Chiuse_Perse_Val__c, o.Check_amministrativo__c, o.Centro_Media__c, o.Centro_Media_Id_DFP__c, o.Canale_di_vendita__c, o.CampaignId, o.Budget_Rimanente__c, o.Budget_Campagna__c, o.Approvazione_richiesta__c, o.Approvazione_commerciale__c, o.Approvata_commercialmente__c, o.Anno_chiusura_num__c, o.Anno_chiusura__c, o.Anagrafica_di_Fatturazione__c, o.Amount_Libero__c, o.Amount, o.Agenzia_di_riferimento_txt__c, o.Agenzia_di_riferimento__c, o.Agenzia_creativa__c, o.Account_Industry__c, o.AccountId From Opportunity o WHERE Id=:arg];                       
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();       
        String profileName = [Select Name from Profile where Id =:id1].Name;
        if(o.Profili_conferma_dfp__c==null || !o.Profili_conferma_dfp__c.contains(profileName)){            
            throw new RemoteVFException('Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportuntà'); 
        } else {        
            o.StageName = 'Chiusa vinta'; 
            o.HiddenValidation__c=true;
            update o;
        }
        //rollback        
        Database.rollback(sp);      
        
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep1 - STOP *******');  
        return null;        
    } 
    
    /**
    * Step 2:
    * This methods decides whether to approve or just upsert an Opportunity to remote DFP server
    *
    @RemoteAction
    public static PageReference chiudiEVinciStep2(String arg){
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep2 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        
        Opportunity o = [SELECT Id, status__c, Profili_conferma_dfp__c FROM Opportunity WHERE id=:arg ];
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();       
        String profileName = [Select Name from Profile where Id =:id1].Name;
        if(o.Profili_conferma_dfp__c==null || !o.Profili_conferma_dfp__c.contains(profileName)){            
            throw new RemoteVFException('Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportuntà'); 
        } else {        
            ExtensionOpportunityIntegration eoi = new ExtensionOpportunityIntegration(arg);
            if(o.status__c!=null && o.status__c=='APPROVED'){
                eoi.upsertOrderSfdcToDfp(true);
            } else {            
                eoi.approveOrder();
            }    
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
                throw new RemoteVFException(errors);                    
            }
        }
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep2 - STOP *******');  
        return null;        
    }
    
    /**
    * This is the last invoked method, it set the StageName to "Chiusa Vinta" and sets true the boolean
    * isWon
    *
    @RemoteAction
    public static PageReference chiudiEVinciStep3(String arg){
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep3 - START *******');  
        //I expect to get the opportunity Id being in the arg.
        //Notice also that I don't try/catch because I want exception to be thrown.
        //the excpetion message will be put in the event.message javascript component
        
        Opportunity o = [SELECT Id, status__c, StageName, isWon, Profili_conferma_dfp__c FROM Opportunity WHERE id=:arg ];
        //check if the user can do this operation:
        Id id1 = UserInfo.getProfileId();       
        String profileName = [Select Name from Profile where Id =:id1].Name;
        if(o.Profili_conferma_dfp__c==null || !o.Profili_conferma_dfp__c.contains(profileName)){            
            throw new RemoteVFException('Il profilo dell\'utente, '+profileName+', non dispone dei privilegi per confermare questa Opportuntà'); 
        } else {            
            o.StageName = 'Chiusa vinta'; 
            o.HiddenValidation__c=true;     
            update o;
        }
        System.debug('****** ExtensionOpportunityIntegration.chiudiEVinciStep3 - STOP *******');  
        return null;        
    }
    
    //custom exception used in the remote methods to report the friendly error messages to the page
    public class RemoteVFException extends Exception {}
*/
    
}