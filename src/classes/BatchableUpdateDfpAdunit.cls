global class BatchableUpdateDfpAdunit implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
    private AdUnit__c[] adUnitsWithParents = new AdUnit__c[]{};
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
    
    
    public BatchableUpdateDfpAdunit() {
        this(100);
        system.debug('costruttore');
    }
    
    
    public BatchableUpdateDfpAdunit(Integer numCallouts) {
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
        AdUnit__c  inv =[Select i.id,i.name, i.path__c, i.LastModifiedDate From AdUnit__c  i ORDER BY LastModifiedDate  DESC limit 1];
        
        DfpDM_RetrievalDate__c dfp_date=[Select d.Name, d.Id, d.DfpDM_LastRetrieval__c From DfpDM_RetrievalDate__c d where name = 'AdUnit'];
        
        String lastMDdate = dfp_date.DfpDM_LastRetrieval__c.format('YYYY-MM-dd\'T\'HH:mm:ss');
        system.debug('lastMDdate: ' + lastMDdate);
        
        DfpInventoryService.Statement filterStatement = new DfpInventoryService.Statement();
        filterStatement.query = 'WHERE lastModifiedDateTime >\'' + lastMDdate + '\' and id != 0 LIMIT 1000 OFFSET ' + currentOffset;
   // prendere gli inattivi e archiviati usare con la massima cautela!!! a tuo rischio e pericolo DANGER!!!! PD PD PD    filterStatement.query = 'WHERE Status in (\'INACTIVE\' , \'ARCHIVED\') and id != 0 LIMIT 1000 OFFSET ' + currentOffset;
        
        system.debug('query '+filterStatement.query );
        DfpInventoryService.AdUnitPage getAdUnitsByStatement = Test.isRunningTest() ? UtilityAdUnit.getTestObject() : dfp.inventoryService.getAdUnitsByStatement(filterStatement);
        if(getAdUnitsByStatement.results != null) {
            System.debug('ADUNITS!!! ' + getAdUnitsByStatement.results.size());
            buffer = (Object []) getAdUnitsByStatement.results;
            bufferIndex = 0;
            currentOffset += 1000;
        }
    }
    
    
    global void execute(Database.BatchableContext BC, Object[] scope) {
        system.debug('execute');
        fillBuffer();
        if(buffer.isEmpty()) return;
        
        DfpInventoryService.AdUnit[] adUnitsToUpsert = new DfpInventoryService.AdUnit[]{};
        
        for(Object x : buffer) {
            if(x instanceof DfpInventoryService.AdUnit) {
                adUnitsToUpsert.add((DfpInventoryService.AdUnit) x);
            }
        }
        
        if(!adUnitsToUpsert.isEmpty()) upsert UtilityAdUnit.processStatement(adUnitsToUpsert, adUnitsWithParents) AdUnit__c.Fields.idDfp__c;
    }
    
    
    global void finish(Database.BatchableContext BC) {
        upsert adUnitsWithParents AdUnit__c.Fields.idDfp__c;
        
        // Aggiorna data ultimo recupero AdUnits
        Datetime RunDate =  Datetime.now();
        system.debug('RunDate: ' + RunDate.format('YYYY-MM-dd\'T\'HH:mm:ss'));
        DfpDM_RetrievalDate__c dfp_date = [Select Name, Id, DfpDM_LastRetrieval__c From DfpDM_RetrievalDate__c where name = 'AdUnit'];
        dfp_date.DfpDM_LastRetrieval__c = RunDate;
        update dfp_date;
        system.debug('DfpDM_LastRetrieval aggiornata con RunDate: ' + RunDate.format('YYYY-MM-dd\'T\'HH:mm:ss'));
        
        Database.executeBatch(new BatchableUpsertImpressionStimate(), 5);
    }
}