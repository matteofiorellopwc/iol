/**
 *  Date:   2014/07/02
 *  Description:   Scheduled class for updating the DataChiusuraRicavo
 *  Author: Luca Venanzetti
 */
public with sharing class UpdateDataChiusuraRicavi {
	
	/**
	* aggiorna la data di chiusura dei ricavi all'ultimo giorno del mese precedente quello attuale
	*/
	public UpdateDataChiusuraRicavi() {
		DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
		Date dataOrdierna = Date.today();
		Date nuovaDataChiusuraRicavi = Date.newInstance(dataOrdierna.year(),dataOrdierna.month(),1);
		nuovaDataChiusuraRicavi = nuovaDataChiusuraRicavi.addDays(-1);
		dataChiusuraRicavo.data__c = nuovaDataChiusuraRicavi;
		update dataChiusuraRicavo;
	}
}