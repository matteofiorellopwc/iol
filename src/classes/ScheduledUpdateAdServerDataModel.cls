/*
    System.schedule('ScheduledUpdateAdServerDataModel', '0 15 4-5 * * ?', new ScheduledUpdateAdServerDataModel());
    run every days at 4:15 am and 5:15 am.
    At 4:15 am executes batch for DFP data model and gets Pages and Setcion from OAS (future call)
    At 5:15 am executes batch from read Section details, this because is not allowed execute batch in a future call
*/
global class ScheduledUpdateAdServerDataModel implements Schedulable {
    private Integer numCallouts;
    
    global void execute(SchedulableContext sc) {
        updateDfpDataModel(numCallouts);
    }
    
    public static void updateDfpDataModel(Integer numCallouts) {
        if(datetime.now().hour() == 4){
            Database.executeBatch(new BatchableUpdateDfpDataModel(numCallouts), 1);
            updateOasDataModel();
        }else{
            Database.executeBatch(new BatchableUpsertDatamodelOas(),10);
        }
    }
    
    public ScheduledUpdateAdServerDataModel() {
        this(100);
    }
    
    public ScheduledUpdateAdServerDataModel(Integer numCallouts) {
        this.numCallouts = numCallouts;
    }
    
    @future(callout=true)
    public static void updateOasDataModel(){
        BatchableUpsertDatamodelOas.getPagesSection();
    }
    
    
    @isTest
    static void testScheduled() {
        Test.startTest();
        OasIntegrationTest.insertTestAuth();
        ScheduledUpdateAdServerDataModel sch = new ScheduledUpdateAdServerDataModel();
        sch = new ScheduledUpdateAdServerDataModel(1);
        sch.execute(null);
        Test.stopTest();
    }
}