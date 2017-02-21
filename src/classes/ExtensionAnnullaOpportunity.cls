public class ExtensionAnnullaOpportunity {

    private Opportunity opportunity {get;set;}
    public Boolean hasErrors {get;set;}

    public ExtensionAnnullaOpportunity(ApexPages.StandardController controller) {
        opportunity = (Opportunity) controller.getRecord();
        hasErrors = false;
    }

    public void init(){
        Boolean canEdit = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                             WHERE UserId =: UserInfo.getUserId() AND RecordId =: opportunity.Id
                            ].HasEditAccess;
        
        //Se non si hanno i permessi apparirà un messaggio d'errore a video
        if(!canEdit) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lei non ha i diritti per effettuare questa operazione'));
            hasErrors = true;
            return;
        }
        if(opportunity.DataPrimaChiusaVinta__c == null){
            return;
        }
        System.SavePoint sp = Database.setSavePoint();
        String oldStageName = opportunity.StageName;
        try{
            opportunity.StageName = 'Annullata';
            opportunity.IsArchived__c = true;
            update opportunity;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Non è possibile annullare questa opportunity: ' + e.getMessage()));
            hasErrors = true;
        }finally{
            if(sp != null){
                Database.rollback(sp);
            }
            opportunity.StageName = oldStageName;
        }
    }

    /**
    * Archivia la campagna e tutti i suoi line items sull'ad server
    */
    public PageReference annullaOpportunity(){
        try{
            if(opportunity.Id_dfp__c != null && !Test.isRunningTest()){
                DfpIntegration dfp = new DfpIntegration();
                UtilityOrderIntegration.pauseOrders(new Decimal[]{opportunity.Id_dfp__c},dfp);
                UtilityOrderIntegration.archiveOrders(new Decimal[]{opportunity.Id_dfp__c},dfp);
                UtilityOrderIntegration.syncDfpToSfdcOrders(new Opportunity[]{opportunity},dfp);
                List<LineItem__c> lineitems = [SELECT Id,Id_dfp__c,Status__c FROM LineItem__c WHERE Opportunity__c = :opportunity.Id];
				UtilityLineItemIntegration.syncDfpToSfdcLineItems(lineitems);
				update lineitems;
            }
            opportunity.IsArchived__c = true;
            opportunity.StageName = 'Annullata';
            update opportunity;
            return goBack();
        }catch(Exception e){
            ApexPages.addMessages(e);
            hasErrors = true;
        }
        return null;
    }

    public PageReference goBack(){
        return new PageReference('/' + opportunity.Id);
    }

}