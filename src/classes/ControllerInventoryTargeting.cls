public class ControllerInventoryTargeting {
    
    public List<AdUnit__c> adUnits {get;set;}
    public List<AdUnitWrapper> adUnitsWrap {get;set;}
    
    public Set<Id> inventoryTargetsIncluded {get;set;}
    public Decimal inventoryTargetsIncludedSize {
        get{
            return inventoryTargetsIncluded.size();
        }
    }
    public String inventoryTargetsIncludedString {
        get{
            String s = '_';
            for(Id i : inventoryTargetsIncluded){
                s += '_' + i + '_';            
            }        
            return s;
        }set;}
                                                  
    public String inventoryTargetsExcludedString {
        get{
            String s = '_';
            for(Id i : inventoryTargetsExcluded){
                s += '_' + i + '_';            
            }
            return s;
        }
        set;
    }  
    
    public Map<Id,Boolean> allInventoryTarget {get;set;}
    public Set<Id> inventoryTargetsExcluded {get;set;}
    public String sobjectName {get;set;}
    public String parentId {get;set;}
    public Map<Id,Boolean> includedRender {get;set;}
    public Map<Id,Boolean> excludedRender {get;set;}
    public Map<id,AdUnit__c> allAdUnits {get;set;}
    Transient Map<id,list<adunit__c>> adunitMap {get;set;}
    public AdUnitWrapper rootAdUnitWrapper {get;set;}
    public Map<id,list<AdUnitWrapper>> adUnitWrapperMap {get;set;}
    public Map<Id,Boolean> renderAdUnit {get;set;}
    public Map<Id,String> adunitsSizes {get;set;}
    public Map<Id,String> adUnitsCanali {get;set;} //id adunit -> stringa con i suoi canali più quelli dei figli
    private AdUnit__c rootAdU;
    Transient Set<Id> setParentIdIncluded;

    public String id{get;set;}
    public Decimal drillDownLevel {get;set;}
    
    public String idAdUnit {get;        
        set {
            idAdUnit = value;
        }
    }
    
    public String filterSize {get;set;}
    public String filterTargetPlatform {get;set;}
    public String filterCanalePrimario {get;set;}
    
    public ControllerInventoryTargeting(){
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');  
        this.parentId = ApexPages.CurrentPage().getParameters().get('parentId');  
        this.drillDownLevel = Decimal.valueOf(ApexPages.CurrentPage().getParameters().get('drillDownLevel')); 
        this.filterSize = ApexPages.CurrentPage().getParameters().get('filterSize');
        this.filterTargetPlatform = ApexPages.CurrentPage().getParameters().get('platform');
        this.filterCanalePrimario = ApexPages.CurrentPage().getParameters().get('canalePrimario');

        init();
    }

    public void init() {
        Long msStart = System.currentTimeMillis();
        System.debug('PD - parentId: '+parentId);
        this.loadInventoryTarget();
        System.debug('PD - setParentIdIncluded: '+setParentIdIncluded);
        //Populating all parents from parentId
        Set<Id> setParents = new Set<Id>();
        AdUnit__c aduParent;
        List<AdUnit__c> aduParents = [SELECT Id, PathSFId__c FROM AdUnit__c WHERE Id = :parentId];
        if (!aduParents.isEmpty()) {
            aduParent = aduParents.get(0);
            if (aduParent.PathSFId__c != null) {
                for (String s : aduParent.PathSFId__c.split(',')) {
                    if (!String.isBlank(s)) { setParents.add(s); }
                }
            }
        }

        allAdUnits = new Map<Id,AdUnit__c>([select id,name,level__c, ParentAdUnit__c,hasParent__c,explicitlyTargeted__c,path__c,Sizes__c, SublevelSizes__c,
                                                   HideAdUnit__c,Target_platform__c,CanalePrimario__c,showAdUnitFormula__c,
                                            (select id from adUnits__r)
                                            from AdUnit__c 
                                            where iddfp__c <> null
                                            AND (
                                                ParentAdUnit__c = :parentId
                                                OR Id IN :setParents
                                                OR Id = :parentId
                                                OR Id IN :setParentIdIncluded
                                                )
                                            order by level__c]);        

        populateAllInventoryTarget();
        this.loadRender();
        System.debug('PD - loadRender TIME (ms): '+(System.currentTimeMillis() - msStart));
        
        adUnits = [select id,name,level__c,(select id from adUnits__r),explicitlyTargeted__c,ParentAdUnit__c,Sizes__c,
                          HideAdUnit__c,Target_platform__c, CanalePrimario__c,showAdUnitFormula__c
                   from AdUnit__c 
                   where iddfp__c <> null 
                   and level__c = : drillDownLevel 
                   and parentAdUnit__c =: parentId 
                   order by name];
        this.calculateInclude();
        this.calculateExclude();
        this.calculateAllSizes();

        this.calculateAdunitsCanali();
        this.calculateTree();
        
        ////////////////////// LEFT PANEL //////////////////////
        //Create AdUnit Wrapper List from AdUnit List
        adUnitsWrap = new List<AdUnitWrapper>();
        for(AdUnit__c au : adUnits) {
            AdUnitWrapper aduw = new AdUnitWrapper(au);
            aduw.children = allAdUnits.get(au.id).AdUnits__r.size();
            allAdUnits.get(au.id).AdUnits__r.clear();
            adUnitsWrap.add(aduw);     
        }
        System.debug('PD - adUnitsWrap TIME (ms): '+(System.currentTimeMillis() - msStart));
        //Filter AdUnit Wrapper List

        system.debug('adUnitsWrap.size() prima filter '+adUnitsWrap.size());
        filterAdUnitsWrap();            
        system.debug('adUnitsWrap.size() dopo filter '+adUnitsWrap.size());

        System.debug('PD - filterAdUnitsWrap TIME (ms): '+(System.currentTimeMillis() - msStart));
        /////////////////////////////////////////////////////////
        
        ////////////////////// RIGHT PANEL //////////////////////
        //Create root AdUnitWrapper
        rootAdUnitWrapper = new AdUnitWrapper(rootAdU);
        
        //Create AdUnitWrapper Map from AdUnit Map
        adUnitWrapperMap = new Map<Id, List<AdUnitWrapper>>();
        for(Id auId : adUnitMap.keySet()) {
            List<AdUnitWrapper> auwL = new List<AdUnitWrapper>();
            for(AdUnit__c au : adUnitMap.get(auId)) {
                auwL.add(new AdUnitWrapper(au));    
            }
            adUnitWrapperMap.put(auId, auwL);        
        }
        /////////////////////////////////////////////////////////

        System.debug('PD - init TIME (ms): '+(System.currentTimeMillis() - msStart));
    //    cleanMaps();
    }
     
    /*public PageReference getPageParameters(){
        Pagereference p = new PageReference('/apex/editInventoryTargetingComponentNew');
        p.getParameters().putAll(new map<string,string>{
            'sobjectName' => sobjectName,
            'includeMode' => ApexPages.CurrentPage().getParameters().get('includeMode'),
            'excludeMode' => ApexPages.CurrentPage().getParameters().get('excludeMode'),
            'editable' => ApexPages.CurrentPage().getParameters().get('editable'),
            'id' => id, 
            'drillDownLevel' => drillDownLevel+'',
            'parentId' => parentId,
            'filterSize' => filterSize,
            'platform' => filterTargetPlatform,
            'canalePrimario' => filterCanalePrimario,
            'maxIncludes' => ApexPages.CurrentPage().getParameters().get('maxIncludes')
        });
        p.setRedirect(true);
        return p;
    }*/
     
    /*public PageReference includeAdUnit(){
       Inventory_Target__c inventoryTarget = this.createInventoryTarget();
       inventoryTarget.InventoryTargetingType__c = 'targeted';          
       insert inventoryTarget;
       set<Id> returnId = this.removeChildIncluded(inventoryTarget.Ad_Unit__c);
       List<Inventory_Target__c> deleteTarget = [select Ad_Unit__c,InventoryTargetingType__c from Inventory_Target__c where Ad_Unit__c IN :returnId and (LineItem__c =: id or Product__c =: id)];
       delete deleteTarget; 
       
       return getPageParameters();
    }*/
    
    public PageReference includeAdUnitBatch(){
        List<Inventory_Target__c> inventoryTargetsToBeInsert = new List<Inventory_Target__c>();
        for(AdUnitWrapper auw : adUnitsWrap) {
            if(auw.includeSelected) {
                Inventory_Target__c inventoryTarget = new Inventory_Target__c();
                inventoryTarget.Ad_Unit__c = auw.adUnit;
                inventoryTarget.includeDescendants__c = true;
                if(sobjectName == 'LineItem__c'){
                    inventoryTarget.LineItem__c = id;
                    inventoryTarget.isLineItemModified__c = true;
                } else {
                    inventoryTarget.Product__c = id;
                }
                inventoryTarget.InventoryTargetingType__c = 'targeted';
                inventoryTargetsToBeInsert.add(inventoryTarget);
            }
        }
        insert inventoryTargetsToBeInsert;
        
        set<Id> adUnitIdSet = new set<Id>();
        for(Inventory_Target__c it : inventoryTargetsToBeInsert) {
            adUnitIdSet.addAll(this.removeChildIncluded(it.Ad_Unit__c));
        }   
        List<Inventory_Target__c> inventoryTargetsToBeDelete = [select Ad_Unit__c,InventoryTargetingType__c from Inventory_Target__c where Ad_Unit__c IN :adUnitIdSet and (LineItem__c =: id or Product__c =: id)];
        delete inventoryTargetsToBeDelete;
        
        //return getPageParameters();
        init();
        return null;
    }
    
    /*public PageReference excludeAdUnit(){
       Inventory_Target__c inventoryTarget = this.createInventoryTarget();
       inventoryTarget.InventoryTargetingType__c = 'excluded'; 
       insert inventoryTarget;  
       
        return getPageParameters();
    }*/
    
    public PageReference excludeAdUnitBatch(){
        List<Inventory_Target__c> inventoryTargetsToBeInsert = new List<Inventory_Target__c>();
        for(AdUnitWrapper auw : adUnitsWrap) {
            if(auw.excludeSelected) {
                Inventory_Target__c inventoryTarget = new Inventory_Target__c();
                inventoryTarget.Ad_Unit__c = auw.adUnit;
                inventoryTarget.includeDescendants__c = true;
                if(sobjectName == 'LineItem__c'){
                    inventoryTarget.LineItem__c = id;
                    inventoryTarget.isLineItemModified__c = true;
                } else {
                    inventoryTarget.Product__c = id;
                }
                inventoryTarget.InventoryTargetingType__c = 'excluded';
                inventoryTargetsToBeInsert.add(inventoryTarget);
            }
        }
        insert inventoryTargetsToBeInsert;
        
        //return getPageParameters();
        init();
        return null;
    }
    
     public void removeInventoryTarget(){
       system.debug('****** Removing inventory target adUnit ' + idAdUnit + ' id ' + id + ' ******' );
       List<Inventory_Target__c> deleteTarget = [select Ad_Unit__c,InventoryTargetingType__c from Inventory_Target__c where Ad_Unit__c =:idAdUnit and (LineItem__c =: id or Product__c =: id)];
       delete deleteTarget;
       this.loadInventoryTarget();
       this.loadRender(); 
       this.calculateInclude();
       this.calculateExclude();
        
        system.debug('****** FINISH Removing inventory target ******');
    } 
    
    public void removeInventoryTargetBatch(){
        List<Inventory_Target__c> deleteTarget;
        Set<Id> adUnitIdSet = new Set<Id>();
        
        if(rootAdUnitWrapper.includeSelected) {
            adUnitIdSet.add(rootAdUnitWrapper.adUnit);
        }
        
        for(List<AdUnitWrapper> auWrapList : adUnitWrapperMap.values()) {
            for(AdUnitWrapper auWrap : auWrapList) {
                if(auWrap.includeSelected) {
                    adUnitIdSet.add(auWrap.adUnit);
                }   
            }           
        }
        
        deleteTarget = [select Ad_Unit__c,InventoryTargetingType__c from Inventory_Target__c where Ad_Unit__c IN : adUnitIdSet and (LineItem__c =: id or Product__c =: id)];
        delete deleteTarget;
        
        //Remove children
        set<Id> adUnitChildIdSet = new set<Id>();
        for(Inventory_Target__c it : deleteTarget) {
            adUnitChildIdSet.add(it.Ad_Unit__c);
        }   
        List<Inventory_Target__c> inventoryTargetsToBeDelete = [select Ad_Unit__c,InventoryTargetingType__c 
                                                                from Inventory_Target__c 
                                                                where InventoryTargetingType__c = 'excluded' 
                                                                and 
                                                                (   Ad_Unit__r.ParentAdUnit__c IN :adUnitChildIdSet
                                                                    OR Ad_Unit__r.ParentAdUnit__r.ParentAdUnit__c IN :adUnitChildIdSet
                                                                    OR Ad_Unit__r.ParentAdUnit__r.ParentAdUnit__r.ParentAdUnit__c IN :adUnitChildIdSet
                                                                    OR Ad_Unit__r.ParentAdUnit__r.ParentAdUnit__r.ParentAdUnit__r.ParentAdUnit__c IN :adUnitChildIdSet
                                                                )
                                                                and (LineItem__c =: id or Product__c =: id)];
        delete inventoryTargetsToBeDelete;
        
        this.loadInventoryTarget();
        this.loadRender(); 
        this.calculateInclude();
        this.calculateExclude();
    }
    
    
    
    private set<Id> removeChildIncluded(Id id){
        if(adUnitMap == null){
            this.calculateTree();
        }
        set<Id> returnId = new set<Id>();
        for(AdUnit__c adunit : adUnitMap.get(id)){
            if(inventoryTargetsIncluded.contains(adunit.id) && !adunit.explicitlyTargeted__c){
                //inventoryTargetsIncluded.remove(adunit.id);
                returnId.add(adunit.id);
            }
            returnId.addAll(removeChildIncluded(adunit.id));
        }
        return returnId;
    }
    
    /*private Inventory_Target__c createInventoryTarget(){
       idAdUnit = ApexPages.currentPage().getParameters().get('idAdUnit');
       //system.debug('Saving on id: ' + id + ' ADUNIT: ' + idAdUnit);
       Inventory_Target__c inventoryTarget = new Inventory_Target__c();
      
       inventoryTarget.Ad_Unit__c = idAdUnit;
       inventoryTarget.includeDescendants__c = true;
       if(sobjectName == 'LineItem__c'){
           inventoryTarget.LineItem__c = id;
           inventoryTarget.isLineItemModified__c = true;
       }else
           inventoryTarget.Product__c = id; 
       return inventoryTarget;
    }*/
    
    private void calculateInclude(){
        for(AdUnit__c adTmp : adUnits){
            Boolean includeButtonCase1 = (!inventoryTargetsIncluded.contains(adTmp.id) && !this.parentIncluded(adTmp.id));      
            Boolean includeButtonCase2 = (!inventoryTargetsIncluded.contains(adTmp.id) && adtmp.explicitlyTargeted__c);       
            includedRender.put(adTmp.id,includeButtonCase1 || includeButtonCase2);
        }
    }
    
    //Posso escluderlo se non è già escluso, se è incluso il padre, e se non è explicittly target (flag)
    private void calculateExclude(){
        for(AdUnit__c adTmp : adUnits){
            excludedRender.put(adTmp.Id,!inventoryTargetsExcluded.contains(adTmp.id) && this.parentIncluded(adTmp.id) && !adtmp.explicitlyTargeted__c);
        }
    }
    
    private boolean parentIncluded(String id){
        boolean included = false;
        AdUnit__c adunit = allAdUnits.get(id);
        while(adunit.hasParent__c == 1){
           adunit = allAdUnits.get(adunit.ParentAdUnit__c);
           if(inventoryTargetsIncluded.contains(adunit.id)){
              included = true;
              break;
           }else if(adunit.explicitlyTargeted__c){ //se un padre è explicitlyTargeted e non è incluso allora esco
                break;                
           }
        }
        return included;
        
    }
    
    
    private void analizeRender(String id){        
        AdUnit__c adunit = allAdUnits.get(id);
        if(inventoryTargetsIncluded.contains(id) ||  inventoryTargetsExcluded.contains(id)){
            renderAdUnit.put(id,true);
            while(adunit.hasParent__c == 1){
                adunit = allAdUnits.get(adunit.ParentAdUnit__c);                
                renderAdUnit.put(adunit.id,true);                
            }
        }else{
            
           // renderAdUnit.put(adunit.id,false);  
            /* while(adunit.hasParent__c == 1){
                adunit = allAdUnits.get(adunit.ParentAdUnit__c);                
                if(inventoryTargetsIncluded.contains(adunit.id) && !renderAdUnit.keySet().contains(id)){
                     renderAdUnit.put(id,true);
                }
        }*/
          
        }
    }
    
    private void loadInventoryTarget(){
        inventoryTargetsIncluded = new Set<Id>();
        inventoryTargetsExcluded = new Set<Id>();
        this.setParentIdIncluded = new Set<Id>();
        allInventoryTarget = new Map<Id,boolean>();
        for(Inventory_Target__c inv : [select Ad_Unit__c,InventoryTargetingType__c,isLineItemModified__c, Ad_Unit__r.PathSFId__c from Inventory_Target__c where (LineItem__c =: id or Product__c =: id)]){
             if(sobjectName == 'LineItem__c'){
                allInventoryTarget.put(inv.Ad_Unit__c,inv.isLineItemModified__c);
             }else{
                    allInventoryTarget.put(inv.Ad_Unit__c,true);
            }
            
            if(inv.InventoryTargetingType__c == 'targeted'){
                inventoryTargetsIncluded.add(inv.Ad_Unit__c);
            }else{
                inventoryTargetsExcluded.add(inv.Ad_Unit__c);
            }
            populateSetParentIdIncludedFromPathId(inv.Ad_Unit__r.PathSFId__c);
        }
        system.debug('ALL ADUNITS: ' + allAdUnits);
        if (allAdUnits != null) {
            system.debug('ALL ADUNITS.size(): ' + allAdUnits.size());
        }
  /*      for(Id adId : allAdUnits.keySet()){
            if(!allInventoryTarget.keySet().contains(adId)){
                     allInventoryTarget.put(adId,true);
                }
        }*/
    }

    private void populateAllInventoryTarget() {
        for(Id adId : allAdUnits.keySet()){
            if(!allInventoryTarget.keySet().contains(adId)){
                 allInventoryTarget.put(adId,true);
            }
        }
    }

    /*
    * Populate the setParentIdIncluded with all Id in the path of Inventory Target Selected
    */
    private void populateSetParentIdIncludedFromPathId(String pathId) {
        if (pathId == null) { return; }

        for (String s : pathId.split(',')) {
            if (!String.isBlank(s)) { setParentIdIncluded.add(s); }
        }
    }

    /*
    * Remove the unnecessary elements from adUnitWrapperMap and allAdUnits maps
    */
    private void cleanMaps() {
        set<id> keysToRemove = new set<id>();

        for (Id key : allAdUnits.keySet()) {
            if (!setParentIdIncluded.contains(key) &&
                key != parentId &&
                allAdUnits.get(key).ParentAdUnit__c != parentId
                ) {
                keysToRemove.add(key);
            }
        }

        for(Id key : adUnitWrapperMap.keySet()){
            for(Integer i=0;i<adUnitWrapperMap.get(key).size();i++){
                if(keysToRemove.contains(adUnitWrapperMap.get(key).get(i).adUnit)){
                    adUnitWrapperMap.get(key).remove(i);
                    i--;
                }
            }
            if(keysToRemove.contains(key)){
                adUnitWrapperMap.remove(key);        
                allAdUnits.remove(key);                
            }

        }
        
    }

    private void loadRender(){
        renderAdUnit = new map<id,boolean>();
        excludedRender = new Map<Id,Boolean>();
        includedRender = new Map<Id,Boolean>();
        for(Id adId : allAdUnits.keySet()){
            this.analizeRender(adid); 
        }
        
        for(Id adId : allAdUnits.keySet()){
            if(!renderAdUnit.keySet().contains(adId)){
                     renderAdUnit.put(adId,false);
                }
        }
        
    }
 
    private void calculateTree(){
        adUnitMap = new Map<id,list<adunit__c>>();
        for(Id adId : allAdUnits.keySet()){            
            
            if(allAdUnits.get(adId).parentAdUnit__c != null){
                if(!adUnitMap.keySet().contains(allAdUnits.get(adId).parentAdUnit__c)){
                    adUnitMap.put(allAdUnits.get(adId).parentAdUnit__c,new list<adunit__c>());
                }
                adUnitMap.get(allAdUnits.get(adId).parentAdUnit__c).add(allAdUnits.get(adId));
            } else {
                rootAdU = allAdUnits.get(adId);
            }
            if(adUnitMap.get(adid) == null){
                adUnitMap.put(adid,new list<adunit__c>());                
            }
        }
    }


    private void calculateAllSizes(){
        adunitsSizes = new Map<Id,String>();
        for(Id adId : allAdUnits.keySet()){
            String sizes = allAdUnits.get(adId).SublevelSizes__c;
            if (sizes == null) { sizes = ''; }
            sizes = sizes.replaceAll(';', ',');
            if (sizes.length() > 0 && sizes.substring(sizes.length() -1) != ',') {
                sizes += ',';
            }
            adunitsSizes.put(adId,','+sizes+'0x0,1x1,Multisize,');        
        }
    }
    /*
    private String calculateSizes(Id id){
        if(adUnitMap == null){
            this.calculateTree();
        }           
        String sizes = allAdUnits.get(id).sizes__c;
        sizes = sizes == null ? '' : sizes;
        sizes = ',' + sizes;
        for(AdUnit__c adunit : adUnitMap.get(id)){
            sizes += calculateSizes(adunit.Id);
        }
        return sizes + ',';
    }
    */

    private Map<Id,AdUnit__c> canaliMap;
    private void calculateAdunitsCanali(){
        adUnitsCanali = new Map<Id,String>();
        canaliMap = new Map<Id,AdUnit__c>([select id,CanalePrimario__c,(select id from adUnits__r)
                                                                from AdUnit__c 
                                                                where iddfp__c <> null]);    
        for(Id adId : allAdUnits.keySet()){
            adUnitsCanali.put(adId,calculateAdunitCanaliRecursive(adId));        
        }

        canaliMap = null;
    }
    private string calculateAdunitCanaliRecursive(Id id){

        String canali = canaliMap.get(id).CanalePrimario__c;
        canali = canali == null ? '' : canali;
        canali = ';' + canali;
        for(AdUnit__c adunit : canaliMap.get(id).adUnits__r){
            canali += calculateAdunitCanaliRecursive(adunit.Id);
        }
        return canali + ';';
    }
    
    /* Filter Ad Unit Wrapper List */
    private void filterAdUnitsWrap() {  
        Integer j = 0;
        while (j < adUnitsWrap.size()) {            
            
            Boolean showAdUnitFormula = allAdUnits.get(adUnitsWrap[j].adUnit).showAdUnitFormula__c;
            Boolean filterSize = adunitsSizes.get(adUnitsWrap[j].adUnit).contains(',' + filterSize + ','); 
            Boolean filterCanalePrimario = adUnitsCanali.get(adUnitsWrap[j].adUnit).contains(';' + filterCanalePrimario + ';') || filterCanalePrimario == '';

            Boolean removeAdunit = !( (showAdUnitFormula && filterSize && filterCanalePrimario) || drillDownLevel == 0 );

            /*
            system.debug('adunit = '+adUnitsWrap.get(j).AdUnit);
            system.debug('showAdUnitFormula = '+showAdUnitFormula);
            system.debug('filterSize = '+filterSize);
            system.debug('filterCanalePrimario = '+filterCanalePrimario);
            system.debug('drillDownLevel == 0 = '+ (drillDownLevel == 0));            
            system.debug('removeAdunit = '+removeAdunit);
            */ 


            if( removeAdunit ){
                adUnitsWrap.remove(j);
            }else {
                j++;
            }
        }       
    }
    
    
    
    public class LineItemWrapper {
        public LineItem__c li{get; set;}
        public Boolean selected {get; set;}
        public LineItemWrapper(LineItem__c a) {
            li = a;
            selected = false;
        }
    }
    
    public class AdUnitWrapper {
        public Id adUnit {get; set;}
        public Boolean includeSelected {get; set;}
        public Boolean excludeSelected {get; set;}
        public Integer children {get;set;}
        public AdUnitWrapper(AdUnit__c adUnit) {
            this.adUnit = adUnit.id;
            this.includeSelected = false;
            this.excludeSelected = false;
            this.children = 0;
        }
        
    }
    
        
}