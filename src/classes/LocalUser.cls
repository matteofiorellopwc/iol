public with sharing class LocalUser {
	public Boolean isLocalUser {get; set;}
	public Boolean isLocalAdminUser {get; set;}

	public LocalUser(Id userId) {
		if (userId != null) {
			setFlags(userId);
		}
	}

	public LocalUser() {
		setFlags(UserInfo.getUserId());
	}

	private void setFlags(Id userId) {
		List<User> users = [SELECT Id, UserLocal__c, SuperUserLocal__c FROM User WHERE Id = :userId];
		if (users.isEmpty()) {
			System.debug('WARNING - No User with Id: '+userId);
		} else {
			isLocalUser = users.get(0).UserLocal__c;
			isLocalAdminUser = users.get(0).SuperUserLocal__c;	
		}
	}
}