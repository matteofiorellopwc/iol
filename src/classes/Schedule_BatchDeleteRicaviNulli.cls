global class Schedule_BatchDeleteRicaviNulli implements Schedulable{
 		
 		
 		global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchableDeleteRicaviNulli());
      //  Database.executeBatch(new BatchableDeleteRicaviNulli());
      //  Database.executeBatch(new BatchableDeleteRicaviNulli('2016-11-01','2017-03-31'));
      //  Database.executeBatch(new BatchableDeleteRicaviNulli('2016-11-01',''));
      //  Database.executeBatch(new BatchableDeleteRicaviNulli('','2017-03-31'));
   }
}