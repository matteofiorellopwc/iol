global class BatchableUpdateDfpCustomTargetValues implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {

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
    
    public BatchableUpdateDfpCustomTargetValues() {
      
        this(100);
        system.debug('costruttore');
    }
    
    public BatchableUpdateDfpCustomTargetValues(Integer numCallouts) {
         system.debug('costruttore callouts ' +numCallouts);   
        this.it = new DfpDataModelIterable(numCallouts);        
    }
    
    global Iterable<Object> start(Database.BatchableContext BC) {
      system.debug('metodostart iterable');
        dfp = new DfpIntegration();         
        return (Iterable<Object>) it;
    }
    
    private void fillBuffer() {
             	system.debug('DfpCustomTargetingService');
	            DfpCustomTargetingService.Statement filterStatement = new DfpCustomTargetingService.Statement();
	            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpCustomTargetingService.CustomTargetingValuePage getCustomTargetingValuesByStatement = Test.isRunningTest() ? UtilityCustomTargeting.getTestValueObject() : dfp.customtargetingService.getCustomTargetingValuesByStatement(filterStatement);
	            if(getCustomTargetingValuesByStatement.results != null) {
	                buffer = (Object []) getCustomTargetingValuesByStatement.results;
	                system.debug('val obj '+getCustomTargetingValuesByStatement.results.size());
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
        
        DfpCustomTargetingService.CustomTargetingValue[] customTargetingValuesToUpsert = new DfpCustomTargetingService.CustomTargetingValue[]{};
     		    
        for(Object x : buffer) {
			if(x instanceof DfpCustomTargetingService.CustomTargetingValue) {
                customTargetingValuesToUpsert.add((DfpCustomTargetingService.CustomTargetingValue) x);
     		}    
        } 
        if(!customTargetingValuesToUpsert.isEmpty()) upsert UtilityCustomTargeting.processValueStatement(customTargetingValuesToUpsert) CustomTargetingValue__c.Fields.idDfp__c;
    
      }
    
    global void finish(Database.BatchableContext BC) {


     
    }
}