/**
 *  Date:   2014/07/01
 *  Description:    Controller for ControllerPannelloGestioneRicavi
 *  Author: Luca Venanzetti
 */
@isTest 
public class TestControllerPannelloGestioneRicavi {
    
    static testMethod void run(){
		
		Date dataOrdierna = Date.today();
		Date precedenteDataChiusuraRicavi = Date.newInstance(dataOrdierna.year(),dataOrdierna.month(),1);
		precedenteDataChiusuraRicavi = precedenteDataChiusuraRicavi.addMonths(-4).addDays(-1);
		
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = precedenteDataChiusuraRicavi;
        insert dataChiusuraRicavo;
         
        ControllerPannelloGestioneRicavi ctrl = new ControllerPannelloGestioneRicavi();
        
        List<SelectOption> anni = ctrl.anni;
        System.assertEquals(anni.size(),3);
        List<SelectOption> mesi = ctrl.mesi;
        System.assertEquals(mesi.size(),12);
        
 
        //Date dataChiusuraRicavoDate = DataChiusuraRicavo__c.getValues('data');
        System.assertEquals(RicavoTriggerHandler.getDataChiusuraRicavo(false),ctrl.dataChiusuraRicavo.data__c);
        System.assertEquals(dataOrdierna.year(),ctrl.nuovoAnnoChiusuraRicavi);
        System.assertEquals(dataOrdierna.month(),ctrl.nuovoMeseChiusuraRicavi);
		
		// simulazione errore
        ctrl.nuovoAnnoChiusuraRicavi = 99999;
		ctrl.nuovoMeseChiusuraRicavi = dataOrdierna.month();
		PageReference pr = ctrl.aggiornaDataChiusuraRicavi();
		
		// simulazione senza errore
		
		Date nuovaDataChiusuraRicavi = Date.newInstance(dataOrdierna.year(),dataOrdierna.month(),1);
		nuovaDataChiusuraRicavi = nuovaDataChiusuraRicavi.addDays(-1);
		
        ctrl.nuovoAnnoChiusuraRicavi = nuovaDataChiusuraRicavi.year();
		ctrl.nuovoMeseChiusuraRicavi = nuovaDataChiusuraRicavi.month();
		pr = ctrl.aggiornaDataChiusuraRicavi();
		
		Date dataChiusuraRicavoAggiornata = RicavoTriggerHandler.getDataChiusuraRicavo(new LocalUser().isLocalAdminUser);
		//DataChiusuraRicavo__c.getValues('data').data__c;
        System.assertEquals(nuovaDataChiusuraRicavi,dataChiusuraRicavoAggiornata);
    }
}