global class ScheduledNotificaToolDiTraffico implements Schedulable {
   global void execute(SchedulableContext sc) {
          BatchableNotificaToolDiTraffico  b = new BatchableNotificaToolDiTraffico(); 
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b);
   }
}