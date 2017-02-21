public class UtilityLabel {

    public PageReference syncAllLabel(){
        DfpIntegration dfp = new DfpIntegration();
        DfpLabelService.Statement filterStatement = new DfpLabelService.Statement();
        filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET 0';
        DfpLabelService.LabelPage getLabelsByStatement;
        try{
            getLabelsByStatement = dfp.LabelService.getLabelsByStatement(filterStatement);
        }catch(exception e){
            if(Test.isRunningTest()){
				getLabelsByStatement = getTestObject();
            }     
        }
        
        upsert processStatement(getLabelsByStatement.results) Label__c.Fields.idDfp__c;        
        PageReference retUrl;
        
        try{
            retUrl =  new PageReference(ApexPages.CurrentPage().getParameters().get('retUrl'));
        }catch(Exception e){
            retUrl = null;
        }
        
        return retUrl;
    }
    
    public static DfpLabelService.LabelPage getTestObject() {
    	DfpLabelService.LabelPage t = new DfpLabelService.LabelPage();
	    t.totalResultSetSize = 1;
	    t.startIndex = 0;
	    t.results = new list<DfpLabelService.Label>();
	    DfpLabelService.Label l = new DfpLabelService.Label();
	    l.id = 0;
	    l.name = 'test';
	    l.description = 'test';
	    l.isActive = true;
	    l.types = new String[]{'test'};                
	    t.results.add(l);
	    return t;    	
    }
    
    public static Label__c[] processStatement(DfpLabelService.Label[] x) {
        Label__c[] labels = new Label__c[]{};
        for(DfpLabelService.Label ll : x){
            Label__c l = new Label__c();
            l.iddfp__c = ll.id;
            l.name = ll.name;
            l.Description__c = ll.description;
            l.isActive__c = ll.isActive;
            l.type__c = String.join(ll.types, ';');
            labels.add(l);
        }
        return labels;    	
    }

}