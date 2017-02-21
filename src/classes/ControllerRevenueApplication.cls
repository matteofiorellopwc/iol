public class ControllerRevenueApplication{

    public list<Revenue_application__c> revenueApplications {get;set;}
    public list<Revenue_application__c> revenueApplicationsMinorRicavo {get;set;}
    list<Revenue_application__c> revenueApplicationsToDelete {get;set;}
    list<Revenue_application_pacchetto__c> revenueApplicationsPacchettoToDelete {get;set;}
    map<id,Revenue_application_pacchetto__c> revenuePacchettoMap {get;set;} //id revenue pacchetto -> revenue pacchetto
    map<id,list<revenue_application__c>> revenueApplicationsPacchettoMap {get;set;} //id revenue pacchetto -> revenue applications
    map<id,revenue_application__c> revenueApplicationsMap {get;set;} //id revenue pacchetto -> revenue application tmp per componente
    
    public integer indexRevenueToDelete {get;set;}
    public integer indexApplicaDifferenza {get;set;}
    
    public List<Decimal> totali {get;set;}
    
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public Id id {get;set;}
    public Double percentualeCommisioning {get;set;}
    public Double totaleParent {get;set;}
    public Double quantita {get;set;}
    
    public LineItem__c li {get;set;}
    public Pacchetto_Combo_Opportunity__c pco {get;set;}
    
    public string type {get;set;}

    public boolean isFatturato {get;set;} //se c'è almeno un ticket collegato

    public double totalDiffSumRevenue {get;set;} //differenza tra totale e somma revenue

    public static   Map<Integer,String> mesiMap = new Map<Integer,String>{
        1 => 'Gennaio',
        2 => 'Febbraio',
        3 => 'Marzo',
        4 => 'Aprile',
        5 => 'Maggio',
        6 => 'Giugno',
        7 => 'Luglio',
        8 => 'Agosto',
        9 => 'Settembre',
        10 => 'Ottobre',
        11 => 'Novembre',
        12 => 'Dicembre'
    };

    public List<selectOption> getModalitaOption(){
       List<SelectOption> options = new List<SelectOption>();
       List<Schema.PicklistEntry> ple = LineItem__c.modalitaEditRevenue__c.getDescribe().getPicklistValues();
         
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));
       }
       return options;
    }
    
    public ControllerRevenueApplication(LineItem__c li){
    	totali = new List<Decimal>();
    	totali.add(li.TotaleRevenueApplication__c);
        type = 'LineItem';
        isFatturato = false;
        this.li = li;
        List<Revenue_application__c> allRevenueApplications = getAllRevenueApplications(li);
        revenueApplications = new List<Revenue_application__c>();
        revenueApplicationsMinorRicavo = new List<Revenue_application__c>();
        
        for(Revenue_application__c revenue : allRevenueApplications){
            if(revenue.minorRicavo__c){
                revenueApplicationsMinorRicavo.add(revenue);
            }else{
                revenueApplications.add(revenue);
            }
        }
        if(! revenueApplicationsMinorRicavo.isEmpty()){
            revenueApplicationsMinorRicavo.add(new Revenue_application__c(Mese__c='Totale',Valore__c=li.SommaRevenueMinorRicavo__c));
        }
        
        revenueApplicationsToDelete = new list<Revenue_application__c>();
        for(Revenue_application__c ra : revenueApplications){
            if(ra.Ticket_Fatturazione__c != null){
                isFatturato = true;
            }
        }
    }
    
    public static Revenue_application__c[] getAllRevenueApplications(LineItem__c li){
    	return [select Anno__c,Custom__c,Mese__c,Revenue_application_pacchetto__c,Numero_giorni__c,Percentuale_applicata__c,order__c,
                      Valore__c,Line_Item__c,Numero_impression__c,numero_click__c,Ticket_Fatturazione__c,MinorRicavo__c 
                from Revenue_application__c
                where Line_Item__c =: li.id
                order by anno_numero__c,mese_numero__c
              ];
    }
    
    public ControllerRevenueApplication(Pacchetto_Combo_Opportunity__c pco){
        type = 'Pacchetto';
        isFatturato = false;
        this.pco = pco;
        
        revenuePacchettoMap = new map<id,Revenue_application_pacchetto__c>();
        revenueApplicationsPacchettoMap = new map<id,list<revenue_application__c>>();
        revenueApplicationsMap = new map<id,revenue_application__c>();
        revenueApplications = new list<revenue_application__c>();
        if(pco.id != null){
            list<Revenue_application__c> revenueApplicationsTmp = [select Anno__c,Custom__c,Mese__c,Numero_giorni__c,Percentuale_applicata__c,
                                                  Valore__c,Line_Item__c,Numero_impression__c,numero_click__c,Ticket_Fatturazione__c,
                                                  Revenue_application_pacchetto__c,order__c
                                            from Revenue_application__c
                                            where Line_Item__r.pacchetto_combo_opportunity__c =: pco.id
                                            order by anno_numero__c,mese_numero__c
                                          ];
                                          
            list<Revenue_application_pacchetto__c> revenuePacchettoTmp = [select id,Anno__c,Custom__c,Mese__c,Numero_giorni__c,Percentuale_applicata__c,
                                                          Valore__c,Pacchetto_combo_opportunity__c,order__c
                                                    from Revenue_application_pacchetto__c
                                                    where pacchetto_combo_opportunity__c =: pco.id
                                                    order by anno_numero__c asc,mese_numero__c asc];
            
            for(Revenue_application_pacchetto__c rap : revenuePacchettoTmp){
                revenue_application__c ra = new revenue_application__c();
                ra.Anno__c = rap.anno__c;
                ra.Custom__c = rap.Custom__c;
                ra.Mese__c = rap.Mese__c;
                ra.Numero_giorni__c = rap.Numero_giorni__c;
                ra.Percentuale_applicata__c = rap.Percentuale_applicata__c;
                ra.Valore__c = rap.Valore__c;
                ra.Revenue_application_pacchetto__c = rap.id;
                ra.order__c = rap.order__c;
                revenueApplications.add(ra);
                revenueApplicationsPacchettoMap.put(rap.id,new list<revenue_application__c>());
                revenueApplicationsMap.put(rap.id,ra);
                revenuePacchettoMap.put(rap.id,rap);
            }
            for(Revenue_application__c ra : revenueApplicationsTmp){
                id rapId;
                if(ra.Revenue_application_pacchetto__c != null && revenueApplicationsPacchettoMap.get(ra.Revenue_application_pacchetto__c) != null){
                    revenueApplicationsPacchettoMap.get(ra.Revenue_application_pacchetto__c).add(ra);
                    rapId = ra.Revenue_application_pacchetto__c;
                }else{
                    for(Revenue_application_pacchetto__c rap : revenuePacchettoTmp){
                        if(rap.mese__c == ra.mese__c && rap.anno__c == ra.anno__c && math.abs(rap.percentuale_applicata__c - ra.percentuale_applicata__c)<=1 ){
                            revenueApplicationsPacchettoMap.get(rap.id).add(ra);
                            rapId = rap.id;
                        }
                    }
                }
                if(ra.Ticket_Fatturazione__c != null){
                    isFatturato = true;
                    if(rapId != null){
                        revenueApplicationsMap.get(rapId).ticket_fatturazione__c = ra.ticket_fatturazione__c;
                    }
                }
            }
        }
        revenueApplicationsPacchettoToDelete = new list<Revenue_application_pacchetto__c>();
        revenueApplicationsToDelete = new list<revenue_application__c>();
    }
    
    public void resetRevenueApplicationToDelete(lineitem__c li){
        //revenueApplicationsToDelete = revenueApplications;
        //revenueApplications = revenueApplications.deepClone(false,false,false);
        revenueApplicationsToDelete = new list<Revenue_application__c>();
    }
    
    //al posto di reset se sto inserendo un pacchetto
    public void initRevenueApplicationToDelete(){
        revenueApplicationsPacchettoToDelete = new list<Revenue_application_pacchetto__c>();
        revenueApplicationsToDelete = new list<revenue_application__c>();
        //revenueApplicationsToDelete = [select id from Revenue_application__c where Line_Item__r.pacchetto_combo_opportunity__c =: pco.id];
        //revenueApplicationsPacchettoToDelete = [select id from Revenue_application_pacchetto__c where pacchetto_combo_opportunity__c =: pco.id];
    }
    
    public list<revenue_application__c> revenueApplicationsTmp {get;set;}
    public void saveTmpRevenueApplications(){
        revenueApplicationsTmp = revenueApplications.deepClone(true,true,true); //per ripristinare in caso di errori
    }
    
    public void restoreFromTmpRevenueApplication(){
        revenueApplications = revenueApplicationsTmp.deepClone(true,true,true);
    }
    
    public string checkRevenueApplication(LineItem__c li){
        return [select Incoerenze_revenue_application__c from lineitem__c where id =: li.id].Incoerenze_revenue_application__c;
    }
    
    public string checkRevenueApplication(Pacchetto_Combo_Opportunity__c pco){
        return [select Incoerenze_revenue_application__c from Pacchetto_Combo_Opportunity__c where id =: pco.id].Incoerenze_revenue_application__c;
    }

    public void updateCheckRevenueApplication(LineItem__c li){
        LineItemTriggerHandler.skipUpdateLineItem = false;
        update [select id from revenue_application__c where line_item__c =: li.id];
    }
    
    public void updateCheckRevenueApplication(Pacchetto_Combo_Opportunity__c pco){
        //master-detail con roll-up, update automatico
    }
 
    
    public void customSave(){
        for(integer i=0;i<revenueApplications.size();i++){
            revenueApplications[i].order__c = i;
        }
        system.debug('revenueApplications to update: '+revenueApplications);
        upsert revenueApplications;
        system.debug('revenueApplication to delete: '+revenueApplicationsToDelete);
        delete revenueApplicationsToDelete;
    }

    public void customSave(Pacchetto_combo_opportunity__c pco,list<lineitem__c> lis){
        System.debug('REVENUE PACCHETTO TO DELETE!!! ' + revenueApplicationsToDelete);
        delete revenueApplicationsPacchettoToDelete;
        delete revenueApplicationsToDelete;

        list<revenue_application_pacchetto__c> revenueApplicationsPacchettoToUpsert = new list<revenue_application_pacchetto__c>();
        list<revenue_application__c> revenueApplicationsToUpsert = new list<revenue_application__c>();
        
        for(Revenue_application__c ra : revenueApplications){
            revenue_application_pacchetto__c rap = new revenue_application_pacchetto__c();
            if(ra.Revenue_application_pacchetto__c != null){
                rap = revenuePacchettoMap.get(ra.Revenue_application_pacchetto__c);
            }else{
                rap.Pacchetto_combo_opportunity__c = pco.id;
            }
            rap.Anno__c = ra.anno__c;
            rap.Custom__c = ra.Custom__c;
            rap.Mese__c = ra.Mese__c;
            rap.Numero_giorni__c = ra.Numero_giorni__c;
            rap.Percentuale_applicata__c = ra.Percentuale_applicata__c;
            rap.Valore__c = ra.Valore__c;
            rap.order__c = ra.order__c;
            revenueApplicationsPacchettoToUpsert.add(rap);
        }
        upsert revenueApplicationsPacchettoToUpsert;
        System.debug('REVENUE APPLICATION PACCHETTO TO UPSERT!!! ' + revenueApplicationsPacchettoToUpsert);
        //lis = [select id,totale__c,quantita__c,Valore_commisioning_agenzia_territoriale__c from lineitem__c where id in : lis];
        Map<Id, LineItem__c> liMap = new Map<Id, LineItem__c>(lis);
        System.debug('LIMAP!!! ' + liMap);
        
        Map<String, Revenue_application__c[]> raMesiMap = new Map<String, Revenue_application__c[]>();
        Map<String, Decimal> totaliMeseMap = new Map<String, Decimal>();
        Map<Id, Revenue_application__c[]> raLiMap = new Map<Id, Revenue_application__c[]>();
        
        for(revenue_application_pacchetto__c rap : revenueApplicationsPacchettoToUpsert){
            system.debug('rap:'+rap);
            totaliMeseMap.put(rap.Anno__c + rap.Mese__c, rap.valore__c);
            if(revenueApplicationsPacchettoMap.get(rap.id) == null || revenueApplicationsPacchettoMap.get(rap.id).size() == 0){
                for(lineitem__c li : lis){
                    system.debug('li:'+li);
                    revenue_application__c raLi = new revenue_application__c();
                    raLi.Anno__c = rap.anno__c;
                    raLi.Custom__c = rap.Custom__c;
                    raLi.Mese__c = rap.Mese__c;
                    raLi.Percentuale_applicata__c = rap.Percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
                    //raLi.Numero_impression__c = rap.percentuale_applicata__c * li.quantita__c / 100;
                    raLi.valore__c = rap.percentuale_applicata__c * li.totale__c / 100;
                    raLi.valore__c = raLi.valore__c.setScale(2,RoundingMode.HALF_UP);
                    //Decimal valore_comm_agenzia_territoriale = li.Totale__c * (li.Percentuale_commisioning_agenzia__c > 0 ? li.Percentuale_commisioning_agenzia__c : 0);
                    //raLi.Valore_di_commisioning__c = rap.percentuale_applicata__c * valore_comm_agenzia_territoriale / 100;
                    raLi.line_Item__c = li.id;
                    raLi.Revenue_application_pacchetto__c = rap.id;
                    revenueApplicationsToUpsert.add(raLi);

                    //if(raLi.Mese__c != 'Totale') {                                            
                        if(raLiMap.get(li.Id) == null) {
                            raLiMap.put(li.Id, new Revenue_application__c[]{});
                        }
                        raLiMap.get(li.Id).add(raLi);
                        System.debug('TEMP RALIMAP!!! ' + raLiMap);
                    //}                    
                }
            }else{ //era una revenue pacchetto che esisteva già
                for(revenue_application__c ra : revenueApplicationsPacchettoMap.get(rap.id)){
                    ra.Anno__c = rap.anno__c;
                    ra.Custom__c = rap.Custom__c;
                    ra.Mese__c = rap.Mese__c;
                    
                    if(isFatturato){
                        if(ra.ticket_fatturazione__c != null){
                            if(liMap.get(ra.line_item__c).totale__c > 0){
                                ra.valore__c = ra.valore__c.setScale(2, RoundingMode.HALF_UP);
                                ra.percentuale_applicata__c = (ra.valore__c / liMap.get(ra.line_item__c).totale__c) * 100;
                                ra.percentuale_applicata__c = ra.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
                            }else{
                                ra.percentuale_applicata__c = 0;
                            }
                        }else{
                            //QUESTI CONTI VENGONO FATTI DOPO!
                            /*
                            system.debug('ra da fatturare: '+ra.id);
                            //ra.valore__c = rap.percentuale_applicata__c * liMap.get(ra.line_item__c).totale__c / 100;
                            if(pco.totale__c > 0){
                                System.debug('PCO TOTALE!!! ' + pco.totale__c);
                                System.debug('RAP TOTALE!!! ' + rap.valore__c);
                                System.debug('LI TOTALE!!! ' + liMap.get(ra.line_item__c).totale__c);
                                
                                ra.valore__c = rap.valore__c * liMap.get(ra.line_item__c).totale__c/pco.totale__c;
                                ra.valore__c = ra.valore__c.setScale(2,RoundingMode.HALF_UP);                                
                                ra.percentuale_applicata__c = (ra.valore__c / liMap.get(ra.line_item__c).totale__c) * 100;
                                ra.percentuale_applicata__c = ra.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
                            }*/
                        }
                    }else{
                        ra.valore__c = rap.percentuale_applicata__c * liMap.get(ra.line_item__c).totale__c / 100;
                        ra.valore__c = ra.valore__c.setScale(2,RoundingMode.HALF_UP);
                        ra.percentuale_applicata__c = rap.percentuale_applicata__c;                                                        
                    }
                    
                    //
                    //ra.percentuale_applicata__c = rap.percentuale_applicata__c;
                    //ra.valore__c = ra.percentuale_applicata__c * liMap.get(ra.line_item__c).totale__c / 100;
                    //
                    
                    //ra.Numero_impression__c = rap.percentuale_applicata__c * liMap.get(ra.line_item__c).quantita__c / 100;
                    //Decimal valore_comm_agenzia_territoriale = liMap.get(ra.line_item__c).Totale__c * (liMap.get(ra.line_item__c).Percentuale_commisioning_agenzia__c > 0 ? liMap.get(ra.line_item__c).Percentuale_commisioning_agenzia__c : 0);
                    //ra.Valore_di_commisioning__c = rap.percentuale_applicata__c * valore_comm_agenzia_territoriale / 100;                                        
                    //ra.Valore_di_commisioning__c = rap.percentuale_applicata__c * liMap.get(ra.line_item__c).Valore_commisioning_agenzia_territoriale__c / 100;
                    ra.Revenue_application_pacchetto__c = rap.id;
                    
                    //if(ra.Mese__c != 'Totale') {
                        if(raLiMap.get(ra.line_item__c) == null) {
                            raLiMap.put(ra.line_item__c, new Revenue_application__c[]{});
                        }
                        raLiMap.get(ra.line_item__c).add(ra);
                    //}                    
                    
                    revenueApplicationsToUpsert.add(ra);
                }
            }
        }
        
        Decimal totaleFatturato = 0;
        
        //Costruisco la matrice dei mesi e calcolo il totale già fatturato
        for(Id liId : raliMap.keySet()) {
            for(Revenue_application__c ra : raliMap.get(liId)) {
                if(ra.Mese__c != 'Totale') {
                    if(raMesiMap.get(ra.Anno__c + ra.Mese__c) == null) {
                        raMesiMap.put(ra.Anno__c + ra.Mese__c, new Revenue_application__c[]{});
                    }
                    raMesiMap.get(ra.Anno__c + ra.Mese__c).add(ra);
                    if(ra.Ticket_Fatturazione__c != null) totaleFatturato += ra.Valore__c;
                }               
            }
        }        
                                
        //Fixo le percentuali e i valori sui singoli lineitems
        for(Id liId : raLiMap.keySet()) {
            fixAndValidateRaLineItem(raLiMap.get(liId), liMap.get(liId).totale__c, totaliMeseMap, totaleFatturato, pco.Totale__c);
        }
        
        System.debug('RALIMAP!!! ' + raLiMap);
        
        checkMatrice(raMesiMap, totaliMeseMap);
        
        System.debug('FIXEDRALIMAP!!! ' + raLiMap);
        System.debug('RAMESIMAP!!! ' + raMesiMap);
        
        upsert revenueApplicationsToUpsert;
        
        revenueApplicationsPacchettoToDelete.clear();
        revenueApplicationsToDelete.clear();
    }

    public void setParentValues(LineItem__c li){
        startDate = li.start_date__c;
        endDate = li.end_date__c;
        id = li.id;
        percentualeCommisioning = li.Percentuale_commisioning_agenzia__c;
        totaleParent = li.totale__c;
        quantita = li.quantita__c;
    }
    
    public void setParentValues(Pacchetto_Combo_Opportunity__c pco){
        startDate = pco.data_inizio__c;
        endDate = pco.data_fine__c;
        id = null;
        percentualeCommisioning = null;
        totaleParent = pco.totale__c;
        quantita = pco.quantita_totale__c;
    }

    public void creaRevenueApplicationDaDate(){
        system.debug('init crea da date');
        
        if(startDate > endDate){
            return;
        }

        Map<string,integer> mesiGiorniMap = new Map<string,integer>(); //mappa 'mese_anno' => numero giorni
        list<string> keySetMap = new list<string>(); //per mantenere l'ordine
            
        for(Revenue_application__c ra : revenueApplications) {
            if(ra.Id != null) revenueApplicationsToDelete.add(ra);
            if(ra.Revenue_application_pacchetto__c != null) {
                revenueApplicationsToDelete.addAll(revenueApplicationsPacchettoMap.get(ra.Revenue_application_pacchetto__c)); 
                revenueApplicationsPacchettoToDelete.add(new Revenue_Application_pacchetto__c(Id = ra.Revenue_application_pacchetto__c));
            }
        }
        revenueApplications = new list<Revenue_application__c>();

        integer daysBetween = startDate.daysBetween(endDate);
        daysBetween += 1;
        date d = startDate;
        while(d <= endDate){
            if(mesiGiorniMap.get(d.month()+'_'+d.year()) == null){
                mesiGiorniMap.put(d.month()+'_'+d.year(),0);
                keySetMap.add(d.month()+'_'+d.year());
            }
            mesiGiorniMap.put(d.month()+'_'+d.year(),mesiGiorniMap.get(d.month()+'_'+d.year())+1);
            d = d.addDays(1);
        }
        
        Revenue_application__c totale = new Revenue_application__c(Line_Item__c=id);
        
        //double totaleCommisioning = 0;
        //if(percentualeCommisioning != null){
        //    totaleCommisioning = percentualeCommisioning * totaleParent / 100;
        //}
        //system.debug('totaleCommisioning = ' + totaleCommisioning);
        
        totale.mese__c = 'Totale';
        totale.percentuale_applicata__c = 0;
        totale.valore__c = 0;
        //totale.Numero_impression__c = 0;
        //totale.Numero_click__c = 0;        
        //totale.Valore_di_commisioning__c = 0;
        
        double sommaPerc = 0.0;
        integer i = -1;
        
        for(string s : keySetMap){
            i++;
            Revenue_application__c ra = new Revenue_application__c(Line_Item__c=id);
            ra.mese__c = mesiMap.get(integer.valueof(s.split('_')[0]));
            ra.anno__c = s.split('_')[1];
            ra.Numero_giorni__c = mesiGiorniMap.get(s);
            ra.percentuale_applicata__c = mesiGiorniMap.get(s) * 100.00 / daysBetween;
            ra.percentuale_applicata__c = ra.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
            ra.valore__c = ra.percentuale_applicata__c * totaleParent / 100;
            //ra.Valore_di_commisioning__c = ra.percentuale_applicata__c * totaleCommisioning / 100;
            //ra.Numero_impression__c = ra.percentuale_applicata__c * quantita / 100;
            revenueApplications.add(ra);
            
            sommaPerc += ra.percentuale_applicata__c;
        }
        
        if(sommaPerc != 100.00 && i!=-1){
            revenueApplications[i].percentuale_applicata__c = revenueApplications[i].percentuale_applicata__c - (sommaPerc - 100.00);
            revenueApplications[i].valore__c = revenueApplications[i].percentuale_applicata__c * totaleParent / 100;
            //revenueApplications[i].Numero_impression__c = revenueApplications[i].percentuale_applicata__c * quantita / 100;
            //revenueApplications[i].Valore_di_commisioning__c = revenueApplications[i].percentuale_applicata__c * totaleCommisioning / 100;
        }
        
        for(Revenue_application__c ra :  revenueApplications){
            totale.percentuale_applicata__c += ra.percentuale_applicata__c;
            totale.valore__c += ra.valore__c;
            //totale.Numero_impression__c += ra.Numero_impression__c;
            //totale.Valore_di_commisioning__c += ra.Valore_di_commisioning__c;
        }        
        
        totale.percentuale_applicata__c = totale.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
        revenueApplications.add(totale);        
        //sistemo percentuali e totali con i 2 decimali
        updateRevenueApplication(true);
        system.debug('end crea da date');

		if(type == 'LineItem'){        
	        boolean isRicaviEmpty = [select id from Ricavo__c where Line_Item__c = : li.id].size() == 0;
	        if(isRicaviEmpty){
	        	//ControllerRicavi contRicavi = new ControllerRicavi(li);
	        	//contRicavi.creaRicaviDaDate();
	        }
		}
    }

    /*
    * Used for product with Vetrina__c = true
    * The total value is setted for the first month an the next ones are 0
    */
    public void creaRevenueApplicationDaDateVetrina(){
        System.debug('START - ControllerRevenueApplication.creaRevenueApplicationDaDateVetrina');

    //Date Check
        if(startDate > endDate){
            System.Debug('PuntoDebug - startDate > endDate, no operation');
            return;
        }
    //Preparing for deleting remaining RA
        for (Revenue_application__c ra : revenueApplications) {
            if(ra.Id != null) { revenueApplicationsToDelete.add(ra); }
        }
    //Populating RA List
        revenueApplications = new List<Revenue_application__c>();
        //Populating first month, with wholw value
        revenueApplications.add(
            new Revenue_application__c(
                Line_Item__c=id,
                Mese__c = mesiMap.get(startDate.month()),
                Anno__c = String.valueOf(startDate.year()),
                Percentuale_applicata__c = 100,
                Valore__c = totaleParent
            )
        );
        //Populate remaining months
/*        Date d = startDate.toStartOfMonth() ; //Used as counter
        d = d.addMonths(1);
        while(d <= endDate){
            Revenue_application__c ra = new Revenue_application__c(
                Line_Item__c=id,
                Mese__c = mesiMap.get(d.month()),
                Anno__c = String.valueOf(d.year()),
                Percentuale_applicata__c = 0,
                Valore__c = 0
            );
            revenueApplications.add(ra);

            d = d.addMonths(1);
        }*/
        //Adding RA Total
        revenueApplications.add(
            new Revenue_application__c(
                Line_Item__c=id,
                Percentuale_applicata__c = 100,
                Mese__c='Totale',
                Valore__c = totaleParent
            )
        );
        System.debug('END - ControllerRevenueApplication.creaRevenueApplicationDaDateVetrina. revenueApplications: '+revenueApplications);
    }
    
    public void addRevenueApplicationCustom(){
        Revenue_application__c ra = new Revenue_application__c(Line_Item__c=id,Custom__c=true);
        revenueApplications.add(revenueApplications.size()-1,ra);
        updateRevenueApplication();
    }
    
    public void deleteRevenueApplicationCustom(){        
        Revenue_application__c raToRemove = revenueApplications.remove(indexRevenueToDelete);
        System.debug('RATOREMOVE!!! ' + raToRemove);
        if(raToRemove.Id != null) revenueApplicationsToDelete.add(raToRemove);
        if(raToRemove.Revenue_application_pacchetto__c != null) {
            revenueApplicationsToDelete.addAll(revenueApplicationsPacchettoMap.get(raToRemove.Revenue_application_pacchetto__c)); 
            revenueApplicationsPacchettoToDelete.add(new Revenue_Application_pacchetto__c(Id = raToRemove.Revenue_application_pacchetto__c));
        }
        updateRevenueApplication();
    }
    
    public void applicaDifferenza(){
        //se faccio una modifica dopo la prima fatturazione per applicare la differenza col totale su una revenue
        if(totalDiffSumRevenue != null){
            revenueApplications.get(indexApplicaDifferenza).valore__c += totalDiffSumRevenue;
        }
        updateRevenueApplication();
    }
    
    private String getModalitaEdit() {
        string modalitaEdit = '';
        if(li != null){
            modalitaEdit = li.modalitaEditRevenue__c;
        }else{
            modalitaEdit = pco.modalitaEditRevenue__c;            
        }
        System.debug('MODALITA EDIT REVENUE!!! ' + modalitaEdit);
        return modalitaEdit;        
    }
    
    public void updateRevenueApplication(){
        updateRevenueApplication(false);
    }
    
    public void checkTotaliAndUpdateRevenueApplication() {
        if(isAdsense && getModalitaEdit() == 'Valore') {
            Decimal total = 0;
            for(Revenue_application__c ra : revenueApplications) {
                if(ra.Mese__c != 'Totale') {
                    total += ra.Valore__c;
                }                           
            }
            li.totale__c = total;
            li.Ultima_modifica_prezzo__c = 'totale';
            totaleParent = total;
            System.debug('NEW TOTALE !!! ' + li.totale__c);
        } 
        updateRevenueApplication();
    }
    
    public void updateRevenueApplication(Boolean forceFixValori){
        if(revenueApplications.isEmpty()) return;
                            
        Decimal totaleCommisioning = 0;
        if(percentualeCommisioning != null){
            totaleCommisioning = percentualeCommisioning * totaleParent / 100;
        }
        Decimal valore = 0; //somma valori facendo setscale per ogni valore
        //Decimal valore_commisioning = 0; //somma valore commisioning
        Decimal perctotale = 0; //somma delle percentuali facendo setscale per ogni revenue
        //Decimal numero_impression = 0; //somma impressions
        
        string modalitaEdit = forceFixValori ? 'Percentuale' : getModalitaEdit();
                
        //Revenue totale
        Revenue_application__c raTotale;
        //Indice ultima revenue, la modifico per far tornare il totale
        integer lastindex = -1;
        Decimal lastValore = 0;
        
        for(Integer i = 0; i < revenueApplications.size(); i++){
            Revenue_application__c ra = revenueApplications.get(i);
            if(ra.custom__c && ra.percentuale_applicata__c != null && (isblank(ra.mese__c) || isblank(ra.anno__c))){
                if(isblank(ra.mese__c)){
                    ra.mese__c.addError('Obbligatorio');
                }
                if(isblank(ra.anno__c)){
                    ra.anno__c.addError('Obbligatorio');
                }
                return;
            }
            if(ra.percentuale_applicata__c == null){ // && ! ra.custom__c
                ra.percentuale_applicata__c = 0;
            }
            if(ra.valore__c == null){
                ra.valore__c = 0;
            }
            
            if(ra.mese__c != 'Totale'){      
                if(ra.ticket_fatturazione__c != null || isFatturato || modalitaEdit == 'Valore'){
                    if(totaleParent != 0){
                        ra.percentuale_applicata__c = (ra.valore__c / totaleParent) * 100;
                    }else{
                        ra.percentuale_applicata__c = 0;
                    }
                    
                }else{
                    ra.valore__c = ra.percentuale_applicata__c * totaleParent / 100;
                }
                
                ra.percentuale_applicata__c = ra.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
                ra.valore__c = ra.valore__c.setScale(2,RoundingMode.HALF_UP);
                
                //ra.Numero_impression__c = ra.percentuale_applicata__c * quantita / 100;
                //ra.Valore_di_commisioning__c = (ra.percentuale_applicata__c * totaleCommisioning / 100).setScale(2,RoundingMode.HALF_UP);
                //numero_impression += ra.Numero_impression__c;
                
                valore += ra.valore__c;
                //valore_commisioning += ra.Valore_di_commisioning__c;
                perctotale += ra.percentuale_applicata__c;
                
                //if(ra.Ticket_fatturazione__c == null && (lastValore < ra.Valore__c || lastIndex == -1)) {
                if((ra.Ticket_fatturazione__c == null || modalitaEdit == 'Valore') && (lastValore < ra.Valore__c || lastIndex == -1)) {
                    lastindex = i;
                    lastValore = ra.Valore__c;
                }
            }else{
                raTotale = ra;
            }
        }
        //perctotale = perctotale.setScale(2, RoundingMode.HALF_UP);
        
        if(modalitaEdit == 'Valore' && valore == totaleParent){
            revenueApplications[lastindex].percentuale_applicata__c += (100 - perctotale);
            perctotale += (100 - perctotale);        
        }
        if(modalitaEdit == 'Percentuale' && perctotale == 100){
            revenueApplications[lastindex].valore__c -= (valore-totaleParent);
            valore -= (valore-totaleParent);
        }
    
        if(raTotale != null){
            raTotale.valore__c = valore;
            raTotale.percentuale_applicata__c = perctotale;
            //raTotale.Numero_impression__c = numero_impression;
            //raTotale.Valore_di_commisioning__c = valore_commisioning;
        }

        System.debug('PERCTOTALE!!! ' + perctotale);
        System.debug('VALORETOTALE!!! ' + valore);  
        
        totalDiffSumRevenue = totaleParent - valore;
    }

    public Boolean isAdSense {
        get {
            if(li == null) return false;
            return (li.Type_DFP__c == 'ADSENSE' || li.Type_DFP__c == 'AD_EXCHANGE' || (li.delivery_model__c == 'CPM' && li.Type_DFP__c == 'SPONSORSHIP'));
        }
    }
    public boolean isBlank(String s){
        return (s == '' || s == null);
    }

    /**
     *  Questo metodo calcola la somma delle revenue di un pacchetto per un determinato mese e approssima i valori delle revenue affinchè sia somma revenue = totale mese pacchetto
     *  Prerequisito affinchè tutto funzioni è che le somme delle revenue dei lineitem componenti il pacchetto diano il totale di quel pacchetto. E' necessario quindi fixare prima i valori
     *  sui singoli lineitem
     */         
    public static Decimal checkAndFixSommaMesiRevenues(Revenue_application__c[] raL, Decimal totale, Decimal resto) {
        Decimal totRa = 0;          
        
        Integer lastIndex = -1;
        Decimal lastValore = 0;
        
        System.debug('TOTALE!!! ' + totale);
        Revenue_application__c[] cleanRaL = new Revenue_application__c[]{};
        for(Integer i = 0; i< raL.size(); i++) {
            Revenue_application__c ra = raL.get(i);                      
            if(ra.mese__c != 'Totale') {
                if(lastIndex == -1 || lastValore < ra.Valore__c) {
                    lastIndex = i;
                    lastValore = ra.Valore__c;
                }
                cleanRaL.add(ra);               
                totRa += ra.Valore__c;
            } 
        }

        System.debug(resto);
        if (resto != null) {
            cleanRaL[lastIndex].Valore__c += resto;
            totRa += resto;
        }                   
        
        if(totRa != totale) {
            System.debug('SCARTO DA APPLICARE!!! ' + (totale - totRa));
            cleanRaL[lastIndex].Valore__c += (totale - totRa);            
        }
        return -(totale - totRa);
    }

    /**
     *  Questo metodo approssima le percentuali e i valori delle revenue del singolo lineitem in modo che
     *  la somma delle percentuali faccia 100 e la somma dei valori dia il totale del lineitem
     *  Viene utilizzato per fixare le revenue dei lineitem di un pacchetto,
     *  che derivando dalle percentuali delle revenue del pacchetto potrebbero non tornare nel caso
     *  ci fossero revenue già fatturate
     */ 
    public static void fixAndValidateRaLineItem(Revenue_application__c[] raL, Decimal totaleLi, Map<String, Decimal> totaliMese, Decimal totaleFatturato, Decimal totalePacchetto) {
        System.debug('ENTER FIXANDVALIDATERA!!! ' + raL);
        Integer lastIndex = -1;
        Decimal lastValore = 0;
        Decimal p = 0;
        Decimal v = 0;  
        Revenue_application__c raValore = null;
        if(totaleFatturato == null) totaleFatturato = 0;            
        for(Integer i = 0; i < raL.size(); i++) {
            Revenue_application__c ra = raL.get(i);                                 
            if(ra.Mese__c != 'Totale') {
                if(ra.Mese__c == null || ra.Anno__c == null) throw new RevenueApplicationException('Mese e anno sono obbligatori');     
                if(totaleFatturato > 0 && ra.ticket_fatturazione__c == null) {
                    //Calcolo la parte fatturata su questo lineitem
                    Decimal fatturatoLi = 0;
                    for(Revenue_application__c r : raL) {
                        if(r.Ticket_fatturazione__c != null && r.Mese__c != 'Valore') fatturatoLi += r.Valore__c;
                    }
                    System.debug('!!! ' + ra.Mese__c);                  
                    System.debug('!!! ' + totaliMese);                  
                    System.debug('!!! ' + totaliMese.get(ra.Anno__c + ra.Mese__c));                  
                    System.debug('!!! ' + totalePacchetto);                 
                    System.debug('!!! ' + totaleFatturato );                    
                    System.debug('!!! ' + totaleLi);                    
                    System.debug('!!! ' + fatturatoLi);                 
                    if(totaliMese.get(ra.Anno__c + ra.Mese__c) == 0 || totaleLi - fatturatoLi == 0) {                 
                    	ra.valore__c = 0;
                    } else {
                    	ra.valore__c = totaliMese.get(ra.Anno__c + ra.Mese__c) / (totalePacchetto - totaleFatturato) * (totaleLi - fatturatoLi);                    	
                    }                                       
                    ra.valore__c = ra.valore__c.setScale(2, Roundingmode.HALF_UP);
                    ra.percentuale_applicata__c = (ra.valore__c / totaleLi) * 100;
                    ra.percentuale_applicata__c = ra.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
                }
                v += ra.valore__c;
                p += ra.percentuale_applicata__c;
                //if(ra.ticket_fatturazione__c == null && (lastIndex == -1 || lastValore < ra.Valore__c)) {
                if(lastIndex == -1 || lastValore < ra.Valore__c) {
                    lastIndex = i;
                    lastValore = ra.Valore__c;
                }                         
            } else raValore = ra;
        }
        System.debug('PERCENTUALE TOTALE!!! ' + p);
        System.debug('VALORE TOTALE!!! ' + v);
        System.debug('DIFF PERCENTUALE!!! ' + (100 - p));
        System.debug('DIFF VALORE!!! ' + (totaleLi - v));
        
        if(raValore != null) {
            raValore.valore__c = totaleLi;
            raValore.percentuale_applicata__c = 100;
        } 
        raL[lastIndex].percentuale_applicata__c += (100 - p);   
        raL[lastIndex].valore__c += (totaleLi - v);     
    }
    
    
    /**
     *  Questo metodo calcola la somma delle revenue di un lineitem e approssima uno dei valori delle revenue affinchè sia somma revenue = totale lineitem
     *  Questo è necessario in quanto abbiamo totali a 2 decimali che dovrebbero essere a n decimali per avere i valori corretti, quindi bisogna per forza
     *  fare un'approssimazione.
     *  Se usePercentuale = true, il metodo presuppone che siano state imputate le percentuali, controlla che la loro somma dia 100 e approssima i valori
     *  Se usePercentuale = false, il metodo presuppone che siano stati imputati i valori, controlla che la loro somma dia il totale su lineitem, e approssima le percentuali 
     */      
    public static void checkAndFixLineItemRevenues(Revenue_application__c[] raL, Decimal totale, Boolean usePercentuale) {
        Decimal totRa = 0;          
        Decimal totPercent = 0;
        Revenue_application__c[] cleanRaL = new Revenue_application__c[]{};

        for(Revenue_application__c ra : raL) {
            if(ra.mese__c != 'Totale') {                        
                cleanRaL.add(ra);                               
                totRa += ra.Valore__c;
                totPercent += ra.Percentuale_applicata__c;      
            }           
        }
        
        if(usePercentuale) {
            if(totPercent != 100) throw new RevenueApplicationException('Somma percentuali');
            if(totRa != totale) {
                cleanRaL[cleanRaL.size() - 1].Valore__c += (totale - totRa);
            }
        } else {
            if(totRa != totale) throw new RevenueApplicationException();
            if(totPercent != 100) {
                cleanRaL[cleanRaL.size() - 1].Percentuale_applicata__c += (100 - totPercent);
            }
        }
    }
    
    public static void checkMatrice(Map<String, Revenue_application__c[]> matrice, Map<String, Decimal> totali) {
        Decimal currentResto = null;        

        for(String mese : matrice.keySet()) {   
            System.debug('ANNOMESE!!! ' + mese);
            System.debug('REVENUES!!! ' + matrice.get(mese));
            System.debug('TOTALE!!! ' + totali.get(mese));
                                                        
            currentResto = checkAndFixSommaMesiRevenues(matrice.get(mese), totali.get(mese), currentResto);                                 
        }           
    }

    public static Revenue_application__c[] getMinorRicavi(LineItem__c li){
        Revenue_application__c[] revenueOriginali = [select Data_primo_mese__c,Valore__c,Anno__c,Mese__c,Line_Item__c,Ticket_Fatturazione__c
                                                            from Revenue_application__c
                                                            where Line_Item__c =: li.id
                                                            and valore__c > 0
                                                            and minorRicavo__c = false
                                                            and Mese__c <> 'Totale'
                                                            order by anno_numero__c,mese_numero__c desc
                                                          ];
        Revenue_application__c[] revenueMinorRicavi = new Revenue_application__c[]{};
        Decimal minorRicavo = li.ValoreRipianificabileApprovatoFormula__c;
        for(Revenue_application__c r : revenueOriginali){
            if(r.Ticket_fatturazione__c == null){
                Revenue_application__c raMinorRicavo = new Revenue_application__c(
                                                                Line_Item__c = li.id,
                                                                Anno__c = r.Anno__c,
                                                                Mese__c = r.Mese__c,
                                                                Percentuale_applicata__c = null,
                                                                minorRicavo__c = true
                                                            );
				
                if(r.Valore__c <= minorRicavo){
                    raMinorRicavo.Valore__c = -r.Valore__c;
                    revenueMinorRicavi.add(raMinorRicavo);
                    minorRicavo += raMinorRicavo.Valore__c;
                }else if(minorRicavo > 0){
                    raMinorRicavo.Valore__c = -minorRicavo;
                    revenueMinorRicavi.add(raMinorRicavo);
                    minorRicavo += raMinorRicavo.Valore__c;
                }
            }
        }

        if(minorRicavo > 0){
            if(!revenueMinorRicavi.isEmpty()){
                revenueMinorRicavi[revenueMinorRicavi.size()-1].Valore__c -= minorRicavo;
            }else{
                Revenue_application__c raMinorRicavo = new Revenue_application__c(
                                                                Line_Item__c = li.id,
                                                                Anno__c = revenueOriginali[0].Anno__c,
                                                                Mese__c = revenueOriginali[0].Mese__c,
                                                                Valore__c = -minorRicavo,
                                                                Percentuale_applicata__c = null,
                                                                minorRicavo__c = true
                                                            );
                revenueMinorRicavi.add(raMinorRicavo);
            }
        }

        return revenueMinorRicavi;
    }

    
    public class RevenueApplicationException extends Exception {}
    
    
    @isTest
    static void testMatrice() {
        Map<String, Revenue_application__c[]> matrix = new Map<String, Revenue_application__c[]>{
            'Gennaio'  => new Revenue_application__c[]{
                new Revenue_application__c(mese__c = 'Gennaio', valore__c = 207.31, percentuale_applicata__c = 20.94),  
                new Revenue_application__c(mese__c = 'Gennaio', valore__c = 418.8, percentuale_applicata__c = 20.94),
                new Revenue_application__c(mese__c = 'Gennaio', valore__c = 0.01, percentuale_applicata__c = 20.94) 
            },
            'Febbraio' => new Revenue_application__c[]{
                new Revenue_application__c(mese__c = 'Febbraio', valore__c = 229.48, percentuale_applicata__c = 23.18),
                new Revenue_application__c(mese__c = 'Febbraio', valore__c = 463.6, percentuale_applicata__c = 23.18),
                new Revenue_application__c(mese__c = 'Febbraio', valore__c = 0.01, percentuale_applicata__c = 23.18)
            },
            'Marzo'    => new Revenue_application__c[]{
                new Revenue_application__c(mese__c = 'Marzo', valore__c = 553.21, percentuale_applicata__c = 55.88),
                new Revenue_application__c(mese__c = 'Marzo', valore__c = 1117.6, percentuale_applicata__c = 55.88),
                new Revenue_application__c(mese__c = 'Marzo', valore__c = 0.02, percentuale_applicata__c = 55.88)
            }
        };
        
        Map<String, Decimal> totali = new Map<String, Decimal>{
            'Gennaio' => 626.07,
            'Febbraio' => 693.13,
            'Marzo' =>1670.84
        };
        
        
        checkMatrice(matrix, totali);

        System.assertEquals(626.07, matrix.get('Gennaio')[0].valore__c + matrix.get('Gennaio')[1].valore__c + matrix.get('Gennaio')[2].valore__c);
        System.assertEquals(693.13, matrix.get('Febbraio')[0].valore__c + matrix.get('Febbraio')[1].valore__c + matrix.get('Febbraio')[2].valore__c);
        System.assertEquals(1670.84, matrix.get('Marzo')[0].valore__c + matrix.get('Marzo')[1].valore__c + matrix.get('Marzo')[2].valore__c);       
        
        System.assertEquals(990, matrix.get('Gennaio')[0].valore__c + matrix.get('Febbraio')[0].valore__c + matrix.get('Marzo')[0].valore__c);
        System.assertEquals(2000, matrix.get('Gennaio')[1].valore__c + matrix.get('Febbraio')[1].valore__c + matrix.get('Marzo')[1].valore__c);
        System.assertEquals(0.04, matrix.get('Gennaio')[2].valore__c + matrix.get('Febbraio')[2].valore__c + matrix.get('Marzo')[2].valore__c);
    }
    
    public static testMethod void testControllerRevenueApplication(){
        Opportunity o = new Opportunity(name='test',CloseDate=date.today(),stageName='test');
        insert o;
        LineItem__c li = new LineItem__c(Opportunity__c=o.id,start_Date__c=date.newInstance(2013,1,1),end_Date__c=date.newInstance(2013,1,1),totale__c=0);
        insert li;
        ControllerRevenueApplication c = new ControllerRevenueApplication(li);
        c.setParentValues(li);
        List<selectOption> so = c.getModalitaOption();
        c.creaRevenueApplicationDaDate();
        c.revenueApplications[0].valore__c = 0;
        c.revenueApplications[0].percentuale_applicata__c = 0;
        c.updateRevenueApplication();
        c.addRevenueApplicationCustom();
        c.revenueApplications[1].valore__c = 0;
        c.revenueApplications[1].percentuale_applicata__c = 0;
        c.updateRevenueApplication();
        c.revenueApplications[1].mese__c = 'Gennaio';
        c.revenueApplications[1].anno__c = '2014';
        c.saveTmpRevenueApplications();
        c.restoreFromTmpRevenueApplication();
        c.customSave();
        c.checkRevenueApplication(li);
        
    }


    @isTest
    static void creaRADaDateVetrina() {
        Opportunity o = new Opportunity(name='test',CloseDate=date.today(),stageName='test');
        insert o;
        LineItem__c li = new LineItem__c(Opportunity__c=o.id,start_Date__c=date.newInstance(2013,1,1),end_Date__c=date.newInstance(2014,1,31),totale__c=666);
        insert li;

        ControllerRevenueApplication c = new ControllerRevenueApplication(li);
        c.setParentValues(li);
        c.revenueApplications = new List<Revenue_application__c>();
        c.revenueApplications.add(new Revenue_application__c(Id='a0I11000001IFKS'));

        Test.startTest();
        c.creaRevenueApplicationDaDateVetrina();
        Test.stopTest();

        System.assertEquals(1, c.revenueApplicationsToDelete.size());
        System.assertEquals('a0I11000001IFKS', c.revenueApplicationsToDelete.get(0).Id);
        System.assertEquals(2, c.revenueApplications.size());
        for (Revenue_application__c ra : c.revenueApplications) {
            if (ra.Mese__c == 'Totale') {
                System.assertEquals(666, ra.Valore__c);
                System.assertEquals(100, ra.Percentuale_applicata__c);
            } else if (ra.Mese__c == ControllerRevenueApplication.mesiMap.get(1) && ra.Anno__c == '2013') {
                System.assertEquals(666, ra.Valore__c);
                System.assertEquals(100, ra.Percentuale_applicata__c);
                System.assertEquals('2013', ra.Anno__c);
            } else { //Not Needed
                System.assertEquals(0, ra.Valore__c);
                System.assertEquals(0, ra.Percentuale_applicata__c);
                System.assertEquals('2013', ra.Anno__c);
            }
        }
    }
}