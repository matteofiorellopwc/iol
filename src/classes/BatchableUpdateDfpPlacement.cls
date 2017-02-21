global class BatchableUpdateDfpPlacement implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
    private DfpIntegration dfp;
    private Integer currentObject = 0;
    private Integer currentOffset = 0;
    private Object[] buffer = new Object[]{};
    private Integer bufferIndex = 0;
    private DfpDataModelIterable it; 
    
    public class DfpDataModelIterator implements Iterator<Object> {
        private Integer[] numCallouts = new Integer[]{};
        private Integer counter = 0;

        public DfpDataModelIterator(Integer numCallouts) {
            for(Integer i = 0; i < numCallouts; i++) {
                this.numCallouts.add(i);
            }           
        }

        public Boolean hasNext() {
            return counter <= numCallouts.size() -1;
        }
        
        public Object next() {
            return numCallouts[counter++];
        }
    }
    
    global class DfpDataModelIterable implements Iterable<Object> {
        private DfpDataModelIterator it;
        
        private DfpDataModelIterable(Integer numCallouts) {
            this.it = new DfpDataModelIterator(numCallouts);
        }
        
        global Iterator<Object> Iterator(){
            return it;
        }               
    }
    
    public BatchableUpdateDfpPlacement() {
      
        this(100);
        system.debug('costruttore');
    }
    
    public BatchableUpdateDfpPlacement(Integer numCallouts) {
         system.debug('costruttore callouts ' +numCallouts);   
        this.it = new DfpDataModelIterable(numCallouts);        
    }
    
    global Iterable<Object> start(Database.BatchableContext BC) {
      system.debug('metodostart iterable');
        dfp = new DfpIntegration();         
        return (Iterable<Object>) it;
    }
    
    private void fillBuffer() {
      system.debug('fillBuffer');
  	DfpDM_RetrievalDate__c dfp_date=[Select d.Name, d.Id, d.DfpDM_LastRetrieval__c From DfpDM_RetrievalDate__c d where name = 'Placement'];
    String lastMDdate=dfp_date.DfpDM_LastRetrieval__c.format('YYYY-MM-dd\'T\'HH:mm:ss');
    system.debug(' lastMDdate     '+lastMDdate);
            DfpPlacementService.Statement filterStatement = new DfpPlacementService.Statement();
            filterStatement.query ='WHERE lastModifiedDateTime >\''+lastMDdate +'\' and id != 0 LIMIT 1000 OFFSET ' + currentOffset;   
            system.debug('query '+filterStatement.query );
            DfpPlacementService.PlacementPage getPlacementsByStatement = Test.isRunningTest() ? UtilityPlacement.getTestObject() : dfp.placementService.getPlacementsByStatement(filterStatement);
            if(getPlacementsByStatement.results != null) {
                buffer = (Object []) getPlacementsByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            }   
     
    }
        
      
    
    global void execute(Database.BatchableContext BC, Object[] scope) {
      system.debug('execute');
        fillBuffer();
        if(buffer.isEmpty()) return;
        
        DfpPlacementService.Placement[] placementsToUpsert = new DfpPlacementService.Placement[]{};
      
        for(Object x : buffer) {
            if(x instanceof DfpPlacementService.Placement) {
                   placementsToUpsert.add((DfpPlacementService.Placement) x);
            }
            
        } 
        if(!placementsToUpsert.isEmpty()) upsert UtilityPlacement.processStatement(placementsToUpsert) Placement__c.Fields.idDfp__c;
      }
    
    global void finish(Database.BatchableContext BC) {

        Datetime d=  Datetime.now();
        system.debug(d);
        DfpDM_RetrievalDate__c dfp_date=[Select d.Name, d.Id, d.DfpDM_LastRetrieval__c From DfpDM_RetrievalDate__c d where name = 'Placement'];
    	dfp_date.DfpDM_LastRetrieval__c=d;
    	system.debug('dataDFP aggiornata'+d.format('YYYY-MM-dd\'T\'HH:mm:ss'));
 		update dfp_date;
     
    }
}