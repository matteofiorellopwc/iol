trigger AdUnit on AdUnit__c (before update, after insert, after update) {	
	if(Trigger.isBefore && Trigger.isUpdate) {
		Map<Id, Set<String>> parent2SizesMap = new Map<Id, Set<String>>();	
		for(Id auId : trigger.newMap.keySet()) {
			parent2SizesMap.put(auId, new Set<String>());	
		} 
				
		for(AdUnit__c child : [SELECT Id, sizes__c, sublevelSizes__c, ParentAdUnit__c FROM AdUnit__c WHERE ParentAdUnit__c IN :trigger.newMap.keySet() AND ExplicitlyTargeted__c = false]) {			
			if(child.sublevelSizes__c != null && child.sublevelSizes__c != '') parent2SizesMap.get(child.ParentAdUnit__c).addAll(child.sublevelSizes__c.split(';'));
		}
				
		for(Id auId : parent2SizesMap.keySet()) {
			AdUnit__c au = trigger.newMap.get(auId);
			Set<String> sublevelSizes = parent2SizesMap.get(auId);
			if(au.sizes__c != null && au.sizes__c != '') sublevelSizes.addAll(au.Sizes__c.split(','));
			String[] sublevelSizesList = new String[]{};
			sublevelSizesList.addAll(sublevelSizes);
			if(!sublevelSizesList.isEmpty()) {
				au.SublevelSizes__c = String.join(sublevelSizesList, ';');
			}  
		}					
	}
	
	if(Trigger.isAfter) {		
		Map<Id, AdUnit__c> parentAU = new Map<Id, AdUnit__c>();
		for(AdUnit__c au : trigger.new) {			
			if(au.ParentAdUnit__c != null) parentAU.put(au.ParentAdUnit__c, new AdUnit__c(Id = au.ParentAdUnit__c));
		}		
		update parentAU.values();		
	}	
}