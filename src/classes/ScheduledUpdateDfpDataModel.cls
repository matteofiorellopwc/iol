global class ScheduledUpdateDfpDataModel implements Schedulable {
    private Integer numCallouts;
    
    global void execute(SchedulableContext sc) {
        updateDfpDataModel(numCallouts);
    }
    
    public static void updateDfpDataModel(Integer numCallouts) {
        Database.executeBatch(new BatchableUpdateDfpDataModel(numCallouts), 1);      
    }                  
    
    public ScheduledUpdateDfpDataModel() {
    	this(100);
    }
    
    public ScheduledUpdateDfpDataModel(Integer numCallouts) {
		this.numCallouts = numCallouts;
    }
    
    @isTest
    static void testScheduled() {
    	Test.startTest();
    	ScheduledUpdateDfpDataModel sch = new ScheduledUpdateDfpDataModel();
    	sch = new ScheduledUpdateDfpDataModel(1);
    	sch.execute(null);
    	Test.stopTest();
    }
}