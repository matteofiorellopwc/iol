public class UtilityAdUnit{

    public PageReference checkOldAdunit(){
        DfpIntegration dfp = new DfpIntegration();
        DfpInventoryService.Statement filterStatement = new DfpInventoryService.Statement();
        filterStatement.query = 'WHERE id != 0 LIMIT 1000 OFFSET 0';
        
        DfpInventoryService.AdUnitPage getAdUnitsByStatement = dfp.inventoryService.getAdUnitsByStatement(filterStatement);
        
        List<AdUnit__c> adUnitsnew = new List<AdUnit__c>();
        
        for(DfpInventoryService.AdUnit a : getAdUnitsByStatement.results){
            AdUnit__c adUnit = new AdUnit__c();
            adUnit.status__c = a.status;
            adUnit.Name = a.name;
            adUnit.code__c = a.adUnitCode;
            adUnit.idDfp__c = a.id;
            adUnit.parentId__c = a.parentId; 
            adUnit.sizes__c = '';
            adUnit.explicitlyTargeted__c = a.explicitlyTargeted;
            adUnit.target_platform__c = 'ANY';
            adUnit.description__c = a.description;
        
            if(a.adUnitSizes != null){
                for(DfpInventoryService.AdUnitSize aus : a.adUnitSizes){
                    if (aus.environmentType == 'VIDEO_PLAYER') {
                        adUnit.sizes__c += aus.size.width+'x'+aus.size.height+'v,';
                    } else {
                        adUnit.sizes__c += aus.size.width+'x'+aus.size.height+',';
                    }
                }
                adUnit.sizes__c = adUnit.sizes__c.substring(0,adUnit.sizes__c.length()-1);
            }
            
            adUnitsnew.add(adUnit);            
        }
        
        map<string,adunit__c> adunitOldMap = new map<string,adunit__c>();
        set<id> adunitsTargeted = new set<id>();
        for(Inventory_Target__c it : [select Ad_Unit__c from Inventory_Target__c]){
            adunitsTargeted.add(it.Ad_Unit__c);
        }
        list<adunit__c> adunitsOld = [select id,Level__c,idDfp__c,Path__c from adunit__c where id in : adunitsTargeted];
        for(adunit__c adu : adunitsOld){
            adunitOldMap.put(adu.path__c,adu);
        }
        map<string,adunit__c> adunitNewMap = new map<string,adunit__c>();
        
        Savepoint sp = Database.setSavepoint();
        boolean error = false;
        try{
           upsert adUnitsnew AdUnit__c.Fields.idDfp__c;
            system.debug('1');
            Map<String,Id> adUnitMap = new Map<String,Id>();
                for(adUnit__c a : [select id,idDfp__c from adUnit__c where id in : adUnitsnew]){
                    adUnitMap.put(a.idDfp__c,a.id);
                }
            for(AdUnit__c a : adUnitsnew){
                a.ParentAdUnit__c = adUnitMap.get(a.parentId__c);
            }
        
            update adUnitsnew;
            adUnitsnew = [select id,Level__c,idDfp__c,Path__c from adunit__c where id in : adUnitsnew];
            for(adunit__c adu : adUnitsnew){
                adunitNewMap.put(adu.path__c,adu);
            }
            
            for(adunit__c adu : adunitsold){
               string s = adu.path__c;
               if(adunitNewMap.get(adu.path__c) != null){
                   s = s+': new->'+adunitnewMap.get(adu.path__c).iddfp__c+',old ->'+adu.iddfp__c;
                   adu.iddfp__c = adunitNewMap.get(adu.path__c).iddfp__c;
               }else{
                   s = s+' NON TROVATO';
               }
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.iNFO,s)); 
            }
               
            


        }catch(exception e){
            error = true;
        }finally{
           Database.rollback(sp);
        }         
        
        if(!error){
            update adunitsOld;
        }
        return null;
    }

    public static DfpInventoryService.AdUnitPage getTestObject() {
        DfpInventoryService.AdUnitPage getAdUnitsByStatement = new DfpInventoryService.AdUnitPage();               
        getAdUnitsByStatement.startIndex = 0;
        getAdUnitsByStatement.results = new list<DfpInventoryService.AdUnit>();
        DfpInventoryService.AdUnit a = new DfpInventoryService.AdUnit();
        a.name = 'test';
        a.id = 'test';
        a.explicitlyTargeted = false;
        getAdUnitsByStatement.results.add(a);
        return getAdUnitsByStatement;
    }
    
    public PageReference syncAllAdunit(){
        DfpIntegration dfp = new DfpIntegration();
        dfp.inventoryService.RequestHeader.networkCode = '5180';
        DfpInventoryService.Statement filterStatement = new DfpInventoryService.Statement();
        
        final Integer querySize = 500;
        Integer offset = 0;              
        
        DfpInventoryService.AdUnitPage getAdUnitsByStatement;
        List<AdUnit__c> adUnits = new List<AdUnit__c>();
        AdUnit__c[] adUnitsWithParents = new AdUnit__c[]{};
        do {        
            filterStatement.query = 'WHERE id != 0 ORDER BY id LIMIT ' + querySize + ' OFFSET ' + offset;
            System.debug(filterStatement.query);
            if(Test.isRunningTest()) {
                getAdUnitsByStatement = new DfpInventoryService.AdUnitPage();               
                getAdUnitsByStatement.startIndex = 0;
                if(offset == 0) {
                    getAdUnitsByStatement.results = new list<DfpInventoryService.AdUnit>();
                    DfpInventoryService.AdUnit a = new DfpInventoryService.AdUnit();
                    a.name = 'test';
                    a.id = 'test';
                    a.explicitlyTargeted = false;
                    getAdUnitsByStatement.results.add(a);
                }           
            } else {
                getAdUnitsByStatement = dfp.inventoryService.getAdUnitsByStatement(filterStatement);
            }                                               
                        
            if(getAdUnitsByStatement.results != null) {
                adUnits.addAll(processStatement(getAdUnitsByStatement.results, adUnitsWithParents));
            }
                                                
            offset += querySize;
        } while(getAdUnitsByStatement.results != null);               
                
        upsert adUnits AdUnit__c.Fields.idDfp__c;   
        upsert adUnitsWithParents AdUnit__c.Fields.idDfp__c;             
          
        PageReference retUrl;
        
        try{
            retUrl =  new PageReference(ApexPages.CurrentPage().getParameters().get('retUrl'));
        }catch(Exception e){
            retUrl = null;
        }
        
        return retUrl;
    }
        
    public static AdUnit__c[] processStatement(DfpInventoryService.AdUnit[] x, AdUnit__c[] adUnitsWithParents) {
        AdUnit__c[] res = new AdUnit__c[]{};
        for(DfpInventoryService.AdUnit a : x){
            AdUnit__c adUnit = new AdUnit__c();
            adUnit.idDfp__c = a.id;            
            if(a.parentId != null) {                        
                AdUnit__c parent = new AdUnit__c(idDfp__c = a.parentId);                        
                adUnitsWithParents.add(new AdUnit__c(idDfp__c = a.id, ParentAdUnit__r = parent));                   
            }else{
            	system.debug('ADUNIT SENZA PARENT!!! a.name '+a.name+' a.id '+a.id+' a.parentId '+a.parentId);
            
            /*
             ApexClass batchClass = [select id, name from apexclass where name = 'WVBatchGeocodeBatchable'];
			 AsyncApexJob[] activeJobs = [select id from AsyncApexJob where(ApexClassId = :batchClass.Id and (Status = 'Queued' or Status = 'Processing')];
			  
			 for(Integer count=0; count<activeJobs.size(); count++ )
			 {
			  try  
			  {  
			   System.abortJob(activeJobs[count].id);
			  }
			  catch( Exception myException )
			  {
			  system.debug(myException);
			  }
			 } 
            */
            
            }            
            adUnit.status__c = a.status;
            adUnit.Name = a.name;
            adUnit.code__c = a.adUnitCode;
            adUnit.parentId__c = a.parentId;
            adUnit.sizes__c = '';
            adUnit.explicitlyTargeted__c = a.explicitlyTargeted;
            adUnit.target_platform__c = 'ANY';
            adUnit.description__c = a.description;

            if(a.adUnitSizes != null){
                for(DfpInventoryService.AdUnitSize aus : a.adUnitSizes){
                    if (aus.environmentType == 'VIDEO_PLAYER') {
                        adUnit.sizes__c += aus.size.width+'x'+aus.size.height+'v,';
                    } else {
                        adUnit.sizes__c += aus.size.width+'x'+aus.size.height+',';
                    }
                }
                adUnit.sizes__c = adUnit.sizes__c.substring(0,adUnit.sizes__c.length()-1);
            }
            
            res.add(adUnit);
        }
        return res;
    }
    
    public static Map<Id, Set<Id>> getConflictMap(Set<Id> adUnitIds) {
        return getConflictMap(adUnitIds, null); 
    }
    
    public static Map<Id, Set<Id>> getConflictMap(Set<Id> adUnitIds, Map<Id, Set<Id>> excludedAdUnits) {
        AdUnit__c[] allAdUnits = [SELECT Id, ParentAdUnit__c, Status__c, hideAdUnit__c, explicitlyTargeted__c FROM AdUNit__c];
        return getConflictMap(adUnitIds, excludedAdUnits, allAdUnits);
    }
    
    public static Map<Id, Set<Id>> getConflictMap(Set<Id> adUnitIds, Map<Id, Set<Id>> excludedAdUnits, AdUnit__c[] allAdUnits) {
        Map<Id, Set<Id>> res = new Map<Id, Set<Id>>();
        for(Id adUnitId : adUnitIds) {
            res.put(adUnitId, new Set<Id>());
        }
        
        Map<Id, Set<Id>> parent2ChildRel = new Map<Id, Set<Id>>();
        Map<Id, AdUnit__c> adUnitMap = new Map<Id, AdUnit__c>();
        for(AdUnit__c au : allAdUnits) {            
            if(au.ParentAdUnit__c != null) {
                if(!parent2ChildRel.containsKey(au.ParentAdUnit__c)) parent2ChildRel.put(au.ParentAdUnit__c, new Set<Id>());
                parent2ChildRel.get(au.ParentAdUnit__c).add(au.Id);             
            }
            adUnitMap.put(au.Id, au);
        }
        
        if(excludedAdUnits == null) excludedAdUnits = new Map<Id, Set<Id>>();
        fillExcludedMap(excludedAdUnits, adUnitMap, parent2ChildRel);
                
        for(Id adUnitId : adUnitIds) {
            //Go Down
            addBottomConflicts(res.get(adUnitId), parent2ChildRel, adUnitMap, adUnitId);
            //Go Up
            addUpConflicts(res.get(adUnitId), parent2ChildRel, adUnitMap, adUnitId);
            
            res.get(adUnitId).add(adUnitId);
            
            Id[] excludedIds = new Id[]{};
            if(excludedAdUnits.containsKey(adUnitId)) {
                excludedIds.addAll(excludedAdUnits.get(adUnitId));
            }
            res.get(adUnitId).removeAll(excludedIds);
        }
                         
        return res;      
    }
    
    public static void fillExcludedMap(Map<Id, Set<Id>> excludedAdUnits, Map<Id, AdUnit__c> adUnitMap, Map<Id, Set<Id>> parent2ChildRel) {
        for(Id adUnitId : excludedAdUnits.keySet()) {
            Set<Id> allExcluded = new Set<Id>();
            for(Id exAuId : excludedAdUnits.get(adUnitId)) {
                addBottomConflicts(allExcluded, parent2ChildRel, adUnitMap, exAuId);
            }
            excludedAdUnits.get(adUnitId).addAll(allExcluded);
        }       
    }
    
    private static void addBottomConflicts(Set<Id> res, Map<Id, Set<Id>> parent2ChildMap, Map<Id, AdUnit__c> adUnitMap, Id adUnitId) {
        if(parent2ChildMap.containsKey(adUnitId)) {
            for(Id child : parent2ChildMap.get(adUnitId)) {
                if(!adUnitMap.get(child).explicitlyTargeted__c) {
                    res.add(child);
                    addBottomConflicts(res, parent2ChildMap, adUnitMap, child);
                }       
            }   
        }                   
    } 
    
    private static void addUpConflicts(Set<Id> res, Map<Id, Set<Id>> parent2ChildMap, Map<Id, AdUnit__c> adUnitMap, Id adUnitId) {
        Id parentId = adUnitMap.get(adUnitId).ParentAdUnit__c;
        if(parentId != null) {
            res.add(parentId);
            if(!adUnitMap.get(parentId).explicitlyTargeted__c) addUpConflicts(res, parent2ChildMap, adUnitMap, parentId);
        }       
    }
    
    public static list<SelectOption> getAdunitscpd(String canalePrimario){
        list<SelectOption> so = new list<SelectOption>();
        String query = 'SELECT Id, Path__c FROM AdUnit__c WHERE showAdUnitFormula__c = TRUE AND Level__c > 0';
        if(canalePrimario != null && canalePrimario != '') query += ' AND CanalePrimario__c includes (\''+canalePrimario+'\') ';
        query += ' ORDER BY Path__c ASC';
        for(AdUnit__c adu : Database.query(query)){
            so.add(new SelectOption(adu.id,adu.path__c));
        }
        return so;
    }

    public static list<SelectOption> getAdunitscpdFromOldCanalePrimario(String canalePrimario, Date startDate, Date endDate, String formato){
        list<SelectOption> so = new list<SelectOption>();
        for(Inventory_Target__c it : [SELECT Ad_Unit__c, Ad_Unit__r.path__c FROM Inventory_Target__c WHERE LineItem__c IN (SELECT Id FROM LineItem__c WHERE Product__r.Canale_Primario__c =: canalePrimario AND Start_Date__c >= :startDate AND End_Date__c <= :endDate AND Product__r.formato__c =:formato)]) {
            so.add(new SelectOption(it.Ad_Unit__c,it.Ad_Unit__r.path__c));    
        }
        return so;
    }

/*    
    public static void getAdUnitSizes(){
        DfpIntegration dfp = new DfpIntegration();
        List<DfpInventoryService.AdUnitSize> sizes = dfp.inventoryService.getAdUnitSizes();
        System.debug('numbero of sizes: '+sizes.size());
        for(DfpInventoryService.AdUnitSize s : sizes){
            System.debug('width: '+s.size.width+' height: '+s.size.height);
        }
    }
*/    
    
/*    //ESEMPIO QUERY CON DATETIME
    DfpIntegration dfp = new DfpIntegration();
    DfpInventoryService.Statement filterStatement = new DfpInventoryService.Statement();
    filterStatement.query = 'WHERE id != 0 AND lastModifiedDateTime > :var1 LIMIT 1000 OFFSET 0';
    filterStatement.values = new List<DfpInventoryService.String_ValueMapEntry>();
    DfpInventoryService.String_ValueMapEntry val = new DfpInventoryService.String_ValueMapEntry();
    val.key = 'var1';
    val.value = new DfpInventoryService.Value();
    val.value.type = 'DateTimeValue';
    val.value.value = DataValueUtility.getInventoryDateTime(System.Now().addDays(-2));
    filterStatement.values.add(val);
    DfpInventoryService.AdUnitPage getAdUnitsByStatement = dfp.inventoryService.getAdUnitsByStatement(filterStatement);
    system.debug(getAdUnitsByStatement);
*/    


}