public class UtilityCustomTargeting {
    public static DfpCustomTargetingService.CustomTargetingKeyPage getTestKeyObject() {
        DfpCustomTargetingService.CustomTargetingKeyPage getCustomTargetingKeysByStatement = new DfpCustomTargetingService.CustomTargetingKeyPage();
        getCustomTargetingKeysByStatement.totalResultSetSize = 1;
        getCustomTargetingKeysByStatement.startIndex = 0;
        getCustomTargetingKeysByStatement.results = new list<DfpCustomTargetingService.CustomTargetingKey>();
        DfpCustomTargetingService.CustomTargetingKey ctk = new DfpCustomTargetingService.CustomTargetingKey();
        ctk.name = 'test';
        ctk.id = 0;
        ctk.displayName = 'test';
        ctk.type_x = 'test';
        getCustomTargetingKeysByStatement.results.add(ctk);
        return getCustomTargetingKeysByStatement;                
    }
    
    public static DfpCustomTargetingService.CustomTargetingValuePage getTestValueObject() {
        DfpCustomTargetingService.CustomTargetingValuePage getCustomTargetingValuesByStatement = new DfpCustomTargetingService.CustomTargetingValuePage();
        getCustomTargetingValuesByStatement.totalResultSetSize = 1;
        getCustomTargetingValuesByStatement.startIndex = 0;
        getCustomTargetingValuesByStatement.results = new list<DfpCustomTargetingService.CustomTargetingValue>();
        DfpCustomTargetingService.CustomTargetingValue ctv = new DfpCustomTargetingService.CustomTargetingValue();
        ctv.name = 'test';
        ctv.customTargetingKeyId = 0;
        ctv.id = 1;
        ctv.displayName = 'test';
        ctv.matchType = 'test';
        getCustomTargetingValuesByStatement.results.add(ctv);
        return getCustomTargetingValuesByStatement;     
    }

    public static DfpAudienceSegmentService.AudienceSegmentPage getTestAudienceValueObject() {
        DfpAudienceSegmentService.AudienceSegmentPage getAudienceSegmentValuesByStatement = new DfpAudienceSegmentService.AudienceSegmentPage();
        getAudienceSegmentValuesByStatement.totalResultSetSize = 1;
        getAudienceSegmentValuesByStatement.startIndex = 0;
        getAudienceSegmentValuesByStatement.results = new list<DfpAudienceSegmentService.AudienceSegment>();
        DfpAudienceSegmentService.AudienceSegment ctv = new DfpAudienceSegmentService.AudienceSegment();
        ctv.name = 'test';
        ctv.id = 2;
        getAudienceSegmentValuesByStatement.results.add(ctv);
        return getAudienceSegmentValuesByStatement;     
    }    
    
    public PageReference syncAllCustomTargeting(){
        DfpIntegration dfp = new DfpIntegration();
        dfp.audienceSegmentService.RequestHeader.networkCode = '5180';
        DfpCustomTargetingService.Statement filterStatement = new DfpCustomTargetingService.Statement();
        filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET 0';
        DfpCustomTargetingService.CustomTargetingKeyPage getCustomTargetingKeysByStatement;
        try{
            getCustomTargetingKeysByStatement = dfp.customtargetingService.getCustomTargetingKeysByStatement(filterStatement);
        }catch(exception e){
            if(Test.isRunningTest()){
                getCustomTargetingKeysByStatement = getTestKeyObject();
            }
        }
                
        DfpCustomTargetingService.CustomTargetingValuePage getCustomTargetingValuesByStatement;
        try{
            getCustomTargetingValuesByStatement = dfp.customtargetingService.getCustomTargetingValuesByStatement(filterStatement);
        }catch(exception e){
            if(test.isRunningTest()){
                getCustomTargetingValuesByStatement = getTestValueObject();
            }
        }
         
        DfpAudienceSegmentService.Statement filterStatement2 = new DfpAudienceSegmentService.Statement();
        filterStatement2.query = filterStatement.query;
        DfpAudienceSegmentService.AudienceSegmentPage getAudienceSegmentValuesByStatement;
        try {
            getAudienceSegmentValuesByStatement = dfp.audienceSegmentService.getAudienceSegmentsByStatement(filterStatement2);
        }catch(exception e){
            if(test.isRunningTest()){
                getAudienceSegmentValuesByStatement = getTestAudienceValueObject();
            }
        }

        upsert processKeyStatement(getCustomTargetingKeysByStatement.results) CustomTargetingKey__c.Fields.idDfp__c;        
        upsert processValueStatement(getCustomTargetingValuesByStatement.results) CustomTargetingValue__c.Fields.idDfp__c;                
        upsert processAudienceStatement(getAudienceSegmentValuesByStatement.results) CustomTargetingValue__c.Fields.idDfp__c;
        PageReference retUrl;
        
        try{
            retUrl =  new PageReference(ApexPages.CurrentPage().getParameters().get('retUrl'));
        }catch(Exception e){
            retUrl = null;
        }
        
        return retUrl;
    }

    public static CustomTargetingKey__c[] processKeyStatement(DfpCustomTargetingService.CustomTargetingKey[] x) {
        CustomTargetingKey__c[] res = new CustomTargetingKey__c[]{};
        for(DfpCustomTargetingService.CustomTargetingKey ctk : x){
            CustomTargetingKey__c customTargetingKey = new CustomTargetingKey__c();

            customTargetingKey.Name = ctk.name;
            customTargetingKey.idDfp__c = ctk.id;
            customTargetingKey.displayName__c = ctk.displayName;
            customTargetingKey.type__c = ctk.type_x;
            
            res.add(customTargetingKey);
        }   

        return res;
    }
    
    public static CustomTargetingValue__c[] processValueStatement(DfpCustomTargetingService.CustomTargetingValue[] x) {
        CustomTargetingValue__c[] res = new CustomTargetingValue__c[]{};
        for(DfpCustomTargetingService.CustomTargetingValue ctv : x){
            CustomTargetingValue__c customTargetingValue = new CustomTargetingValue__c();

            customTargetingValue.name = ctv.name;
            customTargetingValue.customTargetingKey__r = new CustomTargetingKey__c(idDfp__c = ctv.customTargetingKeyId);
            customTargetingValue.idDfp__c = ctv.id;
            customTargetingValue.displayName__c = ctv.displayName;
            customTargetingValue.matchType__c = ctv.matchType;
            customTargetingValue.type__c = 'CustomTargetingValue';
            res.add(customTargetingValue);
        }
        return res;
    }

    public static CustomTargetingValue__c[] processAudienceStatement(DfpAudienceSegmentService.AudienceSegment[] x) {
        CustomTargetingValue__c[] res = new CustomTargetingValue__c[]{};
        for(DfpAudienceSegmentService.AudienceSegment aus : x) {
            CustomTargetingValue__c customTargetingValue = new CustomTargetingValue__c();
            customTargetingValue.name = aus.name.substring(0, aus.name.length() >= 80 ? 80 : aus.name.length());
            customTargetingValue.customTargetingKey__r = new CustomTargetingKey__c(idDfp__c = -10);
            customTargetingValue.idDfp__c = aus.id;
            customTargetingValue.displayName__c = aus.name;
            customTargetingValue.status__c = aus.status;
            //customTargetingValue.matchType__c = aus.matchType;
            customTargetingValue.type__c = 'AudienceSegment';
            res.add(customTargetingValue);    
        }

        if(!res.isEmpty()) {
            CustomTargetingKey__c ctk = new CustomTargetingKey__c(
                Name = 'Audience Segment',
                idDfp__c = -10,
                displayName__c = 'Audience Segment'
            ); 
            upsert ctk CustomTargetingKey__c.Fields.idDfp__c;
        }
        return res;
    }

    public static Map<String,String> getCustomCriteriaMap(Set<String> idsString){
        Decimal[] ids = new Decimal[]{};
        for(String s : idsString){
            ids.add(Decimal.valueOf(s));
        }

        Map<String,String> customCriteriaMap = new Map<String,String>();
        if(ids.size() > 0){
            for(CustomTargetingKey__c c : [select displayName__c,idDfp__c from CustomTargetingKey__c where idDfp__c in : ids]){
                customCriteriaMap.put(c.idDfp__c+'',c.displayName__c);
            }
            for(CustomTargetingValue__c c : [select displayName__c,idDfp__c from CustomTargetingValue__c where idDfp__c in : ids]){
                customCriteriaMap.put(c.idDfp__c+'',c.displayName__c);
            }             
        }

        return customCriteriaMap;
    }

    //usato nel customSave di extensionEditLineItem
    public static boolean checkErrorAudienceSegment(LineItem__c li){
    
        if (li.product__r.CanalePrimario__c == 'Audience Targeting'){
            if (![select id from Custom_Criteria__c where Custom_Criteria_Set__r.LineItem__c =: li.id].isEmpty()) {
                return false;
            }
            
            Geography__c[] ggList = [select excludedValuesIds__c,IncludedValuesIds__c from Geography__c where Geography__c.LineItem__c =: li.id];
            if (ggList.isEmpty()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire almeno un Custom Criteria o un Geography Target'));
                return true;
            } else {
                for (Geography__c gg : ggList) {
                    if (gg.excludedValuesIds__c == Null && gg.IncludedValuesIds__c == Null) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire almeno un Custom Criteria o un Geography Target'));
                        return true;
                    }
                }
            }
        }
        
        return false;
    }
    
    //usato nello step 1 di globalOpportunityCloseAndWin
    public static Map<Id,Boolean> checkErrorAudienceSegment(LineItem__c[] lis){
        Map<Id,Boolean> checkErrorMap = new Map<Id,Boolean>();

        for(LineItem__c li : lis){
            checkErrorMap.put(li.id, li.product__r.CanalePrimario__c == 'Audience Targeting');
        }
        for(Custom_Criteria__c cc : [select Custom_Criteria_Set__r.LineItem__c  from Custom_Criteria__c where Custom_Criteria_Set__r.LineItem__c in : lis]){
            checkErrorMap.put(cc.Custom_Criteria_Set__r.LineItem__c, false);
        }
        for(Geography__c gg : [select Geography__c.LineItem__c, excludedValuesIds__c, IncludedValuesIds__c from Geography__c where Geography__c.LineItem__c in : lis]){
            if (gg.excludedValuesIds__c != Null || gg.IncludedValuesIds__c != Null) {
                checkErrorMap.put(gg.LineItem__c, false);
            }
        }

        return checkErrorMap;
    }
}