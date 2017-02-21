public class ControllerContendingCPM {
	final Id lineItemId;
	final transient Map<Id,AdUnit__c> allAdUnits;
	final transient Map<Id, Set<Id>> parent2ChildRel;
	 
	public LineItem__c[] contendingLineItems { get; private set; }

	public ControllerContendingCPM() {
		lineItemId = ApexPages.CurrentPage().getParameters().get('id');
		
		string paramStartDate = ApexPages.CurrentPage().getParameters().get('startdate');
        string paramEndDate = ApexPages.CurrentPage().getParameters().get('enddate');
        string paramPriority = ApexPages.CurrentPage().getParameters().get('priority');


		contendingLineItems = new LineItem__c[]{};

		allAdUnits = new Map<Id, AdUnit__c>([SELECT
			Id,
			ParentAdUnit__c, 
			Status__c, 
			hideAdUnit__c, 
			explicitlyTargeted__c 
			FROM AdUNit__c
		]);

	 	parent2ChildRel = new Map<Id, Set<Id>>();    	
    	for(AdUnit__c au : allAdUnits.values()) {    		
    		if(au.ParentAdUnit__c != null) {
				if(!parent2ChildRel.containsKey(au.ParentAdUnit__c)) parent2ChildRel.put(au.ParentAdUnit__c, new Set<Id>());
    			parent2ChildRel.get(au.ParentAdUnit__c).add(au.Id);    			
    		}
    	}

		LineItem__c li = [SELECT
			Id,
			Start_date__c,
			End_date__c,
			Priority__c,
			Product__r.Size__c,
			Product__r.multisize__c,
			(SELECT Ad_Unit__c, InventoryTargetingType__c FROM Inventory_Target__r)
			FROM LineItem__c
			WHERE Id = :lineItemId		
		];

		if(paramStartDate != null) {
            li.start_date__c = date.parse(paramStartDate);
        }
        if(paramEndDate != null) {
            li.end_date__c = date.parse(paramEndDate);
        }
        if(paramPriority != null ){
        	li.Priority__c = paramPriority;
        }
        Decimal priorityNumber = Decimal.valueOf(li.Priority__c);
				
		Set<String> sourceSizes = new Set<String>();
		if(li.Product__r.multisize__c != null && li.Product__r.multisize__c != '') {
			sourceSizes.addAll(li.Product__r.multisize__c.split(';'));
		} else {
			sourceSizes.add(li.Product__r.Size__c);
		}
 		
		Set<Id> includedAdUnits = new Set<Id>();
		Set<Id> excludedAdUnits = new Set<Id>();	
		for(Inventory_Target__c it : li.Inventory_Target__r) {
			if(it.InventoryTargetingType__c == 'targeted') {
				includedAdUnits.add(it.Ad_Unit__c);
			} else {
				excludedAdUnits.add(it.Ad_Unit__c);
			}
		}						
						
		Map<Id, Set<Id>> conflictMap = UtilityAdUnit.getConflictMap(
			includedAdUnits, 
			getExcludedMap(excludedAdUnits), 
			allAdUnits.values()
		);
		
		Set<Id> conflictSet = new Set<Id>();
		conflictSet.addAll(conflictMap.keySet());
		for(Id adUnitId : conflictMap.keySet()) {
			conflictSet.addAll(conflictMap.get(adUnitId));
		}
		
		System.debug('INCLUDED AD UNITS: ' + includedAdUnits);
		System.debug('EXCLUDED AD UNITS: ' + excludedAdUnits);
		System.debug('CONFLICT SET: ' + conflictSet);
		System.debug('LI STARTDATE: ' + li.Start_date__c);
		System.debug('LI ENDDATE: ' + li.End_date__c);
		
		for(LineItem__c l : [SELECT
			Id,
			Name,
			Start_date__c,
			End_date__c,
			Priority__c,
			Opportunity__r.Name,
			Opportunity__r.Owner.Name,
			Product__r.Size__c,
			Product__r.multisize__c,
			Name_dfp__c,
			Quantita__c,
			Delivery_Model__c,
			(SELECT Ad_Unit__c, InventoryTargetingType__c FROM Inventory_Target__r WHERE InventoryTargetingType__c = 'excluded')
			FROM LineItem__c
			WHERE Start_date__c <= :li.End_date__c
			AND End_date__c >= :li.Start_Date__c 
			AND Priority_formula__c <= : priorityNumber
			AND Id IN (SELECT LineItem__c FROM Inventory_Target__c WHERE Ad_Unit__c IN :conflictSet AND InventoryTargetingType__c = 'targeted')
			AND Id <> :li.Id
			AND End_date__c >=: date.today()
			ORDER BY Priority__c
		]) {
			String[] targetSizes = new String[]{};
			if(l.Product__r.Size__c == 'Multisize') {
				targetSizes = l.Product__r.multisize__c.split(';');
			} else {
				targetSizes.add(l.Product__r.Size__c);
			}

			System.debug('SOURCE SIZES: ' + sourceSizes);
			System.debug('TARGET SIZES: ' + targetSizes);

			Boolean foundOne = false;
			for(String targetSize : targetSizes) {
				if(sourceSizes.contains(targetSize)) {
					foundOne = true;
					break;
				}
			}

			System.debug('FOUND ONE: ' + foundOne);
			if(!foundOne) continue;
			
			//Controllo su inventory target esclusi
			if(!l.Inventory_Target__r.isEmpty()) {
				Set<Id> exAdSet = new Set<Id>();
				for(Inventory_Target__c it : l.Inventory_Target__r) {
					exAdSet.add(it.Ad_Unit__c);
				}						 
				for(Set<Id> e : getExcludedMap(exAdSet).values()) {
					exAdSet.addAll(e);
				}
				Set<Id> inclAdUnitSource = includedAdUnits.clone();
				
				System.debug('ORIGINAL!!! ' + inclAdUnitSource);
				System.debug('TARGET!!! ' + exAdSet);
				
				inclAdUnitSource.removeAll(exAdSet);
				if(!inclAdUnitSource.isEmpty()) contendingLineItems.add(l);
			} else {		
				contendingLineItems.add(l);
			}
		}
	}
	
	private Map<Id, Set<Id>> getExcludedMap(Set<Id> excludedAdUnits) {
		Map<Id, Set<Id>> excludedMap = new Map<Id, Set<Id>>();				
		for(Id adUnitId : excludedAdUnits) {
			Id parentAdUnit = allAdUnits.get(adUnitId).ParentAdUnit__c;
			if(parentAdUnit != null) {
				if(!excludedMap.containsKey(parentAdUnit)) excludedMap.put(parentAdUnit, new Set<Id>());
				excludedMap.get(parentAdUnit).add(adUnitId);
			}	
		}
		UtilityAdUnit.fillExcludedMap(excludedMap, allAdUnits, parent2ChildRel);
		return excludedMap;		
	}
	
	public PageReference back() {
		return new PageReference('/' + lineItemId);
	}
}