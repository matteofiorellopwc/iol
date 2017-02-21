public class UtilityTicketing {

	/*
	OLD VERSION
	public static String getContoRicavo(String contoRicavoLi,String nazione,Decimal anno){
		String conto = '';
		if(anno >= 2014){
			conto = contoRicavoLi;
		}else{
			if(nazione == 'Italia'){
				conto = '22.01.20.001'; 
			}else{
				conto = '22.01.20.002';
			}
		}
		return conto;
	}
	*/

	//NEW VERSION
	public static String getContoRicavo(LineItem__c li, String nazione, Decimal anno, String prodName){
		String conto = '';
		system.debug('getContoRicavo prodotto '+prodName);
		//sky 50.01.02.008
		//TIM SPOT  nel nome prodotto e assegno 50.01.02.009
		String tmp = getCanale(li);
		if(prodName.toLowerCase().indexOf('sky') != -1 ){
			conto = '50.01.02.008';
			/////SMS MMS Piatt
		}else if(prodName.toLowerCase().indexOf('sms') != -1 || prodName.toLowerCase().indexOf('mms') != -1 || prodName.toLowerCase().indexOf('piatt') != -1){
			conto = '50.01.02.009';
		}else if(li.local__c){
			conto = '50.01.02.003';
		}else if(anno >= 2014){
			if(li.Opportunity__r.Account.Cliente_Gruppo__c){
				conto = '50.01.92.001';
			} else{
				if(String.IsNotBlank(li.Conto_Ricavo__c)){
					conto = li.Conto_Ricavo__c;
				}
				else{
					if(tmp == 'Online Network' || tmp == 'Google AFC' || tmp == 'Simply'){
						if(tmp == 'Online Network'){
							conto = '50.01.07.002';
						}
						if(tmp == 'Google AFC'){
							conto = '50.01.03.001';
						}
						if(tmp == 'Simply'){
							conto = '50.01.07.001';
						}
					}
					else{
						conto = '50.01.02.001';
					}
				}
			}
		}else{
			if(nazione == 'Italia'){
				conto = '22.01.20.001'; 
			}else{
				conto = '22.01.20.002';
			}
		}
		return conto;
	}
		
	public static String getCanale(LineItem__c li){
		return li.DimensioneCanale__c;
		/*
		String s;
		if(String.isNotBlank(li.Product__r.Canale_Prodotto__c)){
			s = li.Product__r.Canale_Prodotto__c;
		}else if(String.isNotBlank(li.Opportunity__r.Account.Canale_Cliente__c)){
			s = li.Opportunity__r.Account.Canale_Cliente__c;
		}else if(String.isNotBlank(li.Opportunity__r.Owner.Tipo__c) && li.Opportunity__r.Owner.Tipo__c == 'Marketing'){
			s = 'Online Network';
		}else if(
				(String.isNotBlank(li.Opportunity__r.Owner.Tipo__c) && li.Opportunity__r.Owner.Tipo__c == 'Dipendente') &&
				(String.isBlank(li.Opportunity__r.Centro_Media__c) && String.isBlank(li.Opportunity__r.Agenzia_di_riferimento__c))
				){
					s = 'Direct Sales';
		}else if(String.isBlank(li.Opportunity__r.Centro_Media__c)){
			s = 'Agents';
		}else if(String.isNotBlank(li.Opportunity__r.Centro_Media__c)){
			if((String.isNotBlank(li.Opportunity__r.Owner.Tipo__c) && li.Opportunity__r.Owner.Tipo__c == 'Dipendente') && 
				String.isBlank(li.Opportunity__r.Agenzia_di_riferimento__c)){
				s = 'Media Planner';
			}else{
				s = 'MP with Agents';
			}
		}
		return s;
		*/
	}
	
	
	public static String getBusinessLine(Quote q){
		//Attenzione!! Ci sono sharing rule sui ticket che si basano su questi valori
		String s = 'Portal';
		if(q <> null){
			if(String.isNotBlank(q.Opportunity.Owner.Area_BL__c) && q.Opportunity.Owner.Area_BL__c == 'Locale')
				s = 'Italiaonline Local';
		}
		return s;
	}
	
	/*
	public static Boolean checkEmptyBoolean(Boolean b){
		//It checks if the string is null or empty and return 'NA' if true
		if(b == null)
			return false;
		else
			return b;
	}
	*/
	
	public static String checkEmptyString(String s){
		//It checks if the string is null or empty and return 'NA' if true
		if(String.isEmpty(s))
			return 'na';
		else
			return s;
	}
	
	/*
	public static Date checkEmptyDate(Date d){
		if(d == null)
			return date.newInstance(1970, 1, 1);
		else
			return d;
	}

	public static Datetime checkEmptyDateTime(Datetime dt){
		if(dt == null)
			return Datetime.newInstance(1970, 1, 1);
		else
			return dt;
	}
	
	public static Decimal checkEmptyDecimal(Decimal nd){
		if(nd == null)
			return 0;
		else
			return nd;
	}
	*/
	
	/* Logic in formula field Product2.Dimensione_Prodotto__c
	
	public static String getDimProdotto(Revenue_application__c ra){
		String s;
		if(ra.Line_Item__r.Product__r.Family.toUpperCase().contains('ITNET')){
			s = 'Sito B2C';
		}
		else{
			String categoriaLib = ra.Line_Item__r.Product__r.Categoria_libero__c;
			if(categoriaLib == 'Rich media' || categoriaLib == 'Video')
				s = categoriaLib;
			else
				if(categoriaLib == 'Network' || categoriaLib == 'Display' || categoriaLib == 'Biscotto' || categoriaLib == 'Promoeditoriale' || categoriaLib == 'Link testuale' || categoriaLib == 'Libero Advertising')
					s = 'Display';
				else
					if(categoriaLib == 'Search' || categoriaLib == 'Box search')
						s = 'Search';
					else
						if(categoriaLib == 'Bottoni' || categoriaLib == 'Partnership' || categoriaLib == 'Publiredazionale')
							s = 'Publiredazionale';
						else
							if(categoriaLib == 'Premium' || categoriaLib == 'Infostrada' || categoriaLib == 'Editoriali')
								s = 'Dem';
		}
		return s;
	}
	*/

	/*
		Imposta il numero riga e le date per una lista di righe.
		Per ogni ticket, mette gli stessi numeri riga e le stesse date sulle righe
		che fanno parte dello stesso pacchetto
	*/
	public static void setNumeroRigaDateOnRigheFatturazione(Riga_Fatturazione__c[] righe,Integer startNo){
		map<string,ticketClass> ticketMap = new map<string,ticketClass>();
		for(Riga_Fatturazione__c r : righe){
			if(!ticketMap.containsKey(r.Ticket_Fatturazione__c)){
				ticketMap.put(r.Ticket_Fatturazione__c,new ticketClass());
			}
			ticketMap.get(r.Ticket_Fatturazione__c).addRiga(r);
		}
		for(string tkt : ticketMap.keyset()){
			ticketMap.get(tkt).setNumeriRigaDate(startNo);
		}

	}

	/*
		Utility per raggruppamento righe dello stesso ticket
	*/
	private class ticketClass{
		private list<Riga_Fatturazione__c> righeNoPacchetto = new list<Riga_Fatturazione__c>();
		private map<String,Riga_Fatturazione__c[]> righeDiPacchetto = new map<String,Riga_Fatturazione__c[]>();
		private map<String,Date> startDatePacchetti = new map<String,Date>();
		private map<String,Date> endDatePacchetti = new map<String,Date>();

		public void addRiga(Riga_Fatturazione__c r){
			if(r.PacchettoOpportunity__c == null){
				righeNoPacchetto.add(r);
			}else{
				if(!righeDiPacchetto.containsKey(r.PacchettoOpportunity__c)){
					righeDiPacchetto.put(r.PacchettoOpportunity__c,new Riga_Fatturazione__c[]{});
					startDatePacchetti.put(r.PacchettoOpportunity__c,r.Start_date__c);
					endDatePacchetti.put(r.PacchettoOpportunity__c,r.End_date__c);
				}
				righeDiPacchetto.get(r.PacchettoOpportunity__c).add(r);
				if(r.Start_date__c < startDatePacchetti.get(r.PacchettoOpportunity__c) ){
					startDatePacchetti.put(r.PacchettoOpportunity__c,r.Start_date__c);
				}
				if(r.End_date__c > endDatePacchetti.get(r.PacchettoOpportunity__c) ){
					endDatePacchetti.put(r.PacchettoOpportunity__c,r.End_date__c);
				}
			}
		}
		public void setNumeriRigaDate(Integer startNo){
			for(Riga_Fatturazione__c r : righeNoPacchetto){
				r.Numero_Riga__c = startNo;
				startNo++;
			}
			for(String pac : righeDiPacchetto.keySet()){
				for(Riga_Fatturazione__c r : righeDiPacchetto.get(pac)){
					r.Numero_Riga__c = startNo;
					r.Start_date__c = startDatePacchetti.get(pac);
					r.End_date__c = endDatePacchetti.get(pac);
					// CLAUDIO B 22/11/2016 - il numero di riga deve essere incrementato perchè SAP sovrappone righe con stesso numero
					// Allo stesso tempo il nuovo campo raggruppamento viene valorizzato in modo che SAP possa raggruppare le righe del pacchetto
					startNo++;
					r.Raggruppamento__c = '1';
					// E
				}
				
				//startNo++;
			}
		}
	}
}