/**
 *  Date:   2014/07/02
 *  Description:   Test class for scheduled class UpdateDataChiusuraRicavi
 *  Author: Luca Venanzetti
 */
@isTest
private class TestUpdateDataChiusuraRicavi {

    static testMethod void run() {
        
        Date dataOrdierna = Date.today();
		Date precedenteDataChiusuraRicavi = Date.newInstance(dataOrdierna.year(),dataOrdierna.month(),1);
		precedenteDataChiusuraRicavi = precedenteDataChiusuraRicavi.addMonths(-4).addDays(-1);
		
		// imposto la data di chiusura ricavi a 4 mesi fa
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = precedenteDataChiusuraRicavi;
        insert dataChiusuraRicavo;
        
        // lancio l'aggiornamento della data all'ultimo giorno del mese precedente
        UpdateDataChiusuraRicavi scheduledClass = new UpdateDataChiusuraRicavi();
        
        Date dataChiusuraRicaviAttesa = Date.newInstance(dataOrdierna.year(),dataOrdierna.month(),1);
		dataChiusuraRicaviAttesa = dataChiusuraRicaviAttesa.addDays(-1);
		
        dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        System.assertEquals(dataChiusuraRicavo.data__c,dataChiusuraRicaviAttesa);
    }
}