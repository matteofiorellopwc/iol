@isTest
public class testTriggerItNet{


    public static testMethod void testPropagazioneDataChiusura(){
        Account a = UtilTestApritisito.insertClienteTest(null);
        Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
        Product2 p = UtilTestApritisito.insertProdottiItNet(1)[0];
        Listino__c l = UtilTestApritisito.insertListino();
        UtilTestApritisito.insertRigheListino(l,new Product2[]{p});
        ProdottoSottoContratto__c psc = UtilTestApritisito.insertProdottiSottoContratto(sc,new Product2[]{p})[0];
        
        c.data_chiusura__c = date.today().addDays(30);
        c.Propaga_data_chiusura__c = true;
        update c;
        
        system.assertEquals(date.today().addDays(30),[select data_chiusura__c from ProdottoSottoContratto__c where id =: psc.id].data_chiusura__c);
    }
    
        
    public static testMethod void testScheduledDisableTempItNet() {
        Account a = UtilTestApritisito.insertClienteTest('Temp');
        ScheduledDisableTempItNet sch = new ScheduledDisableTempItNet();
        Test.startTest();
        sch.execute(null);
        Test.stopTest();
        a = [SELECT Stato__c FROM Account];
        System.assertEquals('Temp', a.Stato__c);
    }


}