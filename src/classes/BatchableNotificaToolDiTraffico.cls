global class BatchableNotificaToolDiTraffico implements Database.Batchable<sObject> {
    
     global BatchableNotificaToolDiTraffico (){
                //Batch Constructor
     }
//     private static String query = 'SELECT Name, Start_Date__c, End_Date__c, Delivery_Model__c FROM LineItem__c WHERE Name = :LI_0000053933';
     private static String query ='SELECT Notifica_tool_di_traffico__c FROM Opportunity WHERE Ultima_sincronizzazione_DFP__c = TODAY';
     // Start Method
     global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
      }
    
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
     for(Opportunity opp : scope) {
           
            
           
              opp.Notifica_tool_di_traffico__c = true;
              
          }
          update scope;             
        
    }
         global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
    }
}