public class ControllerDayPartTargeting {
    public List<dayPartListItem> allDayParts {get;set;}
    public List<dayPartListItem> allDayBandParts {get;set;}
    
    public SObject obj {get;set;}
    
    public String id{get;set;}
    public String sobjectName{get;set;}
    
    public List<Integer> i24 {get;set;}
    public List<Integer> i3 {get;set;}    
    public List<List<String>> dayBand {get;set;}
    
    public ControllerDayPartTargeting(){
        
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
        
        dayBand = new List<List<String>>();
        List<String> tmp = new List<String>{'0','12'};
        dayBand.add(tmp);
        tmp = new List<String>{'12','16'};
        dayBand.add(tmp);
        tmp = new List<String>{'16','24'};
        dayBand.add(tmp);
        
        System.debug('id: ' + id + ' target: ' + sobjectName); 
        obj = Database.query('select id,Name,ad_server__c,Day_Part_Targeting_Type__c,Delivery_Model__c,TimeZoneDay__c from ' + sobjectName + ' where id = \''+ id + '\' limit 1' );
        
        System.debug('OBJ: ' + obj);
        
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
        /*
        obj = controller.getRecord();
        System.debug('StandardController: ' + controller.getRecord().getSObjectType() );*/
        
        Set<String> dtAlreayChecked = new Set<String>();
        for(DayPartTargeting__c d : [select dayOfWeek__c,Start_Hour__c,End_Hour__c from DayPartTargeting__c where (LineItem__c =: obj.id or Product__c =: obj.id)]){
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
                //dpt.daypart.Opportunity__c = ((opportunityLineItem)controller.getRecord()).OpportunityId;
                if(obj.getSObjectType() == LineItem__c.SObjectType)
                    dpt.daypart.LineItem__c = obj.Id;
                else
                    dpt.daypart.Product__c = obj.Id;
                dayOfWeekPart.listDp.add(dpt);
            }
            allDayParts.add(dayOfWeekPart);
                        
            dayOfWeekPart = new dayPartListItem();
            dayOfWeekPart.listDp = new List<DayPartTarget>();
            dayOfWeekPart.dayOfWeek = pl.getValue();
            
           
            
            for(Integer i=0;i<3;i++){
                DayPartTarget dpt = new DayPartTarget();
                //dpt.checked = dtAlreayChecked.contains(pl.getValue()+(i*8+'')+(i*8+8));
                dpt.checked = dtAlreayChecked.contains(pl.getValue()+(dayBand[i][0])+(dayBand[i][1]));
                dpt.daypart = new DayPartTargeting__c();
                dpt.daypart.dayOfWeek__c = pl.getValue();
                dpt.daypart.Start_Minute__c = 'ZERO';
                //dpt.daypart.Start_Hour__c = i*8+'';
                dpt.daypart.Start_Hour__c = dayBand[i][0];
                dpt.daypart.End_Minute__c = 'ZERO';
                //dpt.daypart.End_Hour__c = (i*8+8)+'';
                dpt.daypart.End_Hour__c = dayBand[i][1];
                if(obj.getSObjectType() == LineItem__c.SObjectType)
                    dpt.daypart.LineItem__c = obj.Id;
                else
                    dpt.daypart.Product__c = obj.Id;
                dayOfWeekPart.listDp.add(dpt);
            }
            allDayBandParts.add(dayOfWeekPart);            
        }
    }
    
    
    /*
    	save new dpt and delete olds
    */
    public PageReference customSave(){
    
        system.debug('custom save in ManageDayPartTargeting');
        
        List<DayPartTargeting__c> dtToInsert = new List<DayPartTargeting__c>();
        List<dayPartListItem> partsToCheck = allDayParts;
        if(obj.get('Day_Part_Targeting_Type__c') == 'Bands'){
            partsToCheck = allDayBandParts;
        }
        
        
        //for OAS is not allowed choose different hours for different days
        //save hours grouped by day of week
        map<string,set<string>> dpMap = new map<string,set<string>>();
        
        for(dayPartListItem i : partsToCheck){
            for(DayPartTarget dp : i.listDp){ 
                system.debug(dp);
                if(dp.checked){
                    dtToInsert.add(dp.daypart);
                    if(dpMap.get(dp.daypart.dayOfWeek__c) == null){
                    	dpMap.put(dp.daypart.dayOfWeek__c,new set<string>());
                    }
                    dpMap.get(dp.daypart.dayOfWeek__c).add(dp.daypart.Start_Hour__c+'-'+dp.daypart.End_Hour__c);
                }
            }
        }
        //check all day of week each other
        if((string) obj.get('ad_server__c') == 'OAS'){
	        for(string d1 : dpMap.keySet()){
	            for(string d2 : dpMap.keySet()){
	        		if(! dpMap.get(d1).containsAll(dpMap.get(d2))){
	        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Se servito da OAS, non è possibile inserire orari diversi in giorni diversi'));
	        			return null;
	        		}
	            }
	        }
        }
        system.debug(dtToInsert);
        List<DayPartTargeting__c> dtToDelete = [select id from DayPartTargeting__c where LineItem__c =: obj.Id or Product__c =: obj.Id];
        
        //DML
        try {
        	LineItemTriggerHandler.skipValidationTotali = true;
	        upsert obj;
        } finally {
        	LineItemTriggerHandler.skipValidationTotali = false;
        }
        
        insert dtToInsert;
        delete dtToDelete;
        
        PageReference p = new PageReference('/apex/editDayPartTargetingComponent?sobjectName=' + this.sobjectName + '&id=' + obj.id + '&editMode=false');        
        p.setRedirect(true);
        return p;
    }
    
    public List<selectOption> DayTargetingTypes{
            get {
                List<SelectOption> options = new List<SelectOption>();

                Schema.DescribeFieldResult fieldResult = LineItem__c.Day_Part_Targeting_Type__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for( Schema.PicklistEntry f : ple)
                {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
                //options.add(new SelectOption(f.getValue(), f.getValue()));
                } 
                return options;
            }
        set;
    }
    
    public List<selectOption> TimeZoneDays{
        get {
                List<SelectOption> options = new List<SelectOption>();

                Schema.DescribeFieldResult fieldResult = LineItem__c.TimeZoneDay__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for( Schema.PicklistEntry f : ple)
                {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
                } 
                return options;
            }
        set;
    }
    
    public class dayPartListItem{
        public String dayOfWeek {get;set;}
        public List<DayPartTarget> listDp {get;set;}
    }
    
    public class DayPartTarget{
        public DayPartTargeting__c daypart {get;set;}
        public boolean checked {get;set;}
    }
    
    
      static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;
        
        ApexPages.CurrentPage().getParameters().put('id',p.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','Product2');
        
        ControllerDayPartTargeting cdpt = new ControllerDayPartTargeting();
        List<selectOption> t = cdpt.DayTargetingTypes;
        for(ControllerDayPartTargeting.dayPartListItem dpli : cdpt.allDayParts){
            for(ControllerDayPartTargeting.DayPartTarget dpt : dpli.listDp){
                dpt.checked = true;
            }
        }        
        cdpt.customSave();
        
        List<selectOption> d = cdpt.TimeZoneDays;

     }

}