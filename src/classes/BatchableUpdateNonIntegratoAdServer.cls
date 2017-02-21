public class BatchableUpdateNonIntegratoAdServer implements Database.Batchable<SObject>, Database.Stateful {
  private String query = 'SELECT Id, NonIntegratoAdServer__c  FROM LineItem__c where Integrato_con_OAS_formula__c = \'true\' ';
  
  private String errorCsv = '';
  private boolean doDml; //if false, update and rollback
  private boolean newValue; //new value for NonIntegratoAdServer__c
  
    public Database.Querylocator start(Database.BatchableContext BC) {
        errorCsv = 'LineItemId,ErrorMessage,StatusCode\n';
        return Database.getQueryLocator(query);
    }
  
    public BatchableUpdateNonIntegratoAdServer(boolean newValue, boolean doDml){
        query += 'and NonIntegratoAdServer__c = false';
        this.doDml = doDml;
        this.newValue = newValue;
    }
  
    public BatchableUpdateNonIntegratoAdServer(boolean newValue, boolean doDml,string filter){
        query += filter;
        this.doDml = doDml;
        this.newValue = newValue;
    }
  
  public void execute(Database.BatchableContext BC, SObject[] scope) {
    System.savePoint sp = Database.setSavePoint();
    try{
        for(SObject so : scope) {
            LineItem__c li = (LineItem__c) so;
            li.NonIntegratoAdServer__c = newValue;
        }
        
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipValidationAdServer = true;
        Database.SaveResult[] saveRes = database.update(scope,false);
        for(integer i=0;i<saveRes.size();i++){
            Database.SaveResult sr = saveRes[i];
            if(! sr.isSuccess()){
                errorCsv += scope[i].get('Id') + ',"' + sr.getErrors() + '",' + '\n';
            }
        }
        
    }finally {
        if(!doDml){
            Database.rollback(sp);
        }
    }
  }
  
  public void finish(Database.BatchableContext BC) {
    delete [SELECT Id FROM Document WHERE Name = 'SetNonIntegratoAdServerLineItem.csv' AND FolderId = :UserInfo.getUserId()];
    Document d = new Document();
    d.Name = 'SetNonIntegratoAdServerLineItem.csv';
    d.folderId = UserInfo.getUserId();
    d.body = Blob.valueOf(errorCsv);
    insert d;
  }
  
  public static testMethod void testBatchableUpdateNonIntegratoAdServer(){
      Opportunity o = new Opportunity(name='test',closeDate=date.today(),stageName='test');
      insert o;
      Product2 p = new Product2(name='test',family='Banner');
      insert p;
      LineItem__c li = new lineitem__c(ad_Server__c='OAS',delivery_model__c='CPM',opportunity__c=o.id,product__c=p.id);
      insert li;
      Database.executeBatch(new BatchableUpdateNonIntegratoAdServer(false,false),10);
  }
  
  
}