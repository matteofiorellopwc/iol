@isTest
private class AdUnitsDfpCtrlTest {

    static testMethod void myUnitTest() {
        //Crea Ad Units
        List<AdUnit__c> adUnits = new List<AdUnit__c>();
        for (Integer i = 1; i < 1500; i++) {
            adUnits.add(new AdUnit__c(Name = 'Test', status__c = 'ACTIVE', idDfp__c = String.valueOf(i)));
		}
        insert adUnits;
        
        PageReference testPage = Page.AdUnitsDfp;
        Test.setCurrentPage(testPage);
        AdUnitsDfpCtrl controller = new AdUnitsDfpCtrl();
        controller.getCanaliPrimari();
        for(AdUnitsDfpCtrl.AdUnit au : controller.adUnitDfpList1) {
        	au.checked = true;    
        }
        
        for(AdUnitsDfpCtrl.AdUnit au : controller.adUnitDfpList2) {
        	au.checked = true;    
        }
        controller.canaliPrimariSelected.add('Home page');
        controller.assignCanalePrimario();
        controller.syncDfp.getJobStatus();
        System.assertEquals(controller.adUnitDfpList1[0].adUnit.CanalePrimario__c, 'Home page');
    }
}