global class ControllerPlacement{
    
    public List<Placement__c> placements {get;set;}
    public String sobjectname {get;set;}
    public Id id {get;set;}
    public List<PlacementTargeting__c> placementIncluded {get;set;}
    public Map<Id,boolean> includeMap {get;set;}
    public boolean isInclude {get;set;}
    Transient Map<Id,AdUnit__c> allAdUnits {get;set;}
    Transient Map<Id,String> adunitsSizes {get;set;}
    Transient Map<id,list<adunit__c>> AdunitMap {get;set;}
    public Map<Id,String> placementsSizes {get;set;}
    public Map<String,Id> mapIdDfp {get;set;}
    public String filterSize {get;set;}
    public String canalePrimario {get;set;}
    
    public ControllerPlacement(){       
         System.debug('Placement on product: ' + id);
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
         this.filterSize = ApexPages.CurrentPage().getParameters().get('filterSize');
        this.canalePrimario = ApexPages.CurrentPage().getParameters().get('canalePrimario');
        
        allAdUnits = new Map<Id,AdUnit__c>([select id,name,idDfp__c ,level__c,ParentAdUnit__c,hasParent__c,explicitlyTargeted__c,
        											path__c,Sizes__c,HideAdUnit__c,Target_platform__c,SublevelSizes__c
        									from AdUnit__c 
        									where iddfp__c <> null 
        									order by level__c]);
        this.calculateTree();
        
        placementIncluded = [select id,name,Placement__c from PlacementTargeting__c where Line_Item__c =:id or Product__c =:id];
        set<id> placementIncludedId = new set<id>();
        for(PlacementTargeting__c pt : placementIncluded){
          placementIncludedId.add(pt.Placement__c);
        }


        /*placements = [select id,name,targetedAdUnitIds__c, CanalePrimario__c 
                      from Placement__c 
                      where id in : placementIncludedId 
                      OR status__c = 'ACTIVE'];       
        */
        System.debug(LoggingLevel.WARN,'Canale primario: '+canalePrimario);
        String queryString = 'select id,name,targetedAdUnitIds__c from Placement__c where ';
        if(canalePrimario.length()>0){
          queryString += '(id in : placementIncludedId OR status__c = \'ACTIVE\')  AND CanalePrimario__c includes (\''+canalePrimario+'\')';
        }else{
          queryString += 'id in : placementIncludedId OR status__c = \'ACTIVE\'';
        }
        placements = Database.query(queryString); 
        
        System.debug(LoggingLevel.WARN,'Record estratti: '+placements);
        
        isInclude = placementIncluded.isEmpty();
        this.loadPlacementProduct(placementIncludedId);
        this.calculateAllSizes();
        this.calculateAllSizesPlacements();
    }
    
   private void loadPlacementProduct(set<id> placementIncludedId){
      includeMap = new Map<id,boolean>();
      for(Placement__c inv : placements){
        includeMap.put(inv.id,placementIncludedId.contains(inv.id));
      }
    }
    
    
   private void calculateAllSizes(){
        adunitsSizes = new Map<Id,String>();
        mapIdDfp = new Map<String,Id>();
        for(Id adId : allAdUnits.keySet()){
            mapIdDfp.put(allAdUnits.get(adId).idDfp__c,adId);
            adunitsSizes.put(adId,calculateSizes(adId));        
        }
    }
    
  private void calculateAllSizesPlacements(){
      placementsSizes = new Map<Id,String>();
      for(Placement__c pl : placements){        
           if(pl != null)             
              placementsSizes.put(pl.id,calculateSizesPlacement(pl));        
        }
     // System.debug('*********** Placement sizes: ' + placementsSizes);
  }
  
  private String calculateSizesPlacement(Placement__c pl){
     String sizes = '';
     if(pl.targetedAdUnitIds__c != null){
          List<String> targeted = pl.targetedAdUnitIds__c.split(',');
         for(String t : targeted){
             sizes += adunitsSizes.get(mapIdDfp.get(t));
             sizes += ',';
         }
     }
     return sizes;
  }
    
   private void calculateTree(){
        adUnitMap = new Map<id,list<adunit__c>>();
        for(Id adId : allAdUnits.keySet()){            
            
            if(allAdUnits.get(adId).parentAdUnit__c != null){
                if(!adUnitMap.keySet().contains(allAdUnits.get(adId).parentAdUnit__c)){
                    adUnitMap.put(allAdUnits.get(adId).parentAdUnit__c,new list<adunit__c>());
                }
                adUnitMap.get(allAdUnits.get(adId).parentAdUnit__c).add(allAdUnits.get(adId));
            }            
            if(adUnitMap.get(adid) == null){
                adUnitMap.put(adid,new list<adunit__c>());                
            }
        }
    }
    
    private String calculateSizes(Id id){           
        String sizes = allAdUnits.get(id).SublevelSizes__c;
        sizes = sizes == null ? 'Multisize,' : sizes;
        sizes = ',' + sizes;
        for(AdUnit__c adunit : adUnitMap.get(id)){
            sizes += calculateSizes(adunit.Id);
        }
        return sizes + ',';
    }
    
    @RemoteAction
    global static String addPlacement(String id, String parentId,String sobjectName){

        PlacementTargeting__c p = new PlacementTargeting__c();
        
        if(sobjectName == 'lineitem__c'){
          p.Line_Item__c = parentId;
          p.Product__c = null;
        }else if(sobjectName == 'product__c'){
          p.Product__c = parentId;
          p.Line_Item__c = null;
        }else{
          return null;
        }
        
        p.Placement__c = id;
        
        insert p;
        
        return 'inserted ' + p.Id; 
    } 
    
    @RemoteAction
    global static String removePlacement(String id, String parentId){
        List<PlacementTargeting__c> p = [select id from PlacementTargeting__c where Placement__c =: id and (Product__c =: parentId or Line_Item__c =: parentId) ];        
        delete p;
        
        return 'deleted ' + id; 
    } 
    
    
      static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;
        
        Placement__c placement = new Placement__c(Name='Test',targetedAdUnitIds__c = '1',status__c='ACTIVE');
        insert placement;
        
        AdUnit__c a = new AdUnit__c(Name='Test ad unit',idDfp__c = '1');   
        insert a;
        
        ApexPages.CurrentPage().getParameters().put('id',p.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','Product__c'); 
        ApexPages.CurrentPage().getParameters().put('canalePrimario',''); 
          
       
        ControllerPlacement cp = new ControllerPlacement();
        System.assertEquals(1,cp.placements.size());
        System.assertEquals(0,cp.placementIncluded.size());
        
        ControllerPlacement.addPlacement(placement.id,p.id,'Product__c');
       
        cp = new ControllerPlacement();
        System.assertEquals(1,cp.placementIncluded.size());
        
        ControllerPlacement.removePlacement(placement.id,p.id);
        
        cp = new ControllerPlacement();
        System.assertEquals(0,cp.placementIncluded.size());
        
        
       

     }


}