global class schedule_BatchMassDeleteAsset implements Schedulable{
 		global void execute(SchedulableContext sc) {
        Database.executeBatch(new MassDeleteAsset(), 100);
   }
}