public class UtilityPlacement {
    public static DfpPlacementService.PlacementPage getTestObject() {
        DfpPlacementService.PlacementPage getPlacementsByStatement = new DfpPlacementService.PlacementPage();
        getPlacementsByStatement.totalResultSetSize = 1;
        getPlacementsByStatement.startIndex = 0;
        getPlacementsByStatement.results = new list<DfpPlacementService.Placement>();
        DfpPlacementService.Placement p = new DfpPlacementService.Placement();
        p.id = 0;
        p.name = 'test';
        p.description = 'test';
        p.status = 'ACTIVE';
        p.isAdSenseTargetingEnabled = false;
        //p.isAdPlannerTargetingEnabled = false;
        p.adSenseTargetingLocale = 'test';
        p.targetedAdUnitIds = new list<string>();
        p.targetedAdUnitIds.add('test');
        getPlacementsByStatement.results.add(p);
        return getPlacementsByStatement;        
    }

    public PageReference syncAllPlacement(){
        DfpIntegration dfp = new DfpIntegration();
        DfpPlacementService.Statement filterStatement = new DfpPlacementService.Statement();
        filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET 0';
        DfpPlacementService.PlacementPage getPlacementsByStatement;
                
        try{
            getPlacementsByStatement = dfp.placementService.getPlacementsByStatement(filterStatement);
        }catch(Exception e){
            if(Test.isRunningTest()){
                getPlacementsByStatement = getTestObject();
            }
        }        
        
        upsert processStatement(getPlacementsByStatement.results) Placement__c.Fields.idDfp__c;
        
        PageReference retUrl;
        
        try{
            retUrl =  new PageReference(ApexPages.CurrentPage().getParameters().get('retUrl'));
        }catch(Exception e){
            retUrl = null;
        }
        
        return retUrl;
    }

    public static Placement__c[] processStatement(DfpPlacementService.Placement[] x) {
        Placement__c[] placements = new Placement__c[]{};        
        for(DfpPlacementService.Placement pl : x){
            Placement__c p = new Placement__c();
            p.iddfp__c = pl.id;
            p.name = pl.name;
            p.Description__c = pl.description;
            p.status__c = pl.status;
            p.isAdSenseTargetingEnabled__c = pl.isAdSenseTargetingEnabled;
            //p.isAdPlannerTargetingEnabled__c = pl.isAdPlannerTargetingEnabled;
            p.adSenseTargetingLocale__c = pl.adSenseTargetingLocale;
            p.targetedAdUnitIds__c = '';
            if(pl.targetedAdUnitIds != null){
                for(string s : pl.targetedAdUnitIds){
                    p.targetedAdUnitIds__c += s+',';
                }
                p.targetedAdUnitIds__c += ',';
                p.targetedAdUnitIds__c = p.targetedAdUnitIds__c.replace(',,','');
            }
            placements.add(p);
        }
        return placements;      
    }
}