global class MassDeleteAsset implements Database.Batchable<Sobject>
{
  global final String query = 'Select day__c FROM Asset where tipo__c=\'Erogato DFP Giornaliero\' and day__c < LAST_N_MONTHS:3 limit 5000';
 
  global Database.QueryLocator start(Database.BatchableContext BC)
  {
 
       return Database.getQueryLocator(query);
  }
 
    global void execute(Database.BatchableContext BC, List<Sobject> records)
   {
        delete records;
   }
 
  global void finish(Database.BatchableContext BC)
  {
  }
}