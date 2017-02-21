/**
 *  Date:   2014/07/01
 *  Description:    Controller for PannelloGestioneRicavi
 *  Author: Luca Venanzetti
 */

public class ControllerPannelloGestioneRicavi {
	
	public DataChiusuraRicavo__c dataChiusuraRicavo {get; set;}
	public Boolean errorOccurred {get;set;}
	
	public List<SelectOption> anni {
		get{
			List<SelectOption> items = new List<SelectOption>();
			Date current = Date.today();
			for(Integer i = current.year()-1; i<=current.year()+1; i++){
				items.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
			}
			return items;
		}
		set;
	}
	public Integer nuovoAnnoChiusuraRicavi {get;set;}
	public List<SelectOption> mesi {
		get{
			List<SelectOption> items = new List<SelectOption>();
			items.add(new SelectOption('1','Gennaio'));
			items.add(new SelectOption('2','Febbraio'));
			items.add(new SelectOption('3','Marzo'));
			items.add(new SelectOption('4','Aprile'));
			items.add(new SelectOption('5','Maggio'));
			items.add(new SelectOption('6','Giugno'));
			items.add(new SelectOption('7','Luglio'));
			items.add(new SelectOption('8','Agosto'));
			items.add(new SelectOption('9','Settembre'));
			items.add(new SelectOption('10','Ottobre'));
			items.add(new SelectOption('11','Novembre'));
			items.add(new SelectOption('12','Dicembre'));
			return items;
		}
		set;
	}
	public Integer nuovoMeseChiusuraRicavi {get;set;} 

	public ControllerPannelloGestioneRicavi(){
		errorOccurred = false;
		LocalUser localUser = new LocalUser();
		if(localUser.isLocalUser && !localUser.isLocalAdminUser){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Non hai i privilegi sufficienti per eseguire questa operazione.'));
			errorOccurred = true;
			return;
		} 
		String type = localUser.isLocalAdminUser ? 'local' : 'nazionale';
		dataChiusuraRicavo = DataChiusuraRicavo__c.getValues(type); 
		Date current = Date.today(); 
		nuovoAnnoChiusuraRicavi = current.year();
		nuovoMeseChiusuraRicavi = current.month();
		String dataChiusuraRicavoAsString = dataChiusuraRicavo.data__c.day() + '/' + dataChiusuraRicavo.data__c.month() + '/' + dataChiusuraRicavo.data__c.year(); 
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'La data di chiusura attuale è '+dataChiusuraRicavoAsString));
	}

	/**
	* Cambia la data di default della chiusura dei ricavi (modifica su Custom Setting)
	*/
	public PageReference aggiornaDataChiusuraRicavi(){
		try{
			dataChiusuraRicavo.data__c = Date.newInstance(Integer.valueOf(nuovoAnnoChiusuraRicavi), Integer.valueOf(nuovoMeseChiusuraRicavi), 1);
			dataChiusuraRicavo.data__c = dataChiusuraRicavo.data__c.addMonths(1);
			dataChiusuraRicavo.data__c = dataChiusuraRicavo.data__c.addDays(-1);
			update dataChiusuraRicavo;
			String dataChiusuraRicavoAsString = dataChiusuraRicavo.data__c.day() + '/' + dataChiusuraRicavo.data__c.month() + '/' + dataChiusuraRicavo.data__c.year();
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'La data di chiusura dei ricavi è stata aggiornata al '+dataChiusuraRicavoAsString));
		}catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
			errorOccurred = true;
		}
		return null;
	}

}