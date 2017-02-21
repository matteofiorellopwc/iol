public class ControllerLabel {

    public Id objId {get;set;}
    private Boolean isProduct {
        get {
            if(objId == null) return null;
            return (objId.getSObjectType() == Product2.SObjectType);
        }
    }
    public List<label> labels {get;set;}
    
    public id appLabelToDelete {get;set;}

    public class label{
        public label__c label {get;set;}
        public boolean checked {get;set;}
    }
    
    public list<AppliedLabel__c> existingLabel {get;set;}
    
    public ControllerLabel(){
        this.objId = (Id)ApexPages.CurrentPage().getParameters().get('id');
        existingLabel = [SELECT Label__c,Label__r.name,Label__r.description__c FROM AppliedLabel__c WHERE Product__c = :objId OR Line_Item__c = :objId];
        set<id> appliedLabel = new set<id>();
        for(AppliedLabel__c al : existingLabel){
            appliedLabel.add(al.Label__c);
        }
        
        labels = new list<label>();
        for(label__c l : [select id,name,description__c from label__c where isActive__c = true]){
            if(!appliedLabel.contains(l.id)){
                label ll = new label();
                ll.label = l;
                ll.checked = false;
                labels.add(ll);
            }
        }
    }

    public PageReference customSave(){
        list<AppliedLabel__c> appliedLabelsToInsert = new list<AppliedLabel__c>();
        for(label l : labels){
            if(l.checked){
                AppliedLabel__c al = new AppliedLabel__c();
                al.Label__c = l.label.id;
                al.Line_Item__c = isProduct ? null : objId;
                al.Product__c = isProduct ? objId : null;
                appliedLabelsToInsert.add(al);
            }
        }
        
        insert appliedLabelsToInsert;
        //delete existingLabel;
        //existingLabel = [select Label__c,Label__r.name,Label__r.description__c from AppliedLabel__c where Line_Item__c =: lineItemid];
        PageReference p = new PageReference('/apex/editLabelComponent?id='+objId+'&editable='+ApexPages.currentPage().getParameters().get('editable'));
        p.setRedirect(true);
        return p;
    }
    
    public void deleteAppLabel(){
        AppliedLabel__c al = [select id from AppliedLabel__c where id =: appLabelToDelete];
        delete al;
        existingLabel = [SELECT Label__c,Label__r.name,Label__r.description__c FROM AppliedLabel__c WHERE Product__c = :objId OR Line_Item__c = :objId];
    }
    
     static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;
        
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        
        LineItem__c li = new LineItem__c();
        li.product__c = p.id;
        li.opportunity__c = o.id;
        insert li;
                
        label__c l = new Label__c();
        l.isActive__c = true;
        l.type__c = 'COMPETITIVE_EXCLUSION';
        insert l;
        
        ApexPages.CurrentPage().getParameters().put('id',li.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','LineItem__c');
        
        ControllerLabel cl = new ControllerLabel();
        cl.labels[0].checked = true;
        cl.customSave();
                
        cl = new ControllerLabel();
        cl.appLabelToDelete = cl.existingLabel[0].id;
        System.debug(LineItemTriggerHandler.skipUpdateLineItem);
        LineItemTriggerHandler.skipUpdateLineItem = false;
        LineItemTriggerHandler.skipValidationTotali = true;
        cl.deleteAppLabel();
        

     }

}