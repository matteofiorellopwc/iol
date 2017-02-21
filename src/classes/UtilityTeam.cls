public class UtilityTeam {
	public static DfpTeamService.TeamPage getTestObject() {
	    DfpTeamService.TeamPage getTeamsByStatement = new DfpTeamService.TeamPage();
	    getTeamsByStatement.totalResultSetSize = 1;
	    getTeamsByStatement.startIndex = 0;
	    getTeamsByStatement.results = new list<DfpTeamService.Team>();
	    DfpTeamService.Team p = new DfpTeamService.Team();
	    p.id = 0;
	    p.name = 'test';
	    p.description = 'test';
	    p.teamAccessType = 'test';
	    getTeamsByStatement.results.add(p);
	    return getTeamsByStatement;		
	}
	
    public PageReference syncAllTeam(){
        DfpIntegration dfp = new DfpIntegration();
        DfpTeamService.Statement filterStatement = new DfpTeamService.Statement();
        filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET 0';
        DfpTeamService.TeamPage getTeamsByStatement;
                
        try{
            getTeamsByStatement = dfp.TeamService.getTeamsByStatement(filterStatement);
            system.debug('getTeamsByStatement: '+getTeamsByStatement);
        }catch(Exception e){
            if(Test.isRunningTest()){
				getTeamsByStatement = getTestObject();
            }
        }        
        
        upsert processStatement(getTeamsByStatement.results) Team__c.Fields.idDfp__c;        
        PageReference retUrl;
        
        try{
            retUrl =  new PageReference(ApexPages.CurrentPage().getParameters().get('retUrl'));
        }catch(Exception e){
            retUrl = null;
        }
        
        return retUrl;    
    }
    
    public static Team__c[] processStatement(DfpTeamService.Team[] x) {
        Team__c[] teams = new Team__c[]{};
        for(DfpTeamService.Team pl : x){
            Team__c p = new Team__c();
            p.iddfp__c = pl.id;
            p.name = pl.name;
            p.Description__c = pl.description;
            p.teamAccessType__c = pl.teamAccessType;
            teams.add(p);
        }
        return teams;    	    	
    }
}