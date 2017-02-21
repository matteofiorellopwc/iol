public class ControllerCpdAvailability_test{
    public class CpdSlot{
        public Integer h {get;set;}
        public list<LineItem__c> lis {get;set;}
        public set<id> lisId {get;set;}
        public double totalGoal {get;set;}
        public double confirmedGoal {get;set;} //somma dei goal per i lineitem con Bloccante__c = true
    }
    
    public class CpdSlotListItem{
        public Date d {get;set;}
        public String dayOfWeek {get;set;}
        public list<CpdSlot> slots {get;set;}
        public list<TemplateCandidate> templates {get;set;}
        public set<id> liIds {get;set;} //lineitem già controllati        
    } 
    
    public class TemplateCandidate{
        public CPDTemplate__c template {get;set;}
        public integer counter {get;set;}
        public integer confirmedCounter {get;set;}
        public TemplateCandidate(CPDTemplate__c template){
            this.template = template;
            counter = 0;
            confirmedCounter = 0;
        }
    }
    
    public LineItem__c li {get;set;}
    public String formattedStartDate {get;set;} //usato nella pagina per cambiare i filtri
    public String formattedEndDate {get;set;} //usato nella pagina per cambiare i filtri
    public List<CpdSlotListItem> slots {get;set;}
    public List<Integer> ii {get;set;}
    
    /*
      se devo ancora salvare ma ho settato il campo fascia oraria su line item non considero i day part targeting salvati
      ma ne creo di finti per quella fascia 
    */
    public string fasciaOraria = null;
        
    public string canale_primario_selected {get;set;}
    public string canale_primario_old_selected {get;set;}
    public string size_selected {get;set;}
    public string multisize_selected {get;set;}
    public string tipologia_canale_selected {get;set;}
    public string ad_unit_cpd_selected {get;set;}
    public string formato_selected {get;set;}
    public string prodotto_selected {get;set;}
    
    public Map<Id,Product2> productsMap {get;set;} //map Id -> prodotto
    
    public list<selectOption> canali {get;set;}
    public list<selectOption> canaliOld {get;set;}
    public list<selectOption> size {get;set;}    
    public list<selectOption> multisize {get;set;}
    
    public list<SelectOption> formati {get;set;}
    public map<String,list<SelectOption>> prodotti {get;set;}
    
    public Opportunity opportunity {get;set;}
    
    private Id AccountId {get;set;}
    
    public LineItem__c lineItem {get;set;} 
    
    public Boolean isRunning {get;set;}
    
    public boolean isVisibleDayPartTab {get;set;}
    public boolean isVisibleFrequencyCapTab {get;set;}
    public boolean isVisibleInventoryTargetTab {get;set;}
    public boolean isVisibleTechnologyTargetTab {get;set;}
    public boolean isVisibleCustomCriteriaTab {get;set;}
    public boolean isVisibleCookiesTab {get;set;}
    public boolean isVisiblePagesSectionsTab {get;set;}
    public boolean isVisibleGeographyTab {get;set;}
  
	
    

    public list<selectOption> adunitscpd {get;set;}    
        
    public string lineItemsNonBloccanti {get;set;}
        
    //Used for multiple lis availability Id lineitem => set<Id> adunit
    public Map<Id, Set<Id>> conflictAdUnitMap {get;set;}
    
    //Used for cpd availability without li Id adunit => set<Id> adunit
    public Map<Id, Set<Id>> conflictAdUnitMapWithoutLi {get;set;}
    
    public ControllerCpdAvailability_test(ApexPages.StandardController controller) {
   
    	
   		
   		adunitscpd = new list<SelectOption>();
       
        this.initPicklistsAndTemplates();
        this.initController();
        string paramStartDate = ApexPages.CurrentPage().getParameters().get('startdate');
        string paramEndDate = ApexPages.CurrentPage().getParameters().get('enddate');
        
        this.fasciaOraria = ApexPages.CurrentPage().getParameters().get('fasciaOraria');
        
        
 		

        if(controller.getId() != null){
            li = [SELECT id,product__r.size__c,product__r.multisize__c,product__r.Canale_Primario__c,product__r.CanalePrimario__c,
                         product__r.formato__c,product__r.Categoria_libero__c,
                         Start_Date__c,End_date__c,status__c,reservationStatus__c,
                         product__r.fascia_oraria__c,Goal__c,Bloccante__c,settore_brand__c,
                         opportunity__r.status__c,opportunity__r.Probability,Name_Dfp__c,brand__c,Opportunity__r.isWon,
                         (Select Id From Day_Part_Targeting__r)
                  FROM LineItem__c
                  where id =: controller.getId()];
           
            size_selected = li.product__r.Size__c; 
            multisize_selected = li.product__r.multisize__c;       
            
            system.debug('before get conflict map');            
            conflictAdUnitMap = getConflictAdUnitMapFromInventoryTarget(li.id, null);
            system.debug('after get conflict map');
           
        } else {
            li = new LineItem__c();
            li.start_date__c = date.today();
            li.end_date__c = date.today().addDays(2);
        }
                
        if(paramStartDate != null) {
            system.debug('set start date');
            li.start_date__c = date.parse(paramStartDate);
        }
        if(paramEndDate != null) {
            system.debug('set end date');       
            li.end_date__c = date.parse(paramEndDate);
        }
       
        formattedStartDate = li.Start_Date__c.format();
        formattedEndDate = li.End_Date__c.format();
        
        if(controller.getId() != null){
            checkAvailability();
        }
        
        system.debug('end');

    }
    
    private Map<Id,Set<Id>> getConflictAdUnitMapFromInventoryTarget(Id liId, Id productId) {
        Set<Id> adUnitIds = new Set<Id>();
        String query = 'SELECT Ad_Unit__c FROM Inventory_Target__c WHERE ';
        if(liId != null) query += 'LineItem__c =:liId';
        else query += 'Product__c =:productId';
        for(Inventory_Target__c it : Database.query(query)) {
            adUnitIds.add(it.Ad_Unit__c); 
        }     
        Map<Id, Set<Id>> cMap = UtilityAdUnit.getConflictMap(adUnitIds);
        Map<Id, Set<Id>> res = new Map<Id, Set<Id>>();
        res.put(liId != null ? liId : productId, new Set<Id>());
        for(Set<Id> x : cMap.values()) {
            res.get(liId != null ? liId : productId).addAll(x);
        }
        return res;
    }
    
    public ControllerCpdAvailability_test() {  
        this.initPicklistsAndTemplates();   
        this.initController();
    }
    
    private void initPicklistsAndTemplates() {
        
        prodotti = new map<String,list<SelectOption>>();
    	formati = new list<SelectOption>();
   		formati.add(new SelectOption('','--seleziona--'));
        
        
		User Utente = [SELECT Id, Visualizza_prodotti_Network__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		if(Utente.Visualizza_prodotti_Network__c){
        	productsMap = new Map<Id,Product2>([Select Name,Id,Formato__c
                                                    from Product2 
                                                    where delivery_model__c = 'CPD'
                                                    and isActive = true
                                                    and formato__c <> null
                                                    and local__c = false
                                                    and ad_server__c = 'DFP'
                                                    and Family = 'Banner'
                                                ]);
		} else{
        	productsMap = new Map<Id,Product2>([Select Name,Id,Formato__c
                                                    from Product2 
                                                    where delivery_model__c = 'CPD'
                                                    and isActive = true
                                                    and formato__c <> null
                                                    and local__c = false
                                                    and ad_server__c = 'DFP'
                                                    and Family = 'Banner'
                                                    and categoria_libero__c <> 'Network'
                                                    and type__c not in ('NETWORK','AD_EXCHANGE', 'ADSENSE') 
                                                ]);
		}
		if (productsMap != null){
           		for(Product2 p : productsMap.values()){
            		if(!prodotti.containsKey(p.Formato__c)){
               			prodotti.put(p.Formato__c,new list<SelectOption>());
                		prodotti.get(p.Formato__c).add(new SelectOption('','--seleziona--'));   
                		formati.add(new SelectOption(p.Formato__c,p.Formato__c)); 
            		}
            		prodotti.get(p.Formato__c).add(new SelectOption(p.Id,p.Name));
        		} 
		}else{
						prodotti.put('non ci sono formati!',new list<SelectOption>());
                		prodotti.get('non ci sono formati!').add(new SelectOption('','--seleziona--'));   
                		formati.add(new SelectOption('non ci sono formati!','non ci sono formati!'));
		}
		
        formati.sort();
        
       // AccountId = [Select Id from Account where RecordType.Name = 'Brand' and Id_Dfp__c <> null limit 1].Id;
		isRunning = false;
        }
            
    private void initController(){
        conflictAdUnitMap = new Map<Id, Set<Id>>();
        conflictAdUnitMapWithoutLi = new Map<Id, Set<Id>>();
      
        ii = new List<Integer>();
        for(Integer i=0;i<24;i++){
            ii.add(i);
        }        
        slots = new List<CpdSlotListItem>();
        
        //  ad_unit_cpd_selected = adunitscpd.get(0).getValue();
       // canale_primario_selected = '';
       // canale_primario_old_selected = '';
        //tipologia_canale_selected = 'vecchio';
      //  tipologia_canale_selected = 'nuovo';
        // size_selected = 'Total';
    }
    
    public set<lineitem__c> liInConflict {get;set;} //in conflitto ma non bloccanti (perchè li.non_bloccante__c = 'false')
    public set<lineitem__c> liToRelease {get;set;} //li da rilasciare, sono quelli da rilasciare quando si conferma un'opportunità
    public string conflictMessage {get;set;}
    
    public Map<string,boolean> checkAvailabilityLineItem(LineItem__c lineitem){
       conflictMessage = '';
       liInConflict = new set<lineitem__c>();
       liToRelease = new set<lineitem__c>();
       set<id> liToReleaseId = new set<id>();
       this.li = lineItem;
       formattedStartDate = li.Start_Date__c.format();
       formattedEndDate = li.End_Date__c.format();
       size_selected = li.product__r.Size__c;
       multisize_selected = li.product__r.multisize__c;
       
       if(!conflictAdUnitMap.containsKey(li.Id)) {
        conflictAdUnitMap = getConflictAdUnitMapFromInventoryTarget(li.Id, li.Product__c);            
       }
              
       this.checkAvailability();
       boolean conflict = false;
       boolean block = false;
       for(CpdSlotListItem slot : slots){
           system.debug('day: '+slot.dayOfWeek);
           for(CpdSlot s : slot.slots){
               if(s.lisId.contains(li.id)){    //ci sono potenziali conflitti se quel giorno a quell'ora c'è il lineitem di partenza
                   system.debug('h = '+s.h+' slots = '+s.lis+ 'li.bloccante__c = '+li.bloccante__c);
                   double checkGoal = s.confirmedGoal + (li.bloccante__c == 'true' ? 0 : li.goal__c); //se è bloccante l'ho già aggiunto al confirmedGoal
                   if(checkGoal > 100){
                        return exitCheck(true,conflict,'Superato il goal totale per il giorno '+slot.d.day()+'/'+slot.d.month()+'/'+slot.d.year()+' alle ore '+s.h+':00');
                   }
                   for(LineItem__c d : s.lis){                                          
                       if(d.id != li.id){ 
                           conflict = true;
                           system.debug('possibile conflitto tra '+d.id+' e '+li.id+' per il giorno '+slot.d.day()+'/'+slot.d.month()+'/'+slot.d.year()+' alle ore '+s.h+':00');
                           /* //se c'è un errore quello che conta è il goal totale, si possono avere dei conflitti
                           if(d.bloccante__c == 'true'){
                               return exitCheck(true,conflict,'Conflitto con altro lineitem bloccante: <a href="/'+d.id+'">'+d.name_dfp__c+'</a><br />');
                           }else if(d.opportunity__c == lineitem.opportunity__c){
                               return exitCheck(true,conflict,'Conflitto con altro lineitem della stessa opportunità: <a href="/'+d.id+'">'+d.name_dfp__c+'</a><br />');
                           }else{
                               liInConflict.add(d);
                           }*/
                           if(! lineItemsNonBloccanti.contains(d.id)){
                               liInConflict.add(d);
                               
                               if(s.confirmedGoal + (li.bloccante__c == 'true' ? 0 : li.goal__c) + (d.bloccante__c == 'true' ? 0 : d.goal__c) > 100){
                               //Devo rilasciare un lineitem se, una volta chiuso, farebbe superare il goal massimo 
                                    if(!liToReleaseId.contains(d.id)){ //Evito duplicati
                                     liToRelease.add(d); //Usato quando si conferma una campagna.
                                     liToReleaseId.add(d.id);
                  }
                               }
                           }
                       }
                   }
               }
           }
       }
       return exitCheck(block,conflict,'');
    } 
    
    public Map<string,boolean> exitCheck(boolean block,boolean conflict,string message){
        Map<String,boolean> p = new Map<String,Boolean>();
        p.put('conflict', conflict);
        p.put('block', block);
        conflictMessage = message;
        return p;
    }
    

    public void checkAvailability(){
        set<id> conflictAdUnitSet = new set<id>();

        date startdate;
        date enddate;     
        String settoreBrand = '';
        String[] productSizes = new String[]{};

        try {
            startdate = Date.parse(formattedStartDate);
            enddate = Date.parse(formattedEndDate);
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore nell\'inserimento delle date.'));
            return;
        }
 
        if(li.id == null){
            if((ad_unit_cpd_selected == '' || ad_unit_cpd_selected == null)){
                set<id> adUnitCpdSet = new set<id>();            
                for(selectOption so : adunitscpd){
                    if(so.getValue() != ''){
                        adUnitCpdSet.add(so.getValue());
                    }
                }
                Map<id,set<id>> conflictMap = UtilityAdUnit.getConflictMap(adUnitCpdSet);
                for(id aid : conflictMap.keySet()){
                    conflictAdUnitSet.addAll(conflictMap.get(aid));
                }

            } else {
                conflictAdUnitSet = UtilityAdUnit.getConflictMap(new set<id>{(Id) ad_unit_cpd_selected}).get((Id) ad_unit_cpd_selected);
            }
            
        } else {
            conflictAdUnitSet = conflictAdUnitMap.get(li.Id);
            canale_primario_selected = li.product__r.CanalePrimario__c;                                  
            size_selected = li.product__r.Size__c;
            multisize_selected = li.product__r.multisize__c;
            settoreBrand = li.Settore_brand__c;
            if(li.product__r.size__c != 'Multisize') {
                productSizes.add(li.product__r.size__c);
            } else {
                productSizes.addAll(li.product__r.multisize__c.split(';'));
            }
        }
        system.debug('size selected: '+size_selected);
        String queryBase = 'select id,status__c,product__r.categoria_libero__c,product__r.multisize__c,product__r.canale_primario__c,product__r.CanalePrimario__c,product__r.size__c,product__r.fascia_oraria__c,' + 
                          'settore_brand__c,product__r.formato__c,reservationStatus__c,opportunity__r.status__c,goal__c,opportunity__r.Probability,Bloccante__c,' + 
                          'Name_Dfp__c,brand__c,Opportunity__r.isWon,End_Date__c,Start_Date__c,' + 
                          '(Select Id From Day_Part_Targeting__r) '+
                          ' from LineItem__c ';
        if(li.id != null){
            queryBase += ' where id <> \''+li.id+'\'';
        }else{
            queryBase += ' where id <> null ';
        }

        queryBase += ' AND End_Date__c >= : startdate  AND Start_Date__c <= : enddate ';            
        queryBase += ' AND product__r.delivery_model__c = \'CPD\'';
        queryBase += ' AND Id IN (SELECT Lineitem__c FROM Inventory_Target__c WHERE Ad_Unit__c IN : conflictAdUnitSet AND LineItemEndDate__c >= : startdate AND LineItemStartDate__c <= : enddate)';

        string query = queryBase + ' AND ( ( id <> null '; // poi va in AND; 
        string queryTemplateNonBloccanti = queryBase + ' AND ( ( id = null  '; //poi va in OR      

        String filterSize = '';
        /*
        if(!productSizes.isEmpty()) {
            system.debug('size = ' + productSizes);
            for(String s : productSizes) {
                if(filterSize != ''){
                     filterSize += ' OR ';
                }
                filterSize += ' (product__r.size__c = \'' + s + '\' OR product__r.multisize__c INCLUDES (\'' + s + '\'))';
            }
            filterSize = ' AND (' + filterSize + ')';
        } */
        
        query += filterSize;
        if(!isBlank(size_selected) && size_selected != 'Multisize'){
            system.debug('size selected: '+size_selected);
            query += ' AND ( product__r.size__c  = : size_selected OR product__r.multisize__c INCLUDES (\'' + size_selected + '\')) ';
        } else if (size_selected == 'Multisize'){
            query += '';
            Integer i = 1;
            for(String s : multisize_selected.split(';')){
                if (i==1) {             
                    query += ' AND (NOT((NOT(product__r.multisize__c INCLUDES (\'' + s + '\'))) AND((NOT( product__r.size__c = \'' + s + '\')))';
                } else{
                    query += ' AND ((NOT(product__r.multisize__c INCLUDES (\'' + s + '\'))) AND((NOT( product__r.size__c = \'' + s + '\'))))';
                }
                i++;
            }
            query += '))';
        }
        

        query += ' ) ';
        queryTemplateNonBloccanti += ' ) ';

        CPDTemplate__c[] candidatesTemplate = [SELECT
            name,
            size__c,
            Attivo__c,
            Bloccante__c,
            Settore_brand__c 
            FROM CPDTemplate__c 
            WHERE attivo__c = true
            AND (size__c like : '%'+size_selected+'%' or size__c = '*' or size__c = null)                           
            AND (Settore_brand__c like : '%'+settoreBrand+'%' or Settore_brand__c = '*' or Settore_brand__c = null)
        ];
           
        /*Nota:
        per ogni campo un template può avere:
           n valori separati da virgola -> per essere candidato uno di quei valori deve essere quello del lineitem di riferimento.
                                           vanno in conflitto i lineitem che hanno uno di quei valori
           * -> è sempre un template candidato
                vanno in conflitto tutti i lineitem
           vuoto -> è sempre un template candidato
                    vanno in conflitto i lineitem che hanno come valore lo stesso del lineitem di partenza

        */
           
        list<string> filter;
        if(candidatesTemplate.size() > 0){
            for(integer i = 0;i<candidatesTemplate.size();i++){
               
                CPDTemplate__c t = candidatesTemplate.get(i);
              
                string queryTemplate = ' AND ( id <> null ';                                                            
                /*
                if(isblank(t.size__c)){
                    if(!isblank(size_selected) && size_selected !='Multiselect'){
                        queryTemplate += ' AND product__r.size__c = : size_selected ';
                    }
                }else if(t.size__c != '*' && size_selected !='Multiselect'){
                    filter = t.size__c.split(',');
                    queryTemplate += ' AND ( id = null ';
                    for(string s : filter){
                        queryTemplate += ' OR product__r.size__c = \''+s+'\' ';
                    }
                    queryTemplate += ' ) ';
                }
                 */              
                if(isblank(t.Settore_brand__c)){
                    if(!isblank(settoreBrand)){
                        queryTemplate += ' AND settore_brand__c = : settoreBrand';
                    }
                }else if(t.Settore_brand__c != '*'){
                    filter = t.Settore_brand__c.split(',');
                    queryTemplate += ' AND ( id = null ';
                    for(string s : filter){
                        queryTemplate += ' OR Settore_brand__c = \''+s+'\' ';
                    }
                    queryTemplate += ' ) ';
                }
               
                queryTemplate += ' )';
               
                if(t.bloccante__c){
                    query += queryTemplate;
                }else{
                    queryTemplateNonBloccanti += queryTemplate;
                }
            }           
        }
           
        query += ' ) ';
        queryTemplateNonBloccanti += ' ) ';

        system.debug('query '+query);

        Map<Id,LineItem__c> liMap = new Map<Id,LineItem__c>((List<LineItem__c>)Database.query(query));
        if(li.id != null){
            liMap.put(li.id,li);
        }
        set<id> liMapKeys = liMap.keySet();
        queryTemplateNonBloccanti += ' AND id not in : liMapKeys ';

        system.debug('queryTemplateNonBloccanti '+queryTemplateNonBloccanti);

        /*
        system.debug();
        system.debug();
        */

        Map<Id,LineItem__c> liMapNonBloccanti = new Map<Id,LineItem__c>((List<LineItem__c>)Database.query(queryTemplateNonBloccanti));
        list<id> listIdNonBloccanti = new list<id>();
        listIdNonBloccanti.addAll(liMapNonBloccanti.keySet());
        lineItemsNonBloccanti = String.join(listIdNonBloccanti,',');

        List<DayPartTargeting__c> dptList = [select id,dayOfWeek__c,Start_Hour__c,End_Hour__c,LineItem__c
                                            from DayPartTargeting__c 
                                            where LineItem__c in : liMap.keySet() or LineItem__c in : liMapNonBloccanti.keySet()
                                            order by createdDate asc
                                           ];
                                  
        //i lineitem cpd che non hanno dayparttargeting vanno tutto il giorno, li aggiungo qui per visualizzarli
        for(id liid : liMap.keySet() ){
            Lineitem__c li = liMap.get(liid);
            createDpList(li,dptList,startdate,enddate);
        }
        for(id liid : liMapNonBloccanti.keySet() ){
            Lineitem__c li = liMapNonBloccanti.get(liid);
            createDpList(li,dptList,startdate,enddate);
        }
            
        slots = new List<CpdSlotListItem>();
        Date minDate = startdate;//Date.newInstance(li.Start_Date__c.year(),li.Start_Date__c.month(),li.Start_Date__c.day());
        Date maxDate = enddate;//Date.newInstance(li.End_Date__c.year(),li.End_Date__c.month(),li.End_Date__c.day());
        Date d = mindate;//Date.newInstance(li.Start_Date__c.year(),li.Start_Date__c.month(),li.Start_Date__c.day());
        do{
           system.debug(d);
           CpdSlotListItem si = new CpdSlotListItem();
           si.d = d;
           si.dayOfWeek = getDayOfWeek(d);
           si.slots = new List<CpdSlot>();
           si.templates = new list<TemplateCandidate>();
           si.liIds = new set<id>();
           for(CPDTemplate__c t : candidatesTemplate){
                si.templates.add(new TemplateCandidate(t));
           }
           for(Integer i = 0;i < 24;i++){
               CpdSlot slot = new CpdSlot();
               slot.h = i;
               slot.lis = new List<LineItem__c>();
               slot.lisId = new set<id>();
               slot.totalGoal = 0;
               slot.confirmedGoal = 0;
               for(DayPartTargeting__c dp : dptList){
                   system.debug('dp: '+dp);
                   if(dp.dayOfWeek__c == si.dayOfWeek && Integer.valueOf(dp.Start_Hour__c) <= i && Integer.valueOf(dp.End_Hour__c) > i){
                       if(liMap.get(dp.LineItem__c) != null){
                           LineItem__c liTmp = liMap.get(dp.LineItem__c);
                           if(d <= liTmp.End_Date__c && d >= liTmp.Start_Date__c){
                               slot.lis.add(liTmp);
                               slot.lisId.add(liTmp.id);
                               slot.totalGoal += liTmp.goal__c;
                               if(liTmp.Bloccante__c == 'true' || (liTmp.id != li.id && liTmp.Opportunity__c == li.Opportunity__c)) { //se è nella stessa opp è comunque bloccante
                                   slot.confirmedGoal += liTmp.goal__c;
                               }
                               if(! si.liIds.contains(liTmp.id)){
                                   si.liIds.add(liTmp.id);
                                   for(TemplateCandidate tc : si.templates){
                                        if(checkLiTemplate(liTmp,tc.template)){
                                            tc.counter ++;
                                            if(liTmp.bloccante__c == 'true'){
                                                tc.confirmedCounter++;
                                            }
                                        }
                                   }
                               }
                           }
                       }else{ //line item di template non bloccante
                           LineItem__c liTmp = liMapNonBloccanti.get(dp.LineItem__c);
                           system.debug('li non bloccante = '+liTmp.id);
                           if(d <= liTmp.End_Date__c && d >= liTmp.Start_Date__c){
                               slot.lis.add(liTmp);
                               slot.lisId.add(liTmp.id);
                               if(! si.liIds.contains(liTmp.id)){
                                   si.liIds.add(liTmp.id);
                               }
                           }
                       }
                   }
               }
               si.slots.add(slot);
           }
           slots.add(si);
           d=d.addDays(1);
        }while(d <= maxDate);       
        
    }
    
    /*
      checkAvailability for a line item list
      it has bad performance, it should be optimized to reduce statement and query
      return true if there's is avalability
    */
    public static boolean checkAvailabilityLineItems(lineitem__c[] lis){
        String cpdMessage = '';       
        
        Map<Id, Set<Id>> conflictMap = new Map<Id, Set<Id>>();
        set<id> adUnitCPDSet = new set<id>(); 
        Set<Id> liWithInventoryTargetIds = new Set<Id>();
        Set<Id> prodWithInventoryTargetIds = new Set<Id>();
    
        //Costruisco la mappa dei conflitti
        conflictMap = new Map<Id, Set<Id>>();        
        for(lineItem__c li : lis) { 
            if(li.delivery_model__c == 'CPD' && !li.skipDispoCpd__c && li.end_date__c >= date.today() && li.goal__c != null){               
                if(li.Id != null) {
                  conflictMap.put(li.Id, new Set<Id>());
                  liWithInventoryTargetIds.add(li.Id);    
                } else {
                  conflictMap.put(li.product__c, new Set<Id>());
                  prodWithInventoryTargetIds.add(li.Product__c);                  
                }
            }
        }
                
        Inventory_Target__c[] its = [SELECT Id, LineItem__c, Product__c, Ad_Unit__c FROM Inventory_Target__c WHERE LineItem__c IN :liWithInventoryTargetIds OR Product__c IN:prodWithInventoryTargetIds];
        for(Inventory_Target__c it : its) {
            adUnitCPDSet.add(it.Ad_Unit__c);      
        }                        

        Map<Id, Set<Id>> cMap = UtilityAdUnit.getConflictMap(adUnitCPDSet);
    
        for(Inventory_Target__c it: its) {
            conflictMap.get(it.LineItem__c != null ? it.LineItem__c : it.Product__c).addAll(cMap.get(it.Ad_Unit__c));
        }                
        
        ControllerCpdAvailability_test checkCpd = new ControllerCpdAvailability_test();
        for(lineitem__c li : lis){
            if(li.delivery_model__c == 'CPD' && !li.skipDispoCpd__c && li.end_date__c >= date.today() && li.goal__c != null){            
                checkCPD.conflictAdUnitMap = conflictMap;
                Map<String,boolean> checkedCPD = checkCpd.checkAvailabilityLineItem(li);
                if(checkedCPD.get('block')){  
                    cpdMessage += '<a href="/'+li.id+'">'+li.name_dfp__c+'</a><br />';             
                }
            }
        }
        
        if(cpdMessage != ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'CPD in conflitto con altro lineItem.<br />'+cpdMessage));
            return false;               
        }
        
        return true;
    }
    
    public void createDpList(LineItem__c li,List<DayPartTargeting__c> dptList,date startdate,date enddate){
       system.debug(li.Name_Dfp__c + ' -> '+li.opportunity__r.status__c);
       set<string> dplistkey = new set<string>();
       if(li.Day_Part_Targeting__r.isEmpty() || (li.id == this.li.id && this.fasciaOraria != null) ){
           String startH = '0';
           String endH = '24'; 
           
           /*
            Se il line item è quello di cui sto verificando la disponibilità e il campo fasciaOraria non è nullo,
            creo dei dpt finti per quella fascia.
            Devo però eliminare quelli che sono eventualmente salvati
           */
           system.debug('this.fasciaOraria = '+this.fasciaOraria);
           if(li.id == this.li.id && this.fasciaOraria != null){
              
              integer i = 0;
              while(i < dptList.size()){
                if(dptList[i].lineItem__c == this.li.id){
                  dptList.remove(i);
                }else{
                  i++;
                }
              }
              startH = this.fasciaOraria.split('-').get(0).trim();
            endH = this.fasciaOraria.split('-').get(1).trim();
           }
           
           Date min = li.start_date__c < startdate ? startdate : li.start_date__c;
           Date max = li.end_date__c > enddate ? enddate : li.end_date__c;
           for(Date dd = min;dd<=max;dd=dd.addDays(1)){
               DayPartTargeting__c dpt = new DayPartTargeting__c();
               dpt.dayOfWeek__c = getDayOfWeek(dd);
               dpt.Start_Hour__c = startH;
               dpt.End_Hour__c = endH;
               dpt.LineItem__c = li.id;
               string key = dpt.dayOfWeek__c+dpt.Start_Hour__c+dpt.End_Hour__c+dpt.LineItem__c;
               if(!dplistkey.contains(key)){
                   dptList.add(dpt);
                   dplistkey.add(key);
               }
           }
       }
    }
    
    //controlla se un lineitem con un template
    public boolean checkLiTemplate(LineItem__c liToCheck,CPDTemplate__c template){
        boolean res = true;
        res = res && checkField(template.size__c,liToCheck.product__r.size__c,li.product__r.size__c);
        system.debug('after formato: '+res);        
        return res;
    }
    
    public boolean checkField(string templateField,string liToCheckField,string liField){
        //templateField -> campo del template
        //liToCheckField -> campo del lineitem da controllare
        //liField -> campo del lineitem di riferimento
        system.debug('templateField: '+templateField);
        system.debug('liToCheckField: '+liToCheckField);
        system.debug('liField: '+liField);
        boolean res = templateField == '*';
        res = res || ( isblank(templateField) ? liField == liToCheckField : templateField.contains(liToCheckField));
        return res;
    }
        
    public string createStringFromList(List<String> stringList){
        string result = '';
        for(string curVal : stringList){
            result += ',' + curVal;
        }
        if(result.length() > 0){
           //result = result.substring(1,result.length());
            result += ',';
        }
        return result;  
    }
    
    public String getDayOfWeek(Date d){
        Integer i = d.toStartOfWeek().daysBetween(d);
        Map<Integer,String> dayMap = new Map<Integer,String>{
            0 => 'MONDAY',
            1 => 'TUESDAY',
            2 => 'WEDNESDAY',
            3 => 'THURSDAY',
            4 => 'FRIDAY',
            5 => 'SATURDAY',
            6 => 'SUNDAY'
        };
        return dayMap.get(i);
    }
   
    public List<selectOption> getItems(Schema.sObjectField field){
      return getItems(field, true);
    }   
    
    public List<selectOption> getItems(Schema.sObjectField field, Boolean addBlank){
       List<SelectOption> options = new List<SelectOption>();
    
       Schema.DescribeFieldResult fieldResult = field.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         
       if(addBlank) options.add(new SelectOption('', ''));
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));
       }
       return options;
    }
        
    public boolean isBlank(string s){
        return s == '' || s == null;
    }
    
        public void chooseProduct(){
        deleteProduct();
         UtilityTrigger.skipTrigger = true;
       if(opportunity == null){
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Name LIKE '%Test_CPM_availability' AND Tipo_Opportunity__c = 'Test'];
            opportunity = (opp != null && opp.size()>0)  ? opp[0] : null;
        } 
        if(opportunity == null){
            opportunity = new Opportunity(
                Name = 'Test_CPM_availability',
                AccountId = AccountId,
                StageName = '0 %',
                CloseDate = System.today(),
                Commissione_Agenzia__c = 0,
                Tipo_Opportunity__c = 'Test'
            );
            insert opportunity;  
        }
        Set<Id> ids = new Set<Id>();
        if (prodotto_selected != null){
        	ids.add(prodotto_selected);
        	system.debug('@@@prodotto_selected: ' + prodotto_selected);
        	LineItem__c lineItem = ExtensionAddProduct.addProducts(UtilProduct.getProductsByIds(ids),null,opportunity.Id)[0];
       		// lineItem.Ad_Server__c = [SELECT Ad_Server_formula__c FROM LineItem__c WHERE Id = :lineItem.Id].Ad_Server_formula__c;
       		// update lineItem; 
        	lineItem = [ SELECT Id,Product__c,Product__r.Size__c,Product__r.multisize__c
            	        FROM LineItem__c 
                	    WHERE Id = :lineItem.Id
                    	];
		      
       		for(impressions_stimate__c is : [SELECT Adunit__r.path__c FROM impressions_stimate__c WHERE Product__r.Id =: ids ]) {
        	    adunitscpd.add(new SelectOption(is.Adunit__r.Id,is.Adunit__r.path__c));     
        	}                        
	
    		size_selected = lineItem.Product__r.Size__c;
    		multisize_selected = lineItem.Product__r.multisize__c;
    
    
        }
    }

    public void deleteProduct(){
        if(lineItem != null){
            delete lineItem;
            lineItem = null;
        }
        
        adunitscpd.clear();
        size_selected = '';
        multisize_selected ='';
        ad_unit_cpd_selected ='';
    }   
    
}