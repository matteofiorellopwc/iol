@isTest
private class GenericObjectTest {
	
	@isTest static void test_method_setlvl() {
		Opportunity o = new Opportunity();
		Test.startTest();
        GenericObject ctrl = new GenericObject(o);
        ctrl.setLvl(LoggingLevel.DEBUG);
        Test.stopTest();

	}
	
	@isTest static void test_method_debug() {
		Opportunity o = new Opportunity();
		Test.startTest();
        GenericObject ctrl = new GenericObject(o);
        ctrl.logDebug('test di logDebug');
        Test.stopTest();
	}

}