public class extensionCloneOpportunity{
    public opportunity opp {get;set;}
    public list<LineItem> lineitems {get;set;}
    public list<LineItem> lineitemsWithoutPcp {get;set;}
    public boolean hasPack {get;set;}
    public static FattoreCorrettivoFasceOrarie__c fatt = FattoreCorrettivoFasceOrarie__c.getInstance('default');
    
    id oppId;
    id newOppId;
    string oppStatus;
    
    public class cloneException extends exception{ }
    
    public class LineItem{
        public lineitem__c li {get;set;}
        public boolean checked {get;set;}
    }
    
    public extensionCloneOpportunity(ApexPages.StandardController controller){      
        oppId = controller.getId();
        oppStatus = ((opportunity) controller.getRecord()).status__c;
        hasPack = false;//!([select id from Pacchetto_Combo_Opportunity__c where opportunity__c =: oppId].isEmpty());
        hasError = false;
        opp = database.query(Util.getFieldsSOQL('Opportunity', ' id = \''+oppId+'\' ', false, '',true));
        opp = opp.clone(false,true,false,false);
        opp.name = '';
        opp.id_dfp__c = null;
        opp.id_oas__c = null;
        opp.Ultima_sincronizzazione_DFP__c = null;
        opp.Ultima_sincronizzazione_OAS__c = null;
        opp.allowOverbook__c = false;
        opp.stageName = '0 %';
        opp.probability = 0;
        opp.status__c = 'DRAFT';
        opp.status_oas__c = 'P';
        opp.Approvata_commercialmente__c = false;
        opp.data_ultima_riapertura__c = null;
        opp.HiddenValidation__c = false;
        opp.SkipDispoCPD__c = false;
        opp.Check_amministrativo__c = false;
        opp.Escludi_da_fatt_auto__c = false;

        // DEPLOY decommentare riga opp.OverbookApprovato__c = false;

        opp.DataPrimaChiusaVinta__c = null;
        opp.OwnerBrandHistory__c = null;
        opp.OwnerCMHistory__c = null;
        opp.AgenziaTerritorialeHistory__c = null;
        
        lineitems = new list<lineItem>();
        lineitemsWithoutPcp = new LineItem[]{};
        for(lineitem__c lic : UtilityLineItemIntegration.getLineItemsByOppId(oppId,false)){
            lineitem li = new lineitem();
            li.checked = false;
            li.li = lic;
            lineitems.add(li);
            if(li.li.Pacchetto_Combo_Prodotto__c == null) lineitemsWithoutPcp.add(li); 
        }
    }
    
    public PageReference cloneLineItems(){
        Savepoint sp = Database.setSavepoint();
        try{
                    
            list<lineitem__c> lineItemListInit = new list<lineitem__c>();
            for(lineitem li : lineitemsWithoutPcp){
                if(li.checked){
                    lineItemListInit.add(li.li);
                }
            }
            list<lineitem__c> lineitemList = lineItemListInit.deepclone(false,false,false);
            
            cloneLineItems(lineItemListInit,lineitemList,oppId,oppStatus);
            
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore: '+e.getMessage()));
            Database.rollback(sp);
            opp = opp.clone(false, true, false, false);
            return null;
        }
        return new pageReference('/'+oppId);
    }
    
    public PageREference cloneOpp(){
        hasError = false;
        pacchettiCounter = 0;
        
        Savepoint sp = Database.setSavepoint();
        try{
            insert opp;
            newOppId = opp.Id;
            
            list<lineitem__c> lineItemListInit = UtilityLineItemIntegration.getLineItemsByOppId(oppId,false);
            list<lineitem__c> lineitemList = lineItemListInit.deepclone(false,false,false);
            
            Map<Id, LineItem__c> old2newLiMap = cloneLineItems(lineItemListInit,lineitemList,opp.Id,opp.status__c);
                        
            Pacchetto_Combo_Opportunity__c[] pcoInit = database.query(Util.getFieldsSOQL('Pacchetto_Combo_Opportunity__c', ' Opportunity__c = \''+oppid+'\' ', false, 'PacchettoCombo__r.isActive__c, PacchettoCombo__r.Totale__c, PacchettoCombo__r.Sconto_applicabile__c',true)); //[SELECT Id, PacchettoCombo__c, PacchettoCombo__r.isActive__c FROM Pacchetto_Combo_Opportunity__c WHERE Opportunity__c = :oppId];
            Pacchetto_Combo_Opportunity__c[] pco = pcoInit.deepClone(false,false,false);
            LineItem__c[] lineItemPacchetti = [SELECT Id, Pacchetto_Combo_Prodotto__c, Pacchetto_Combo_Opportunity__c, Pacchetto_Combo_Prodotto__r.PacchettoCombo__c FROM LineItem__c WHERE Opportunity__c = :oppId AND Pacchetto_Combo_Prodotto__c <> NULL];
                        
            prepareClonePacchetti(pcoInit, pco, lineItemPacchetti, old2newLiMap, opp.Id, oppId, opp.Commissione_Agenzia__c);
            if(newPacchetti == null || newPacchetti.isEmpty()) return new PageReference('/'+opp.id);
            else return null;                       
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore:'+e.getMessage()));
            Database.rollback(sp);
            opp = opp.clone(false, true, false, false);
            hasError = true;
            return null;
        }
        return new PageReference('/'+opp.id);
    }
    
    Integer pacchettiCounter = 0;
    Pacchetto_Combo_Opportunity__c[] newPacchetti;
    
    public Boolean hasNextPacchetto {get{
        if(newPacchetti == null || pacchettiCounter >= newPacchetti.size()) return false;
        return true;
    }}
    
    public Boolean hasError {get;private set;}
    private Boolean cloningPacchetto {get;private set;}
    
    public Pacchetto_Combo_Opportunity__c nextPacchetto {get {
        if(newPacchetti == null || pacchettiCounter >= newPacchetti.size()) return null;
        else return newPacchetti[pacchettiCounter++];
    }}
               
    public PageReference prepareClonePacchetti(Pacchetto_Combo_Opportunity__c[] pcoInit, Pacchetto_Combo_Opportunity__c[] pco, LineItem__c[] lineItems, Map<Id, LineItem__c> old2newLiMap, id oppId, id oldOppId, decimal commissione) {
        list<id> pacchettiIds = new list<id>();
        for(Pacchetto_Combo_Opportunity__c p : pcoInit){
            pacchettiIds.add(p.PacchettoCombo__c);
        }
        
        //Check1 - Is pacchetto active?        
        for(Integer i = 0; i < pcoInit.size(); i++) {
            Pacchetto_Combo_Opportunity__c p = pco.get(i);
            if(!p.PacchettoCombo__r.isActive__c) {
                throw new cloneException('Non è possibile clonare pacchetti disattivati');
            }
        }   
        
        //Check2 - Pacchetto has been modified?
        Map<Id, Set<Id>> pacchetto2prodottiMap = new Map<Id, Set<Id>>();
        for(Pacchetto_Combo_Prodotto__c pcp : [SELECT Id, PacchettoCombo__c, Product__r.Id FROM Pacchetto_Combo_Prodotto__c WHERE PacchettoCombo__c IN :pacchettiIds]) {
            if(!pacchetto2prodottiMap.containsKey(pcp.PacchettoCombo__c)) pacchetto2prodottiMap.put(pcp.PacchettoCombo__c, new Set<Id>());
            pacchetto2prodottiMap.get(pcp.PacchettoCombo__c).add(pcp.Id);
        }

        Map<Id, Set<Id>> pacchetto2lineitemsMap = new Map<Id, Set<Id>>();       
        for(LineItem__c l : lineItems) {            
            if(l.Pacchetto_Combo_Prodotto__r.PacchettoCombo__c != null) {
                if(!pacchetto2lineitemsMap.containsKey(l.Pacchetto_Combo_Prodotto__r.PacchettoCombo__c)) {
                    pacchetto2lineitemsMap.put(l.Pacchetto_Combo_Prodotto__r.PacchettoCombo__c, new Set<Id>());
                }
                pacchetto2lineitemsMap.get(l.Pacchetto_Combo_Prodotto__r.PacchettoCombo__c).add(l.Pacchetto_Combo_Prodotto__c);                             
            }           
        }        

        for(Id pacchettoId : pacchettiIds) {
            if(pacchetto2prodottiMap.get(pacchettoId).size() != pacchetto2lineitemsMap.get(pacchettoId).size())
                throw new cloneException('Non è possibile clonare pacchetti modificati');
        }
                    
        //Execute clone of pacchetto combo opportunity
        map<id,Pacchetto_Combo_Opportunity__c> Old2NewPcoMap = new map<id,Pacchetto_Combo_Opportunity__c>();
        for(Integer i = 0; i < pco.size(); i++) {
            Pacchetto_Combo_Opportunity__c p = pco.get(i);
            old2newPcoMap.put(pcoInit.get(i).Id, p);
            p.Opportunity__c = oppId;
            p.PacchettoCombo__c = pcoInit.get(i).PacchettoCombo__c;
        }   
        
        insert pco;
        
        //Link lineitem and pacchetto
        Map<Id, LineItem__c> oldLiMap = new Map<Id,LineItem__c>(lineItems);
        
        Set<Id> pacchettiComboIds = new Set<Id>();
        for(Id oldLiId : oldLiMap.keySet()) {
            LineItem__c oldLi = oldLiMap.get(oldLiId);
            if(oldLi.Pacchetto_Combo_Prodotto__c != null) {
                pacchettiComboIds.add(oldLi.Pacchetto_Combo_Prodotto__c);
            }
        }
        Map<Id, Pacchetto_Combo_Prodotto__c> pacchettiProdotto = new Map<Id, Pacchetto_Combo_Prodotto__c>([SELECT Listino__c, Modificabile_in_line_item__c, Quantita__c, Goal__c, Start_date__c, End_date__c, Fascia_oraria__c, Tipo_Tariffa__c FROM Pacchetto_Combo_Prodotto__c WHERE Id IN :pacchettiComboIds]);      
    
        for(Id oldLiId : oldLiMap.keySet()) {
            System.debug('NEW LI ID ' + old2newLiMap.get(oldLiId).Id);
            LineItem__c newLi = old2newLiMap.get(oldLiId);
            if(newLi != null) {
                LineItem__c oldLi = oldLiMap.get(oldLiId);
                Boolean hasNewPCO = old2newPcoMap.containsKey(oldLi.Pacchetto_Combo_Opportunity__c);
                
                System.debug('LINKING ');
                System.debug(newLi);
                System.debug(oldLi);                
                System.debug(hasNewPCO);
                            
                newLi.Pacchetto_Combo_Opportunity__c = (hasNewPCO ? old2newPcoMap.get(oldLi.Pacchetto_Combo_Opportunity__c).Id : null);
                newLi.Pacchetto_Combo_Prodotto__c = oldLi.Pacchetto_Combo_Prodotto__c;
                //newLi.prezzo_listino__c = pacchettiProdotto.get(oldLi.Pacchetto_Combo_Prodotto__c).Listino__c / (1 - commissione/100);
                Pacchetto_Combo_Prodotto__c pcp  = pacchettiProdotto.get(oldLi.Pacchetto_Combo_Prodotto__c);
                Set<String> modificabileInLineitem = new Set<String>();
                if(pcp.Modificabile_in_line_item__c != null && pcp.Modificabile_in_line_item__c != '') {
                    modificabileInLineitem.addAll(pcp.Modificabile_in_line_item__c.split(';')); 
                }
                
                if(!modificabileInLineitem.contains('Date')) {
                    newLi.start_date__c = pcp.Start_Date__c;
                    newLi.end_date__c = pcp.End_Date__c;
                }
                
                if(!modificabileInLineItem.contains('Quantità')) {
                    newLi.Quantita__c = pcp.Quantita__c;
                }
                
                if(!modificabileInLineItem.contains('Goal')) {
                    newLi.Goal__c = pcp.Goal__c;    
                }

                if(!modificabileInLineItem.contains('Fascia oraria')) {
                    newLi.Fascia_oraria__c = pcp.Fascia_oraria__c;
                }

                if(!modificabileInLineItem.contains('Tariffa Festiva/Feriale')) {
                    newLi.TipoTariffa__c = pcp.Tipo_tariffa__c;
                }
            }
        }
        
        LineItemTriggerHandler.skipValidationTotali = true;
        update old2newLiMap.values();
        
        //Revenue_application_pacchetto__c[] rapToInsert = new Revenue_application_pacchetto__c[]{};
                        
        //for(Revenue_application_pacchetto__c rap : database.query(Util.getFieldsSOQL('Revenue_application_pacchetto__c', ' Pacchetto_Combo_Opportunity__r.Opportunity__c = \''+oldOppId+'\' ', false, '',true))) {
        //    Revenue_application_pacchetto__c newRap = rap.clone(false, true, false, false);
        //    newRap.Pacchetto_Combo_Opportunity__c = old2newPcoMap.get(rap.Pacchetto_Combo_Opportunity__c).Id;
        //    rapToInsert.add(newRap);
        //}               
        
        //insert rapToInsert; 
        
        newPacchetti = old2newPcoMap.values();
            
        return null;        
    }
        
    public PageReference clonePacchetto() {
        if(cloningPacchetto != null && cloningPacchetto) return null;
        cloningPacchetto = true;
        try {
            ExtensionEditPacchettoOpportunity eepo = new ExtensionEditPacchettoOpportunity(new ApexPages.Standardcontroller(nextPacchetto));
            eepo.updateCalc();
            LineItemTriggerHandler.skipValidationTotali = true;
            eepo.customSave(false, false);
            //if(pacchettiCounter == 1) throw new CloneException('test error');
            if(hasNextPacchetto) return null;
            else return new pageReference('/'+newOppId);
        } catch(CloneException e) {
            //Rollback. Elimino tutta l'opportunità
            delete opp;
            opp = opp.clone(false,true,false,false);
            newPacchetti = null;
            hasError = true;
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;            
        } finally {
            cloningPacchetto = false;
        }
    }
    
    
/*    public PageReference clonePacchetti(Pacchetto_Combo_Opportunity__c[] pcoInit, Pacchetto_Combo_Opportunity__c[] pco, LineItem__c[] lineItems, Map<Id, LineItem__c> old2newLiMap, id oppId, id oldOppId, decimal commissione) {     
        
                
        //Fix revenues and total on lineitems and pacchetti
        for(Pacchetto_Combo_Opportunity__c p : Old2NewPcoMap.values()) {
            ExtensionEditPacchettoOpportunity eepo = new ExtensionEditPacchettoOpportunity(new ApexPages.Standardcontroller(p));
            eepo.updateCalc();
            eepo.customSave();
        }       
    }*/
    
    public static Map<Id, LineItem__c> cloneLineItems(list<lineitem__c> lineItemListInit,list<lineitem__c> lineitemList,id oppId,string oppStatus){
        LineItemTriggerHandler.skipValidationAdServer = true;

        map<id,LineItem__c> OldNewIdMap = new map<id,LineItem__c>(); // map.put(oldid,newid);

        set<id> productIds = new set<id>();
        for(lineitem__c li : lineitemList){
            productIds.add(li.product__c);
        }
        
        Map<Id, Product2> pMap = new Map<Id, Product2>(UtilProduct.getProductsByIds(productIds));
        
        for(integer i=0;i<lineItemList.size();i++){
            lineitem__c li = lineItemList.get(i);
            if(!li.product__r.isActive){
                throw new cloneException('Non è possibile clonare line item di prodotti disattivati');
            }
            if(li.nonIntegratoAdServer__c){
                throw new cloneException('Non è possibile clonare Banner non integrati con Ad Server');
            }
            li.opportunity__c = oppId;
                        
            li.CalcolaCPDconImpStimate__c = lineItemListInit.get(i).product__r.CalcolaCPDconImprStimate__c;                        
            if(li.Delivery_Model__c == 'CPD' && li.CalcolaCPDconImpStimate__c) {
                try{    
                    Id adunitId = null;            
                    if(pMap.get(li.Product__c) != null && pMap.get(li.Product__c).Inventory_Target__r.size() == 1) {
                        adunitId = pMap.get(li.Product__c).Inventory_Target__r[0].Ad_Unit__c;
                    } else if(li.Inventory_Target__r.size() == 1) {
                        adunitId = li.Inventory_Target__r[0].Ad_Unit__c;
                    } else throw new CloneException('');
                    
                    Impressions_Stimate__c is = [SELECT AdUnit__c, Feriali__c, Festive__c, Attivo__c, AdUnit__r.Path__c, AdUnit__r.Level__c 
                                     FROM Impressions_Stimate__c
                                     WHERE Product__c = : li.product__c
                                     AND AdUnit__c =: adunitId 
                                     AND Attivo__c = true];
                    li.ImpressionsStimateFeriali__c = is.feriali__c;
                    li.ImpressionsStimateFestive__c = is.festive__c;
                }catch(exception e){                    
                    throw new cloneException(e.getMessage());//'Impossibile trovare le impressions stimate');
                }
            }

            li.Impressions_unitarie_stimate__c = lineItemListInit.get(i).product__r.Impressions_stimate__c;
            li.Fattore_correttivo_fascia_0_12__c =  fatt.Fattore_correttivo_fascia_0_12__c;
            li.Fattore_correttivo_fascia_12_16__c = fatt.Fattore_correttivo_fascia_12_16__c;
            li.Fattore_correttivo_fascia_16_24__c = fatt.Fattore_correttivo_fascia_16_24__c;  
            if(li.Pacchetto_Combo_Prodotto__c == null) {
                li.Prezzo_listino__c = lineItemListInit.get(i).product__r.BasePrice__c;
            }
            li.priority__c = lineItemListInit.get(i).product__r.Priority__c;
            li.priority_oas__c = lineItemListInit.get(i).product__r.Priority_oas__c;
            li.Multisize__c = lineItemListInit.get(i).product__r.Multisize__c;
            
            system.debug('li.Prezzo_listino__c = '+li.Prezzo_listino__c);
            li.Breakeven_cost__c = lineItemListInit.get(i).product__r.Breakeven_cost__c; 
            if(oppStatus == 'APPROVED'){
                li.Status__c = 'NEEDS_CREATIVES';
                li.reservationstatus__c = 'RESERVED';
            }else{
                li.Status__c = 'DRAFT';
                li.reservationstatus__c = 'UNRESERVED';            
            }
            
            if(pMap.containsKey(li.Product__c) && !pMap.get(li.Product__c).Day_Part_Targeting__r.isEmpty()) {
                li.Day_Part_Targeting_Type__c = pMap.get(li.Product__c).Day_Part_Targeting_Type__c;
            }            
            
            li.clicksDelivered__c = 0;
            li.impressionsDelivered__c = 0;
            li.stato_lavorazione_oas__c = null;
            li.Trafficker_OAS_picklist__c = null;
            li.Ultima_modifica_campi_OAS__c = null;
            li.Note_Trafficker__c = null;
            li.id_dfp__c = null;
            li.id_oas__c = null;
            li.ad_Server__c = null;
            li.skipDispoCpd__c = false;
            li.skipValidationAdServer__c = false;
            li.Line_Item_Ripianificato__c = null;
            li.Ripianificato__c = false;
            li.RimozioneParteNonErogata__c = false;
            li.Cancellato__c = false;
            li.CPCQuantityAutomationUpdated__c = false;
            li.Data_sospensione_erogazione__c = null;
            li.ImpressionErogateMinorRicavo__c = null;
            // DEPLOY decommentare riga li.QuantitaApprovazioneOverbook__c = null;
        }
        insert lineItemList;
        for(integer i=0;i<lineItemList.size();i++){
            oldNewIdMap.put(lineItemListInit[i].id,lineItemList[i]);
        }
        
        list<optional__c> optsToInsert = new list<optional__c>();
        //list<revenue_application__c> raToInsert = new list<revenue_application__c>();
        list<appliedLabel__c> labelToInsert = new list<appliedLabel__c>();
        List<FrequencyCap__c> fCapToInsert = new List<FrequencyCap__c>();
        List<DayPartTargeting__c> dayPartToInsert = new List<DayPartTargeting__c>();
        List<Inventory_Target__c> inventoryToInsert = new List<Inventory_Target__c>();
        List<TechnologyTargeting__c> techToInsert = new List<TechnologyTargeting__c>();
        List<PlacementTargeting__c> placementToInsert = new List<PlacementTargeting__c>();
        List<SectionOasTargeted__c> sectionToInsert = new List<SectionOasTargeted__c>();       
        List<CookieSearchOasTargeted__c> cookieSearchToInsert = new List<CookieSearchOasTargeted__c>();     
        List<Geography__c> geographyToInsert = new List<Geography__c>();

        for(lineitem__c li : lineItemList){
        	/*
                Label, day part targeting, inventory target, page,section target, placement
                se sono definite sul prodotto valgono quelle altrimenti si prendono dal line item
            */
        	
            list<optional__c> opts = li.Optionals__r.deepclone(false,false,false);
            for(optional__c o : opts){
                o.line_Item__c = li.id;
                o.product__c = null;
            }
            //list<revenue_application__c> rApps = li.Revenue_applications__r.deepclone(false,false,false);
            //for(revenue_application__c ra : rApps){
            //    ra.line_Item__c = li.id;
            //    ra.Ticket_Fatturazione__c = null;
            //}
            
			list<appliedLabel__c> labels = li.AppliedLabel__r.deepclone(false,false,false);
            if(pMap.containsKey(li.Product__c) && !pMap.get(li.Product__c).AppliedLabel__r.isEmpty()) {
                labels = pMap.get(li.Product__c).AppliedLabel__r.deepclone(false, false, false);
            }
            for(appliedLabel__c al : labels){
                al.line_Item__c = li.id;
                al.product__c = null;
            }
			
            List<DayPartTargeting__c> dayPart = li.Day_Part_Targeting__r.deepclone(false,false,false);
            if(pMap.containsKey(li.Product__c) && !pMap.get(li.Product__c).Day_Part_Targeting__r.isEmpty()) {
                dayPart = pMap.get(li.Product__c).Day_Part_Targeting__r.deepclone(false, false, false);
            }
            for(DayPartTargeting__c dp : dayPart){
                dp.lineITem__c = li.id;
                dp.product__c = null;
            }
            
            List<Inventory_Target__c> inventory = li.Inventory_Target__r.deepclone(false,false,false);
            List<SectionOasTargeted__c> sections = li.SectionsOasTargeted__r.deepclone(false,false,false);
            
            if( pMap.containsKey(li.Product__c) &&
                (
                    !pMap.get(li.Product__c).Inventory_Target__r.isEmpty()
                    ||
                    !pMap.get(li.Product__c).SectionsOasTargeted__r.isEmpty()
                )
              ){
                inventory = pMap.get(li.Product__c).Inventory_Target__r.deepclone(false,false,false);
                sections = pMap.get(li.Product__c).SectionsOasTargeted__r.deepclone(false,false,false);
            }
            for(Inventory_Target__c it : inventory){
                it.lineITem__c = li.id;
                it.product__c = null;
            }
            for(SectionOasTargeted__c sot : sections){
                sot.lineItem__c = li.id;
                sot.product__c = null;
            }
            
            
            List<PlacementTargeting__c> placements = li.PlacementTargeting__r.deepclone(false,false,false);
            if(pMap.containsKey(li.Product__c) && !pMap.get(li.Product__c).PlacementTargeting__r.isEmpty()) {
                placements = pMap.get(li.Product__c).PlacementTargeting__r.deepclone(false,false,false);
            }
            for(PlacementTargeting__c pt : placements){
                pt.line_Item__c = li.id;
                pt.product__c = null;
            }			
			
                
            List<FrequencyCap__c> fCaps = li.Frequency_Caps__r.deepclone(false,false,false);
            for(FrequencyCap__c fc : fCaps){
                fc.lineItem__c = li.id;
                fc.product__c = null;
            }            
            
            
            List<TechnologyTargeting__c> techno = li.Technology_Targeting__r.deepclone(false,false,false);
            for(TechnologyTargeting__c tt : techno){
                tt.lineITem__c = li.id;
                tt.product__c = null;
            }
            
            List<CookieSearchOasTargeted__c> cookieSearch = li.CookieSearchTermsOASTargeted__r.deepclone(false,false,false);
            for(CookieSearchOasTargeted__c cst : cookieSearch){
                cst.lineItem__c = li.id;
                cst.product__c = null;
            }

            List<Geography__c> geography = li.Geography__r.deepclone(false,false,false);
            for(Geography__c geo : geography){
                geo.LineItem__c = li.id;
                geo.Product__c = null;
            }
                            
            optsToInsert.addAll(opts);
            //raToInsert.addAll(rApps);
            labelToInsert.addAll(labels);
            fCapToInsert.addAll(fCaps);
            dayPartToInsert.addAll(dayPart);
            inventoryToInsert.addAll(inventory);
            techToInsert.addAll(techno);
            placementToInsert.addAll(placements);
            sectionToInsert.addAll(sections);
            cookieSearchToInsert.addAll(cookieSearch);
            geographyToInsert.addAll(geography);
        }
        
        insert optsToInsert;
        //insert raToInsert;
        insert labelToInsert;
        insert fCapToInsert;
        insert dayPartToInsert;
        insert inventoryToInsert;
        insert techToInsert;
        insert placementToInsert;
        insert sectionToInsert;
        insert cookieSearchToInsert;
        insert geographyToInsert;
        
        list<id> lineItemListId = new list<id>();
        for(lineitem__c li : lineItemList){
            lineItemListId.add(li.id);
        }
        
        List<CustomCriteriaSet__c> customCriteriaSets = [Select logicalOperator__c, Product__c, LineItem__c, 
                                                             (Select Custom_Targeting_Key__c, keyId__c, operator__c, valueIds__c,values__c
                                                              From Custom_Criteria__r) 
                                                         From CustomCriteriaSet__c where LineItem__c in : lineItemListInit];
                                                         
        List<CustomCriteriaSet__c> customSetToInsert = customCriteriaSets.deepclone(false,false,false);
        for(CustomCriteriaSet__c ccs : customSetToInsert){
            ccs.lineItem__c = oldNewIdMap.get(ccs.lineitem__c).Id;
            ccs.product__c = null;
        }
        insert customSetToInsert;
        
        List<Custom_Criteria__c> customCriteriaToInsert = new List<Custom_Criteria__c>();
        for(Integer i=0;i<customCriteriaSets.size();i++){
            for(Custom_Criteria__c cc : customCriteriaSets.get(i).Custom_Criteria__r){
                Custom_Criteria__c ccCloned = cc.clone();   
                ccCloned.Custom_Criteria_Set__c = customSetToInsert.get(i).id;
                customCriteriaToInsert.add(ccCloned);
            }
        }
        insert customCriteriaToInsert;
        
        return OldNewIdMap;
    }
    
    



}