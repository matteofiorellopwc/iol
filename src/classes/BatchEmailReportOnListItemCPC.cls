global class BatchEmailReportOnListItemCPC implements Database.Batchable<sObject> {
    
     global BatchEmailReportOnListItemCPC (){
                //Batch Constructor
     }
//     private static String query = 'SELECT Name, Start_Date__c, End_Date__c, Delivery_Model__c FROM LineItem__c WHERE Name = :LI_0000053933';
     private static String query =' SELECT Name, Start_Date__c, End_Date__c, Delivery_Model__c FROM LineItem__c WHERE Delivery_Model__c = \'CPC\' AND End_Date__c  >= YESTERDAY AND Start_Date__c < TODAY AND (Opportunity_Stage__c = \'Chiusa vinta\' OR Opportunity_Stage__c = \'Chiusa Vinta - in modifica\') AND Id_DFP__c != null ';
     // Start Method
     global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
      }
    
    
    global void execute(Database.BatchableContext BC, List<LineItem__c> scope) {
     for(LineItem__c opp : scope) {
           
            
           
              opp.Invia_report_giornaliero_CPC_check__c = true;
              System.debug('Invia report giornaliero CPC_check: ' + opp);
              
          }
          update scope;             
        
    }
    
     
       
         global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
    }
}