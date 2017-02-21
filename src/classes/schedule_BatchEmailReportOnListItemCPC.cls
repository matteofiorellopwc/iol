global class schedule_BatchEmailReportOnListItemCPC implements Schedulable {
   global void execute(SchedulableContext sc) {
          BatchEmailReportOnListItemCPC  b = new BatchEmailReportOnListItemCPC(); 
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b);
   }
}