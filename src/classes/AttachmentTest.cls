@isTest
private class AttachmentTest{
	static testMethod void congaAttachmentTest() {
        //PREPARE DATA:
        // Insert custom setting
		EmailLog__c customSetting = new EmailLog__c(Name = 'Email addizionali report campagna', emails__c = 'test1@test.com,test2@test2.com');
        insert customSetting;
        
        Opportunity opp = utilityTest.insertDfpOasOpp();
        
        User u = [SELECT Name,Profile.Name FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Attachment attach = new Attachment();   	
    	attach.Name = 'Report settimanale campagna';
        attach.OwnerId = u.Id;
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	attach.body = bodyBlob;
        attach.parentId = opp.id;
        insert attach;
    	
    	List<Attachment> attachments = [SELECT Name FROM Attachment WHERE parentId = :opp.id];
    	System.assertEquals(1, attachments.size());
    }
}