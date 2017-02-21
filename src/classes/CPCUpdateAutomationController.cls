public with sharing class CPCUpdateAutomationController {
	public List<SelectOption> months {get; set;}
	public String month {get; set;}
	public transient Map<Id, LineItem__c> mapLI {get; private set;}
	public Map<Decimal, Id> mapDFPId;
	public Map<Id, WrapperLI> mapWrappers {get; set;}
	public Integer sizeMapWrappers {get; set;}
	public Boolean isDFPDataRetrieved {get; private set;}
    public List<SelectOption> years {get; private set;}
    public String year {get; set;}
	public static final String REVENUE_TOTAL = 'Totale';

	public CPCUpdateAutomationController() {
		System.debug('PD - CPCUpdateAutomationController constructor');
		setMonths();
		setYearsPicklist();
		year = String.valueOf(System.today().year());
		isDFPDataRetrieved = false;
		sizeMapWrappers = 0;
		mapDFPId = new Map<Decimal, Id>();
		mapLI = new Map<Id, LineItem__c>();
		mapWrappers = new Map<Id, WrapperLI>();
	}

/* Population of Month Combobox */
	public void setMonths() {
		months = new List<SelectOption>();
		months.add(new SelectOption('', '-- Select --'));
		months.add(new SelectOption('1', 'Gennaio'));
		months.add(new SelectOption('2', 'Febbraio'));
		months.add(new SelectOption('3', 'Marzo'));
		months.add(new SelectOption('4', 'Aprile'));
		months.add(new SelectOption('5', 'Maggio'));
		months.add(new SelectOption('6', 'Giugno'));
		months.add(new SelectOption('7', 'Luglio'));
		months.add(new SelectOption('8', 'Agosto'));
		months.add(new SelectOption('9', 'Settembre'));
		months.add(new SelectOption('10', 'Ottobre'));
		months.add(new SelectOption('11', 'Novembre'));
		months.add(new SelectOption('12', 'Dicembre'));		
	}

	/* Population of Year Combobox */
	public void setYearsPicklist() {
		Integer currYear = System.today().year();
    	years = new List<SelectOption>();
		years.add(new SelectOption(String.valueOf(currYear-1), String.valueOf(currYear-1)));
		years.add(new SelectOption(String.valueOf(currYear), String.valueOf(currYear)));
		years.add(new SelectOption(String.valueOf(currYear+1), String.valueOf(currYear+1)));
    }

/*Population of OLI List*/
	public void setLI() {
		if (month == null || month == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Selezionare il mese.'));
			mapWrappers.clear();
			return;
		}
		String whereClause = 'Delivery_Model__c = \'CPC\' '+
			'AND Type_DFP__c = \'PRICE_PRIORITY\' '+
			'AND Id_DFP__c != null '+
			'AND CPCQuantityAutomationUpdated__c = false '+
			'AND CALENDAR_MONTH(Start_date__c) = '+Integer.valueOf(month)+
			'AND CALENDAR_Year(Start_date__c) = '+Integer.valueOf(year);	
		String query = Util.getFieldsSOQL('LineItem__c', whereClause, false,'Opportunity__r.Name, (SELECT Id, Mese_numero__c, Mese__c FROM Revenue_applications__r), (SELECT Id, Mese_numero__c, Mese__c FROM Ricavi__r)',false);
		System.debug('PD - Query: '+query);
		List<LineItem__c> listLI = Database.query(query);
		mapLI = new Map<Id, LineItem__c>();
		for (LineItem__c li : listLI) {
			mapLI.put(li.Id, li);
		}
		System.debug('PD - mapLI: '+mapLI);
		isDFPDataRetrieved = false;
		if (mapLI.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Non sono stati trovati Line Item con i criteri di ricerca slezionati.'));
			mapWrappers.clear();
			return;
		}
		checkLIConfiguration();
	}

/* Check on the Line Item configuration*/
	public void checkLIConfiguration() {
	//Setting wrapper
		mapWrappers.clear();
		for (Id idLI : mapLI.keySet()) {
			LineItem__c li = mapLI.get(idLI);
			WrapperLI wli = new WrapperLI(li);
		//Check on the Start Date and End Date
			if (!(li.Start_date__c != null && li.End_date__c != null
				&& li.End_date__c.month() == li.Start_date__c.month())) {
				wli.error = 'Data inizio e fine differiscono per il mese. ';
			}
		//Check for Package
			if (li.Pacchetto_combo_opportunity__c != null) {
				wli.error = 'Il Line Item fa parte di un Pacchetto. ';
				wli.isUpdatable = false;
			}
		//Check for End Date
			if (li.End_date__c >= System.today() && !Test.isRunningTest()) {
				wli.error = 'Il Line Item ha la End Date nel futuro. ';
				wli.isUpdatable = false;
			}
		//Check for the RevenueApplication correct configuration (1 for total and 1 for selected month)
			List<Revenue_application__c> listRevenue = li.Revenue_applications__r;
			System.debug('PD - listRevenue (LI '+idLI+'): '+listRevenue);
			String errRevenue = '';
			if (listRevenue.size() != 2) { //Number of RevenueApplication different from 2
				errRevenue = 'Le Revenue Application deve essere unica sul mese selezionato';
			} else { //Check on Revenue Application month
				Boolean isCurrMonthExistingRA = (listRevenue.get(0).Mese_numero__c == Integer.valueOf(month) || listRevenue.get(1).Mese_numero__c == Integer.valueOf(month));
				Boolean isTotalExistingRA = (listRevenue.get(0).Mese__c == REVENUE_TOTAL || listRevenue.get(1).Mese__c == REVENUE_TOTAL);
				if (!isCurrMonthExistingRA) {
					errRevenue += 'Manca la Revenue per il mese selezionato.';
				}
				if (!isTotalExistingRA) {
					errRevenue += 'Manca la Revenue per il Totale.';
				}
			}
			//Setting the error message
			if (errRevenue != '') {
				wli.error += errRevenue;
				wli.isUpdatable = false;
			}
		//Check for the Ricavo correct configuration (1 for total and 1 for selected month)
			List<Ricavo__c> listRicavo = li.Ricavi__r;
			System.debug('PD - listRicavo (LI'+idLI+'): '+listRicavo);
			String errRicavo = '';
			if (listRicavo.size() != 2) { //Number of Ricavo different from 2
				errRicavo = 'Il Ricavo deve essere unico sul mese selezionato';
			} else { //Check on Ricavo month
				Boolean isCurrMonthExistingRicavo = (listRicavo.get(0).Mese_numero__c == Integer.valueOf(month) || listRicavo.get(1).Mese_numero__c == Integer.valueOf(month));
				Boolean isTotalExistingRicavo = (listRicavo.get(0).Mese__c == REVENUE_TOTAL || listRicavo.get(1).Mese__c == REVENUE_TOTAL);
				if (!isCurrMonthExistingRicavo) {
					errRicavo += 'Manca il Ricavo per il mese selezionato.';
				}
				if (!isTotalExistingRicavo) {
					errRicavo += 'Manca il Ricavo per il Totale.';
				}
			}
			//Setting the error message
			if (errRicavo != '') {
				wli.error += errRicavo;
				wli.isUpdatable = false;
			}
			//Populating the list of Id DFP
			Decimal idDFP = null;
			try {
				idDFP = Integer.valueOf(li.Id_DFP__c);
			} catch (Exception ex) {
				System.debug('Error for the conversione of Id FDP "'+idDFP+'" to decimal. '+ex.getMessage());
			}
			if (idDFP != null) {
				this.mapDFPId.put(idDFP, li.Id);
			}

		//Addind the element to wrapper
			wli.actualValue = li.Totale__c;
			wli.currentQuantity = li.Quantita__c;
			mapWrappers.put(li.Id, wli);
		}
		System.debug('PD - mapWrappers: '+mapWrappers);
		sizeMapWrappers = mapWrappers.size();
	}

/* Getting info about click from DPS*/
	public void getInfoFromDFP() {
		List<Decimal> listDFPId = new List<Decimal>();
		listDFPId.addAll(mapDFPId.keySet());

		try {
			DfpLineItemService.LineItemPage dfpResult = null;
			
			//TEST in Production
			/*
			dfpintegration dfp = new dfpintegration(); 
			Dfp.lineItemService.RequestHeader.networkCode = '5180'; 
			dfpResult = UtilityLineItemIntegration.getLineItemsByIds(listDFPId, dfp);
			System.debug('PD - dfpResult '+dfpResult.results);
			*/
			if (Test.isRunningTest()) {
				dfpResult = CPCUpdateAutomationControllerTest.testDfpResult;
			} else {
				dfpResult = UtilityLineItemIntegration.getLineItemsByIds(listDFPId);
			}
			//Building the result map
			System.debug('PD - dfpResult: '+dfpResult);
			Map<Long, DfpLineItemService.LineItem> mapIdResult = new Map<Long, DfpLineItemService.LineItem>();
			for (DfpLineItemService.LineItem result : dfpResult.results) {
				mapIdResult.put(result.id, result);
			}
			//Populating the wrapper
			for (WrapperLI wrapper : mapWrappers.values()) {
				Long idDFP = (Long)wrapper.li.Id_DFP__c;
				if (mapIdResult.get(idDFP) != null && mapIdResult.get(idDFP).stats != null) {
					wrapper.clickDFP = mapIdResult.get(idDFP).stats.clicksDelivered;
					//Calculating the total to show it in the table
				} else {
					wrapper.msg = 'Errore durante il recupero dei dati da DFP. Nessuno stats pervenuto.';
//					wrapper.clickDFP = 10000 + Math.roundToLong((10000 * Math.random()));
					wrapper.toUpdate = false; //If previously checked for update
					wrapper.isUpdatable = false;
				}
				wrapper.li.Quantita__c = wrapper.clickDFP;
				wrapper.li.Duration__c = 'LIFETIME';
				UtilLineItem.updatecalc(wrapper.li, 'netnetprice', null);
				wrapper.newValue = wrapper.li.Totale__c;
			}
			System.debug('PD - mapWrappers after DFP Integration: '+mapWrappers);
			isDFPDataRetrieved = true;
		} catch(Exception ex) {
			String error = 'Error during the retrieving of information from SFP. '+ex.getMessage()+' '+ex.getStackTraceString();
			System.debug(error);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, error));
		}
	} 

/* Updating the Line Items selected*/
	public void updateLI() {
		List<LineItem__c> listLItoUpdate = new List<LineItem__c>();
		List<Revenue_application__c> listRevenueToUpdate = new List<Revenue_application__c>();
		List<Ricavo__c> listRicavoToUpdate = new List<Ricavo__c>();
		System.debug('PD - listRevenuetoUpdate: '+listRevenuetoUpdate);
		System.debug('PD - listRicavoToUpdate: '+listRicavoToUpdate);
		Map<Integer, Id> mapListIndexId = new Map<Integer, Id>(); //To manage the result of Line Items
		for (Id idLI : mapWrappers.keySet()) {
			WrapperLI wLI = mapWrappers.get(idLI);
		//Setting the Line Item
			if (wLI.clickDFP != null && wLI.toUpdate) {
				LineItem__c li = wLI.li.clone(true, true, false, false);
			//	li.Quantita__c =  wLI.clickDFP;
				li.clicksDelivered__c = wLI.clickDFP;
				li.CPCQuantityAutomationUpdated__c = true;
			//	UtilLineItem.updatecalc(li, 'netnetprice', null);
				if (wLI.isFixedTotal) { //In this case the total is different from UnitPrice * Quantity, so the Unit price must change
					//The field Totale__c has been set by the user
					UtilLineItem.updatecalc(li, 'totale', null);
				} else {
					li.Totale__c = wLI.newValue; //To avoid accidental overriding of Totale__c from page
				}
				mapListIndexId.put(listLItoUpdate.size(), li.Id);
				listLItoUpdate.add(li);
			//Setting the Revenue Application
				for (Revenue_application__c ra : li.Revenue_applications__r) { //Just 2 items
					ra.Percentuale_applicata__c = 100;
					ra.Valore__c = li.Totale__c;
					ra.Numero_click__c = wLI.clickDFP;
					listRevenueToUpdate.add(ra);
				}
			//Setting the Ricavi
				for (Ricavo__c rc : li.Ricavi__r) { //Just 2 items
					rc.Percentuale_applicata__c = 100;
					rc.Valore__c = li.Totale__c;
					listRicavoToUpdate.add(rc);
				}
			}
		}
	//Update Revenue and Ricavi
		LineItemTriggerHandler.skipUpdateLineItem = true;
		LineItemTriggerHandler.skipValidationTotali = true;
		Database.SaveResult[] resultsRevenue = Database.Update(listRevenueToUpdate, false);
		Database.SaveResult[] resultsRicavo = Database.Update(listRicavoToUpdate, false);
		System.debug('PD - Revenue Update result: '+resultsRevenue);
		System.debug('PD - Ricavo Update result: '+listRicavoToUpdate);
	//Update LI
		LineItemTriggerHandler.skipValidationTotali = false;
		System.debug('PD - Line Item to Update: '+listLItoUpdate);
		Database.SaveResult[] results = Database.update(listLItoUpdate, false);
		for (Integer i = 0; i<results.size(); i++) {
			String msg = 'OK';
			String idLineItem = results[i].getId();
			if (!results[i].isSuccess()) {
				msg = getErrorFromResult(results[i].getErrors());
				idLineItem = mapListIndexId.get(i); //Cause results[i].getId() is null

			}
			mapWrappers.get(idLineItem).msg = msg;
		}
		System.debug('PD - mapWrappers after Update: '+mapWrappers);
	}

	public static String getErrorFromResult(Database.Error[] errors) {
		String error = '';
		try {
			for (Database.Error err : errors) {
				error += err.getMessage() + '. ';
			}
		} catch (Exception ex) {
			System.debug('Error during the get error: '+ex.getMessage());
		}
		return error;
	}

	public class WrapperLI {
		public LineItem__c li {get; set;}
		public Boolean toUpdate {get; set;}
		public String msg {get; set;}
		public String error {get; set;}
		public Decimal currentQuantity {get; set;}
		public Long clickDFP {get; set;}
		public Boolean isUpdatable {get; set;}
        public Boolean isFixedTotal {get; set;}
        public Decimal actualValue {get; set;}
        public Decimal newValue {get; set;}

		public WrapperLI(LineItem__c li){
			this.li = li;
			this.toUpdate = false;
			this.msg = '';
			this.error = '';
			this.isUpdatable = true;
            this.isFixedTotal = false;
		}
	}
}