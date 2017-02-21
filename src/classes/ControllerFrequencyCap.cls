/*
    Controller for frequencyCap.component
    Manage frequency cap for product and line item (both for DFP and OAS)
*/
public class ControllerFrequencyCap{

    public String id {get;set;}
    public String sobjectName{get;set;} //'LineItem__c' or 'Product2'
    public sobject parent {get;set;} //LineItem__c or Product2 object
    public integer indexToDelete {get;set;}

    public List<FrequencyCap__c> frequencyCaps {get;set;}
    List<FrequencyCap__c> frequencyCapsToDelete;
    
    public ControllerFrequencyCap(){
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
        string sftable = sobjectName == 'Product__c' ? 'Product2' : 'LineItem__c';
        parent = database.query('select Ad_Server__c, OasPrimaryFrequencyClickPerVisitor__c, OasPrimaryFrequencyImpPerVisitor__c, OasSecondaryFrequencyImpPerVisitor__c, OasPrimaryFreqScope__c, OasSecondaryFreqScope__c from '+sftable+ ' where id = \''+id+'\'');

        //set defaul value
        //for OAS frequency caps are saved in line item fields
        if(parent.get('Ad_Server__c') == 'OAS'){
            parent.put('OasPrimaryFrequencyClickPerVisitor__c',parent.get('OasPrimaryFrequencyClickPerVisitor__c') == null ? '0' : parent.get('OasPrimaryFrequencyClickPerVisitor__c')); 
            parent.put('OasPrimaryFrequencyImpPerVisitor__c',parent.get('OasPrimaryFrequencyImpPerVisitor__c') == null ? '0' : parent.get('OasPrimaryFrequencyImpPerVisitor__c')); 
            parent.put('OasSecondaryFrequencyImpPerVisitor__c',parent.get('OasSecondaryFrequencyImpPerVisitor__c') == null ? '0' : parent.get('OasSecondaryFrequencyImpPerVisitor__c')); 
            parent.put('OasPrimaryFreqScope__c',parent.get('OasPrimaryFreqScope__c') == null ? '0' : parent.get('OasPrimaryFreqScope__c')); 
            parent.put('OasSecondaryFreqScope__c',parent.get('OasSecondaryFreqScope__c') == null ? '0' : parent.get('OasSecondaryFreqScope__c')); 
        }
        
        //for DFP frequency caps are saved in frequencyCap__c object (related to line item or product)
        String query = 'select maxImpressions__c,numTimeUnits__c,timeUnit__c,lineitem__c,product__c from frequencyCap__c where '+sobjectName+' = \''+id+'\'';
        frequencyCapsToDelete = Database.query(query);
        frequencyCaps = new List<FrequencyCap__c>();
        for(FrequencyCap__c fc : frequencyCapsToDelete){
            frequencyCaps.add(fc.clone());
        }
    }
    
    /*
        delete previous frequency caps and add the new
    */
    public PageReference customSave(){
       Pagereference p = null;
       try{
        insert frequencyCaps;
        delete frequencyCapsToDelete;
        p = new PageReference('/apex/editfrequencyCapComponent?sobjectName=' + sobjectName + '&id=' + id + '&editMode=false' + '&editable=' + ApexPages.currentPage().getParameters().get('editable'));
        p.setRedirect(true);
       }catch(DMLException ex){
          ApexPages.addMessages(ex);
       }
        return p;
    }
    
    public void customSaveOas(){
       try{
        update parent;
       }catch(DMLException ex){
          ApexPages.addMessages(ex);
          return;
       }
       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,'Salvato'));
    }
    
    public void addFrequencyCap(){
        FrequencyCap__c fc = new FrequencyCap__c();
        fc.put(sobjectName,id);
        frequencyCaps.add(fc);
    }
    
    public void deleteFrequencyCap(){
        frequencyCaps.remove(indexToDelete);
    }
    
  static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;
        
        frequencyCap__c fc = new frequencyCap__c();
        
        fc.maxImpressions__c = 10; 
        fc.numTimeUnits__c = 10;
        fc.Product__c = p.Id;
        insert fc;      
        
        ApexPages.CurrentPage().getParameters().put('id',p.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','Product__c');
        
        
        ControllerFrequencyCap cfc = new ControllerFrequencyCap();
        cfc.indexToDelete = 0;
        cfc.addFrequencyCap();
        cfc.customSave();
        cfc.deleteFrequencyCap();
     }
    
    
}