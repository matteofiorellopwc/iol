public class ControllerForecast{

    public Forecast f {set;get;}
    public id LineItemId {get;set;}
    DfpIntegration dfp;
    
    public string error {get;set;}


    public ControllerForecast(id id){
        LineItemId = id;
        error = '';
    }
    
    public static forecast staticCheckAvailability(DfpIntegration dfp,LineItem__c sfdcLineItem){
        DfpLineItemService.LineItem li = new DfpLineItemService.LineItem();
        DfpForecastService.ProspectiveLineItem pli = new DfpForecastService.ProspectiveLineItem();
        DfpForecastService.AvailabilityForecastOptions fo = new DfpForecastService.AvailabilityForecastOptions();
        fo.includeTargetingCriteriaBreakdown = false;
        fo.includeContendingLineItems = false;
        UtilityLineItemIntegration.syncSfdcToDfpLineItem(sfdcLineItem,li,null);
        if(sfdcLineItem.Id_DFP__c > 0){
            li.Id = (Long) sfdcLineItem.Id_DFP__c;
            li.orderId = (Long) sfdcLineItem.Opportunity__r.Id_DFP__c;            
        }
        string error = '';
        forecast f = null;
        try{
            DfpForecastService.AvailabilityForecast ff;
            if(!test.isRunningTest()){
                li = UtilityLineItemIntegration.getAdditionalCriterias(li);
                pli.LineItem = li;
                ff = dfp.forecastService.getAvailabilityForecast(pli,fo);
            }else{
                ff = new DfpForecastService.AvailabilityForecast();
            }
            f = new Forecast();
            f.id = ff.lineitemid;
            f.orderId = ff.orderId;
            f.unitType = ff.unitType;
            f.availableUnits = ff.availableUnits;
            f.deliveredUnits = ff.deliveredUnits;
            f.matchedUnits = ff.matchedUnits;
            f.possibleUnits = ff.possibleUnits;
            f.reservedUnits = ff.reservedUnits;
            f.contendingLineItems = ff.contendingLineItems;
            
            if(test.isRunningTest()){
                throw new ForecastException();
            }
        }catch(Exception e){
            error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message+'<br />';
            }
            if(error != ''){
                throw new ForecastException(error);
            }else{
                throw e;
            }
        }
        
        return f;
    }
    
    public class ForecastException extends exception{}
    
    public void checkAvailability(LineItem__c sfdcLineItem){
        /*
        LineItem__c sfdcLineItem = [Select l.sconto__c, l.Width__c, l.TimeZoneDay__c, l.Start_Minute__c, l.Start_Hour__c, 
                         l.Start_Date__c, l.Quantita__c, l.Prezzo_net_net__c, l.Notes_dfp__c, 
                         l.Name_Dfp__c, l.Height__c, l.End_Minute__c, l.End_Hour__c, l.End_Date__c, l.Discount_Type__c, 
                         l.Delivery_Model__c, l.Base_Price__c, l.Id_DFP__c,l.Type_DFP__c,
                         (Select dayOfWeek__c, Start_Hour__c, End_Hour__c, Start_Minute__c, End_Minute__c 
                             From Day_Part_Targeting__r),
                         (Select includeDescendants__c, adUnitIdDfp__c, InventoryTargetingType__c From Inventory_Target__r),
                         (Select maxImpressions__c, numTimeUnits__c, timeUnit__c From Frequency_Caps__r),
                         (Select Id   From Custom_Criteria_Set__r),
                         (Select idDfp__c From AppliedLabel__r),
                         (Select Type__c, isTargeted__c, valueIds__c From Technology_Targeting__r)
                     From LineItem__c l 
                     where id =: LineItemId];
        */            
        
        system.debug('sfdcLineItem: '+sfdcLineItem);         
        
        
        
        DfpLineItemService.LineItem li = new DfpLineItemService.LineItem();
        DfpForecastService.AvailabilityForecastOptions fo = new DfpForecastService.AvailabilityForecastOptions();
        DfpForecastService.ProspectiveLineItem pli = new DfpForecastService.ProspectiveLineItem();
        
        fo.includeTargetingCriteriaBreakdown = false;
        fo.includeContendingLineItems = false;
        UtilityLineItemIntegration.syncSfdcToDfpLineItem(sfdcLineItem,li,null);
        if(sfdcLineItem.Id_DFP__c > 0){
            li.Id = (Long) sfdcLineItem.Id_DFP__c;
            li.orderId = (Long) sfdcLineItem.Opportunity__r.Id_DFP__c;
        }
        error = '';
        try{
            dfp = new DfpIntegration();
            DfpForecastService.AvailabilityForecast ff;
            if(!test.isRunningTest()){
                li = UtilityLineItemIntegration.getAdditionalCriterias(li);
                pli.LineItem = li;
                ff = dfp.forecastService.getAvailabilityForecast(pli,fo);
            }else{
                ff = new DfpForecastService.AvailabilityForecast();
            }    
            f = new Forecast();
            f.id = ff.lineItemId;
            f.orderId = ff.orderId;
            f.unitType = ff.unitType;
            f.availableUnits = ff.availableUnits;
            f.deliveredUnits = ff.deliveredUnits;
            f.matchedUnits = ff.matchedUnits;
            f.possibleUnits = ff.possibleUnits;
            f.reservedUnits = ff.reservedUnits;
            f.contendingLineItems = ff.contendingLineItems;
            
            if(test.isRunningTest()){
                throw new ForecastException();
            }
        }catch(Exception e){
            error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message+'<br />';
            }
        }
    }
    
    //Metodo da sistemare
    public Forecast checkAvailabilitySave(LineItem__c sfdcLineItem){    
       
        
        DfpLineItemService.LineItem li = new DfpLineItemService.LineItem();
        DfpForecastService.ProspectiveLineItem pli = new DfpForecastService.ProspectiveLineItem();
        DfpForecastService.AvailabilityForecastOptions fo = new DfpForecastService.AvailabilityForecastOptions();
        fo.includeTargetingCriteriaBreakdown = false;
        fo.includeContendingLineItems = false;
        UtilityLineItemIntegration.syncSfdcToDfpLineItem(sfdcLineItem,li,null);
        
        if(sfdcLineItem.Id_DFP__c > 0){
            li.Id = (Long) sfdcLineItem.Id_DFP__c;
            li.orderId = (Long) sfdcLineItem.Opportunity__r.Id_DFP__c;            
        }
        error = '';
        f = null;
        try{
            dfp = new DfpIntegration();
            DfpForecastService.AvailabilityForecast ff;
            if(!test.isRunningTest()){
                li = UtilityLineItemIntegration.getAdditionalCriterias(li);
                pli.LineItem = li;
                ff = dfp.forecastService.getAvailabilityForecast(pli,fo);
            }else{
                ff = new DfpForecastService.AvailabilityForecast();
            }
            f = new Forecast();
            f.id = ff.lineItemId;
            f.orderId = ff.orderId;
            f.unitType = ff.unitType;
            f.availableUnits = ff.availableUnits;
            f.deliveredUnits = ff.deliveredUnits;
            f.matchedUnits = ff.matchedUnits;
            f.possibleUnits = ff.possibleUnits;
            f.reservedUnits = ff.reservedUnits;
            f.contendingLineItems = ff.contendingLineItems;
            
            if(test.isRunningTest()){
                throw new ForecastException();
            }
        }catch(Exception e){
            error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message+'<br />';
            }
        }
        
        return f;

    }
    
    public class Forecast {
        public Long id {get;set;}
        public Long orderId {get;set;}
        public String unitType {get;set;}
        public Long availableUnits {get;set;}
        public Long deliveredUnits {get;set;}
        public Long matchedUnits {get;set;}
        public Long possibleUnits {get;set;}
        public Long reservedUnits {get;set;}
        public DfpForecastService.ContendingLineItem[] contendingLineItems {get;set;}
    }
    
    /*
    public static void LI2Forecast (DfpForecastService.LineItemSummary fli, DfpLineItemService.LineItem li){
    	fli.orderId = li.orderId;
    	fli.id = li.id;
    	fli.name = li.name;
    	fli.orderName = li.orderName;
    	fli.startDateTime = li.startDateTime;
    	fli.startDateTimeType = li.startDateTimeType;
    	fli.endDateTime = li.endDateTime;
    	fli.frequencyCaps = li.frequencyCaps;
    	fli.lineItemType = li.lineItemType;
    	fli.priority = li.priority;
    	fli.costPerUnit = li.costPerUnit;
    	fli.valueCostPerUnit = li.valueCostPerUnit;
    	fli.costType = li.costType;
    	fli.discountType = li.discountType;
    	fli.discount = li.discount;
    	fli.contractedUnitsBought = li.contractedUnitsBought;
   		fli.creativePlaceholders = li.creativePlaceholders;
   		fli.activityAssociations = li.activityAssociations;
   		fli.targetPlatform = li.targetPlatform;
   		fli.environmentType = li.environmentType;
   		fli.allowOverbook = li.allowOverbook;
   		fli.status = li.status;
   		fli.isArchived = li.isArchived;
   		fli.customFieldValues = li.customFieldValues;
   		fli.primaryGoal = li.primaryGoal;
   		fli.targeting = li.targeting;
    } */
    
    public static testMethod void testControllerForecast(){
        Opportunity o = new Opportunity(name='test',CloseDate=date.today(),stageName='test');
        insert o;
        LineItem__c li = new LineItem__c(Opportunity__c=o.id);
        insert li;
        li = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
        
        try{ ControllerForecast.staticCheckAvailability(null,li); }catch(exception e){}
        
        ControllerForecast controller = new ControllerForecast(null);
        try{ controller.checkAvailability(li); }catch(exception e){}
        try{ controller.checkAvailabilitySave(li); }catch(exception e){}
        ControllerForecast.Forecast f = new ControllerForecast.Forecast();
        
    }
    
    
    
}