public class ControllerRicavi{

    public list<Ricavo__c> ricavi {get;set;}
    public list<Ricavo__c> minorRicavi {get;set;} //solo per visualizzazione su line item ripianificato
    public list<Ricavo__c> ricaviToDelete {get;set;}
    
    public boolean ricaviPersonalizzati {get;set;}
    
    public integer indexRicavoToDelete {get;set;}
    public integer indexApplicaDifferenza {get;set;}
    
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public Id id {get;set;} 
    public Double totaleParent {get;set;}
    public Double quantita {get;set;}
    public boolean ripianificazioneLineItem {get;set;}
     
    public LineItem__c li {get;set;}
    
    public double totalDiffSumRicavi {get;set;} //differenza tra totale e somma ricavi

    public static Map<Integer,String> mesiMap = new Map<Integer,String>{
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
    public static Map<String,Integer> mesiNumeroMap = new Map<String,Integer>{
        'Gennaio' => 1,
        'Febbraio' => 2,
        'Marzo' => 3,
        'Aprile' => 4,
        'Maggio' => 5,
        'Giugno' => 6,
        'Luglio' => 7,
        'Agosto' => 8,
        'Settembre' => 9,
        'Ottobre' => 10,
        'Novembre' => 11,
        'Dicembre' => 12 
    };

    public List<selectOption> getModalitaOption(){
       List<SelectOption> options = new List<SelectOption>();
       List<Schema.PicklistEntry> ple = LineItem__c.ModalitaEditRicavo__c.getDescribe().getPicklistValues();
         
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));
       }
       return options;
    }

    public ControllerRicavi(){
        ricavi = new List<Ricavo__c>();
        minorRicavi = new List<Ricavo__c>();
        ricaviToDelete = new list<Ricavo__c>();
    }
    
    public ControllerRicavi(LineItem__c li){
        this.li = li;
        ricavi = new List<Ricavo__c>(); 
        minorRicavi = new List<Ricavo__c>();

        list<Ricavo__c> allRicavi = getAllRicavi(li);

        for(Ricavo__c r : allRicavi){
            if(r.minorRicavo__c){
                minorRicavi.add(r);
            }else{
                ricavi.add(r);
            }
        }
        assignOrderToRicavi();
        if(! minorRicavi.isEmpty()){
            minorRicavi.add(new Ricavo__c(Mese__c='Totale',Valore__c=li.Totale_ripianificato__c));
        } 

        ricaviToDelete = new list<Ricavo__c>();
        ricaviPersonalizzati = esistonoRicaviCustom2();
    }
    
    public void controllaSeEsistonoRicaviPersonalizzati(){
        ricaviPersonalizzati = esistonoRicaviCustom2();
    }

    public static Ricavo__c[] getAllRicavi(LineItem__c li){
            return [select Anno__c,anno_numero__c,Custom__c,Modificato__c, Mese__c,mese_numero__c,Percentuale_applicata__c,order__c,Data_primo_mese__c,
                              Valore__c,Line_Item__c,Data_ultimo_mese__c,lineItemDiRipianificazione__c,minorRicavo__c
                        from Ricavo__c
                        where Line_Item__c =: li.id
                        order by anno_numero__c,mese_numero__c asc
                      ];
    }
    
    public void getRicaviNegativi(Id lineItemDaRipianificare, Id lineItemDiRipianificazione){
        ricavi = [select Anno__c,anno_numero__c,Custom__c,Modificato__c, Mese__c,mese_numero__c,Percentuale_applicata__c,order__c,
                          Valore__c,Line_Item__c,Data_ultimo_mese__c
                    from Ricavo__c
                    where Line_Item__c =: lineItemDaRipianificare
                    and lineItemDiRipianificazione__c = :lineItemDiRipianificazione
                    order by anno_numero__c,mese_numero__c
                  ];
        for(Ricavo__c ricavo : ricavi){
            ricavo.Valore__c = -ricavo.Valore__c;
        }
    }
    
    
    public void resetRicaviToDelete(lineitem__c li){
        ricaviToDelete = new list<Ricavo__c>();
    }
    
    //al posto di reset se sto inserendo un pacchetto
    public void initRicaviToDelete(){
        ricaviToDelete = new list<Ricavo__c>();
    }
    
    public list<Ricavo__c> ricaviTmp {get;set;}
    public void saveTmpRicavi(){
        ricaviTmp = ricavi.deepClone(true,true,true); //per ripristinare in caso di errori
    }
    
    public void restoreFromTmpRicavi(){
        ricavi = ricaviTmp.deepClone(true,true,true);
    }
    
    public string checkRicavi(LineItem__c li){
        return [select IncoerenzeRicavi__c from lineitem__c where id =: li.id].IncoerenzeRicavi__c;
    }
    
    public void updateCheckRicavi(LineItem__c li){  
        LineItemTriggerHandler.skipUpdateLineItem = false;
        update [select id from Ricavo__c where line_item__c =: li.id];
    }
    
    public void assignOrderToRicavi(){
        for(integer i=0;i<ricavi.size();i++){
            ricavi[i].order__c = i;
        }
    }
    
    public void customSave(){
        assignOrderToRicavi();
        system.debug(LoggingLevel.WARN,'ricavi to update: '+ricavi);
        upsert ricavi;
        system.debug(LoggingLevel.WARN,'ricavi to delete: '+ricaviToDelete);
        delete ricaviToDelete;
    }
    
    

    public void setParentValues(LineItem__c li){
        startDate = li.start_date__c;
        endDate = li.end_date__c;
        id = li.id;
        totaleParent = li.totale__c;
        quantita = li.quantita__c;
    }
    
    public void calcolaRicavi(LineItem__c lineItemOriginale,LineItem__c lineItemRipianificazione){

        Date dataChiusuraRicavi = RicavoTriggerHandler.getDataChiusuraRicavo(lineItemOriginale.Opportunity__r.Local__c); 
        
        Scenario scenario = getScenario(lineItemOriginale);

        system.debug(LoggingLevel.WARN,'scenario = '+scenario.scenario);

        if(scenario.scenario == 'rimozioneParteNonErogata'){
            if(lineItemOriginale.Data_sospensione_erogazione__c != null){
                startDate = lineItemOriginale.Data_sospensione_erogazione__c.date().addDays(1);
            }else{
                startDate = lineItemOriginale.End_Date__c;
            }
            if(startDate <= dataChiusuraRicavi){
                if(!scenario.ricaviOriginaliMesiAperti.isEmpty()){
                    startDate = scenario.ricaviOriginaliMesiAperti[0].Data_primo_mese__c;
                }else{
                    startDate = dataChiusuraRicavi.addMonths(1).toStartOfMonth();
                }
            }

            if(lineItemOriginale.End_Date__c > startDate){
                endDate = lineItemOriginale.End_Date__c; 
            }else{
                endDate = startDate;
            }
            totaleParent = lineItemOriginale.ValoreRipianificabileApprovatoFormula__c;
            id = lineItemOriginale.Id;
        }
        
        if(scenario.scenario == 'lineItemSoloSuMesiChiusi'){
            startDate = lineItemRipianificazione.start_date__c;
            endDate = lineItemRipianificazione.end_date__c;
            totaleParent = lineItemRipianificazione.Totale__c;
            id = lineItemOriginale.Id;
        }else if(scenario.scenario == 'lineItemTerminato'){
            if(scenario.ricaviOriginaliMesiAperti.isEmpty()){
                // MCOLO - startDate = dataChiusuraRicavi.addMonths(1).toStartOfMonth();
                startDate = lineItemRipianificazione.start_date__c;
                // MCOLO - endDate = dataChiusuraRicavi.addMonths(1).toStartOfMonth();
                endDate = lineItemRipianificazione.end_date__c;
            }else{
                // MCOLO - startDate = scenario.ricaviOriginaliMesiAperti[0].Data_primo_mese__c;
                startDate = lineItemRipianificazione.start_date__c;
                // MCOLO - endDate = lineItemOriginale.end_date__c;
                endDate = lineItemRipianificazione.end_date__c;
                if(startDate > endDate){
                    Integer lastIndex = scenario.ricaviOriginaliMesiAperti.size()-1;
                    endDate = scenario.ricaviOriginaliMesiAperti[lastIndex].Data_ultimo_mese__c; 
                }
            }
            totaleParent = lineItemRipianificazione.Totale__c;
            id = lineItemOriginale.Id;  
        }else if(scenario.scenario == 'lineItemNonTerminato'){
            //startDate = Date.newInstance(lineItemOriginale.Data_sospensione_erogazione__c.year(),lineItemOriginale.Data_sospensione_erogazione__c.month(),lineItemOriginale.Data_sospensione_erogazione__c.day()+1);
            if(scenario.ricaviOriginaliMesiAperti.isEmpty()){
                // MCOLO - startDate = dataChiusuraRicavi.addMonths(1).toStartOfMonth();
                startDate = lineItemRipianificazione.start_date__c;
                // MCOLO - endDate = dataChiusuraRicavi.addMonths(1).toStartOfMonth();
                endDate = lineItemRipianificazione.end_date__c;

            }else{
                // MCOLO - startDate = lineItemOriginale.Data_sospensione_erogazione__c.date().addDays(1);
                startDate = lineItemRipianificazione.start_date__c;
                // MCOLO - endDate = lineItemOriginale.end_date__c;
                endDate = lineItemRipianificazione.end_date__c;

                if(startDate <= dataChiusuraRicavi){
                    startDate = scenario.ricaviOriginaliMesiAperti[0].Data_primo_mese__c;
                }
                if(endDate < startDate){
                    endDate = startDate;
                }
            }

            totaleParent = lineItemRipianificazione.Totale__c;
            id = lineItemOriginale.Id;
        }
        
        creaRicaviDaDate();
    
        List<Ricavo__c> ricaviStorno = new List<Ricavo__c>();
        for(Ricavo__c ricavo : ricavi){
            if(ricavo.Mese__c == 'Totale'){
                continue;
            }
            ricavo.minorRicavo__c = true;
            ricavo.percentuale_applicata__c = null;
            ricavo.valore__c = -ricavo.valore__c;
            ricavo.LineItemDiRipianificazione__c = lineItemRipianificazione.Id;
            ricaviStorno.add(ricavo);
        }
        ricavi = ricaviStorno;

        
        customSave();
        
        for(Ricavo__c ricavo : ricavi){
            ricavo.valore__c = -ricavo.valore__c;
        }       
        
    }

    /*
    * Used for product with Vetrina__c = true
    * The total value is setted in these ratios
    * - First month: precentAmountFirstMonth
    * - Other months: precentAmountOtherMonth
    */
    public void creaRicaviDaDateVetrina(Decimal precentAmountFirstMonth){
        System.debug('START - ControllerRicavi.creaRicaviDaDateVetrina');
        System.debug(LoggingLevel.WARN, 'Punto Debug - initial ricavi: '+ricavi);

        if(startDate.toStartOfMonth() == endDate.toStartOfMonth()){
            precentAmountFirstMonth = 100;            
        }

        Decimal precentAmountOtherMonth = 100 - precentAmountFirstMonth;
    //Date check
        if(startDate > endDate){
            return;
        }
    //Preparing for deleting or storing remaining Ricavi
        Map<String, Ricavo__c> mapMonthYearRicavo = new Map<String, Ricavo__c>();
        for (Ricavo__c rc : ricavi) {
            if(rc.Id != null) {
                if (rc.Mese__c == 'Totale') { ricaviToDelete.add(rc); } //Deleting the Totale
                else {
                    rc.Valore__c = 0;
                    rc.Percentuale_applicata__c = 0;
                    mapMonthYearRicavo.put(rc.Anno__c+'_'+ ('000'+mesiNumeroMap.get(String.valueOf(rc.Mese__c))).right(2) , rc);
                }
            }
        }
        System.debug(LoggingLevel.WARN, 'Punto Debug - initial mapMonthYearRicavo: '+mapMonthYearRicavo);
    //Populating Ricavo List
        ricavi = new List<Ricavo__c>();
        Date d = startDate.toStartOfMonth() ; //Used as counter
        //0 - Evaluating the value of ricavo to equally distribute the 20%
        Decimal totalRemainingMonth = (totaleParent * precentAmountOtherMonth/100).setScale(2,RoundingMode.HALF_UP); //Initial value
        Integer numMonthsBetween = d.monthsBetween(endDate); //adding first month
        Decimal valueSingleMonth = 0;
        Decimal percentSingleMonth = 0;
        if (numMonthsBetween > 0) {
            valueSingleMonth = (totalRemainingMonth / numMonthsBetween).setScale(2,RoundingMode.HALF_UP);
            percentSingleMonth = (precentAmountOtherMonth / numMonthsBetween).setScale(2,RoundingMode.HALF_UP);
        }
        if (percentSingleMonth == 0) { percentSingleMonth = 0.1; } //In case of small numbers
        totalRemainingMonth = numMonthsBetween * valueSingleMonth; //Final value, if could be different cause of rounds
        Decimal totalFirstMonth = totaleParent - totalRemainingMonth;
        //1 - Populating the first month
        Ricavo__c rcFirstMonth = new Ricavo__c(
            Line_Item__c=id,
            Percentuale_applicata__c = precentAmountFirstMonth,
            Valore__c = totalFirstMonth,
            Mese__c=mesiMap.get(startDate.month()),
            Anno__c=String.valueOf(startDate.year())
        );
        //If it's already present, the Id will be populated (update)
        String monthYearFirst = String.valueOf(startDate.year())+'_'+('000'+String.valueOf(startDate.month())).right(2);
        if (mapMonthYearRicavo.get(monthYearFirst) != null) {
            rcFirstMonth.Id = mapMonthYearRicavo.get(monthYearFirst).Id;
            mapMonthYearRicavo.put(monthYearFirst, rcFirstMonth);
        } else { ricavi.add(rcFirstMonth); }
        //2 - Populating other months
        d = d.addMonths(1); //Skip first month
        Decimal currentTotalPercent = precentAmountFirstMonth; //Initial value
        while(d <= endDate){
            String monthYear = String.valueOf(d.year())+'_'+('000'+String.valueOf(d.month())).right(2);
            if (d.month() == endDate.month()) { //Last month, fix the percent
                percentSingleMonth = 100 - currentTotalPercent;
            }
            Ricavo__c rc = new Ricavo__c(
                Line_Item__c=id,
                Mese__c = mesiMap.get(Integer.valueOf(d.month())),
                Anno__c = String.valueOf(d.year()),
                Percentuale_applicata__c = percentSingleMonth,
                Valore__c = valueSingleMonth
            );
            if (mapMonthYearRicavo.get(monthYear) != null) {
                rc.Id = mapMonthYearRicavo.get(monthYear).Id;
                mapMonthYearRicavo.put(monthYear, rc);
            } else { ricavi.add(rc); }

            currentTotalPercent += percentSingleMonth;
            d = d.addMonths(1);
        }

        String[] orderedKeys = new String[]{};
        orderedKeys.addAll(mapMonthYearRicavo.keySet());

        orderedKeys.sort();

        for(String s : orderedKeys){
            ricavi.add(mapMonthYearRicavo.get(s)); //Adding all ricavi    
        }

        //3 - Adding Ricavo Total
        ricavi.add(
            new Ricavo__c(
                Line_Item__c=id,
                Percentuale_applicata__c = 100,
                Mese__c='Totale',
                Valore__c = totaleParent
            )
        );        

        System.debug(LoggingLevel.WARN, 'Punto Debug - mapMonthYearRicavo: '+mapMonthYearRicavo);
        System.debug(LoggingLevel.WARN, 'Punto Debug - ricavi: '+ricavi);
        System.debug('END - ControllerRicavi.creaRicaviDaDateVetrina');
    }

    public void creaRicaviDaDate(){
       system.debug('init crea da date');
        
        if(startDate > endDate){
            return;
        }

        Map<string,integer> mesiGiorniMap = new Map<string,integer>(); //mappa 'mese_anno' => numero giorni
        list<string> keySetMap = new list<string>(); //per mantenere l'ordine
        list<String> oldRicaviKeys = new list<string>();
        Map<String,Ricavo__c> oldRicavi = new Map<String,Ricavo__c>();
        
        for(Ricavo__c ra : ricavi) {
            if(ra.Id != null){
                //ricaviToDelete.add(ra);
                if(ra.Mese__c == 'Totale'){
                    ricaviToDelete.add(ra);
                }else{
                    ra.percentuale_applicata__c = 0;
                    ra.valore__c = 0;
                    String key = mesiNumeroMap.get(ra.mese__c)+'_'+ra.anno__c;
                    oldRicaviKeys.add(key);
                    oldRicavi.put(key,ra);
                }
            }
        }
        ricavi = new list<Ricavo__c>();
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
        
        Ricavo__c totale = new Ricavo__c(Line_Item__c=id);
        
        totale.mese__c = 'Totale';
        totale.percentuale_applicata__c = 0;
        totale.valore__c = 0;
        
        double sommaPerc = 0.0;
        integer i = -1;
        for(string s : keySetMap){
            i++;
            Ricavo__c ra = null;
            if(oldRicavi.keySet().contains(s)){
                ra = oldRicavi.get(s);
            }else{
                ra = new Ricavo__c(Line_Item__c=id); 
            }
            ra.mese__c = mesiMap.get(integer.valueof(s.split('_')[0]));
            ra.anno__c = s.split('_')[1];
            Date dataInizioMese = Date.newInstance(Integer.valueOf(ra.anno__c),mesiNumeroMap.get(ra.mese__c),1);
            ra.dataInizioCompetenza__c = startDate < dataInizioMese ? dataInizioMese : startDate;
            Date dataFineMese = Date.newInstance(Integer.valueOf(ra.anno__c),mesiNumeroMap.get(ra.mese__c),1).addMonths(1).addDays(-1);
            ra.dataFineCompetenza__c = endDate < dataFineMese ? endDate : dataFineMese;
            ra.percentuale_applicata__c = mesiGiorniMap.get(s) * 100.00 / daysBetween;
            ra.percentuale_applicata__c = ra.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
            ra.valore__c = ra.percentuale_applicata__c * totaleParent / 100;
            ra.Modificato__c = false;
            ra.Custom__c = false;
            ricavi.add(ra);
            sommaPerc += ra.percentuale_applicata__c;
        }
        List<String> ricaviToAdd = new List<String>();
        for(integer j = 0; j<oldRicaviKeys.size(); j++){
            String key = oldRicaviKeys.get(j);
            if(key == '100_3000'){
                continue;
            }
            boolean found = false;
            for(String s : keySetMap){
                if(s == key){
                    found = true;
                    break;
                }
            }
            if(!found){
                ricaviToAdd.add(key);
            }
        }

        for(String s : ricaviToAdd){
            ricavi.add(oldRicavi.get(s));
        }
        
        if(sommaPerc != 100.00 && i!=-1){
            ricavi[i].percentuale_applicata__c = ricavi[i].percentuale_applicata__c - (sommaPerc - 100.00);
            ricavi[i].valore__c = ricavi[i].percentuale_applicata__c * totaleParent / 100;
        }
        
        for(Ricavo__c ra :  ricavi){
            totale.percentuale_applicata__c += ra.percentuale_applicata__c;
            totale.valore__c += ra.valore__c;
        }        
        
        totale.percentuale_applicata__c = totale.percentuale_applicata__c.setScale(2,RoundingMode.HALF_UP);
        ricavi.add(totale);        
        //sistemo percentuali e totali con i 2 decimali
        updateRicavi(true);
        system.debug('end crea da date');    
        
    }
    
    public void addRicaviCustom(){
        Ricavo__c ra = new Ricavo__c(Line_Item__c=id,Custom__c=true, Modificato__c = true);
        ricavi.add(ricavi.size()-1,ra);
        updateRicavi();
    }
    
    public void deleteRicaviCustom(){        
        Ricavo__c raToRemove = ricavi.remove(indexRicavoToDelete);
        System.debug('RTOREMOVE!!! ' + raToRemove);
        if(raToRemove.Id != null) ricaviToDelete.add(raToRemove);
        updateRicavi();
    }
    
    public void applicaDifferenza(){
        //se faccio una modifica dopo la prima fatturazione per applicare la differenza col totale su un ricavo
        String updatedRicavoAsString = Apexpages.currentPage().getParameters().get('updatedRicavo');
        Integer updatedRicavo = Integer.valueOf(updatedRicavoAsString);
        for(Ricavo__c ra : ricavi) {
            if(ra.Order__c == updatedRicavo){
                ra.Modificato__c = true;
            }           
        }
        if(totalDiffSumRicavi != null){
            ricavi.get(indexApplicaDifferenza).valore__c += totalDiffSumRicavi;
        }
        updateRicavi();
    }
    
    private String getModalitaEdit() {
        return li.ModalitaEditRicavo__c;     
    }
    
    public void updateRicavi(){
        updateRicavi(false);
    }
    
    public void checkTotaliAndUpdateRicavi() {
        String updatedRicavoAsString = Apexpages.currentPage().getParameters().get('updatedRicavo');
        Integer updatedRicavo = Integer.valueOf(updatedRicavoAsString);
        for(Ricavo__c ra : ricavi) {
            if(ra.Order__c == updatedRicavo){
                ra.Modificato__c = true;
            }           
        }
        if(isAdsense && getModalitaEdit() == 'Valore') {
            Decimal total = 0;
            for(Ricavo__c ra : ricavi) {
                if(ra.Mese__c != 'Totale') {
                    total += ra.Valore__c;
                }
            }
            li.totale__c = total;
            li.Ultima_modifica_prezzo__c = 'totale';
            totaleParent = total;
            System.debug('NEW TOTALE !!! ' + li.totale__c);
        } 
        updateRicavi();
    }
    
    public void updateRicavi(Boolean forceFixValori){
        if(ricavi.isEmpty()) return;
        
        assignOrderToRicavi();
                            
        Decimal valore = 0; //somma valori facendo setscale per ogni valore
        //Decimal valore_commisioning = 0; //somma valore commisioning
        Decimal perctotale = 0; //somma delle percentuali facendo setscale per ogni ricavo
        //Decimal numero_impression = 0; //somma impressions
        
        string modalitaEdit = forceFixValori ? 'Percentuale' : getModalitaEdit();
                
        //Ricavo totale
        Ricavo__c raTotale;
        //Indice ultima ricavo, la modifico per far tornare il totale
        integer lastindex = -1;
        Decimal lastValore = 0;
        
        for(Integer i = 0; i < ricavi.size(); i++){
            Ricavo__c ra = ricavi.get(i);
            if(ra.custom__c && ra.percentuale_applicata__c != null && (isblank(ra.mese__c) || isblank(ra.anno__c))){
                if(isblank(ra.mese__c)){
                    ra.mese__c.addError('Obbligatorio');
                }
                if(isblank(ra.anno__c)){
                    ra.anno__c.addError('Obbligatorio');
                }
                return;
            }
            if(ra.percentuale_applicata__c == null){ 
                ra.percentuale_applicata__c = 0;
            }
            if(ra.valore__c == null){
                ra.valore__c = 0;
            }
            
            if(ra.mese__c != 'Totale'){      
                if(modalitaEdit == 'Valore'){
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
                valore += ra.valore__c;
                perctotale += ra.percentuale_applicata__c;
                if(lastValore < ra.Valore__c || lastIndex == -1) {
                    lastindex = i;
                    lastValore = ra.Valore__c;
                }
            }else{
                raTotale = ra;
            }
        }
        
        if(modalitaEdit == 'Valore' && valore == totaleParent){
            ricavi[lastindex].percentuale_applicata__c += (100 - perctotale);
            perctotale += (100 - perctotale);        
        }
        if(modalitaEdit == 'Percentuale' && perctotale == 100){
            ricavi[lastindex].valore__c -= (valore-totaleParent);
            valore -= (valore-totaleParent);
        }
    
        if(raTotale != null){
            raTotale.valore__c = valore;
            raTotale.percentuale_applicata__c = perctotale;
        }

        System.debug('PERCTOTALE!!! ' + perctotale);
        System.debug('VALORETOTALE!!! ' + valore);  
        
        totalDiffSumRicavi = totaleParent - valore;
    }

    public Boolean isAdSense {
        get {
            if(li == null) return false;
            return (li.Type_DFP__c == 'ADSENSE' || li.Type_DFP__c == 'AD_EXCHANGE');
        }
    }
    public boolean isBlank(String s){
        return (s == '' || s == null);
    }
 
    public static Scenario getScenario(LineItem__c li){
        Scenario scenario = new Scenario();

        Date dataChiusuraRicavi = RicavoTriggerHandler.getDataChiusuraRicavo(li.Opportunity__r.Local__c); 
        //Date dataChiusuraRicavi = DataChiusuraRicavo__c.getValues('data').data__c;
        scenario.isLineItemSoloSuMesiAperti = true;
        scenario.isLineItemSoloSuMesiChiusi = true;

        Ricavo__c[] allRicavi = getAllRicavi(li);

        for(Ricavo__c ricavo : allRicavi){
            if(ricavo.Mese__c == 'Totale'){
                continue;
            }

            if(ricavo.Data_primo_mese__c > dataChiusuraRicavi && !ricavo.minorRicavo__c){
                scenario.ricaviMesiAperti.add(ricavo);
            }

            if(ricavo.Valore__c == 0){
                continue;
            }
            if(ricavo.Data_primo_mese__c < dataChiusuraRicavi){
                scenario.isLineItemSoloSuMesiAperti = false;
            }else{
                scenario.isLineItemSoloSuMesiChiusi = false;
            }

            if(ricavo.minorRicavo__c){
                scenario.ricaviRipianificati.add(ricavo);
            }else{
                scenario.ricaviOriginali.add(ricavo);
                if(ricavo.Data_primo_mese__c > dataChiusuraRicavi){
                    scenario.ricaviOriginaliMesiAperti.add(ricavo);
                }
            }

            
        }

        if(li.RimozioneParteNonErogata__c){
            scenario.scenario = 'rimozioneParteNonErogata';
        }else  if(scenario.isLineItemSoloSuMesiChiusi){
                scenario.scenario = 'lineItemSoloSuMesiChiusi';
        }else{
            Time endTime = Time.newInstance(Integer.valueOf(li.End_Hour__c),Integer.valueOf(li.End_Minute__c),0,0);
            Boolean lineItemTerminato = Datetime.newInstance(li.End_Date__c,endTime) < Datetime.now();
            if(lineItemTerminato){
                scenario.scenario = 'lineItemTerminato';
            }else{
                scenario.scenario = 'lineItemNonTerminato';
            }
        }
        return scenario;
    }
    
    public static Boolean isLineItemSoloSuMesiAperti(LineItem__c li) {
        return getScenario(li).isLineItemSoloSuMesiAperti;
    }
    
    public static Boolean isLineItemSoloSuMesiApertiStorno(LineItem__c li){
        //Date dataChiusuraRicavi = DataChiusuraRicavo__c.getValues('data').data__c;
        Date dataChiusuraRicavi = RicavoTriggerHandler.getDataChiusuraRicavo(li.Opportunity__r.Local__c); 
        LineItem__c lineItemOriginale = [SELECT Id , 
                                                    (SELECT Id,Data_primo_mese__c
                                                    FROM Ricavi__r
                                                    WHERE LineItemDiRipianificazione__c = :li.Id)
                                                FROM LineItem__c 
                                                WHERE Id = :li.Line_Item_Ripianificato__c];
        for(Ricavo__c ricavo : lineItemOriginale.Ricavi__r){
            if(ricavo.Data_primo_mese__c < dataChiusuraRicavi){
                return false;
            }
        }
        return true;
    }

    
    public class Scenario {
        public String scenario {get;set;}
        public Boolean isLineItemSoloSuMesiAperti {get;set;}
        public Boolean isLineItemSoloSuMesiChiusi {get;set;}
        public List<Ricavo__c> ricaviOriginali {get;set;}
        public List<Ricavo__c> ricaviOriginaliMesiAperti {get;set;}
        public List<Ricavo__c> ricaviRipianificati {get;set;}
        public List<Ricavo__c> ricaviMesiAperti {get;set;}

        public Scenario(){
            ricaviOriginali = new List<Ricavo__c>();
            ricaviRipianificati = new List<Ricavo__c>();
            ricaviOriginaliMesiAperti = new List<Ricavo__c>();
            ricaviMesiAperti = new List<Ricavo__c>();
        }
    }
    
    public Boolean esistonoRicaviCustom2(){
        for(Ricavo__c ricavo : ricavi){
            if(ricavo.Custom__c || ricavo.Modificato__c){
                return true;
            }
        }
        return false;
    }
       
    public class RicaviException extends Exception {}
        
}