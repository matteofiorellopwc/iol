public class ADXPlacementLoaderController {
 	public String fileName {get; set;}
    public Blob fileBody {get; set;}
    public String fileBodyString {get; set;}
    public Map<String, ADXWrapper> wrappers {get; set;}
    public Integer wrapSize {get; private set;}
    public List<SelectOption> months {get; private set;}
    public String month {get; set;}
    public List<SelectOption> years {get; private set;}
    public String year {get; set;}
    public Set<String> setADXId {get; private set;}
    public Map<String, List<LineItem__c>> mapIdADXListLI {get; set;}
    public Map<Id, Decimal> mapIdLIImpressions {get; set;}
	public Map<String, List<Revenue_application__c>> mapRAUpdateList {get; set;}
	public Map<String, List<Revenue_application__c>> mapRAInsertList {get; set;}
	public Map<String, List<Ricavo__c>> mapRicavoUpdateList {get; set;}
	public Map<String, List<Ricavo__c>> mapRicavoInsertList {get; set;}
	public Map<String, List<LineItem__c>> mapLIUpdateList {get; set;}
	public Map<String, Ricavo__c> mapKeyRicavo {get; set;} //Map with idLI+year+month -> Ricavo

    //Static
	public static final String REVENUE_TOTAL = 'Totale';
    public static final String STANDARD_SPLITTER = ';';
	public static Map<Integer, String> mapMonths;
	static {
		mapMonths = new  Map<Integer, String>();
		mapMonths.put(1, 'Gennaio');
		mapMonths.put(2, 'Febbraio');
		mapMonths.put(3, 'Marzo');
		mapMonths.put(4, 'Aprile');
		mapMonths.put(5, 'Maggio');
		mapMonths.put(6, 'Giugno');
		mapMonths.put(7, 'Luglio');
		mapMonths.put(8, 'Agosto');
		mapMonths.put(9, 'Settembre');
		mapMonths.put(10, 'Ottobre');
		mapMonths.put(11, 'Novembre');
		mapMonths.put(12, 'Dicembre');
	}


	public ADXPlacementLoaderController() {
		wrappers = new Map<String, ADXWrapper>();
		mapIdADXListLI = new Map<String, List<LineItem__c>>();
		mapIdLIImpressions = new  Map<Id, Decimal>();
		mapRAUpdateList = new Map<String, List<Revenue_application__c>>();
		mapRAInsertList = new Map<String, List<Revenue_application__c>>();
		mapRicavoUpdateList = new Map<String, List<Ricavo__c>>();
		mapRicavoInsertList = new Map<String, List<Ricavo__c>>();
		mapLIUpdateList = new Map<String, List<LineItem__c>>();
		mapKeyRicavo = new Map<String, Ricavo__c>();

		wrapSize = 0;
		setMonthsPicklist();
		setYearsPicklist();
	}

	/*
	* Loading the file uploaded
	*/
	public void upload() {
    	//Check
		if (fileName == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Nessun file è stato selezionato'));
			return;
		}
		if (fileBody == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Contenuto del file nullo'));
			return;
		}
		if (!checkValues()) {
			return;
		}
		//Parsing the CSV
		wrappers.clear();
		mapIdLIImpressions.clear();
		fileBodyString = fileBody.toString();
		setADXId = new Set<String>();
		try {
			String[] fileLines = fileBodyString.split('\n');
			System.Debug('PuntoDebug - fileLines: '+fileLines);
			if (fileLines.size() < 2) { //No records
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Il file non contiene record o contiene solo l\'header'));
				return;
			}
			for (Integer i = 1; i<fileLines.size(); i++) { //Skipping the header
				String[] inputValues = new String[]{};
                inputValues = fileLines[i].split(STANDARD_SPLITTER);
                if (inputValues[1] == null) { inputValues[1] = '0'; } //Prevent the null point exception
				ADXWrapper wrapper = new ADXWrapper(inputValues[0], Double.valueOf(inputValues[1].replace(',', '.')));
				wrappers.put(inputValues[0], wrapper);
				setADXId.add(inputValues[0]);
			}
		} catch (Exception ex) {
			system.Debug('Exception during the load of file: '+ex.getMessage()+ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'An error has occurred during the process. Please check the data end try to upload again. Error: '+ex.getMessage()));
		}
		wrapSize = wrappers.size();

		searchLI();
		checkWrappers();
		populateValues();
		populateMapsRicavi();

		System.Debug('PuntoDebug - mapRAUpdateList: '+mapRAUpdateList);
		System.Debug('PuntoDebug - mapRAInsertList: '+mapRAInsertList);
		System.Debug('PuntoDebug - mapRicavoUpdateList: '+mapRicavoUpdateList);
		System.Debug('PuntoDebug - mapRicavoInsertList: '+mapRicavoInsertList);
		System.Debug('PuntoDebug - wrappers: '+wrappers);
    }

    /*Line Item  selected with criteria ad update of the wrapper with old value and errors*/
    public void searchLI() {
    	Date refDate = Date.newinstance(Integer.valueOf(year), Integer.valueOf(month), 1);
    	Date refDateNextMonth = refDate.addMonths(1);
    	String whereClause = 'ADX_Placement_ID__c IN :setADXId '+
			'AND Start_date__c < :refDateNextMonth '+
			'AND End_Date__c >= :refDate ';
		String queryRA = '(SELECT Id, Mese_numero__c, Mese__c, Anno__c, Valore__c, ADXPlacementUpdated__c '+
			'FROM Revenue_applications__r)';
		String queryRicavo = '(SELECT Id, Mese_numero__c, Mese__c, Anno__c, Modificato__c '+
			'FROM Ricavi__r)';
		String query = Util.getFieldsSOQL('LineItem__c', whereClause, false, queryRA+', '+queryRicavo ,false);
		System.debug('PD - Query: '+query);

		//Building Map ADXId -> List<LineItem__c> and mapKeyRicavo
		List<LineItem__c> listLI = Database.query(query);
		System.debug('PD - listLI: '+listLI);
		mapIdADXListLI.clear();
		mapKeyRicavo.clear();
    	for (LineItem__c li : listLI) {
    		String idADX = li.ADX_Placement_ID__c;
    		//Update of the wrapper with old value (if exists)
       		if (mapIdADXListLI.get(idADX) == null) { //List Initialization
				mapIdADXListLI.put(idADX, new List<LineItem__c>{li});
    		} else {
	    		mapIdADXListLI.get(idADX).add(li);
	    	}
	    	//Populating map mapKeyRicavo
	    	for (Ricavo__c rc : li.Ricavi__r) {
	    		mapKeyRicavo.put(li.Id+'_'+rc.Anno__c+'_'+rc.Mese__c, rc);
	    	}
    	}

		System.Debug('PuntoDebug - mapKeyRicavo: '+mapKeyRicavo);
    	System.Debug('PuntoDebug - mapIdADXListLI: '+mapIdADXListLI);    	
    }

    /*
    * Check on Line Item and Revenue Applicaion
    */
    public void checkWrappers() {
		for (String key : wrappers.keySet()) {
    		if (mapIdADXListLI.get(key) == null) { //No LineItem with ADX
				wrappers.get(key).setError('Non esistono Line Item con questo ADX Placement ID per la data selezionata');
    		} else {
    			//Check if the RA are already processed
				Map<Id, LIWrapper> mapIdLIW = new Map<Id, LIWrapper>();
				Integer numLIprocessed = 0;
    			for (LineItem__c li :mapIdADXListLI.get(key)) {
    				LIWrapper liw = new LIWrapper(li);
					for (Revenue_application__c ra : li.Revenue_applications__r) {
						if (ra.Mese__c == mapMonths.get(Integer.valueOf(month)) && ra.Anno__c == year && ra.ADXPlacementUpdated__c) {
							liw.setError('Line Item già processato');
							numLIprocessed++;
						}
					}
					mapIdLIW.put(li.Id, liw);
				}
				wrappers.get(key).mapIdLIW = mapIdLIW;
				wrappers.get(key).sizeMap = mapIdLIW.size();
				Boolean areAllProcessed = (numLIprocessed == mapIdADXListLI.get(key).size()); //All LI for this ADX Id are processed
				wrappers.get(key).toImport = !areAllProcessed;
				if (numLIprocessed > 0 && !areAllProcessed) { //Only a part of LI are processed
					wrappers.get(key).setError('Alcuni Line Item sono già stati processati');
				}
				if (areAllProcessed) {
					wrappers.get(key).setError('Procedura già eseguita per il/i Line Item con questo ADX Placement ID');
				}
    			wrappers.get(key).numLI = mapIdADXListLI.get(key).size();
    		}
    	}
    }

    /*
    * For each LineItem, taking the multiplier (0<x≤1), based on the Asset Impression
    */
    public Map<Id, Decimal> getMapProportionalValues() {
    	Map<Id, Decimal> mapProportional = new Map<Id, Decimal>();

    	for (String key : mapIdADXListLI.keySet()) {
    		if (!wrappers.get(key).toImport) { continue; } //Skip import if not chosen
    		if (mapIdADXListLI.get(key).size() > 1) { //2 or more LIs
    			try {
	    			Decimal impressionTotal = 0;
	    			//Calculating the total impression
	    			for (LineItem__c li : mapIdADXListLI.get(key)) {
	    				if (mapIdLIImpressions.get(li.Id) != null) {
	    					impressionTotal+=  mapIdLIImpressions.get(li.Id);
	    				}
	    			}
					//Calculating the factor x/sum
					for (Integer i=0 ;i< mapIdADXListLI.get(key).size(); i++) {
						Id idLI = mapIdADXListLI.get(key).get(i).Id;
						Decimal factor = mapIdLIImpressions.get(idLI) / impressionTotal;
	    				mapProportional.put(idLI, factor);
	    			}
    			} catch(Exception ex) {
    				System.debug('Error in method ADXPlacementLoaderController.getMapProportionalValues (LineItem Id '+mapIdADXListLI.get(key).get(0).Id+'): '+ex.getMessage()+' - '+ex.getStackTraceString());
    				mapProportional.put(mapIdADXListLI.get(key).get(0).Id, null); //Error
    			}
    		} else { //Only 1 LI
    			mapProportional.put(mapIdADXListLI.get(key).get(0).Id, 1);
    		}
    	}
		System.debug('mapProportional: '+mapProportional);
    	return mapProportional;
    }

    /*
    * Search for the information and populate the values, preparing for insert/update
    */
    public void populateValues() {
		if (!checkValues()) {
			return;
		}
		mapIdLIImpressions = new Map<Id, Decimal>();
		Set<Id> setIdLIForAsset = new Set<Id>();
		mapRAUpdateList.clear();
	    mapRAInsertList.clear();
	    mapRicavoUpdateList.clear();
		mapRicavoInsertList.clear();
	    mapLIUpdateList.clear();

		//Calculating the Set of Id for the Multiple Line Item (2 or more for a single ADX Unit)
		for (String key : mapIdADXListLI.keySet()) { //For every LI(s) found
			if (mapIdADXListLI.get(key).size() > 1) {
				for (LineItem__c li : mapIdADXListLI.get(key)) {
					setIdLIForAsset.add(li.Id);
				}
			}
		}

		//Taking the Asset aggregated list and populating the map
		Date dataPrimoMese = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
		System.Debug('PuntoDebug - setIdLIForAsset: '+setIdLIForAsset);
		System.Debug('PuntoDebug - dataPrimoMese: '+dataPrimoMese);
		List<AggregateResult> listGroupedAsset = [SELECT SUM(Impressions__c) sumImpr, Line_Item__c lineitem
			FROM Asset 
			WHERE Line_Item__c IN :setIdLIForAsset
			AND Data_primo_mese__c = :dataPrimoMese
			AND adUnitView__c = 'FLAT'
			GROUP BY Line_Item__c];
		System.Debug('PuntoDebug - listGroupedAsset: '+listGroupedAsset);
		for (AggregateResult aggregate : listGroupedAsset) {
			mapIdLIImpressions.put((Id)aggregate.get('lineitem'), (Double)aggregate.get('sumImpr'));
		}
		System.Debug('PuntoDebug - mapIdLIImpressions: '+mapIdLIImpressions);
		Map<Id, Double> mapProportional = getMapProportionalValues();

		//Preparing the list of LineItem to update
		for (String key : mapIdADXListLI.keySet()) {
			if (!wrappers.get(key).toImport) { continue; } //Skip import if not chosen
			mapLIUpdateList.put(key, new List<LineItem__c>());
			Boolean isAllLIWithError = true; //Check if all the LI for the current ADX ID have an error
			Decimal valueADX = wrappers.get(key).valueADX; //Full Adx Value
			Decimal tempValueTotal = 0; //Incremental total value of ADX at every cycle

			for(Integer i = 0; i<mapIdADXListLI.get(key).size(); i++) {
				LineItem__c li = mapIdADXListLI.get(key)[i];
				if (!wrappers.get(key).mapIdLIW.get(li.Id).toUpdate) { continue; } //Line Item already processed (no LI to update and no relative RA to insert/update)
				
				Decimal factor = mapProportional.get(li.Id); //Portion of value (1 fon a single LI in list)
				if (factor != null) {
					Decimal raValue = valueADX*factor;
					raValue = raValue.setScale(2,ROUNDINGMODE.HALF_UP);
					tempValueTotal += raValue;
					if (i == mapIdADXListLI.get(key).size() -1 ) {
						raValue += valueADX - tempValueTotal;
					}
					li.Totale__c = getLITotal(li, li.Revenue_applications__r, raValue, key).setScale(2,ROUNDINGMODE.HALF_UP);
					UtilLineItem.updatecalc(li, 'totale', null);
					wrappers.get(key).mapIdLIW.get(li.Id).newValue = li.Totale__c;
					wrappers.get(key).mapIdLIW.get(li.Id).monthNewValue = raValue;
					
					mapLIUpdateList.get(key).add(li);
					isAllLIWithError = false;
				} else { //Problem with Asset for the LIs selected
					wrappers.get(key).mapIdLIW.get(li.Id).setError('Problemi con l\'/gli Asset relativo/i a questo Line Item');
				}
				if (li.Pacchetto_combo_opportunity__c != null) {
					wrappers.get(key).mapIdLIW.get(li.Id).setError('Il Line Item fa parte di un Pacchetto');
				}
			}
			if (isAllLIWithError && wrappers.get(key).err == null) { //No previous errors (to avoid override)
				wrappers.get(key).setError('Nessun Line Item è valido per il processo');
			}
		}
    }

    /*
    * This function calculates the total of LineItem and prepare the Revenue application for insert/update
    */
    public Decimal getLITotal(LineItem__c li, List<Revenue_Application__c> listRA, Decimal raValue, String idADX) {
    	Decimal total = 0;
    	if (!mapRAUpdateList.containsKey(idADX)) {
    		mapRAUpdateList.put(idADX, new List<Revenue_application__c>());
    	}
    	if (!mapRAInsertList.containsKey(idADX)) {
	    	mapRAInsertList.put(idADX, new List<Revenue_application__c>());
	    }
    	Revenue_application__c monthRA = new Revenue_application__c(Line_Item__c=li.Id, Valore__c=raValue, Mese__c=mapMonths.get(Integer.valueOf(month)), Anno__c=year, ADXPlacementUpdated__c=true);
    	Revenue_application__c totRA = new Revenue_application__c(Line_Item__c=li.Id, Mese__c=REVENUE_TOTAL, Percentuale_applicata__c=100);
    	//Setting the correct value to the RA of selected month and finding the total value
    	for (Revenue_application__c ra : listRA) {
    		if (ra.Mese__c == mapMonths.get(Integer.valueOf(month)) && ra.Anno__c == year) {
				wrappers.get(idADX).mapIdLIW.get(li.Id).monthOldValue = ra.Valore__c; //Saving old value to show on the page
    			ra.Valore__c = raValue;
    			monthRA = null; //No creation
    		}
    		if (ra.Mese__c == REVENUE_TOTAL) {
    			totRA = null; //No creation
    			continue;
    		}
    		total += ra.Valore__c;
    	}
    	//Updating the list of li.Revenue_applications__r if new RA must be created
    	if (monthRA != null) {
    		listRA.add(monthRA);
    		total += raValue;
    	}
		System.debug('total: '+total);
    	if (totRA != null) { listRA.add(totRA); }
    	//Now we have all the revenue application on the Line Item
    	Decimal totalPartialPercent = 0;
    	Decimal totalPartial = 0;
    	for (Integer i=0; i<listRA.size(); i++) {
		//Total Revenue Application
    		if (listRA.get(i).Mese__c == REVENUE_TOTAL) { //RA Total
    			listRA.get(i).Valore__c = total;
    			if (totRA != null) { //If insert
    				totRA.Valore__c = total;
    			} else { //If Update
    				listRA.get(i).Percentuale_applicata__c = 100;
    				mapRAUpdateList.get(idADX).add(listRA.get(i));
    			}
    			continue;
    		}
		//Monthly Revenue Application
    		Decimal percent = 0;
    	//	if (monthRA == null) {
    			totalPartial += listRA.get(i).Valore__c;
		//	} else {
		//		totalPartial += monthRA.Valore__c;
		//	}			
    		if (i == listRA.size()-1 || totalPartial == total) { //Last element of the list or last element valued (total reached)
    			percent = 100 - totalPartialPercent; //Complement to 100
    		} else {
				percent = (listRA.get(i).Valore__c / total) * 100;
				percent = percent.setScale(3, RoundingMode.FLOOR);
				percent = percent.setScale(2,RoundingMode.HALF_DOWN); //HALF_UP
    		}
			System.debug('listRA.get(i).Valore__c: '+listRA.get(i).Valore__c);
			System.debug('percent: '+percent);
       		listRA.get(i).Percentuale_applicata__c = (percent < 0) ? 0 : percent;

   			//Selected Month
   			if (listRA.get(i).Mese__c == mapMonths.get(Integer.valueOf(month)) && listRA.get(i).Anno__c == year) {
				listRA.get(i).ADXPlacementUpdated__c = true;
	   			if (monthRA != null) { //If insert
					monthRA.Percentuale_applicata__c = (percent < 0) ? 0 : percent;
					totalPartialPercent += percent;
					totalPartial += monthRA.Valore__c; 
					continue; //no update
				}
			}

			mapRAUpdateList.get(idADX).add(listRA.get(i));
    		totalPartialPercent += percent; //Partial percent incremented
			System.debug('totalPartialPercent: '+totalPartialPercent);
			System.debug('totalPartial: '+totalPartial);
    	}
    	//Adding RA for insert in the main list
    	if (monthRA != null) { mapRAInsertList.get(idADX).add(monthRA);}
    	if (totRA != null) { mapRAInsertList.get(idADX).add(totRA);}
		System.Debug('PuntoDebug - total (li='+li.Id+'): '+total);
    	return total;
    }

    public Boolean checkValues() {
    	Boolean isValueCorrect = true;
    	if (month == null || month == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Selezionare il mese prima di effettuare l\'import'));
			isValueCorrect = false;
		}
		if (year == null || year == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Selezionare l\'anno prima di effettuare l\'import'));
			isValueCorrect = false;
		}

		return isValueCorrect;
    }

	/*
    * This function pupulate the map for insert or update of Ricavi based on revenue applications updated or insert
    */
    public void populateMapsRicavi() {
	//Populate master map for RA
    	Map<String, List<Revenue_application__c>> mapRAAll = new Map<String, List<Revenue_application__c>>(); //Used to identify all the RA to insert/update
    	System.Debug('PuntoDebug - mapRAUpdateList: '+mapRAUpdateList);
    	System.Debug('PuntoDebug - mapRAInsertList: '+mapRAInsertList);

    	for (String key : wrappers.keySet()) {
    		mapRAAll.put(key, new List<Revenue_application__c>());
    		if (mapRAUpdateList.get(key) != null) {
    			System.debug('PuntoDebug - ListRAUpdate pre COMPENSATE: '+mapRAUpdateList.get(key));
				compensatePercent(mapRAUpdateList.get(key));
				System.debug('PuntoDebug - ListRAUpdate post COMPENSATE: '+mapRAUpdateList.get(key));
	    		mapRAAll.get(key).addAll(mapRAUpdateList.get(key));
	    	}
	    	if (mapRAInsertList.get(key) != null) {
	    		System.debug('PuntoDebug - ListRAInsert pre COMPENSATE: '+mapRAUpdateList.get(key));
	    		compensatePercent(mapRAInsertList.get(key));
	    		System.debug('PuntoDebug - ListRAInsert post COMPENSATE: '+mapRAUpdateList.get(key));
	    		mapRAAll.get(key).addAll(mapRAInsertList.get(key));
			}
		}
		System.Debug('PuntoDebug - mapRAAll: '+mapRAAll);
	//Populate Maps for Ricavo for insert/update
		for (String key : mapRAAll.keySet()) {
			//Initialize maps
			if (mapRicavoUpdateList.get(key) == null) {
				mapRicavoUpdateList.put(key, new List<Ricavo__c>());
			}
			if (mapRicavoInsertList.get(key) == null) {
				mapRicavoInsertList.put(key, new List<Ricavo__c>());
			}

			//Map valorization
			for (Revenue_application__c ra : mapRAAll.get(key)) {
				String keyRicavo = ra.Line_Item__c+'_'+ra.Anno__c+'_'+ra.Mese__c;
				Boolean isCurrMonthOrTotal = (ra.Mese__c == mapMonths.get(Integer.valueOf(month)) || ra.Mese__c == REVENUE_TOTAL) || Test.isRunningTest();
				//Boolean isCurrMonthOrTotal = true;
				if (mapKeyRicavo.get(keyRicavo) != null) { //Ricavo to Update
	    			Ricavo__c rcUpdate = mapKeyRicavo.get(keyRicavo);
	    			if (isCurrMonthOrTotal) {
	    				rcUpdate.Valore__c = ra.Valore__c;
	    				rcUpdate.Valore__c = rcUpdate.Valore__c.setScale(2,ROUNDINGMODE.HALF_UP);
	    			 }
	    			rcUpdate.Percentuale_applicata__c = ra.Percentuale_applicata__c;
					System.debug('PD - ra: '+ra);
	    			mapRicavoUpdateList.get(key).add(rcUpdate);
	    		} else { //Ricavo to insert
					Ricavo__c rcInsert = new Ricavo__c(
						Line_Item__c = ra.Line_Item__c,
						Anno__c = ra.Anno__c,
						Mese__c = ra.Mese__c,
						Percentuale_applicata__c = ra.Percentuale_applicata__c,
						Modificato__c = true
					);
					if (isCurrMonthOrTotal) {
						rcInsert.Valore__c = ra.Valore__c;
						rcInsert.Valore__c = rcInsert.Valore__c.setScale(2,ROUNDINGMODE.HALF_UP);
					}
					mapRicavoInsertList.get(key).add(rcInsert);
	    		}
			}
		}
		System.Debug('PuntoDebug - mapRicavoUpdateList: '+mapRicavoUpdateList);
		System.Debug('PuntoDebug - mapRicavoInsertList: '+mapRicavoInsertList);
    }

    /*
    * If the total percent sum is over 100, the function reduce the difference on the major Revenue percent value
    * It uses a custom wrapper class to manage multiple LI
    */
    public class CompensatorWrapper {
    	public Decimal maxPercent {get; set;}
    	public Integer indexMaxPercent {get; set;}
    	public Decimal sumPercentEffective {get; set;}

    	public CompensatorWrapper() {
    		this.maxPercent = 0;
    		this.indexMaxPercent = 0;
    		this.sumPercentEffective = 0;
    	}
    }
    public static void compensatePercent(List<Revenue_application__c> listRA) {
    	//Dividing on various line items
 /*   	Map<Id, List<Revenue_application__c>> mapIdLIRA = new Map<Id, List<Revenue_application__c>>();
    	for (Revenue_application__c ra : listRA) {
    		if (!mapIdLIRA.containsKey(ra.Line_Item__c)) {
    			mapIdLIRA.put(ra.Line_Item__c), new List<Revenue_application__c>());
    		}
    		mapIdLIRA.get(ra.Line_Item__c).add(ra);
    	}

    	for (List<Revenue_application__c> listRA)*/

    	//Map with IdLI -> sumEffective (to manage more LI at one time)
    	Map<Id, CompensatorWrapper> mapIdLICompWrap = new Map<Id, CompensatorWrapper>();
    	//Decimal maxPercent = 0;
    	//Integer indexMaxPercent = 0;
    	//Decimal sumPercentEffective = 0;
    	for (Integer i=0; i<listRA.size(); i++) {
    		Id idLI = listRA[i].Line_Item__c;
			if (!mapIdLICompWrap.containsKey(idLI)) {
				mapIdLICompWrap.put(idLI, new CompensatorWrapper());
			}
    		Revenue_application__c ra = listRA[i];
	    	System.debug('PuntoDebug - COMPENSATE - ra '+ra);
	    	System.debug('PuntoDebug - COMPENSATE - listRA[i] '+listRA[i]);
    		if (ra.Mese__c == REVENUE_TOTAL) { continue; } //Skipping on total RA that is 100 (max)
    		mapIdLICompWrap.get(idLI).sumPercentEffective += ra.Percentuale_applicata__c;
    		if (ra.Percentuale_applicata__c > mapIdLICompWrap.get(idLI).maxPercent) { //Find max value
    			mapIdLICompWrap.get(idLI).maxPercent = ra.Percentuale_applicata__c;
    			mapIdLICompWrap.get(idLI).indexMaxPercent = i;
    		}
    	}
    	for (Id idLI : mapIdLICompWrap.keySet()) {
	    	System.debug('PuntoDebug - COMPENSATE sumPercentEffective : '+mapIdLICompWrap.get(idLI).sumPercentEffective);
	    	if (mapIdLICompWrap.get(idLI).sumPercentEffective > 100) {
	    		listRA[mapIdLICompWrap.get(idLI).indexMaxPercent].Percentuale_applicata__c = listRA[mapIdLICompWrap.get(idLI).indexMaxPercent].Percentuale_applicata__c - (mapIdLICompWrap.get(idLI).sumPercentEffective - 100);
		    	System.debug('PuntoDebug - COMPENSATE (sum > 100): '+listRA[mapIdLICompWrap.get(idLI).indexMaxPercent]+' percentuale='+listRA[mapIdLICompWrap.get(idLI).indexMaxPercent].Percentuale_applicata__c);
	    	}
	    }
    }

    /*
    * This funcion fix the month inserted for ricavi for each LI due to approximation (on current month)
    */
    /*
    public void fixRicaviTotal() {
    	Map<Id, Decimal> mapLITotalPartial = new Map<Id, Decimal>(); //LI Id -> Total value for Ricavi minus current month
    	for (String key : mapRicavoUpdateList) {
    		Id idLI = key.split('_')[0];
    	}
    }*/

	/*
	* This function performs the update of records and insert (if necessary)
	*/
    public void import() {
		System.Savepoint sp = Database.setSavepoint();

		//List Building based on wrapper
		List<Revenue_application__c> listRAToUpdate = new List<Revenue_application__c>();
		List<Revenue_application__c> listRAToInsert = new List<Revenue_application__c>();
		List<Ricavo__c> listRicavoToUpdate = new List<Ricavo__c>();
		List<Ricavo__c> listRicavoToInsert = new List<Ricavo__c>();
		List<LineItem__c> listLIToUpdate = new List<LineItem__c>();
		try {
			for (String key : wrappers.keySet()) {
				if (wrappers.get(key).toImport) { //If import flag is active
					listRAToUpdate.addAll(mapRAUpdateList.get(key));
					listRAToInsert.addAll(mapRAInsertList.get(key));
					listRicavoToUpdate.addAll(mapRicavoUpdateList.get(key));
					listRicavoToInsert.addAll(mapRicavoInsertList.get(key));
					listLIToUpdate.addAll(mapLIUpdateList.get(key));
				}
			}
			System.Debug('PuntoDebug - listRAToInsert: '+listRAToInsert);
			System.Debug('PuntoDebug - listRAToUpdate: '+listRAToUpdate);
			System.Debug('PuntoDebug - listRicavoToUpdate: '+listRicavoToUpdate);
			System.Debug('PuntoDebug - listRicavoToInsert: '+listRicavoToInsert);
			System.Debug('PuntoDebug - listLIToUpdate: '+listLIToUpdate);
			LineItemTriggerHandler.skipUpdateLineItem = true;
			LineItemTriggerHandler.skipValidationTotali = true;
			insert listRAToInsert;
			update listRAToUpdate;
			for(Ricavo__c ri : listRicavoToInsert){
				ri.Modificato__c = true;
			}
			insert listRicavoToInsert;
			for(Ricavo__c ri : listRicavoToUpdate){
				ri.Modificato__c = true;
			}
			update listRicavoToUpdate;
			LineItemTriggerHandler.skipValidationTotali = false;
			update listLIToUpdate;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Operazione effettuata'));
		} catch(Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Errore duante l\'operazione: '+ex.getMessage()+' - '+ex.getStackTraceString()));
		}
    }

//--------------
	/* Population of Month Combobox */
	public void setMonthsPicklist() {
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
		years.add(new SelectOption('', '-- Select --'));
		years.add(new SelectOption(String.valueOf(currYear-1), String.valueOf(currYear-1)));
		years.add(new SelectOption(String.valueOf(currYear), String.valueOf(currYear)));
		years.add(new SelectOption(String.valueOf(currYear+1), String.valueOf(currYear+1)));
    }

    //Wrapper to manage the file import
    public class ADXWrapper {
    	public String idADX {get; set;}
    	public Decimal valueADX {get; set;}
    	public Boolean toImport {get; set;}
    	public String err {get; set;}
    	public Integer numLI {get; set;}
    	public Map<Id, LIWrapper> mapIdLIW {get; set;}
    	public Integer sizeMap {get; set;}

    	public ADXWrapper(String idADX, Decimal valueADX) {
			this.idADX = idADX;
			this.valueADX = valueADX.setScale(2, RoundingMode.HALF_EVEN);
			this.toImport = true;
			mapIdLIW = new Map<Id, LIWrapper>();
			sizeMap = 0;
    	}

    	public void setError(String error) {
    		err = error;
    		toImport = false;
    		numLI = 0;
    	}
    }

    //Wrapper for LI
	public class LIWrapper {
		public LineItem__c li {get; set;}
		public Decimal oldValue {get; set;}
		public Decimal newValue {get; set;}
		public Decimal monthOldValue {get; set;}
		public Decimal monthNewValue {get; set;}
		public String err {get; set;}
		public Boolean toUpdate {get; set;}

		public LIWrapper (LineItem__c li) {
			this.li = li;
			this.oldValue = li.Totale__c;
			toUpdate = true;
		}

		public void setError(String err) {
			this.err = err;
			toUpdate = false;
		}
	}
}