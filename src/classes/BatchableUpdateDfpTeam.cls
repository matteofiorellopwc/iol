global class BatchableUpdateDfpTeam implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
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
    
    public BatchableUpdateDfpTeam() {
      
        this(100);
        system.debug('costruttore');
    }
    
    public BatchableUpdateDfpTeam(Integer numCallouts) {
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
  	DfpDM_RetrievalDate__c dfp_date=[Select d.Name, d.Id, d.DfpDM_LastRetrieval__c From DfpDM_RetrievalDate__c d where name = 'Team'];
    String lastMDdate=dfp_date.DfpDM_LastRetrieval__c.format('YYYY-MM-dd\'T\'HH:mm:ss');
		    system.debug(' lastMDdate     '+lastMDdate);
            DfpTeamService.Statement filterStatement = new DfpTeamService.Statement();
            filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET ' + currentOffset;
            DfpTeamService.TeamPage getTeamsByStatement = Test.isRunningTest() ? UtilityTeam.getTestObject() : dfp.TeamService.getTeamsByStatement(filterStatement);
            if(getTeamsByStatement.results != null) {
                buffer = (Object []) getTeamsByStatement.results;
                bufferIndex = 0;                                    
                currentOffset += 1000;
            }   
     
    }
        
      
    
    global void execute(Database.BatchableContext BC, Object[] scope) {
      system.debug('execute');
        fillBuffer();
        if(buffer.isEmpty()) return;
        
        DfpTeamService.Team[] teamsToUpsert = new DfpTeamService.Team[]{};
      
        for(Object x : buffer) {
            if(x instanceof  DfpTeamService.Team) {
                   teamsToUpsert.add(( DfpTeamService.Team) x);
            }
            
        } 
        if(!teamsToUpsert.isEmpty()) upsert UtilityTeam.processStatement(teamsToUpsert) Team__c.Fields.idDfp__c;
      }
    
    global void finish(Database.BatchableContext BC) {

        Datetime d=  Datetime.now();
        system.debug(d);
        DfpDM_RetrievalDate__c dfp_date=[Select d.Name, d.Id, d.DfpDM_LastRetrieval__c From DfpDM_RetrievalDate__c d where name = 'Team'];
    	dfp_date.DfpDM_LastRetrieval__c=d;
    	system.debug('dataDFP aggiornata'+d.format('YYYY-MM-dd\'T\'HH:mm:ss'));
 		update dfp_date;
     
    }
}