public class ManageDayPartTargetingExtension {
    public List<dayPartListItem> allDayParts {get;set;}
    public List<dayPartListItem> allDayBandParts {get;set;}
    
    
    public List<Integer> i24 {get;set;}
    public List<Integer> i3 {get;set;}    
    
    ApexPages.StandardController controller;

    public ManageDayPartTargetingExtension(ApexPages.StandardController controller){
        this.controller = controller;
        allDayParts = new List<dayPartListItem>();
        allDayBandParts = new List<dayPartListItem>();
        i24 = new List<Integer>();
        for(Integer i=0;i<24;i++){
            i24.add(i);
        }
        i3 = new List<Integer>();
        for(Integer i=0;i<3;i++){
            i3.add(i);
        }        
        
        Set<String> dtAlreayChecked = new Set<String>();
        for(DayPartTargeting__c d : [select dayOfWeek__c,Start_Hour__c,End_Hour__c from DayPartTargeting__c where OpportunityLineItem__c =: controller.getId()]){
            dtAlreayChecked.add(d.dayOfWeek__c+d.Start_Hour__c+d.End_Hour__c);
        }
        
        for(Schema.PicklistEntry pl : DayPartTargeting__c.dayOfWeek__c.getDescribe().getPicklistValues()){
            dayPartListItem dayOfWeekPart = new dayPartListItem();
            dayOfWeekPart.listDp = new List<DayPartTarget>();
            dayOfWeekPart.dayOfWeek = pl.getValue();
            for(Integer i=0;i<24;i++){
                DayPartTarget dpt = new DayPartTarget();
                dpt.checked = dtAlreayChecked.contains(pl.getValue()+(i+'')+(i+1));
                dpt.daypart = new DayPartTargeting__c();
                dpt.daypart.dayOfWeek__c = pl.getValue();
                dpt.daypart.Start_Minute__c = 'ZERO';
                dpt.daypart.Start_Hour__c = i+'';
                dpt.daypart.End_Minute__c = 'ZERO';
                dpt.daypart.End_Hour__c = (i+1)+'';
                dpt.daypart.Opportunity__c = ((opportunityLineItem)controller.getRecord()).OpportunityId;
                dpt.daypart.OpportunityLineItem__c = controller.getId();
                dayOfWeekPart.listDp.add(dpt);
            }
            allDayParts.add(dayOfWeekPart);
            
            
            dayOfWeekPart = new dayPartListItem();
            dayOfWeekPart.listDp = new List<DayPartTarget>();
            dayOfWeekPart.dayOfWeek = pl.getValue();
            for(Integer i=0;i<3;i++){
                DayPartTarget dpt = new DayPartTarget();
                dpt.checked = dtAlreayChecked.contains(pl.getValue()+(i*8+'')+(i*8+8));
                dpt.daypart = new DayPartTargeting__c();
                dpt.daypart.dayOfWeek__c = pl.getValue();
                dpt.daypart.Start_Minute__c = 'ZERO';
                dpt.daypart.Start_Hour__c = i*8+'';
                dpt.daypart.End_Minute__c = 'ZERO';
                dpt.daypart.End_Hour__c = (i*8+8)+'';
                dpt.daypart.Opportunity__c = ((opportunityLineItem)controller.getRecord()).OpportunityId;
                dpt.daypart.OpportunityLineItem__c = controller.getId();
                dayOfWeekPart.listDp.add(dpt);
            }
            allDayBandParts.add(dayOfWeekPart);            
        }
    }
    
    public class DayPartTarget{
        public DayPartTargeting__c daypart {get;set;}
        public boolean checked {get;set;}
    }
    
    public class dayPartListItem{
        public String dayOfWeek {get;set;}
        public List<DayPartTarget> listDp {get;set;}
    }
    
    public void customSave(){
        controller.save();
        List<DayPartTargeting__c> dtToInsert = new List<DayPartTargeting__c>();
        List<dayPartListItem> partsToCheck = allDayParts;
        if(((OpportunityLineItem) controller.getRecord()).Day_Part_Targeting_Type__c == 'Bands'){
            partsToCheck = allDayBandParts;
        }
        
        for(dayPartListItem i : partsToCheck){
            for(DayPartTarget dp : i.listDp){
                system.debug(dp);
                if(dp.checked){
                    dtToInsert.add(dp.daypart);
                }
            }
        }
        system.debug(dtToInsert);
        List<DayPartTargeting__c> dtToDelete = [select id from DayPartTargeting__c where OpportunityLineItem__c =: controller.getId()];
        insert dtToInsert;
        delete dtToDelete;
    }

}