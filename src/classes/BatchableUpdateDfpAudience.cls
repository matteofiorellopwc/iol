global class BatchableUpdateDfpAudience implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {

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
    
    public BatchableUpdateDfpAudience() {
      
        this(100);
        system.debug('costruttore');
    }
    
    public BatchableUpdateDfpAudience(Integer numCallouts) {
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
      DfpAudienceSegmentService.Statement filterStatement = new DfpAudienceSegmentService.Statement();
      filterStatement.query = 'WHERE id != 0    LIMIT 1000 OFFSET ' + currentOffset;
       DfpAudienceSegmentService.AudienceSegmentPage getAudienceSegmentValuesByStatement = Test.isRunningTest() ? UtilityCustomTargeting.getTestAudienceValueObject() : dfp.audienceSegmentService.getAudienceSegmentsByStatement(filterStatement);
            if(getAudienceSegmentValuesByStatement.results != null) {
                buffer = (Object []) getAudienceSegmentValuesByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            }   
            
    }
        
    private void movePointerToNextObject() {
        currentOffset = 0;
        buffer.clear();
        currentObject++;
        bufferIndex = 0;                    
    } 
    
    global void execute(Database.BatchableContext BC, Object[] scope) {
     system.debug('execute');
      fillBuffer();
     if(buffer.isEmpty()) return;
        DfpAudienceSegmentService.AudienceSegment[] audienceSegmentsToUpsert = new DfpAudienceSegmentService.AudienceSegment[]{};
  		    
        for(Object x : buffer) {
		 if(x instanceof DfpAudienceSegmentService.AudienceSegment && ((DfpAudienceSegmentService.AudienceSegment) x).type_x != 'THIRD_PARTY') 
                audienceSegmentsToUpsert.add((DfpAudienceSegmentService.AudienceSegment) x);      
        }         
         if(!audienceSegmentsToUpsert.isEmpty()) upsert UtilityCustomTargeting.processAudienceStatement(audienceSegmentsToUpsert) CustomTargetingValue__c.Fields.idDfp__c; 
      }
    
    global void finish(Database.BatchableContext BC) {
     
    }
}