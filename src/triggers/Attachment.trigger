trigger Attachment on Attachment (after insert) {
	
    Set<Id> adminIdSet = new Set<Id>();
    List<Attachment> oppAttachmentsTriggerNew = new List<Attachment>();
    Set<Id> oppIdSet = new Set<Id>();
    Map<Id, Opportunity> oppMap = null;
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for(User u : [SELECT Id,Name,Profile.Name FROM User WHERE Profile.Name = 'System Administrator']) {
    	adminIdSet.add(u.Id);   
    }
    
    for(Attachment att : Trigger.New) {
        if(adminIdSet.contains(att.OwnerId)) { //Sent mail only for opportunity created by System Administrator (created by Conga)
        	if(String.valueOf(att.ParentId).substring(0, 3) == '006') { // and only for Opportunity attachments
                if(att.Name.contains('Report finale campagna') || att.Name.contains('Report settimanale campagna')) { // and only with a specific Name (created by Conga)
                    oppAttachmentsTriggerNew.add(att);
                }
        	}
        }
    }
    for(Attachment att : oppAttachmentsTriggerNew) {
    	oppIdSet.add(att.ParentId);    
    }
    oppMap = new Map<Id, Opportunity>([SELECT Name, Account.Name, Owner.Email, Account.Owner.Email, Centro_Media__r.Owner.Email  FROM Opportunity WHERE Id IN :oppIdSet]);
    
    for(Attachment att : oppAttachmentsTriggerNew) {
        Opportunity opp = oppMap.get(att.ParentId);
        List<String> toAddressesList = new List<String>();
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        
        toAddressesList.add(opp.Owner.Email);
        if(String.isNotBlank(opp.Account.Owner.Email)) {
        	toAddressesList.add(opp.Account.Owner.Email);
        }
        if(String.isNotBlank(opp.Centro_Media__r.Owner.Email)) {
        	toAddressesList.add(opp.Centro_Media__r.Owner.Email);
        }
        
        EmailLog__c el = EmailLog__c.getInstance('Email addizionali report campagna');
        if(String.isNotBlank(el.emails__c)) {
            toAddressesList.addAll(el.emails__c.split(','));
        }
        email.setToAddresses(toAddressesList);
        
        if(att.Name.contains('Report finale campagna')) {
        	email.setSubject('Report finale campagna erogata - ' + opp.Account.Name + '/' + opp.Name);
        } else if (att.Name.contains('Report settimanale campagna')) {
        	email.setSubject('Report settimanale campagna in erogazione - ' + opp.Account.Name + '/' + opp.Name);    
        }
        
        email.setHtmlBody(buildMailBody(att, opp));
        emails.add(email);	
    }
    Messaging.sendEmail(emails);
    
    private String buildMailBody(Attachment att, Opportunity opp) {       
        String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '';
        
        
        if(att.Name.contains('Report finale campagna')) {
        	body += '<p>Il report finale di campagna erogata è stato generato ed è stato allegato all\'opportunity <a href="' + sfdcUrl + '/' + opp.Id +'">' + opp.Name + '</a>.</p>';
        } else if (att.Name.contains('Report settimanale campagna')) {
        	body += '<p>Un nuovo report settimanale di campagna in erogazione è stato generato ed è stato allegato all\'opportunity <a href="' + sfdcUrl + '/' + opp.Id +'">' + opp.Name + '</a>.</p>';
        }
        
        body += '<p>Clicca <a href="' + sfdcUrl + '/servlet/servlet.FileDownload?file=' + att.Id +'">qui</a> per scaricare e visualizzare il report.</p>';
        return body;
    }
}