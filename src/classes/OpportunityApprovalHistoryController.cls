public class OpportunityApprovalHistoryController {
    public String opptyId {get;set;}
    public List<ProcessInstanceHistory> getApprovalSteps() {
      if (opptyId != null) {
        Opportunity opp = [Select Id, (Select TargetObjectId, SystemModstamp, StepStatus,
                                              RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, 
                                              CreatedDate, CreatedById, Comments, ActorId 
                                       From ProcessSteps 
                                       Order by SystemModstamp desc) 
                           from Opportunity 
                           where Id = :opptyId
                          ];
        return opp.ProcessSteps;
      }
      return new List<ProcessInstanceHistory> ();
    } 

}