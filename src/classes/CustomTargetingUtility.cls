public class CustomTargetingUtility{
    
    public PageReference syncAllCustomTargeting(){
        DfpIntegration dfp = new DfpIntegration();
        DfpCustomTargetingService.Statement filterStatement = new DfpCustomTargetingService.Statement();
        filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET 0';
        DfpCustomTargetingService.CustomTargetingKeyPage getCustomTargetingKeysByStatement = dfp.customtargetingService.getCustomTargetingKeysByStatement(filterStatement);
        
        List<CustomTargetingKey__c> customTargetingKeys = new List<CustomTargetingKey__c>();
        for(DfpCustomTargetingService.CustomTargetingKey ctk : getCustomTargetingKeysByStatement.results){
            CustomTargetingKey__c customTargetingKey = new CustomTargetingKey__c();

            customTargetingKey.Name = ctk.name;
            customTargetingKey.idDfp__c = ctk.id;
            customTargetingKey.displayName__c = ctk.displayName;
            customTargetingKey.type__c = ctk.type_x;
            
            customTargetingKeys.add(customTargetingKey);
        }
        
        DfpCustomTargetingService.CustomTargetingValuePage getCustomTargetingValuesByStatement = dfp.customtargetingService.getCustomTargetingValuesByStatement(filterStatement);
        
        upsert customTargetingKeys CustomTargetingKey__c.Fields.idDfp__c;
        
        Map<decimal,id> customTargetingKeysMap = new Map<decimal,id>();
        
        for(CustomTargetingKey__c ctk : [select id,idDfp__c from CustomTargetingKey__c]){
            customTargetingKeysMap.put(ctk.idDfp__c,ctk.id);
        }        
        
        List<CustomTargetingValue__c> customTargetingValues = new List<CustomTargetingValue__c>();
        for(DfpCustomTargetingService.CustomTargetingValue ctv : getCustomTargetingValuesByStatement.results){
            CustomTargetingValue__c customTargetingValue = new CustomTargetingValue__c();

            customTargetingValue.name = ctv.name;
            customTargetingValue.customTargetingKey__c = customTargetingKeysMap.get(ctv.customTargetingKeyId);
            customTargetingValue.idDfp__c = ctv.id;
            customTargetingValue.displayName__c = ctv.displayName;
            customTargetingValue.matchType__c = ctv.matchType;
            
            customTargetingValues.add(customTargetingValue);
        }
        
        upsert customTargetingValues CustomTargetingValue__c.Fields.idDfp__c;        
        
        
        
/*
        Map<String,Id> adUnitMap = new Map<String,Id>();
        for(adUnit__c a : [select id,idDfp__c from adUnit__c]){
            adUnitMap.put(a.idDfp__c,a.id);
        }
        
        for(AdUnit__c a : adUnits){
            a.ParentAdUnit__c = adUnitMap.get(a.parentId__c);
        }
        
        update adUnits;
        
*/        
        String retUrl;
        
        try{
            retUrl =  ApexPages.CurrentPage().getParameters().get('retUrl');
        }catch(Exception e){
            retUrl = null;
        }
        
        return new PageReference(retUrl);
    }
    
}