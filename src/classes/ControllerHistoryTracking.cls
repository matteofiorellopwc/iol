public with sharing class ControllerHistoryTracking {

    public map<string,string> fieldMap {get;set;}
    
    public list<LineItem__History> histories{
        get{
            fieldMap = new map<string,string>();
            
            list<LineItem__History> histories = [Select Id,CreatedById,CreatedDate,ParentId,OldValue,NewValue,Field 
                    From LineItem__History 
                    where parentid =: ApexPages.currentPage().getParameters().get('id')
                    order by CreatedDate desc
                   ];
            //nel test non vengono inseriti i LineItem__History
            if(Test.isRunningTest()){
                histories.add(new LineItem__History (Field='start_date__c'));
                
                //newvalue=date.today(),oldvalue=date.today().adddays(1)
            }

            for(LineItem__History lh : histories){
                fieldMap.put(lh.id+'_new','__');
                fieldMap.put(lh.id+'_old','__');
                
                if(lh.newvalue != null && lh.newvalue instanceof date){
                    fieldMap.put(lh.id+'_new',getString((date) lh.newvalue));
                }
                if(lh.oldvalue != null && lh.oldvalue instanceof date){
                    fieldMap.put(lh.id+'_old',getString((date) lh.oldvalue));
                }                
            }
            
            return histories;
        }
    }
    
    public string getString(Date d){
        return d.day()+'/'+d.month()+'/'+d.year();
    }
    
    public static testMethod void testControllerHistoryTracking(){
        Opportunity o = new Opportunity(name = 'Opportunity Test',stageName = 'Open',closeDate = date.today());
        insert o; 
        lineitem__c li = new lineitem__c(opportunity__c=o.id,start_date__c=date.today());
        insert li;
        ControllerHistoryTracking c = new ControllerHistoryTracking();
        ApexPages.CurrentPage().getParameters().put('id',li.id);
        c.getString(li.start_date__c);
        list<LineItem__History> histories = c.histories;
    }

}