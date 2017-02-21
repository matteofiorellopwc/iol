public with sharing class PlacementsDfpCtrl {

	public List<Placement> placements {get;set;}
	public List<String> placementKeysSelected {get;set;}

	// Costante che determina label e valore per lo sbiancamento del canale primario
    private static final String valoreVuoto = '-------------- Nessuno ---------------';
    
	public PlacementsDfpCtrl() {
		placementKeysSelected = new List<String>();
		retrievePlacements();
		
	}

	public void retrievePlacements(){
		this.placements = new List<Placement>();
		for(Placement__c p : [	SELECT Id,Name,CanalePrimario__c 
								FROM Placement__c 
								WHERE Status__c = 'ACTIVE']){
			this.placements.add(new Placement(p));
		}

	}

	/* Assegna il canale primario ai Placements */
    public void assignCanalePrimario() {
    	List<Placement__c> placementList = new List<Placement__c>();
        
        for(Placement p : placements) {
            if(p.checked) {
            	Placement__c placementObj = new Placement__c();
                placementObj.Id = p.obj.Id;
                if(placementKeysSelected.size() == 1 && placementKeysSelected[0] == valoreVuoto) {
                    placementObj.CanalePrimario__c = '';
                }
                else {
                	placementObj.CanalePrimario__c = '';
                	for(String cps : placementKeysSelected) {
                		if(cps != valoreVuoto) {  
                			placementObj.CanalePrimario__c = placementObj.CanalePrimario__c + cps + ';';
                		}
                	}
                }
                placementList.add(placementObj);
            }           
        }
        
        update placementList;
        retrievePlacements();
    }

    /* Recupera i valori di picklist dal campo CanalePrimario__c del Placement */
	public List<SelectOption> getCanaliPrimari() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Placement__c.CanalePrimario__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        options.add(new SelectOption(valoreVuoto, valoreVuoto));
        return options;
	}

	/* Placement Wrapper Class */
	public class Placement{
		public Placement__c obj {get;set;}
		public Boolean checked {get;set;}

		public Placement(Placement__c p){
			this.obj = p;
			this.checked = false;	
		}
	}
}