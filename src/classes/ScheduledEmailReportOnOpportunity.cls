global class ScheduledEmailReportOnOpportunity implements Schedulable {
    global void execute(SchedulableContext SC) {
    	EmailSender emailSender = new EmailSender();
		emailSender.sendMailToOpportunityDelivered();
		emailSender.sendMailToOpportunityLongerThan14days();
    }
    
    public class EmailSender {
        public void sendMailToOpportunityDelivered() {
        	List<Opportunity> opportunityDelivered = [SELECT Name FROM Opportunity WHERE Data_fine__c = YESTERDAY AND (StageName = 'Chiusa vinta' OR StageName = 'Chiusa Vinta – in modifica')];
        	
        	for(Opportunity opp : opportunityDelivered) {
        		opp.Manda_email_campagna_deliverata__c = true;
        		System.debug('Manda email campagna deliverata: ' + opp);
        	}
        	
        	UtilSkipTrigger.skipOpportunityTrigger = true;
        	update opportunityDelivered;
        }
        
        public void sendMailToOpportunityLongerThan14days() {
        	List<Opportunity> opportunityDeliveringLongerThan14days = [SELECT Name, Data_inizio__c, Data_fine__c, Durata_giorni__c,
                                                                            (SELECT Id FROM Line_Items__r WHERE ImpressionsDelivered__c > 0 and Start_date__c  <= THIS_WEEK and End_date__c >= THIS_WEEK)  
                                                                       FROM Opportunity
																	   WHERE Data_inizio__c < TODAY
																	   AND Data_fine__c >= TODAY 
																	   AND Durata_giorni__c > 14
                                                                       AND (StageName = 'Chiusa vinta' OR StageName = 'Chiusa Vinta – in modifica')];
        	
        	for(Opportunity opp : opportunityDeliveringLongerThan14days) {
        		Integer diff = opp.Data_inizio__c.daysBetween(System.today());
        		
        		if(Math.mod(diff, 7) == 0 && opp.Line_Items__r.size()>0) {
        			opp.Manda_email_settimanale__c = true;
        			System.debug('Manda email settimanale: ' + opp);
        		}	
        	}
        	
        	UtilSkipTrigger.skipOpportunityTrigger = true;
        	update opportunityDeliveringLongerThan14days; 				    
        }

    }
}