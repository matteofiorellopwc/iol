public class OpportunityTeamMemberTriggerHandler {	
	@future
	public static void manageSharing(Set<Id> oppIds) {
		Opportunity[] opps = [SELECT Id,OwnerCentroMediaId__c,Centro_Media__c FROM Opportunity WHERE Id IN :oppIds];				
		OpportunityTriggerHandler.manageSharing(opps, null, null, true);		
	}
}