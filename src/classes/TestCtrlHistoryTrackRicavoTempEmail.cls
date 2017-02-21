/**
 *  Date:   2014/07/02
 *  Description:    Test for ControllerHistoryTrackingRicavoTempEmail
 *  Author: Luca Venanzetti
 */
@isTest
private class TestCtrlHistoryTrackRicavoTempEmail {

    static testMethod void run() {
        
        TestRicavoTriggerHandler.prepareData();
        
        ControllerRicavi ctrlRicavi = new ControllerRicavi(TestRicavoTriggerHandler.li);
        ctrlRicavi.setParentValues(TestRicavoTriggerHandler.li);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();
        
        Ricavo__c[] ricavi = [SELECT Id FROM Ricavo__c WHERE Line_Item__c = :TestRicavoTriggerHandler.li.Id];
        for(Ricavo__c ricavo : ricavi){
        	ricavo.Modificato__c = true;
        }
        update ricavi;
        
        insert new Ricavo__History(Field = 'Valore__c', ParentId = ricavi[0].Id);
        
        ControllerHistoryTrackingRicavoTempEmail ctrl = new ControllerHistoryTrackingRicavoTempEmail();
        ctrl.opportunityId = String.valueOf(TestRicavoTriggerHandler.opportunity.Id);
        System.debug(ctrl.test);
        System.debug(ctrl.lineItemsModificati);
		System.debug(ctrl.ricaviModificati);
		System.assertEquals(1,ctrl.ricaviModificati.size());
		
		List<ControllerHistoryTrackingRicavoTempEmail.Ricavo> ricaviModificati = ctrl.ricaviModificati.get(String.valueOf(TestRicavoTriggerHandler.li.Id));
		for(ControllerHistoryTrackingRicavoTempEmail.Ricavo ricavo : ricaviModificati){
			System.assertEquals('',ricavo.newValue);
			System.assertEquals('Valore',ricavo.getEditedField());
			System.assertEquals('Ricavo modificato',ricavo.getStato());
			System.assertEquals(ricavo.createdDate.format('dd/MM/yyyy HH:mm:ss'),ricavo.getDataModifica());
		}
		
    } 
}