global class BatchableUpdateDfpDataModel implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
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
    
    public BatchableUpdateDfpDataModel() {
        this(100);
    }
    
    public BatchableUpdateDfpDataModel(Integer numCallouts) {
        this.it = new DfpDataModelIterable(numCallouts);        
    }
    
    global Iterable<Object> start(Database.BatchableContext BC) {
        dfp = new DfpIntegration();         
        return (Iterable<Object>) it;
    }
    
    private void fillBuffer() {
        if(currentObject == 0) {
            DfpInventoryService.Statement filterStatement = new DfpInventoryService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpInventoryService.AdUnitPage getAdUnitsByStatement = Test.isRunningTest() ? UtilityAdUnit.getTestObject() : dfp.inventoryService.getAdUnitsByStatement(filterStatement);  
            if(getAdUnitsByStatement.results != null) {
                System.debug('ADUNITS!!! ' + getAdUnitsByStatement.results.size());
                buffer = (Object []) getAdUnitsByStatement.results; 
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();      
            }       
        }
            
        if(currentObject == 1 || Test.isRunningTest()) {
            DfpLabelService.Statement filterStatement = new DfpLabelService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpLabelService.LabelPage getLabelsByStatement = Test.isRunningTest() ? UtilityLabel.getTestObject() : dfp.LabelService.getLabelsByStatement(filterStatement);
            if(getLabelsByStatement.results != null) {
                buffer = (Object []) getLabelsByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();
            }           
        } 
            
        if(currentObject == 2 || Test.isRunningTest()) {
            //dfp.customTargetingService.RequestHeader.networkCode = '5180';
            DfpCustomTargetingService.Statement filterStatement = new DfpCustomTargetingService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpCustomTargetingService.CustomTargetingKeyPage getCustomTargetingKeysByStatement = Test.isRunningTest() ? UtilityCustomTargeting.getTestKeyObject() : dfp.customtargetingService.getCustomTargetingKeysByStatement(filterStatement);
            if(getCustomTargetingKeysByStatement.results != null) {
                buffer = (Object []) getCustomTargetingKeysByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();
            }       
        }
            
        if(currentObject == 3 || Test.isRunningTest()) {
        	
        	movePointerToNextObject();
        	
        	/*
            dfp.audienceSegmentService.RequestHeader.networkCode = '5180';
            DfpAudienceSegmentService.Statement filterStatement = new DfpAudienceSegmentService.Statement();
            filterStatement.query = 'WHERE id != 0    LIMIT 1000 OFFSET ' + currentOffset;
            // filterStatement.query = 'WHERE id != 0 AND type != :var1   LIMIT 1000 OFFSET ' + currentOffset;
            //filterStatement.query = 'WHERE id != 0 AND type != \'THIRD_PARTY\'   LIMIT 1000 OFFSET ' + currentOffset;
          system.debug( 'dio aiutami ');
            filterStatement.values = new List<DfpAudienceSegmentService.String_ValueMapEntry>();
           system.debug( 'size : '+filterStatement.values.size());
            
           DfpAudienceSegmentService.String_ValueMapEntry val = new DfpAudienceSegmentService.String_ValueMapEntry();
            
           
           
            val.key = 'var1';
            system.debug( 'DfpAudienceSegmentService.String_ValueMapEntry : '+val);
            
            
            DfpAudienceSegmentService.TextValue text_val= new DfpAudienceSegmentService.TextValue();
            text_val.value = 'THIRD_PARTY';
            
             val.value = text_val;
           
           
           
            
           
           // Create two mapped parameters: id and status
String_ValueMapEntry[] values = new String_ValueMapEntry[2];
values[0] = new String_ValueMapEntry("id", new NumberValue(null, "123"));
values[1] = new String_ValueMapEntry("status", new TextValue(null, "APPROVED"));

// Create our statement and map our bind variables
Statement statement = new Statement();
statement.setQuery("WHERE id = :id AND status = :status LIMIT 500");
statement.setValues(values);
           
           
           
         
            filterStatement.values.add(val);

            DfpAudienceSegmentService.AudienceSegmentPage getAudienceSegmentValuesByStatement = Test.isRunningTest() ? UtilityCustomTargeting.getTestAudienceValueObject() : dfp.audienceSegmentService.getAudienceSegmentsByStatement(filterStatement);
            if(getAudienceSegmentValuesByStatement.results != null) {
                buffer = (Object []) getAudienceSegmentValuesByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();
            }       
            */
        }

        if(currentObject == 4 || Test.isRunningTest()) {
            //dfp.customTargetingService.RequestHeader.networkCode = '5180';
            DfpCustomTargetingService.Statement filterStatement = new DfpCustomTargetingService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpCustomTargetingService.CustomTargetingValuePage getCustomTargetingValuesByStatement = Test.isRunningTest() ? UtilityCustomTargeting.getTestValueObject() : dfp.customtargetingService.getCustomTargetingValuesByStatement(filterStatement);
            if(getCustomTargetingValuesByStatement.results != null) {
                buffer = (Object []) getCustomTargetingValuesByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();
            }       
        }
            
        if(currentObject == 5 || Test.isRunningTest()) {
            DfpPlacementService.Statement filterStatement = new DfpPlacementService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpPlacementService.PlacementPage getPlacementsByStatement = Test.isRunningTest() ? UtilityPlacement.getTestObject() : dfp.placementService.getPlacementsByStatement(filterStatement);
            if(getPlacementsByStatement.results != null) {
                buffer = (Object []) getPlacementsByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();
            }       
        }

        if(currentObject == 6 || Test.isRunningTest()) {
            DfpTeamService.Statement filterStatement = new DfpTeamService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpTeamService.TeamPage getTeamsByStatement = Test.isRunningTest() ? UtilityTeam.getTestObject() : dfp.TeamService.getTeamsByStatement(filterStatement);
            if(getTeamsByStatement.results != null) {
                buffer = (Object []) getTeamsByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            } else {
                movePointerToNextObject();
            }       
        }           
    }
        
    private void movePointerToNextObject() {
        currentOffset = 0;
        buffer.clear();
        currentObject++;
        bufferIndex = 0;                    
    }       
    
    global void execute(Database.BatchableContext BC, Object[] scope) {
        fillBuffer();
        if(buffer.isEmpty()) return;
        
        DfpInventoryService.AdUnit[] adUnitsToUpsert = new DfpInventoryService.AdUnit[]{};
        DfpLabelService.Label[] labelsToUpsert = new DfpLabelService.Label[]{};
        DfpCustomTargetingService.CustomTargetingKey[] customTargetingKeysToUpsert = new DfpCustomTargetingService.CustomTargetingKey[]{};
        DfpCustomTargetingService.CustomTargetingValue[] customTargetingValuesToUpsert = new DfpCustomTargetingService.CustomTargetingValue[]{};
        DfpPlacementService.Placement[] placementsToUpsert = new DfpPlacementService.Placement[]{};
        DfpTeamService.Team[] teamsToUpsert = new DfpTeamService.Team[]{};
        DfpAudienceSegmentService.AudienceSegment[] audienceSegmentsToUpsert = new DfpAudienceSegmentService.AudienceSegment[]{};

        for(Object x : buffer) {
            if(x instanceof DfpInventoryService.AdUnit) {
                adUnitsToUpsert.add((DfpInventoryService.AdUnit) x);        
            } else if(x instanceof DfpLabelService.Label) {
                labelsToUpsert.add((DfpLabelService.Label) x);
            } else if(x instanceof DfpCustomTargetingService.CustomTargetingKey) {
                customTargetingKeysToUpsert.add((DfpCustomTargetingService.CustomTargetingKey) x);
            } else if(x instanceof DfpCustomTargetingService.CustomTargetingValue) {
                customTargetingValuesToUpsert.add((DfpCustomTargetingService.CustomTargetingValue) x);
            } else if(x instanceof DfpPlacementService.Placement) {
                placementsToUpsert.add((DfpPlacementService.Placement) x);
            } else if(x instanceof DfpTeamService.Team) {
                teamsToUpsert.add((DfpTeamService.Team) x);
            } else if(x instanceof DfpAudienceSegmentService.AudienceSegment && ((DfpAudienceSegmentService.AudienceSegment) x).type_x != 'THIRD_PARTY') {
                audienceSegmentsToUpsert.add((DfpAudienceSegmentService.AudienceSegment) x);
                system.debug('@@@audiencesegment ' + ((DfpAudienceSegmentService.AudienceSegment) x));
            }
        }
        
        if(!adUnitsToUpsert.isEmpty()) upsert UtilityAdUnit.processStatement(adUnitsToUpsert, adUnitsWithParents) AdUnit__c.Fields.idDfp__c;
        if(!labelsToUpsert.isEmpty()) upsert UtilityLabel.processStatement(labelsToUpsert) Label__c.Fields.idDfp__c;
        if(!customTargetingKeysToUpsert.isEmpty()) upsert UtilityCustomTargeting.processKeyStatement(customTargetingKeysToUpsert) CustomTargetingKey__c.Fields.idDfp__c;
        if(!customTargetingValuesToUpsert.isEmpty()) upsert UtilityCustomTargeting.processValueStatement(customTargetingValuesToUpsert) CustomTargetingValue__c.Fields.idDfp__c;
        if(!placementsToUpsert.isEmpty()) upsert UtilityPlacement.processStatement(placementsToUpsert) Placement__c.Fields.idDfp__c;
        if(!teamsToUpsert.isEmpty()) upsert UtilityTeam.processStatement(teamsToUpsert) Team__c.Fields.idDfp__c;
        if(!audienceSegmentsToUpsert.isEmpty()) upsert UtilityCustomTargeting.processAudienceStatement(audienceSegmentsToUpsert) CustomTargetingValue__c.Fields.idDfp__c;
    }
    
    global void finish(Database.BatchableContext BC) {
        upsert adUnitsWithParents AdUnit__c.Fields.idDfp__c; 
        Database.executeBatch(new BatchableUpsertImpressionStimate(), 5);
    }
    
}