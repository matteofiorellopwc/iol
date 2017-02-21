public class LineItemTriggerHandler {
    //Se true, viene skippato tutto il trigger del line item
    public static Boolean skipLineItemTrigger = false;
    //Se true, i trigger degli oggetti figli del lineitem non forzano un update del lineitem quando vengono modificati
    public static Boolean skipUpdateLineItem = false;
    //Se true, non controlla che somma revenue = totale lineitem
    public static Boolean skipValidationTotali = false;
    //Se true, non fa in controlli per gli Ad Server (data inizio,data fine,...)
    public static Boolean skipValidationAdServer = false;
        
    public static Revenue_application__c[] raToUpdate = new Revenue_application__c[]{};
    public static Set<Id> lineItemWithAssetToUpdate = new Set<Id>();
    
    //Mappa contenente le opportunità da aggiornare (per far partire i trigger di rollup sull'opp)
    public static Map<Id, Opportunity> oppToUpdate = new Map<Id, Opportunity>();    

    //Mappe e set per la gestione del team targeted
    public static Set<Id> prodsId = new Set<Id>();      
    public static Map<Id, Set<Id>> prodTeamsTargeted = new Map<Id, Set<Id>>();
    public static Map<Id, Set<Id>> oppTeamsTargeted = new Map<Id, Set<Id>>();
    
    /**
     *  Recupera dati aggiuntivi (optional, revenue, dati sul prodotto) dai lineitem coinvolti nel trigger
     */ 
    public static Map<Id, LineItem__c> getLineItemMap() {        
        return new Map<Id, LineItem__c>([SELECT
            Id,
            product__r.ad_server__c,        
            Somma_percentuale_applicata_revenue_appl__c,
            Somma_valore_revenue_application__c,
            (SELECT mese__c,Percentuale_applicata__c,Ticket_Fatturazione__c,Valore__c,
                    Valore_di_commisioning__c,Obiettivo__c,Anno_numero__c,Mese_numero__c,
                    MinorRicavo__c
                from Revenue_applications__r 
                where mese__c <> 'Totale'),
            (SELECT Incremento_calcolato_lineitem_formula__c,id from optionals__r),
            (SELECT Path__c,Ad_Unit__r.name,InventoryTargetingType__c From Inventory_Target__r order by ad_unit__r.level__c)
            from LineItem__c
            where Id in : trigger.new
        ]);
    }


    /*
        Mappe per calcolare il campo Custom Criteria sui Line Item
    */
    public static Map<String,String> customCriteriaMap;
    public static Map<Id,CustomCriteriaSet__c[]> getCustomCriteriaMap(){
        Map<Id,CustomCriteriaSet__c[]> ccMap = new Map<Id,CustomCriteriaSet__c[]>();

        Set<String> criteriaIds = new Set<String>();

        for(CustomCriteriaSet__c ccSet : [select id,logicalOperator__c,LineItem__c,
                                        (Select keyId__c, operator__c, valueIds__c, isAudienceSegment__c ,
                                            Custom_Targeting_Key__r.visual_name__c,values__c
                                        From Custom_Criteria__r
                                        Where Custom_Targeting_Key__r.RollupOnLineItem__c = true) //voglio visualizzare solo alcune chiavi
                                        from CustomCriteriaSet__c
                                        where LineItem__c in : trigger.new]){
 
            if(!ccSet.Custom_Criteria__r.isEmpty()){
                if(!ccMap.containsKey(ccSet.LineItem__c)){
                    ccMap.put(ccSet.LineItem__c,new CustomCriteriaSet__c[]{});
                }
                ccMap.get(ccSet.LineItem__c).add(ccSet);
                for(Custom_Criteria__c cc : ccSet.Custom_Criteria__r){
                    criteriaIds.add(cc.keyId__c+'');
                    criteriaIds.addAll(cc.valueIds__c.split(','));
                }                
            }
        }
        customCriteriaMap = UtilityCustomTargeting.getCustomCriteriaMap(criteriaIds);
        return ccMap;
    }
    

    /*
        Validazioni su date, campi modificabili per evitare errori durante la sincronizzazione con gli ad server    
    
    */
    public static void validationLineItems(){
        if(!LineItemTriggerHandler.skipValidationAdServer){
            Map<id,LineItem__c> newMap = (Map<id,LineItem__c>) Trigger.newMap;
            Map<id,LineItem__c> oldMap = (Map<id,LineItem__c>) Trigger.oldMap;
            for(id i : newMap.keySet()){
                lineitem__c newLi = newMap.get(i);
                lineitem__c oldLi = oldMap.get(i);
                if(!newLi.skipValidationAdServer__c && newLi.ProductFamily__c == 'Banner' && (newLi.ad_server__c == 'DFP' || newLi.ad_server__c == 'OAS')){
                    datetime startDt = DateTime.newInstance(newLi.start_date__c,Time.newInstance(integer.valueOf(newLi.start_hour__c),integer.valueOf(newLi.start_minute__c),0,0));
                    datetime endDt = DateTime.newInstance(newLi.end_date__c,Time.newInstance(integer.valueOf(newLi.end_hour__c),integer.valueOf(newLi.end_minute__c),0,0));
                    datetime oldStartDt = DateTime.newInstance(oldLi.start_date__c,Time.newInstance(integer.valueOf(oldLi.start_hour__c),integer.valueOf(oldLi.start_minute__c),0,0));
        
                    /*
                        Non posso avere data di inizio nel passato se non ho mai sincronizzato
                    */
                    if(
                        //newLi.opportunityWon__c == 1 && 
                        newLi.id_Dfp__c == null &&
                        newLi.id_oas__c == null &&
                        //(newLi.stato_lavorazione_oas__c == 'Da Caricare Pianificazione' || newLi.stato_lavorazione_oas__c == '' || newLi.stato_lavorazione_oas__c == null) &&
                        startDt < system.now()
                    ){
                        newLi.addError('Il line item ' + newLi.name_dfp__c + ' non può avere data di inizio nel passato');
                    }           
                    
                    /*
                        Se il line item è già stato sincronizzato non posso:
                            - modificare la data di inizio e metterla nel passato
                            - modificare la data di inizio se è già partito (quindi vecchia startDt nel passato) e lo stato del li è incompatibile con la modifica
                    */
                    Boolean hasIdDfp = newLi.id_Dfp__c != null && newLi.id_Dfp__c > 0;
                    Boolean hasIdOAS = newLi.id_oas__c != null && newLi.id_oas__c != '';
                    Boolean newStartDateInPast = startDt < system.now();
                    Boolean oldStartDateInPast = oldStartDt < system.now();
                    Boolean dataLiNonModificabile = UtilityLineItemIntegration.statiNonModificabili.contains(newLi.status__c);
                    if(
                        isChanged(i,'dataorainizio__c') && (hasIdDfp || hasIdOAS) &&
                        (
                            newStartDateInPast ||
                            (oldStartDateInPast && (hasIdOAS || dataLiNonModificabile))
                        )
                    ){
                        newLi.addError('Non è possibile cambiare la data di inizio per il line item ' + newLi.name_dfp__c);
                    }
                    
                    /*
                        Se il line item è già stato sincronizzato non posso cambiare la data di fine e metterla nel passato
                    */
                    if(
                        isChanged(i,'dataorafine__c') && 
                        (
                            (newLi.id_Dfp__c > 0) ||
                            (newLi.id_oas__c != null && newLi.id_oas__c != '')
                            //(newLi.stato_lavorazione_oas__c != 'Da Caricare Pianificazione' && newLi.stato_lavorazione_oas__c != '' && newLi.stato_lavorazione_oas__c != null)
                        ) &&
                        endDt < system.now()
                    ){
                        newLi.addError('Non è possibile mettere la data di fine nel passato per il line item ' + newLi.name_dfp__c);
                    }
                    
                    /*
                        Se salvo la prima volta non posso avere la data di inizio nel passato
                    */
                    if(!oldLi.personalizzato__c && newLi.personalizzato__c && startDt < system.now()){
                        newLi.addError('Non è possibile inserire un lineitem nel passato');
                    }
                }
            }
        }
    }
    
    /*
        Non è possibile cacellare Li già lavorati su OAS con data di inizio nel passato
    */
    public class LineItemHandlerException extends exception{}
    public static void checkDeletedLi(LineItem__c[] liDeleted){
        system.debug('checkDeletedLi');
        if(!LineItemTriggerHandler.skipValidationAdServer){
            for(LineItem__c li : liDeleted){
                datetime startDt = DateTime.newInstance(li.start_date__c,Time.newInstance(integer.valueOf(li.start_hour__c),integer.valueOf(li.start_minute__c),0,0));
                //if((li.stato_lavorazione_oas__c != 'Da Caricare Pianificazione' && li.stato_lavorazione_oas__c != '' && li.stato_lavorazione_oas__c != null && startDt < system.now())){
                if(li.id_oas__c != null && li.id_oas__c != '' && startDt < system.now()){
                    if(UtilSkipTrigger.fromTriggerDeleteOpportunity){
                        throw new LineItemHandlerException('Non è possibile eliminare LI già stati lavorati e partiti su OAS: ' + li.name_dfp__c);
                    }else{
                        li.addError('Non è possibile eliminare LI già stati lavorati e partiti su OAS');
                    }
                }
            }
        }
    }
    
    public static boolean isChanged(id liId, string field){
        return Trigger.oldMap.get(liId).get(field) != Trigger.newMap.get(liId).get(field);
    }
    
    /*
        Controlla che la somma delle revenue e la somma delle percentuali sia coerente con il totale.
        li.Incoerenze_revenue_application__c è una formula che fa già i controlli
    */
    public static void validateTotali(LineItem__c[] triggerNew){
        System.debug('LineItemTriggerHandler.skipValidationTotali = '+LineItemTriggerHandler.skipValidationTotali);
        if(!LineItemTriggerHandler.skipValidationTotali){
            for(LineItem__c li : triggerNew){
                //TODO -> fare un controllo più raffinato
                //Se cambia uno dei 3 campi che devono modificare i trafficker, skippo la validazione
                LineItem__c oldLi = (LineItem__c) trigger.oldMap.get(li.Id);
                if(
                    oldLi.Stato_lavorazione_OAS__c != li.Stato_lavorazione_OAS__c
                    || oldLi.Note_Trafficker__c != li.Note_Trafficker__c
                    || oldLi.Trafficker_OAS_picklist__c != li.Trafficker_OAS_picklist__c
                ) continue;             
                
                if(li.Incoerenze_revenue_application__c != '' && li.Incoerenze_revenue_application__c != null){
                    li.addError(li.Incoerenze_revenue_application__c);
                }
                if(li.IncoerenzeRicavi__c != '' && li.IncoerenzeRicavi__c != null){
                    li.addError(li.IncoerenzeRicavi__c);
                }
            }
        }
    }
    
    /*
     *  Calcola valori di rollup sugli optional
     */
    public static void rollupOptionals(LineItem__c li, Map<Id, LineItem__c> lineItemMap){
        li.somma_optionals__c = 0;
        System.debug('OPTIONALS!!! ' + lineItemMap.get(li.id).Optionals__r);
        for(Optional__c o : lineItemMap.get(li.id).Optionals__r){
            li.somma_optionals__c += o.Incremento_calcolato_lineitem_formula__c;
        }
    }

    /*
        scrive 
        - nel campo inventory_target_string__c l'elenco di tutti gli inventory target
        - nel campo AdUnitInclusi__c l'elenco degli ad unit inclusi
        - nel campo AdUnutEsclusi__c l'elenco degli ad unit esclusi
     */
    public static void joinInventoryTarget(LineItem__c li, Map<Id, LineItem__c> lineItemMap){
        string s = '';
        string[] inventoryInclusi = new string[]{};
        string[] inventoryEsclusi = new string[]{};

        for(inventory_target__c iv : lineItemMap.get(li.id).inventory_target__r){
            if(iv.InventoryTargetingType__c == 'targeted'){
                s += '+';
                inventoryInclusi.add(iv.Path__c);
            }else{
                s += '-';
                inventoryEsclusi.add(iv.Path__c);
            }
            s += iv.path__c;
        }
        li.inventory_target_string__c = s.left(255);
        li.AdUnitInclusi__c = String.join(inventoryInclusi, ',').left(5000);
        li.AdUnitEsclusi__c = String.join(inventoryEsclusi, ',').left(5000);
    }

    /*
        popola il campo CustomCriteria__c
    */
    public static void joinCustomCriteria(LineItem__c li, Map<Id, CustomCriteriaSet__c[]> ccMap){
        String[] sets = new String[]{};
        if(ccMap.containsKey(li.id)){
            for(CustomCriteriaSet__c ccs : ccMap.get(li.id)){
                String[] criteria = new String[]{};
                for(Custom_Criteria__c cc : ccs.Custom_Criteria__r){
                    String s = '('+customCriteriaMap.get(cc.keyId__c+'');
                    s += (cc.operator__c == 'IS' ? ' uguale a ' : ' diverso da '); 
                    String[] values = new String[]{};
                    for(String v : cc.valueIds__c.split(',')){
                        values.add(customCriteriaMap.get(v));
                    }
                    s += String.join(values,',') + ')'; 
                    criteria.add(s);
                }
                if(criteria.size() > 0){
                    sets.add('('+String.join(criteria, ' e ')+')');                
                }
            }            
        }
        li.CustomCriteria__c = String.join(sets, ' o ');
    }
     
    public static Ricavo__c[] checkRicavi(LineItem__c li, Map<Id, LineItem__c> lineItemMap){
        Ricavo__c[] ricavi = lineItemMap.get(li.Id).Ricavi__r;
        Set<Date> ricavoDatesSet = new Set<Date>();
        for(Ricavo__c ricavo : ricavi){
            Date d = Date.newInstance(
                Integer.valueOf(ricavo.Anno_numero__c),
                Integer.valueOf(ricavo.Mese_numero__c),
                1
            );
            if(ricavo.Valore__c >= 0){
                if(ricavoDatesSet.contains(d)){
                     li.addError('Ci sono 2 ricavi con la stessa data');
                }                
                ricavoDatesSet.add(d);
            }
        }
        return ricavi;
        
     }
    
    /**
     *  Calcola alcuni valori di rollup sulle revenue, ed effettua delle validazioni
     *  di coerenza dati sulle revenue. Calcola anche i valori delle varie revenues in base ad alcuni
     *  valori presenti sul lineitem
     *
     *  @Return la lista di revenue da aggiornare
     */
     public static Revenue_application__c[] rollupRevenues(LineItem__c li, Map<Id, LineItem__c> lineItemMap) {
        li.Somma_commisioning_revenue_application__c = 0;
        li.Somma_percentuale_applicata_revenue_appl__c = 0;
        li.Somma_valore_revenue_application__c = 0;
        li.SommaRevenueMinorRicavo__c = 0;

        Revenue_application__c[] raL = lineItemMap.get(li.Id).Revenue_applications__r;
        Date ultimaDataFatturazione = null;
        Date primaDataNonFatturata = null;
        Decimal numeroTicket = 0;
        Set<Date> revenueDatesSet = new Set<Date>();
        System.debug('REVENUES!!! ' + raL);
        for(Revenue_application__c ra : raL){
            //Validazione. Controllo che non ci siano più revenue con lo stesso mese e che non ci siano
            //revenue non fatturate prima di una revenue già fatturata                 
            Date d = Date.newInstance(
                Integer.valueOf(ra.Anno_numero__c),
                Integer.valueOf(ra.Mese_numero__c),
                1
            );

			system.debug('rollupRevenues id:'+ra.id+' primaDataNonFatturata '+	primaDataNonFatturata+ ' ultimaDataFatturazione '+ultimaDataFatturazione + ' ra.Valore__c '+ra.Valore__c+ ' data rev '+d+' ra.Ticket_Fatturazione__c '+ra.Ticket_Fatturazione__c);
			


            if(ra.Ticket_Fatturazione__c != null) {
                numeroTicket++;                                     
                if(ultimaDataFatturazione == null) ultimaDataFatturazione = d;
                else if(ultimaDataFatturazione < d) {
                	ultimaDataFatturazione = d;
                }
            } else if(ra.Valore__c != 0) {
                if(primaDataNonFatturata == null) primaDataNonFatturata = d;
                else if(primaDataNonFatturata > d) primaDataNonFatturata = d;                   
            }
            /*
                TODO aggiungere controllo solo per revenue positive
                if(revenueDatesSet.contains(d)) li.addError('Ci sono 2 revenue con la stessa data');                
            */
            revenueDatesSet.add(d);
            
            //Calcolo valore e valore commissioning
            /* TODO Fare test e cancellare queste righe
            if(!ra.Obiettivo__c && ra.Ticket_Fatturazione__c == null) {
                ra.Valore__c = ra.Percentuale_applicata__c * li.Totale__c / 100;
                ra.Valore_di_commisioning__c = ra.Percentuale_applicata__c * li.Valore_commisioning_agenzia_territoriale__c / 100;
            }
            */
        
            //li.Somma_commisioning_revenue_application__c += ra.Valore_di_commisioning__c != null ? ra.Valore_di_commisioning__c : 0;

            if(ra.MinorRicavo__c){
                li.SommaRevenueMinorRicavo__c += ra.Valore__c != null ? ra.Valore__c : 0;
                if(ra.Valore__c > 0){
                    li.addError('Il valore di un minor ricavo non può essere positivo');
                } 
            }else{
                li.Somma_percentuale_applicata_revenue_appl__c += ra.Percentuale_applicata__c != null ? ra.Percentuale_applicata__c : 0;
                li.Somma_valore_revenue_application__c += ra.Valore__c != null ? ra.Valore__c : 0;
                if(ra.Valore__c < 0 || ra.Percentuale_applicata__c < 0){
                    li.addError('Non si possono avere valori negativi');
                }
            }
            
            if(primaDataNonFatturata < ultimaDataFatturazione) {
        		system.debug('rollupRevenues ERRORE ra item id:'+ra.id+' primaDataNonFatturata '+	primaDataNonFatturata+ ' ultimaDataFatturazione '+ultimaDataFatturazione + ' ra.Valore__c '+ra.Valore__c+ ' data rev '+d+' ra.Ticket_Fatturazione__c'+ra.Ticket_Fatturazione__c);
            }
            
            
        }
        
        li.numeroRevenueFatturate__c = numeroTicket;
        if(primaDataNonFatturata < ultimaDataFatturazione) {
        	system.debug('rollupRevenues Non può esserci una revenue non fatturata antecedente a una revenue fatturata');
        	li.addError('Non può esserci una revenue non fatturata antecedente a una revenue fatturata');            
        }
        return raL;                     
    }
     
    /**
     *  Equivalente di un fieldupdate su adserver e codice sfdc
     */
    public static void updateFieldsFromFormula(LineItem__c[] triggerNew) {
        for(LineItem__c li : triggerNew) {
            updateFieldsFromFormula(li);
        }     
    }
    
    public static void updateFieldsFromFormula(LineItem__c li) { 
        if(li.ad_Server__c == null) li.ad_server__c = li.ad_server_formula__c;
        if(li.CodiceSfdc__c == null) li.CodiceSfdc__c = li.name;
        if(li.CanalePrimarioProdotto__c == null) li.CanalePrimarioProdotto__c = li.CanalePrimarioProdottoFormula__c;
    }
    
    /**
     *  Controlla se nel lineitem sono stati cambiati dei valori che richiedono un aggiornamento degli asset
     */
    public static Boolean hasToUpdateAsset(LineItem__c li, LineItem__c oldLi) {
        return oldLi.Start_Date__c != li.Start_Date__c || oldLi.End_Date__c != li.End_Date__c;
    }

    /**
     *  Inizializzazione e inserimento dei teamtargeted legati ai lineitem
     */
    public static void insertTeamTargeted(LineItem__c[] triggerNew) {
        for(TeamTargeted__c tt : [SELECT
            Id,
            Opportunity__c,
            Product__c,
            Team__c
            FROM TeamTargeted__c
            WHERE Opportunity__c IN :oppToUpdate.keySet()
            OR Product__c in : prodsId
        ]){
            if(tt.Opportunity__c != null) {
                oppTeamsTargeted.get(tt.Opportunity__c).add(tt.Team__c);
            } else {
                prodTeamsTargeted.get(tt.Product__c).add(tt.Team__c);
            }
        }

        TeamTargeted__c[] teamTargetedToInsert = new TeamTargeted__c[]{};
        for(lineitem__c li : triggerNew){
            for(Id i : prodTeamsTargeted.get(li.product__c)){
                if(!oppTeamsTargeted.get(li.opportunity__c).contains(i)){
                    TeamTargetedToInsert.add(new TeamTargeted__c(
                        Team__c = i,
                        Opportunity__c = li.opportunity__c
                    ));
                    oppTeamsTargeted.get(li.opportunity__c).add(i);
                }
            }
        }
        insert teamTargetedToInsert;        
     }
     
     /**    
      *  Spedisce le mail di modifica e cancellazione lineitem se il prodotto è di tipo OAS
      */
     public static void sendOASEmails() {
        if((Trigger.isDelete && Trigger.isBefore && !UtilSkipTrigger.fromTriggerDeleteOpportunity) || (Trigger.isUpdate && Trigger.isAfter)){
            Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
        
            Id TargetObjectId;
            String[] ccEmails = new String[]{};

            try{
                Contact c = UtilNotificheOAS.oasContact;
                TargetObjectId = c.id;
                if(c.Email_in_cc__c != null) {
                    ccEmails = c.Email_in_cc__c.split(',');
                }
            }catch(exception e){
                TargetObjectId = [select id from user where email = 'libero@telnext.com'].id;
            }
            
            EmailTemplate tempIns = UtilNotificheOAS.oasTemplates.get('Notifica_aggiunta_LineItem_OAS');
            EmailTemplate tempDel = UtilNotificheOAS.oasTemplates.get('Notifica_eliminazione_LineItem_OAS');        
                        
            if(Trigger.isDelete ){
                for(SObject liObj : trigger.old){
                    LineItem__c li = (LineItem__c) liObj;
                    if(li.ad_server__c == 'OAS' && li.stato_lavorazione_oas__c != '' && li.stato_lavorazione_oas__c != null && li.Personalizzato__c) {
                        emails.add(UtilNotificheOAS.getMessage(tempDel.id,TargetObjectId ,li.id));
                    }
                }
            }
            
            if(Trigger.isUpdate){
                for(SObject liObj : trigger.new){
                    LineItem__c li = (LineItem__c) liObj;
                    if(li.ad_server__c == 'OAS' && li.opportunityWon__c == 1 && li.personalizzato__c == true && ((LineItem__c)trigger.oldmap.get(li.id)).personalizzato__c == false){
                        emails.add(UtilNotificheOAS.getMessage(tempIns.id,TargetObjectId ,li.id));
                    }else if(UtilNotificheOAS.isChagendLineItem((LineItem__c)Trigger.OldMap.get(li.Id),li) && li.ad_server__c == 'OAS' && li.opportunityWon__c == 1){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(TargetObjectId);
                        mail.setSubject('Line Item modificato: '+ li.name);
                        mail.setHtmlBody(UtilNotificheOAS.getBodyModificaLineItem((LineItem__c)Trigger.oldMap.get(li.Id),li));
                        emails.add(mail);
                    }
                }
            }
            UtilNotificheOAS.sendEmails(emails,ccEmails);
            
            //se riutilizzo il trigger.old dopo l'invio mail i dati ci sono ancora se no manda mail senza dati!!!
            if(Trigger.isDelete){
                for(SObject o : Trigger.old){
                    system.debug('oo'+o.id);
                }
            }            
        }
            
     }
     
     
    //save ids in pacchetto combo opportunity trigger before delete
    public static set<id> pacchettiDeleting = new set<id>();
    
    public static void deleteLineItemChilds() {
        SkipUpdateLineItem = true;

        for(SObject liObj : trigger.old) {
            LineItem__c li = (LineItem__c) liObj;
            if(li.Pacchetto_Combo_Opportunity__c != null && !pacchettiDeleting.contains(li.Pacchetto_Combo_Opportunity__c)){
                //Posso eliminare un lineitem contenuto in un pacchetto solo se elimino tutto il pacchetto
                li.addError('Non si può eliminare un lineitem contenuto in un pacchetto');
            }
        }
        
        Set<Id> deletedLineItemIds = Trigger.oldMap.keySet();
    
        LineItem__c[] deletedLineItem = [SELECT
            Id,
            (SELECT id FROM Day_Part_Targeting__r),
            (SELECT id FROM Frequency_Caps__r),
            (SELECT id FROM Inventory_Target__r),
            (SELECT id FROM Technology_Targeting__r),
            (SELECT id FROM Custom_Criteria_Set__r),
            (SELECT id FROM Optionals__r),
            //(select id from Opportunity_Product__r),
            (SELECT id FROM PlacementTargeting__r),
            (SELECT id FROM Geography__r),
            (SELECT id FROM revenue_applications__r),
            (SELECT id FROM appliedlabel__r),
            (SELECT id FROM CookieSearchTermsOASTargeted__r),
            (SELECT id FROM SectionsOasTargeted__r),
            (SELECT id FROM RicaviRipianificati__r)
            FROM LineItem__c
            WHERE id in :deletedLineItemIds
        ];
                                                                                            
        FrequencyCap__c[] fCaps = new FrequencyCap__c[]{};
        DayPartTargeting__c[] dayPart = new DayPartTargeting__c[]{};
        Inventory_Target__c[] inventory = new Inventory_Target__c[]{};
        TechnologyTargeting__c[] techno = new TechnologyTargeting__c[]{};
        CustomCriteriaSet__c[] criteriaSet = new CustomCriteriaSet__c[]{};
        Optional__c[] optionals = new Optional__c[]{};
        PlacementTargeting__c[] placements = new PlacementTargeting__c[]{};
        //List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        Revenue_application__c[] ras = new Revenue_application__c[]{};
        Geography__c [] geos = new Geography__c[]{};
        AppliedLabel__c[] als = new AppliedLabel__c[]{};
        CookieSearchOasTargeted__c[] csots = new CookieSearchOasTargeted__c[]{};
        SectionOasTargeted__c[] sots = new SectionOasTargeted__c[]{};
        Ricavo__c[] ricaviRipianificati = new Ricavo__c[]{};
    
        for(LineItem__c li : deletedLineItem) {
            fCaps.addAll(li.Frequency_Caps__r);
            dayPart.addAll(li.Day_Part_Targeting__r);
            inventory.addAll(li.Inventory_Target__r);
            techno.addAll(li.Technology_Targeting__r);
            criteriaSet.addAll(li.Custom_Criteria_Set__r);
            optionals.addAll(li.Optionals__r);
            placements.addAll(li.PlacementTargeting__r);
            //olis.addAll(li.Opportunity_Product__r);
            ras.addAll(li.revenue_applications__r);
            als.addAll(li.appliedLabel__r);
            csots.addAll(li.CookieSearchTermsOASTargeted__r);
            sots.addAll(li.SectionsOasTargeted__r);
            ricaviRipianificati.addAll(li.RicaviRipianificati__r);
            geos.addAll(li.Geography__r);
        }
        
        delete fCaps;
        delete dayPart;
        delete inventory;
        delete techno;
        delete criteriaSet;
        delete optionals;
        delete placements;
        //delete olis;
        delete ras;
        delete als;
        delete csots;
        delete sots;  
        delete ricaviRipianificati;
        delete geos;
        //ExtensionEditLineItemNew.printLimits('after delete lineitem childs');          
    }
     
    /**
    *    Metodo che recupera tutti i lineitem collegati ad un oggettino figlio,
     *   in alcuni casi deve settare Bacino_modificato__c = true 
     */ 
    public static LineItem__c[] getLineItems() {
        return getLineItems(false);
    }
    public static LineItem__c[] getLineItems(boolean setBacinoModificato) {
        //Usato solo nei trigger degli oggettini figli del lineitem. In questo caso non voglio fare la validazione delle revenue
        LineItemTriggerHandler.skipValidationTotali = true;       
        Set<Id> lineItemsId = new Set<Id>();
        if(trigger.isInsert || trigger.isUpdate){
            for(sobject so : trigger.new){
                try {
                    lineItemsId.add((id)so.get('line_item__c'));
                } catch(exception e){}
                try {
                    lineItemsId.add((id)so.get('lineitem__c'));
                } catch(exception e){}
            }
        }        
        if(trigger.isDelete){
            for(sobject so : trigger.old){
                try {
                    lineItemsId.add((id)so.get('line_item__c'));
                } catch(exception e){}
                try { 
                    lineItemsId.add((id)so.get('lineitem__c'));
                } catch(exception e){}
            }
        }
    
        LineItem__c[] lis = [SELECT Id,Bacino_modificato__c from LineItem__c WHERE Id in :lineItemsId];

        if(setBacinoModificato){
            for(LineItem__c li : lis){
                li.Bacino_modificato__c = true;
            }
        }

        return lis;
    }        
}