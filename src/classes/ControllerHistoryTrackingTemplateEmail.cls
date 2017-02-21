public class ControllerHistoryTrackingTemplateEmail{
    public string sobjectid {get;set;}
    public dateTime dataUltimaRiapertura {get;set;}
    
    Map<String, Schema.SObjectField> liFields = Schema.SObjectType.LineItem__c.fields.getMap();
    
    
    public String fieldsChanged{
        get{
            list<string> fieldChanged = new list<string>();
            for(AggregateResult ar : [Select Field From LineItem__History where parentid =: sobjectid and CreatedDate >= : dataUltimaRiapertura group by Field]){
                string s = (string) ar.get('Field');
                if(liFields.get(s) != null && s != 'stato_lavorazione_oas__c'){
                    fieldChanged.add(liFields.get(s).getDescribe().getLabel());
                }
            }

            return String.join(fieldChanged,',&nbsp;');
        }
    }
    
    public static testMethod void testControllerHistoryTracking(){
        Opportunity o = new Opportunity(name = 'Opportunity Test',stageName = 'Open',closeDate = date.today());
        insert o; 
        lineitem__c li = new lineitem__c(opportunity__c=o.id,start_date__c=date.today());
        insert li;
        ControllerHistoryTrackingTemplateEmail c = new ControllerHistoryTrackingTemplateEmail();
        c.sobjectid = li.id;
        c.dataUltimaRiapertura = system.now().addDays(-1);
        insert new LineItem__History(parentid=li.id,field='Start_date__c');
        String s = c.fieldsChanged;
        
    }
}