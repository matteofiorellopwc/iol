trigger OpportunityTeamMember on OpportunityTeamMember (
	after delete,
	after insert,
	after update)
{
	if(Trigger.isAfter) {
		OpportunityTeamMember[] otmL = Trigger.isDelete ? trigger.old : trigger.new;
		Set<Id> oppIds = new Set<Id>();
		for(OpportunityTeamMember otm : otmL) {
			oppIds.add(otm.OpportunityId);
		}		
		OpportunityTeamMemberTriggerHandler.manageSharing(oppIds);
	}
}