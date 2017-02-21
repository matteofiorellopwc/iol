@isTest
private class LocalUserTest {

	@isTest static void LocalUser() {
		List<User> usersLocal = [SELECT Id FROM User WHERE UserLocal__c = true AND SuperUserLocal__c = false LIMIT 1];
		List<User> usersSuperLocal = [SELECT Id FROM User WHERE SuperUserLocal__c = true LIMIT 1];
		List<User> usersNotLocal = [SELECT Id FROM User WHERE UserLocal__c = false LIMIT 1];
		System.Debug('PuntoDebug - usersLocal: '+usersLocal);
		System.Debug('PuntoDebug - usersSuperLocal: '+usersSuperLocal);
		System.Debug('PuntoDebug - usersNotLocal: '+usersNotLocal);

		if (!usersLocal.isEmpty()) {
			LocalUser lu = new LocalUser(usersLocal.get(0).Id);
			System.assert(lu.isLocalUser);
			System.assert(!lu.isLocalAdminUser);
		}
		if (!usersSuperLocal.isEmpty()) {
			LocalUser lu = new LocalUser(usersSuperLocal.get(0).Id);
			System.assert(lu.isLocalUser);
			System.assert(lu.isLocalAdminUser);
		}
		if (!usersNotLocal.isEmpty()) {
			LocalUser lu = new LocalUser(usersNotLocal.get(0).Id);
			System.assert(!lu.isLocalUser);
			System.assert(!lu.isLocalAdminUser);
		}
	}
	
}