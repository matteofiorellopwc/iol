public class testForecastExtension{

/*
    ApexPages.StandardController controller;    
    public Forecast f {set;get;}
    DfpIntegration dfp;

    public testForecastExtension(ApexPages.StandardController controller){
        this.controller = controller;
        dfp = new DfpIntegration();
    }
    
    public void checkAvailability(){
        OpportunityLineItem oli = [Select Id,Quantity, TotalPrice, UnitPrice, Start_DateTime__c, End_DateTime__c,Name__c, TimeZoneDay__c,Discount,Discout_Absolute_Value__c,
                                  Id_DFP__c,Height__c,Width__c,Delivery_Model__c,DFP_order_id__c,PricebookEntry.Product2.Id_DFP__c,Type__c 
                                  From OpportunityLineItem
                                  where id =: controller.getId()];
        DfpForecastService.Forecast ff;
        if(oli.Id_DFP__c > 0){
            ff = dfp.forecastService.getForecastById((long)oli.Id_DFP__c);
        }else{
            DfpForecastService.LineItem li = new DfpForecastService.LineItem();
            syncLineItem(oli,li,(long)oli.DFP_order_id__c);
            ff = dfp.forecastService.getForecast(li);            
        }
        f = new Forecast();
        f.id = ff.id;
        f.orderId = ff.orderId;
        f.unitType = ff.unitType;
        f.availableUnits = ff.availableUnits;
        f.deliveredUnits = ff.deliveredUnits;
        f.matchedUnits = ff.matchedUnits;
        f.possibleUnits = ff.possibleUnits;
        f.reservedUnits = ff.reservedUnits;
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
    }   
    
    public void syncLineItem(OpportunityLineItem oli,DfpForecastService.LineItem li,Long orderid){

        li.costType = oli.Delivery_Model__c;
        
        if(oli.Delivery_Model__c == 'CPC' || oli.Delivery_Model__c == 'CPM'){
            if(li.costPerUnit != null){
                li.costPerUnit.microAmount = (long) oli.UnitPrice*1000000;
            }else{
                li.costPerUnit = getLineItemMoney((long)oli.UnitPrice*1000000);
            }  
            
            li.unitsBought = (long) oli.quantity * 1000;
            
        }else{
            if(li.costPerUnit != null){
                li.costPerUnit.microAmount = (long) oli.UnitPrice*1000000;
            }else{
                li.costPerUnit = getLineItemMoney((long)oli.UnitPrice*1000000);
            }          
            
            li.unitsBought = (long) oli.quantity;             
        }
        
        if(oli.Discout_Absolute_Value__c > 0){
            li.discountType = 'ABSOLUTE_VALUE';
            li.discount = oli.Discout_Absolute_Value__c;
        }else if(oli.Discount > 0){
            li.discountType = 'PERCENTAGE';
            li.discount = oli.Discount;        
        }
        
        li.startDateTime = getLineItemDateTime(oli.Start_DateTime__c);
        li.endDateTime = getLineItemDateTime(oli.End_DateTime__c);
        li.lineItemType = oli.type__c;
        li.name = oli.Name__c;
        li.orderId = (long) orderid;
        
        
        li.externalid = oli.id;
        
        li.creativePlaceholders = new List<DfpForecastService.CreativePlaceholder>();
        DfpForecastService.CreativePlaceholder creativePlaceHolder = new DfpForecastService.CreativePlaceholder();
        creativePlaceHolder.size = new DfpForecastService.Size();
        creativePlaceHolder.size.width =  (integer) oli.width__c;
        creativePlaceHolder.size.height = (integer) oli.height__c;
        creativePlaceHolder.size.isAspectRatio = false;
        li.creativePlaceholders.add(creativePlaceHolder);

        li.targeting = new DfpForecastService.Targeting();
        li.targeting.inventoryTargeting = new DfpForecastService.InventoryTargeting();
        li.targeting.inventoryTargeting.targetedAdUnits = new List<DfpForecastService.AdUnitTargeting>();
        DfpForecastService.AdUnitTargeting adUnitTargeting = new DfpForecastService.AdUnitTargeting();
        adUnitTargeting.adUnitId  = oli.PricebookEntry.Product2.Id_DFP__c;
        adUnitTargeting.includeDescendants  = true;
        li.targeting.inventoryTargeting.targetedAdUnits.add(adUnitTargeting);
        
        String oliid = oli.id;
        oliid = oliid.substring(0,15);
        List<DayPartTargeting__c> dayParts = [Select dayOfWeek__c, Start_Minute__c, start_Hour__c, End_Minute__c, End_Hour__c From DayPartTargeting__c where OpportunityLineItem__c =: oliid];
        
        if(!dayParts.isEmpty()){
            li.targeting.dayPartTargeting = new DfpForecastService.DayPartTargeting();
            li.targeting.dayPartTargeting.timeZone = oli.TimeZoneDay__c;
            li.targeting.dayPartTargeting.dayParts = new List<DfpForecastService.DayPart>();
            for(DayPartTargeting__c dp : dayParts){
                DfpForecastService.DayPart d = new DfpForecastService.DayPart();
                d.dayOfWeek = dp.dayOfWeek__c;
                d.startTime = getLineItemTimeOfDay(dp.Start_Hour__c,dp.Start_Minute__c);
                d.endTime = getLineItemTimeOfDay(dp.End_Hour__c,dp.End_Minute__c);
                li.targeting.dayPartTargeting.dayParts.add(d);
            }
        }
    }    
    
    private DfpForecastService.TimeOfDay getLineItemTimeOfDay(String h,String m){
        DfpForecastService.TimeOfDay tod = new DfpForecastService.TimeOfDay();
        tod.hour = Integer.valueOf(h);
        tod.minute = m;
        return tod;
    }
    
    private DfpForecastService.Money getLineItemMoney(long amount){
        DfpForecastService.Money money = new DfpForecastService.Money();
        money.microAmount = amount;
        money.currencyCode = 'EUR';
        return money;
    }
    
    private DfpForecastService.DateTime_x getLineItemDateTime(DateTime dt){
        return getLineItemDateTime(dt.year(),dt.month(), dt.day(), dt.hour(), dt.minute(),dt.second());
    }
    
    private DfpForecastService.DateTime_x getLineItemDateTime(integer year,integer month, integer day, integer hour, integer minute,integer second){
        DfpForecastService.Date_x d = new DfpForecastService.Date_x();
        d.year = year;
        d.month = month;
        d.day = day;
        DfpForecastService.DateTime_x dt = new DfpForecastService.DateTime_x();
        dt.date_x = d;
        dt.hour = hour;
        dt.minute = minute;
        dt.second = second;
        return dt;    
    }    

*/

}