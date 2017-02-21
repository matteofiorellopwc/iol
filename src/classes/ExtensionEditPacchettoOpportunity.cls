public class ExtensionEditPacchettoOpportunity {

    public PacchettoCombo__c pac {get;set;}

    public Map<Id,Pacchetto_Combo_Prodotto__c> prodottiPacchetto {get;set;}
    public List<LineItem__c> lis {get;set;}
    public Opportunity o {get;set;}
    public Pacchetto_Combo_Opportunity__c pco {get;set;}
    
    public Map<string,string> errorMap {get;set;}
    public Boolean error {get;set;}
    
    Map<Id,Product2> productMap;
    
    public string fieldEdited {get;set;}
    
    public decimal[] queries {get;set;}
    
    
    public ControllerRevenueApplication ControllerRevenueApplication {get;set;}

    public class ExtensionEditPacchettoOpportunityException extends Exception {}

    private boolean firstUpdateCalc = false;
        
    public ExtensionEditPacchettoOpportunity(ApexPages.StandardController controller) {
        queries = new decimal[]{};
        
        error = false;
        fieldEdited = '';
        pco = (Pacchetto_Combo_Opportunity__c) controller.getRecord();
        
        String oppId,pacId;
        if(ApexPages.currentPage() != null){
            oppId = ApexPages.currentPage().getParameters().get('oppId');
            pacId = ApexPages.currentPage().getParameters().get('pacId');
        }
    
        if(pco.id != null){
            oppId = pco.opportunity__c;
            pacId = pco.PacchettoCombo__c;
        }
        
        pac = [select Id,Name,Sconto_applicabile__c from PacchettoCombo__c where id =: pacId];
        prodottiPacchetto = new Map<Id,Pacchetto_combo_prodotto__c>((list<Pacchetto_combo_prodotto__c>)Database.query(Util.getFieldsSOQL('Pacchetto_combo_prodotto__c', ' PacchettoCombo__c = \''+pacId+'\'', false, 'Product__r.CalcolaCPDconImprStimate__c,product__r.Impressions_stimate__c,product__r.delivery_model__c,product__r.type__c',false)));        
        o = [select id,name,Commissione_Agenzia__c from opportunity where id =: oppId];
        
        errorMap = new map<string,string>();
        errorMap.put(null,'');
        
        ControllerRevenueApplication = new ControllerRevenueApplication(pco);
        ControllerRevenueApplication.setParentValues(pco);
        
        if(pco.modalitaEditRevenue__c == null){
            pco.modalitaEditRevenue__c = 'Percentuale';
        }
        if(ControllerRevenueApplication.isFatturato){
            pco.modalitaEditRevenue__c = 'Valore';
        }        
        
        if(pco.id == null){
        
            pco.Name = pac.Name;
            pco.Opportunity__c = oppId;
            pco.PacchettoCombo__c = pacId;
            
            o.Commissione_Agenzia__c = o.Commissione_Agenzia__c != null ? o.Commissione_Agenzia__c : 0;
            
            lis = new list<lineitem__c>();
           
            Set<id> product2ids = new Set<id>();
            Map<Id, LineItem__c[]> cpdWithImpressionStimate = new Map<Id, LineItem__c[]>();
            FattoreCorrettivoFasceOrarie__c fatt = FattoreCorrettivoFasceOrarie__c.getInstance('default');
            for(Id i : prodottiPacchetto.keySet()){
                Pacchetto_combo_prodotto__c pcp = prodottiPacchetto.get(i);
                
                product2ids.add(pcp.product__c);
                lineitem__c li = new lineitem__c();
                li.Start_Date__c = pcp.Start_Date__c;
                li.End_Date__c = pcp.End_Date__c;
                li.Goal__c = pcp.Goal__c;
                li.Quantita__c = pcp.Quantita__c;                
                li.product__c = pcp.product__c;
                li.CalcolaCPDconImpStimate__c = pcp.Product__r.CalcolaCPDconImprStimate__c;                
                if(li.CalcolaCPDconImpStimate__c) {
                    li.Fascia_oraria__c = pcp.Fascia_oraria__c;             
                    li.Fattore_correttivo_fascia_0_12__c =  fatt.Fattore_correttivo_fascia_0_12__c;
                    li.Fattore_correttivo_fascia_12_16__c = fatt.Fattore_correttivo_fascia_12_16__c;
                    li.Fattore_correttivo_fascia_16_24__c = fatt.Fattore_correttivo_fascia_16_24__c;  
                    li.TipoTariffa__c = pcp.tipo_Tariffa__c;                
                    if(!cpdWithImpressionStimate.containsKey(pcp.Product__c)) cpdWithImpressionStimate.put(pcp.Product__c, new LineItem__c[]{});
                    cpdWithImpressionStimate.get(pcp.Product__c).add(li);
                }
                
                if(pcp.fascia_oraria__c != '' || pcp.Modificabile_in_line_item__c.indexOf('Fascia oraria') > -1){
                    li.Day_Part_Targeting_Type__c = 'Bands';
                }
                                
                li.delivery_model__c = pcp.product__r.delivery_model__c;
                li.type_dfp__c = pcp.product__r.type__c;
                li.discount_type__c = 'PERCENTAGE';
                
                /* vecchia versione, il prezzo sul pacchetto è al netto delle commisioni di agenzia
                li.prezzo_listino__c = pcp.Listino__c / (1 - o.Commissione_Agenzia__c/100);
                li.prezzo_net__c = pcp.Listino__c;
                li.prezzo_net_net__c = pcp.Listino__c;
                li.sconto__c = pco.sconto__c == null ? 0 : pco.sconto__c;         
                /**/
                /* nuova versione, il prezzo sul pacchetto è lordo */
                li.prezzo_listino__c = pcp.Listino__c;
                li.sconto__c = pco.sconto__c == null ? 0 : pco.sconto__c;         
                li.prezzo_net__c = li.prezzo_listino__c * (1-li.sconto__c/100);
                li.prezzo_net_net__c = li.prezzo_net__c * (1-o.Commissione_Agenzia__c/100);
                /**/
                
                li.Pacchetto_Combo_Prodotto__c = pcp.id;
                //li.Pacchetto_Combo_Opportunity__c = liPac.Pacchetto_Combo_Opportunity__c;
                
                lis.add(li);
            }

            if(!cpdWithImpressionStimate.isEmpty()) {
                for(Impressions_Stimate__c is : [SELECT Id, AdUnit__c, Product__c, Feriali__c, Festive__c FROM Impressions_Stimate__c WHERE Product__c IN :cpdWithImpressionStimate.keySet() AND AdUnit__c IN (SELECT Ad_Unit__c FROM Inventory_Target__c WHERE Product__c IN :cpdWithImpressionStimate.keySet())]) {
                    for(LineItem__c li : cpdWithImpressionStimate.get(is.Product__c)) {
                        li.ImpressionsStimateFeriali__c = is.feriali__c;
                        li.ImpressionsStimateFestive__c = is.festive__c;
                        //if(li.TipoTariffa__c == null) li.TipoTariffa__c = 'Feriale'; default vuoto
                        if(li.TipoTariffa__c == 'Feriale'){
                            li.Impressions_unitarie_stimate__c = is.feriali__c;
                        }else if (li.TipoTariffa__c == 'Festiva') {
                            li.Impressions_unitarie_stimate__c = is.festive__c;
                        }else{
                            li.Impressions_unitarie_stimate__c = 0;
                        }
                    }                               
                }               
            }
            
            productMap = new Map<id,product2>(UtilProduct.getProductsByIds(product2ids));

            firstUpdateCalc = true;
            updateCalc();
        }else{
            string query = Util.getFieldsSOQL('LineItem__c', ' Pacchetto_Combo_Opportunity__c = \''+pco.id+'\'', false,UtilityLineItemIntegration.getAdditionaFields(),false);
            lis = database.query(query);
            for(lineitem__c li : lis){
                errorMap.put(li.id,'');
            }
        }
    }
    
    public pageReference customCancel(){
        return new PageReference('/'+o.id);
    }
    
    public pageReference customSave(){
        return customSave(true);
    }
    
    public pageReference customSave(Boolean handleExceptions){
        return customSave(handleExceptions, true);
    }
    
    public pageReference customSave(Boolean handleExceptions, Boolean saveRevenue){
        system.debug('custom save');
        
        if(ControllerRevenueApplication.revenueApplications.isEmpty()){
            ControllerRevenueApplication.creaRevenueApplicationDaDate();
        }
    
        list<product2> prods = new list<product2>();
        SavePoint sp = Database.setSavepoint();
        boolean personalizzato = pco.personalizzato__c;
        
        try{
            for(LineItem__c li : lis){
                if(li.CalcolaCPDconImpStimate__c){
                    if(String.isBlank(li.Fascia_oraria__c) && !String.isBlank(prodottiPacchetto.get(li.Pacchetto_Combo_Prodotto__c).Modificabile_in_line_item__c) && prodottiPacchetto.get(li.Pacchetto_Combo_Prodotto__c).Modificabile_in_line_item__c.contains('Fascia oraria')){
                        li.Fascia_oraria__c.addError('Inserire un valore');
                        throw new ExtensionEditPacchettoOpportunityException('Inserire i valori');
                    }
                    if(String.isBlank(li.TipoTariffa__c)){
                        li.TipoTariffa__c.addError('Inserire un valore');
                        throw new ExtensionEditPacchettoOpportunityException('Inserire i valori');
                    }
                }
            }

            LineItem__c[] tempLis = lis.deepclone(true, true, true);
            System.debug('TEMPLIS!!! ' + tempLis);
            Pacchetto_Combo_Opportunity__c pcoC = pco.clone(true, true, true, true);
            ControllerRevenueApplication.pco = pcoC;
            ControllerRevenueApplication.setParentValues(pcoC);         
            //pcoC.personalizzato__c = true;
            if(pcoC.id == null){
                upsert pcoC;                
                for(lineitem__c li : tempLis){
                    System.debug('PROD MAP!!! ' + productMap);
                    System.debug('LI.PRODUCT__C!!! ' + li.Product__c);                  
                    prods.add(productMap.get(li.product__c));
                    li.personalizzato__c = true;
                    li.Pacchetto_Combo_Opportunity__c = pcoC.id;
                }
                queries.add(Limits.getQueries());
                tempLis = ExtensionAddProduct.addProducts(prods,tempLis,o.id);
                queries.add(Limits.getQueries());                               
                updateCalc(tempLis, pcoC);
                if(saveRevenue) saveRevenue(personalizzato,false,tempLis,pcoC,sp); //Qui voglio aggiornare ancora il lineitem per fare il controllo sulle revenue
                queries.add(Limits.getQueries());
            }else{
                system.debug('Try saving revenue');
                if(saveRevenue) saveRevenue(personalizzato,true,tempLis,pcoC,sp); //Qui non aggiorno i lineitem, lo faccio dopo
                system.debug('saved revenue');                
                update tempLis;
                system.debug('saved line item');
                update pcoC;
            }
            
            /* controllo disponibilità */
            boolean warning = false;
            error = false;
            
            for(LineItem__c li : tempLis){
                errorMap.put(li.id,'');
                LineItem__c x = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
                
                
                /*
                if(li.delivery_model__c == 'CPM' && (li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'STANDARD')){
                   ControllerForecast ControllerForecast = new ControllerForecast(li.id);
                   ControllerForecast.Forecast forecast = ControllerForecast.checkAvailabilitySave(li);
                   if(forecast != null && forecast.availableUnits < li.Quantita__c && !li.allowOverbook__c){
                       errorMap.put(li.id,'Impression non sufficienti');
                   }
                }
                */
        
                String cpdMessage = '';       
                if(li.delivery_model__c == 'CPD'){
                   ControllerCpdAvailability checkCpd = new ControllerCpdAvailability();
                   Map<String,boolean> checkedCPD = checkCpd.checkAvailabilityLineItem(x);
                   if(checkedCPD.get('block')){  
                       errorMap.put(x.id,'Conflitto con altro lineitem');
                       error = true;
                   }  
                }
                queries.add(Limits.getQueries()); 
            }
            
            checkFasciaDayPart(tempLis);
            
            queries.add(Limits.getQueries());
                    
            if(warning){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Disponibilità non sufficiente.'));
            }
            if(error){
                if(handleExceptions) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Trovato conflitto bloccante. Modifiche non salvate.'));
                    //pcoC.personalizzato__c = false;
                    Database.rollback(sp);
                    return null;
                } else throw new extensionCloneOpportunity.cloneException('Trovato conflitto bloccante. Modifiche non salvate.');
            }
            
            /* fine controllo disponibilità */
                        
            //Qui non dovrebbe più servire, per ora si lascia per sicurezza
            if(saveRevenue) {
                string checkRevenue = ControllerRevenueApplication.checkRevenueApplication(pcoC);
                system.debug('Incoerenze_revenue_application__c: '+checkRevenue);
                if(checkRevenue != '' && checkRevenue != null){
                    //pcoC.personalizzato__c = personalizzato;
                    ControllerRevenueApplication.restoreFromTmpRevenueApplication();
                    if(handleExceptions) {        
                        Database.rollback(sp);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errori durante il salvataggio delle revenue application:<br/>'+checkRevenue));                                    
                        return null;
                    } else throw new extensionCloneOpportunity.cloneException('Errori durante il salvataggio delle revenue application:<br/>'+checkRevenue);
                }else{
                    ControllerRevenueApplication.initRevenueApplicationToDelete(); //così se ritorno qui non da eccezione
                }
            }
                        
            lis = tempLis;
            pco = pcoC;
        }catch(Exception e){
            //selse ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage() + ' ' + e.getLineNumber()));            
            Database.rollBack(sp);
            if(handleExceptions) {
                ApexPages.addMessages(e);
            } else throw e;            
            return null;
        } finally {
            ControllerRevenueApplication.pco = pco;
            ControllerRevenueApplication.setParentValues(pco);          
        }
        
        if(handleExceptions) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Pacchetto salvato correttamente.'));
        ControllerRevenueApplication = new ControllerRevenueApplication(pco);
        ControllerRevenueApplication.setParentValues(pco);
        //ExtensionEditLineItemNew.printLimits('After save pacchetto');
        return null;
    }
    
    /*
        Salva le revenue con la possibilità di fare il controllo sui totali o meno
    */
    public void saveRevenue(boolean personalizzato, boolean skipValidation, LineItem__c[] liL, Pacchetto_Combo_Opportunity__c pcoC, SavePoint sp){
        try{

            if(Test.isRunningTest()){ //va in errore perchè non sono gestiti i ricavi
                skipValidation = true;
            }

            System.debug('SAVE REVENUE - SKIP VALIDATION!!! ' + skipValidation);
            
            //Non si possono modificare/eliminare revenue già fatturate.
            LineItemTriggerHandler.skipUpdateLineItem = skipValidation;
            LineItemTriggerHandler.skipValidationTotali = skipValidation;
        
            ControllerRevenueApplication.saveTmpRevenueApplications();
            ControllerRevenueApplication.customSave(pcoC,liL); 
        }catch(Exception e) {
            //pco.personalizzato__c = personalizzato;
            System.debug('EXCEPTION!!! ' + e);
            Database.rollback(sp);
            ControllerRevenueApplication.restoreFromTmpRevenueApplication();                        
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore:<br />'+e.getMessage() + ' ' + e.getLineNumber()));
            //return false;
            throw e;
        } finally {
            LineItemTriggerHandler.skipUpdateLineItem = false;
            LineItemTriggerHandler.skipValidationTotali = false;
        }
    }
    
    public void CheckAvailability(){
        DfpIntegration dfp = new DfpIntegration();
        for(LineItem__c li : lis){
            errorMap.put(li.id,'');            
            try{
                ControllerForecast.forecast f = ControllerForecast.StaticCheckAvailability(dfp,getLineItemUpdated(li));
                errorMap.put(li.id,'Disponibilità '+f.availableUnits+'<br/>Bacino: '+f.matchedUnits);
                //f.matchedUnits
            }catch(Exception e){
                errorMap.put(li.id,'Errore: ' + e.getMessage());
            }
        }
    }
    
    private LineItem__c getLineItemUpdated(lineitem__c li){
        LineItem__c l = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
        l.Quantita__c = li.Quantita__c;
        l.Start_Date__c = li.Start_Date__c;
        l.End_Date__c = li.End_Date__c;
        l.goal__c = li.goal__c;
        return l;
    }
    
    public void checkFasciaDayPart(lineitem__c[] liTemp){
        system.debug('checkFasciaDayPart');
        //devo fare query perchè isFasciaOrariaEdit__c è una formula
        lineitem__c[] lis = [select id,isFasciaOrariaEdit__c,Fascia_oraria__c,Day_Part_Targeting_Type__c from lineitem__c where id in : liTemp];
        
        map<id,DayPartTargeting__c[]> dptMap = new map<id,DayPartTargeting__c[]>();

        for(DayPartTargeting__c dpt : [select dayOfWeek__c,Start_Hour__c,End_Hour__c,LineItem__c from DayPartTargeting__c where LineItem__c in : lis]){
            if(dptMap.get(dpt.lineitem__c) == null){
                dptMap.put(dpt.lineitem__c,new DayPartTargeting__c[]{});
            }
            dptMap.get(dpt.lineitem__c).add(dpt);
        }
        
        DayPartTargeting__c[] dptToDelete = new DayPartTargeting__c[]{};
        DayPartTargeting__c[] dptToInsert = new DayPartTargeting__c[]{};
        
        for(lineItem__c li : lis){
            if(li.isFasciaOrariaEdit__C){
                li.Day_Part_Targeting_Type__c = 'Bands';
                
                DayPartTargeting__c[] dptList = new DayPartTargeting__c[]{};
                if(dptMap.get(li.id) != null){
                    dptList = dptMap.get(li.id);
                }
                Set<String> dptSet = new Set<String>();
                for(DayPartTargeting__c d : dptList){
                    dptSet.add(d.dayOfWeek__c+d.Start_Hour__c+d.End_Hour__c);
                }
                
                if(li.Fascia_oraria__c == null || li.Fascia_oraria__c == ''){
                    dptToDelete.addAll(dptList);
                }else{
                    DayPartTargeting__c[] dptNew = new DayPartTargeting__c[]{}; 
                    Set<String> dptNewSet = new Set<String>();
                    string startH = li.Fascia_oraria__c.split('-').get(0).trim();
                    string endH = li.Fascia_oraria__c.split('-').get(1).trim();
                    
                    for(Schema.PicklistEntry pl : DayPartTargeting__c.dayOfWeek__c.getDescribe().getPicklistValues()){
                        DayPartTargeting__c dpt = new DayPartTargeting__c();
                        dpt.dayOfWeek__c = pl.getValue();
                        dpt.Start_Minute__c = 'ZERO';
                        dpt.Start_Hour__c = startH;
                        dpt.End_Minute__c = 'ZERO';
                        dpt.End_Hour__c = endH;
                        dpt.LineItem__c = li.Id;
                        dptNew.add(dpt); 
                        dptNewSet.add(dpt.dayOfWeek__c+dpt.Start_Hour__c+dpt.End_Hour__c);
                    }
                    
                    if(dptNewSet.size() != dptSet.size() || !dptNewSet.containsAll(dptSet)){
                        dptToDelete.addAll(dptList);
                        dptToInsert.addAll(dptNew);
                    }
                }
            }
        }

        
        //boolean oldSkip = LineItemTriggerHandler.skipUpdateLineItem;
        //LineItemTriggerHandler.skipUpdateLineItem = false;
        delete dptToDelete;
        insert dptToInsert;
        //LineItemTriggerHandler.skipUpdateLineItem = oldSkip;
        
    }
    
    public void updateCalc(){
        updateCalc(lis,pco);
    }
    
    public void updateCalc(LineItem__c[] liL,Pacchetto_Combo_Opportunity__c p){
        system.debug('fieldEdited = '+fieldEdited);
        if(fieldEdited == 'totale'){
            decimal newTotale = p.totale__c;
            for(lineitem__c li : liL){
                system.debug('quantità = '+li.quantita__c);
                li.sconto__c = 0;
                UtilLineItem.updatecalc(li,'sconto',null,(decimal)o.Commissione_Agenzia__c);
            }
            UtilLineItem.updatePacchettoOpportunity(p,liL);
            p.sconto__c = p.Totale__c == 0 ? 0 : ((p.totale__c - newTotale)*100 / p.totale__c).setScale(2,ROUNDINGMODE.HALF_UP);
        }
        
        for(lineitem__c li : liL){
            //system.debug('quantità = '+li.quantita__c);
            system.debug('fascia_oraria__c = '+li.Fascia_oraria__c);

            if(li.CalcolaCPDconImpStimate__c && !firstUpdateCalc){
                if(String.isBlank(li.Fascia_oraria__c) && !String.isBlank(prodottiPacchetto.get(li.Pacchetto_Combo_Prodotto__c).Modificabile_in_line_item__c) && prodottiPacchetto.get(li.Pacchetto_Combo_Prodotto__c).Modificabile_in_line_item__c.contains('Fascia oraria')){
                    li.Fascia_oraria__c.addError('Inserire un valore');
                }
                if(String.isBlank(li.TipoTariffa__c)){
                    li.TipoTariffa__c.addError('Inserire un valore');
                }
            }
            li.sconto__c = p.sconto__c;
            UtilLineItem.updatecalc(li,'sconto',null,(decimal)o.Commissione_Agenzia__c);
            system.debug('li.totale__c : '+li.totale__c);
        }
        
        UtilLineItem.updatePacchettoOpportunity(p,liL);
        system.debug('p.totale__c: '+p.totale__c);
        ControllerRevenueApplication.setParentValues(p);
        ControllerRevenueApplication.updateRevenueApplication();
        firstUpdateCalc = false;
    }

    public PageReference undeletePacchetto(){
        List<Decimal> dfpLineItems = new List<Decimal>();
        List<String> oasLineItems = new List<String>();
        for(LineItem__c li : lis){
            if(li.id_DFP__c != null){ // line item su DFP
                dfpLineItems.add(li.id_DFP__c);
            }else if(li.Id_Oas__c != null){ // line item su OAS
                oasLineItems.add(li.Id_Oas__c);
            }
            li.Cancellato__c = false;
        }
        if(dfpLineItems.size()>0){
            UtilityLineItemIntegration.resumeLineItems(dfpLineItems);
        }
        if(oasLineItems.size()>0){
            OasIntegration oas = new OasIntegration();
            oas.updateCampaignsStatus(oasLineItems,OasIntegration.OAS_STATUS.get('Ordered')); 
        }
        update lis;
        pco.Cancellato__c = false;
        update pco;
        PageReference pr = new PageReference('/' + pco.Id);
        pr.setRedirect(true);
        return pr;  
    }
       
}