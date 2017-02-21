/* Nel caso in cui le performance di una campagna su più giorni siano inferiori al valore atteso 
 *(ipotizzando una distribuzione lineare del target sul numero di giorni di erogazione), 
 * dovrà essere inviato ad apposita DL un alert di possibile underdelivery del LI
 *
 * Devono essere avvisati:
 *  - Profilo "Libero – Marketing"
 *  - Utente "_PostSales_Team"
 *  - Account Diretta
 *  - Account Centro Media
 *  - Account Agenzia Territoriale
 *  - Utenti in Sharing esplicito sull’Opportunità
 */
 
global class ScheduledAlertUnderdelivery implements Schedulable {
    global void execute(SchedulableContext SC) {
        EmailSender emailSender = new EmailSender();
        emailSender.sendMail();
    }
    
    public class EmailSender {
        /* Method that sends the email to the users with the link to the report "Report_underdelivery_CPM" */
        public void sendMail() {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(getEmailAddresses(getUsersList()));
            
            //For Debug
            //email.setToAddresses(new List<String>{'massimiliano.colombi@italiaonline.it'});
            //email.setCCAddresses(new List<String>{'raffaello.lacontana@telnext.com'});
            
            email.setSubject('Alert Underdelivery');
            email.setHtmlBody(buildMailBody());
            emails.add(email);

            //Send emails
            Messaging.sendEmail(emails);
        }
        
        /* Return the list of users who will receive the email */
        private List<User> getUsersList() {
            List<User> users = new List<User>(); //Users list 
            List<LineItem__c> lineItems = getUnderDeliveredLineItems(); // Underdelivered line-items
            List<Opportunity> opportunities = getOppWithUnderDeliveredLineItems(lineItems); //Opportunities with underdelivered line-items
                        
            Set<Id> userIdSet = new set<id>();

            for(set<id> i : OpportunityTriggerHandler.getUsersRelatedToOpportunities(opportunities).values()){
                userIdSet.addAll(i);
            }

            
            //Add users with Libero – Marketing profile
            for(User u : [SELECT Name FROM User WHERE Alert_Underdelivery__c = TRUE]) {
                userIdSet.add(u.Id);
                System.debug('Aggiunto utente profilo marketing: ' +  u.Id);    
            }
            
            //Add "_PostSales_Team" user
            try {
                userIdSet.add([SELECT Name FROM User WHERE Name = '_PostSales_Team' LIMIT 1].Id);
                System.debug('Aggiunto utente PostSales');
            } catch (Exception e) {
                System.debug('Aggiunto utente PostSales: non trovato!');
            }
            
            
            //Add users in "Manual" and "Team" sharing
            for(OpportunityShare os : [SELECT UserOrGroupId, RowCause FROM OpportunityShare WHERE OpportunityId IN :opportunities AND RowCause IN ('Manual', 'Team')]) {
                if(os.UserOrGroupId.getSobjectType().getDescribe().getName().equals('User')) {   
                    userIdSet.add(os.UserOrGroupId);
                    System.debug('Aggiunto utente '+os.RowCause+': ' + os.UserOrGroupId);    
                }   
            }
                 
            
            users = [SELECT Email FROM User WHERE Id IN :userIdSet];    
            return users;
        }  

        /* Given the list of users, return their email addresses */
        private List<String> getEmailAddresses(List<User> users) {
            List<String> mailToAddresses = new List<String>();
            for(User u: users) {
                mailToAddresses.add(u.Email);
            }
            return mailToAddresses;
        }
        
        /* Return the list of under delivered line-items */
        private List<LineItem__c> getUnderdeliveredLineItems() {
            List<LineItem__c> lineItems = new List<LineItem__c>();
            lineItems = [SELECT Name, StartDateTimeFormula__c, EndDateTimeFormula__c, Opportunity__r.OwnerId, Opportunity__r.Centro_Media__r.OwnerId, Opportunity__r.Account.OwnerId
                         FROM LineItem__c
                         WHERE StartDateTimeFormula__c < :System.now()
                         AND EndDateTimeFormula__c > :System.now()
                         AND delivery_progress__c < 100
                         AND Filtro_per_Underdelivery__c = true
                         AND Opportunity__r.Venditore__r.UserLocal__c = false
                         ];
            return lineItems;       
        }
        
        /* Return the list of opportunities from the line-items */
        private List<Opportunity> getOppWithUnderdeliveredLineItems(List<LineItem__c> lineItems) {
            List<Opportunity> opportunities = new List<Opportunity>();
            Set<Id> opportunitiesId = new Set<id>();
            
            for(LineItem__c li : lineItems) {
                opportunitiesId.add(li.Opportunity__c); 
            }
            opportunities = [SELECT Name, OwnerId, Centro_Media__r.OwnerId, Account.OwnerId, 
                                    Agenzia_di_riferimento__c, Agenzia_di_riferimento__r.Nome_Gruppo_Agenzia__c,
                                    Nome_gruppo_agenzia__c,OwnerCentroMediaId__c,OwnerAccountId__c
                             FROM Opportunity WHERE Id IN :opportunitiesId];
            return opportunities;       
        }
                
        /* Method that builds the body of the email */
        private String buildMailBody() {            
            String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm();
            String reportName = 'Report_underdelivery_CPM'; //Name of the report that will be linked in the mail    
            String body = '';
            try {
                Id reportId = [SELECT Name FROM Report WHERE DeveloperName = 'Report_underdelivery_CPM'].Id;
                body += '<p>Ci sono alcuni line-items in <b>underdelivery</b></p>';
                body += '<p>Clicca <a href="' + sfdcUrl + '/' + reportId +'">qui</a> per visualizzare il report.</p>';
            } catch(Exception e) {
            }
            return body;
        }
    }
}