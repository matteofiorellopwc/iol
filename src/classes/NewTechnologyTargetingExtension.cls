public class NewTechnologyTargetingExtension {
    ApexPages.StandardController controller {get;set;}
    public List<selectOption> technologyTypeItems {get;set;}
    public list<selectedValueClass> selectedValues {get;set;}
    
    
    public class selectedValueClass{
        public boolean checked {get;set;}
        public string id {get;set;}
    }
    
    public PublisherQueryLanguageUtility queryUtil {set;get;}  

    public NewTechnologyTargetingExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        TechnologyTargeting__c record = (TechnologyTargeting__c) controller.getRecord();
        set<string> alreadyMapping = new set<string>();
        
        for(TechnologyTargeting__c tt : [select type__c from TechnologyTargeting__c where Product__c =: record.product__c and LineItem__c =: record.LineItem__c ]){
            alreadyMapping.add(tt.type__c);
        }
        
        technologyTypeItems = getTechnologyType(alreadyMapping);
        
        queryUtil = new PublisherQueryLanguageUtility();
        
        
        selectedValues = new list<selectedValueClass>();
        
        if(record.type__c != '' && record.type__c != null){
            runQuery();
        }
        
    }
    
    public PageReference customSave(){
        system.debug('custom save');

        string values = '';

        for(selectedValueClass svc : selectedValues){
            if(svc.checked){
                values += svc.id+',';
            }
        }
        if(values.length() > 0){
            values += ',';
            values = values.replace(',,','');
        }
        
                

        controller.getRecord().put('valueIds__c',values);
        return controller.save();    
    }
    
    
    public List<selectOption> getTechnologyType(set<string> alreadyMapping){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = TechnologyTargeting__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('', '--none--'));
            
        for( Schema.PicklistEntry f : ple){
            if(!alreadyMapping.contains(f.getValue())){
                options.add(new SelectOption(f.getValue(),f.getLabel()));
            }
        }
        return options;
    }
    
    public void resetType(){
        controller.getRecord().put('Type__c',null);
        queryUtil.table = new Map<String,List<PublisherQueryLanguageUtility.Value>>();
        queryUtil.ii = new List<integer>();
    }
    
    public void runQuery(){
        string type = (string) controller.getRecord().get('Type__c');
        string valueIds = (string) controller.getRecord().get('valueIds__c');
        valueids = (valueids != null) ? valueids : '';
        queryUtil.query = 'select * from '+type+' limit 1000 offset 0';
        system.debug('queryUtil.query: '+queryUtil.query);
        queryUtil.runQuery();
        
        selectedValues = new list<selectedValueClass>();
        
        for(PublisherQueryLanguageUtility.Value v : queryUtil.table.get('id')){
            selectedValueClass ssc = new selectedValueClass();
            ssc.checked = valueIds.contains(v.value);
            ssc.id = v.value;    
            selectedValues.add(ssc);
        }
        
        
    }
    
    

}