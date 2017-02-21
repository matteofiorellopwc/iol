public class ExtensionAddProduct {

    public id prodId {get;set;}
    public id oppId {get;set;}
    public id lineItemRipianifica {get;set;}
    public list<product2> products {get;set;}
    public Id parentLineItem {get; set;}
    public LineItem__c parentLineItemObj {get;set;}
    
    public list<pacchettoCombo__c> pacchetti {get;set;}
    public id pacId {get;set;}
    
    public string prodname {get;set;}
    public list<selectOption> famiglie {get{return getItems(Product2.family);}}
    public string family {get;set;}
    public list<selectOption> sizes {get{return getItems(Product2.size__c);}}
    public string size {get;set;}
    public list<selectOption> types {get{return getItems(Product2.Type__c);}}
    public string type {get;set;}
    public list<selectOption> deliveryModels {get{return getItems(Product2.delivery_model__c);}}
    public string deliveryModel {get;set;}
    public list<selectOption> portals {get{return getItems(Product2.Portale__c);}}
    public string portal {get;set;}
    public list<selectOption> adServers {get{return getItems(Product2.Ad_Server__c);}}
    public string adServer {get;set;}
    public list<selectOption> primaryChannels {get{return getItems(Product2.Canale_Primario__c);}}
    public string primaryChannel {get;set;}
    public list<selectOption> newPrimaryChannels {get{return getItems(Product2.CanalePrimario__c);}}
    public string newPrimaryChannel {get;set;}
    public Boolean showNetworkProduct {get;set;}
    public Boolean showLocalProduct {get;set;}
    public LocalUser localU {get; set;}
    
    public class AddProductException extends exception{}
         
    public List<selectOption> getItems(Schema.sObjectField field){
       List<SelectOption> options = new List<SelectOption>();
    
       Schema.DescribeFieldResult fieldResult = field.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         
       options.add(new SelectOption('',''));
       for(Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));
       }
       return options;
    }
    
    /* Per pagina SelectAdUnitForCpd */
    public list<Impressions_Stimate__c> impressionsStimateList {get;set;}
    public id selectedAdUnitId {get;set;}
    public Decimal selectedFeriali {get;set;}
    public Decimal selectedFestive {get;set;}

    public ExtensionAddProduct(ApexPages.StandardController controller) {
        prodname = '';
        oppId = controller.getId();
        pacchetti = new list<pacchettoCombo__c>();
        products = new list<product2>();
        showNetworkProduct = false;
        parentLineItem = ApexPages.CurrentPage().getParameters().get('parentLineItem');
        /*if(parentLineItem != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'E\' in corso la ripianificazione di un Line Item, scegliere un prodotto per procedere.'));
        }*/
        if(parentLineItem != null){
            parentLineItemObj = [SELECT Id,Nome_DFP__c FROM LineItem__c WHERE Id = :parentLineItem];
        }
         //Local Requirement
        localU = new LocalUser();
        String localParameterOverride = ApexPages.currentPage().getParameters().get('local');
        if (localParameterOverride == '1') {
            localU.isLocalUser = true;
        } else if (localParameterOverride == '0') {
            localU.isLocalUser = false;
        }
        showLocalProduct = localU.isLocalUser;

    }
    
    public void search(){
        String localWhere = ' AND Local__c = ' + showLocalProduct;
        string query = 'select id,name,family,description,type__c,categoria_libero__c,Delivery_Model__c,size__c,RecordTypeId,Integrato_con_DFP_formula__c,ad_server__c,Portale__c,Canale_Primario__c,CanalePrimario__c,goal__c, '+
                       '    (select id from Inventory_Target__r),(select id from PlacementTargeting__r),(select id from SectionsOasTargeted__r)'+
                       'from product2 where name like \'%'+prodname.replace('-', '%')+'%\'' + localWhere;

        if(notVoid(deliverymodel)){
            query += ' and Delivery_Model__c = \''+ deliverymodel +'\'';
        }
        if(notVoid(family)){
            query += ' and family = \''+ family +'\'';
        }
        if(notVoid(size)){
            query += ' and size__c = \''+ size +'\'';
        }
        if(notVoid(type)){
            query += ' and type__c = \''+ type +'\'';
        } 
        if(notVoid(portal)){
            query += ' and portale__c = \''+ portal +'\'';
        }
        if(notVoid(adServer)){
            query += ' and Ad_Server__c = \''+ adServer +'\'';
        }
        if(notVoid(primaryChannel)){
            query += ' and Canale_Primario__c = \''+ primaryChannel +'\'';
        }
        if(notVoid(newPrimaryChannel)){
            query += ' and CanalePrimario__c = \''+ newPrimaryChannel +'\'';
        }
        if(!showNetworkProduct){
            query += ' and type__c not in (\'NETWORK\',\'AD_EXCHANGE\', \'ADSENSE\') ';
            query += ' and categoria_libero__c <> \'Network\'' ;
        }
        
        
        query += ' and Disponibile_solo_in_pacchetto_combo__c = false and isActive = true';
        
        system.debug('query: '+query);
        products = Database.query(query);
    }
    
    public void searchPacchettoCombo(){
        string searchName = '%'+prodName+'%';
        pacchetti = [select id,name from pacchettoCombo__c where name like : searchName and isActive__c = true];
    }
    
    
    public boolean notVoid(String s){
        return s != null  && s != '';
    }
    
    public PageReference addPacchettoCombo(){
        //list<prodotto_pacchetto_combo__c> prodottiPacchetto = [select ];
        return new PageReference('/apex/editPacchettoOpportunity?oppId='+oppId+'&pacId='+pacId);
    }
    
    public static list<lineitem__c> addProducts(list<product2> prods, list<lineItem__c> lineItemsDaPacchetto, id oppId){
        return addProducts(prods,lineItemsDaPacchetto,oppId,null);
    }

    public static list<lineitem__c> addProducts(list<product2> prods, list<lineItem__c> lineItemsDaPacchetto, id oppId,Impressions_Stimate__c impressionStimate){
        LineItemTriggerHandler.skipUpdateLineItem = true;
        
        LineItemTriggerHandler.skipValidationTotali = true;
        
        Opportunity o = [select status__c,Canale_di_vendita__c,accountid,Agenzia_di_riferimento__c,Percentuale_agenzia_su_brand__c from Opportunity where id =: oppId];
        
        /**commisioning**/
        string tipoCliente = 'Nuovo';
        if([select id from opportunity where accountid =: o.accountid and iswon = true and closeDate = LAST_YEAR].isEmpty()){
            tipoCliente = 'Vecchio';
        }
        /**end commisioning**/

        list<lineitem__c> lineItems = new list<lineItem__c>();

        List<FrequencyCap__c> fCapsToInsert = new List<FrequencyCap__c>();
        List<DayPartTargeting__c> dayPartToInsert = new List<DayPartTargeting__c>();
        List<Inventory_Target__c> inventoryToInsert = new List<Inventory_Target__c>();
        List<TechnologyTargeting__c> technoToInsert = new List<TechnologyTargeting__c>();
        List<PlacementTargeting__c> placementsToInsert = new List<PlacementTargeting__c>();        
        List<AppliedLabel__c> appliedLabelsToInsert = new List<AppliedLabel__c>();
        List<SectionOasTargeted__c> sectionToInsert = new List<SectionOasTargeted__c>();       
        List<CookieSearchOasTargeted__c> cookieSearchToInsert = new List<CookieSearchOasTargeted__c>();   
        List<Geography__c> geographyToInsert = new List<Geography__c>();
        
        Id selectedAdUnitId = null;
        
        for(Integer i=0;i<prods.size();i++){
            Product2 p = prods[i];
            lineitem__c li = new lineitem__c();
            
            li.Categoria_Libero__c = p.categoria_libero__c;
            li.formato_prodotto__c = p.formato__c;            
            li.delivery_model__c = p.Delivery_Model__c;
            li.Portale__c = p.Portale__c;
            li.Priority__c = p.Priority__c;
            li.Type_DFP__c = p.Type__c;
            li.deliveryRateType__c = p.deliveryRateType__c;
            li.creativeRotationType__c = p.creativeRotationType__c;
            //OAS Fields
            li.Priority_oas__c = p.Priority_oas__c;
            li.OasPrimaryFrequencyClickPerVisitor__c = p.OasPrimaryFrequencyClickPerVisitor__c;
            li.OasPrimaryFrequencyImpPerVisitor__c = p.OasPrimaryFrequencyImpPerVisitor__c;
            li.OasSecondaryFrequencyImpPerVisitor__c = p.OasSecondaryFrequencyImpPerVisitor__c;
            li.OasPrimaryFreqScope__c = p.OasPrimaryFreqScope__c;
            li.OasSecondaryFreqScope__c = p.OasSecondaryFreqScope__c;
            //

            //Per local ignoro la disponibilità CPD
            if(p.Local__c){
                li.skipDispoCpd__c = true;
            }
            
            // imposto data di inizio fine, se prodotto local 7 gg lavorativi da oggi, altrimenti 8
            
                li.Start_Date__c = Date.today();
                Integer count = 0;
                Integer max = p.Local__c ? 7 : 8; 
                while(count < max){
                li.Start_Date__c = li.Start_Date__c.addDays(1);
                if(li.Start_Date__c.toStartOfWeek().daysBetween(li.Start_Date__c) < 5 || !p.Local__c){
                    count ++;
                }
            }
                if(li.delivery_model__c !='CPC'){
                
                li.End_Date__c = li.Start_Date__c+1;
                
                }  else {                   
                
                Date firstDayOfMonth = li.Start_Date__c.toStartOfMonth();
                Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month())-1);
                li.End_Date__c = lastDayOfMonth;
            }
                        
            if(p.size__c != null && p.size__c.contains('x')){
                li.Width__c = integer.valueOf(p.size__c.split('x')[0].removeEnd('v'));
                li.Height__c = integer.valueOf(p.size__c.split('x')[1].removeEnd('v'));
            }else{
                li.multisize__c = p.multisize__c;
            }
            if(p.roadblockingType__c != null){
                li.roadblockingType__c = p.roadblockingType__c;
            }
            
            li.product__c = p.id;
            li.Day_Part_Targeting_Type__c = p.Day_Part_Targeting_Type__c;
            li.Opportunity__c = oppId;
            
            li.Impressions_unitarie_stimate__c = p.Impressions_stimate__c;
            
            if(p.Delivery_Model__c == 'CPD' && p.CalcolaCPDconImprStimate__c){   
                li.CalcolaCPDconImpStimate__c = true;           
                if(impressionStimate != null){ //arrivo dalla pagina SelectAdUNitForCpd
                    selectedAdUnitId = impressionStimate.adUnit__c;
                    li.ImpressionsStimateFeriali__c = impressionStimate.feriali__c;
                    li.ImpressionsStimateFestive__c = impressionStimate.festive__c;
                    //if(li.TipoTariffa__c == null) li.TipoTariffa__c = 'Feriale'; -> default vuoto
                    if(li.TipoTariffa__c == 'Feriale'){
                        li.Impressions_unitarie_stimate__c = impressionStimate.feriali__c;
                    }else if (li.TipoTariffa__c == 'Festiva') {
                        li.Impressions_unitarie_stimate__c = impressionStimate.festive__c;
                    }else{
                        li.Impressions_unitarie_stimate__c = 0;
                    }
                }else{                      //sto inserendo un pacchetto
                    if(p.Inventory_Target__r.size() == 1){
                        try{
                            Impressions_Stimate__c is = [SELECT AdUnit__c, Feriali__c, Festive__c, Attivo__c, AdUnit__r.Path__c, AdUnit__r.Level__c 
                                                         FROM Impressions_Stimate__c
                                                         WHERE Product__c = :p.Id
                                                         AND AdUnit__c =: p.inventory_target__r[0].Ad_unit__c 
                                                         AND Attivo__c = true];
                            selectedAdUnitId = is.adUnit__c;
                            li.ImpressionsStimateFeriali__c = is.feriali__c;
                            li.ImpressionsStimateFestive__c = is.festive__c;
                            //if(li.TipoTariffa__c == null) li.TipoTariffa__c = 'Feriale'; -> default vuoto
                            if(li.TipoTariffa__c == 'Feriale'){
                                li.Impressions_unitarie_stimate__c = is.feriali__c;
                            }else if (li.TipoTariffa__c == 'Festiva') {
                                li.Impressions_unitarie_stimate__c = is.festive__c;
                            }else{
                                li.Impressions_unitarie_stimate__c = 0;
                            }
                        }catch(exception e){
                            throw new AddProductException('Errore nella creazione di un line item per il prodotto '+p.name+ '.\n'+e);
                        }
                    }
                }
            }
            
            
            li.Somma_optionals__c = 0;
            li.Prezzo_listino_optionals__c = 0;
            p.BasePrice__c = p.BasePrice__c != null ? p.BasePrice__c : 0;
            li.Prezzo_listino__c = p.BasePrice__c;
            li.Breakeven_cost__c = p.Breakeven_cost__c;                
            
            li.sconto__c = 0;
            li.Prezzo_net__c = p.BasePrice__c;
            li.Prezzo_net_net__c = li.Prezzo_net__c; //* (1 - % agenzia)
            li.quantita__c = 0;
            li.quantita_calcolata__c = 0;
            li.Personalizzato__c = false; //per i pacchetti/combo non deve essere false
            
            if(p.Family == 'Banner'){
                if(o.status__c == 'APPROVED'){
                    li.Status__c = 'NEEDS_CREATIVES';            
                    li.reservationStatus__c = 'RESERVED';
                }else{
                    li.Status__c = 'DRAFT';
                    li.reservationStatus__c = 'UNRESERVED';                    
                }
            }
            
            if(li.Type_DFP__c == 'SPONSORSHIP' || li.Type_DFP__c == 'NETWORK' || li.Type_DFP__c == 'HOUSE'){
                if(p.goal__c != null && p.ad_Server__c == 'DFP'){
                    li.Goal__c = p.goal__c;
                    li.Goal_delivery__c = p.goal__c;
                }else{
                    li.Goal__c = 100;
                    li.Goal_delivery__c = 100;
                }
            }
    
            li.Target_platform__c = p.Target_platform__c;
            if(p.isAspectRatio__c){
                li.Target_platform__c = 'MOBILE';
            }else{
                li.Target_platform__c = 'ANY';
            }
            
            if(p.Family == 'DEM'){ //vedi anche inventory
                if(o.status__c == 'APPROVED'){
                    li.Status__c = 'NEEDS_CREATIVES';            
                    li.reservationStatus__c = 'RESERVED';
                }else{
                    li.Status__c = 'DRAFT';
                    li.reservationStatus__c = 'UNRESERVED';
                }
                li.delivery_model__c = 'CPM';
                li.Priority__c = null;
                li.Type_DFP__c = 'STANDARD';
                li.Width__c = 1;
                li.Height__c = 1;
                li.allowOverbook__c = true;
            }
            
            FattoreCorrettivoFasceOrarie__c fatt = FattoreCorrettivoFasceOrarie__c.getInstance('default');
            li.Fattore_correttivo_fascia_0_12__c =  fatt.Fattore_correttivo_fascia_0_12__c;
            li.Fattore_correttivo_fascia_12_16__c = fatt.Fattore_correttivo_fascia_12_16__c;
            li.Fattore_correttivo_fascia_16_24__c = fatt.Fattore_correttivo_fascia_16_24__c;
            system.debug('fatt.Fattore_correttivo_fascia_0_16__c'+fatt.Fattore_correttivo_fascia_0_16__c);  
            li.Fattore_correttivo_fascia_0_16__c = fatt.Fattore_correttivo_fascia_0_16__c;
            system.debug('fatt.Fattore_correttivo_fascia_0_16__c'+li.Fattore_correttivo_fascia_0_16__c );  

            /*****Commisioning*****/
            
            if(o.Agenzia_di_riferimento__c != null){
                if(o.Percentuale_agenzia_su_brand__c != null){
                    li.Percentuale_commisioning_agenzia__c = o.Percentuale_agenzia_su_brand__c;
                }else{
                    list<Commisioning__c> commisionings = [select Percentuale_applicata__c 
                                                           from Commisioning__c
                                                           where Canale_di_vendita__c includes (: o.Canale_di_vendita__c) and
                                                                 Formato__c includes (: p.formato__c) and
                                                                 Tipo_cliente__c includes (: tipoCliente) and
                                                                 Agenzia__c =: o.Agenzia_di_riferimento__c
                                                          ];
                    if(commisionings.isEmpty()){
                        commisionings = [select Percentuale_applicata__c 
                                           from Commisioning__c
                                           where Canale_di_vendita__c includes (: o.Canale_di_vendita__c) and
                                                 Formato__c includes (: p.formato__c) and
                                                 Tipo_cliente__c includes (: tipoCliente) and
                                                 Agenzia__c = NULL
                       ];
                    }
                    
                    if(commisionings.isEmpty()){
                        li.Note_commisioning__c = 'Nessun valore di commisioning trovato';
                        li.Percentuale_commisioning_agenzia__c = 0;
                    }else if(commisionings.size() == 1){
                        li.Note_commisioning__c = '';
                        li.Percentuale_commisioning_agenzia__c = commisionings[0].Percentuale_applicata__c;
                    }else{
                        li.Note_commisioning__c = 'Trovati ' +commisionings.size()+ ' valori di commisioning';
                    }
                }
            }
            /*****End commisioning*****/
            
            /*
            PricebookEntry pbe = p.PricebookEntries[0];
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=oppId,PricebookEntryId=pbe.id);
            oli.line_item__c = li.id;
            oli.quantity = -1;
            oli.UnitPrice = 0;
            insert oli;
    
            system.debug('line item = '+li);
            update li;
            */
                        
            /***Controllo inserimento prodotti in pacchetto combo***/
            if(lineItemsDaPacchetto != null){
                LineItem__c liPac = lineItemsDaPacchetto.get(i);
                li.Start_Date__c = liPac.Start_Date__c;
                li.End_Date__c = liPac.End_Date__c;
                li.Goal__c = liPac.Goal__c;
                li.prezzo_listino__c = liPac.prezzo_listino__c;
                li.Pacchetto_Combo_Opportunity__c = liPac.Pacchetto_Combo_Opportunity__c;
                li.Pacchetto_Combo_Prodotto__c = liPac.Pacchetto_Combo_Prodotto__c;
                li.Quantita__c = liPac.Quantita__c;
                li.sconto__c = liPac.sconto__c;
                li.prezzo_listino__c = liPac.prezzo_listino__c;
                li.TipoTariffa__c = liPac.TipoTariffa__c;
                li.Fascia_Oraria__c = liPac.Fascia_Oraria__c;
                li.Day_Part_Targeting_Type__c = liPac.Day_Part_Targeting_Type__c;
                li.prezzo_net__c = liPac.prezzo_net__c;
                li.prezzo_net_net__c = liPac.prezzo_net_net__c;
                li.sconto__c = liPac.sconto__c;
                li.ultima_modifica_prezzo__c = liPac.ultima_modifica_prezzo__c;
                li.Personalizzato__c = liPac.Personalizzato__c;
            }
            /*******/

            lineitems.add(li);

        }
        
        
        insert lineItems;

        
        AdUnit__c adu = [select id from AdUnit__c where level__c = 0]; //per le DEM
        for(integer i=0;i<lineItems.size();i++){
            Product2 p = prods.get(i);
            LineItem__c li = lineItems.get(i); 
            List<FrequencyCap__c> fCaps = p.Frequency_Caps__r.deepclone(false,false,false);
            List<DayPartTargeting__c> dayPart = p.Day_Part_Targeting__r.deepclone(false,false,false);
            List<Inventory_Target__c> inventory = p.Inventory_Target__r.deepclone(false,false,false);
            List<TechnologyTargeting__c> techno = p.Technology_Targeting__r.deepclone(false,false,false);
            List<PlacementTargeting__c> placements = p.PlacementTargeting__r.deepclone(false,false,false);
            List<AppliedLabel__c> labels = p.AppliedLabel__r.deepclone(false,false,false);
            List<SectionOasTargeted__c> sections = p.SectionsOasTargeted__r.deepclone(false,false,false);
            List<CookieSearchOasTargeted__c> cookieSearch = p.CookieSearchTermsOASTargeted__r.deepclone(false,false,false);
            List<Geography__c> geography = p.Geography__r.deepclone(false,false,false);
            

            for(FrequencyCap__c fc : fCaps){
                fc.lineItem__c = li.id;
                fc.product__c = null;
            }
            
            for(DayPartTargeting__c dp : dayPart){
                dp.lineITem__c = li.id;
                dp.product__c = null;
            }
            
            
            /*
                se selectedAdUnitId non è vuoto e inventory è vuoto vuol dire che sto inserendo un cpd dalla pagina
                SelectAdUNitForCpd e quindi devo inserire l'inventory target
                se invece inventory non è vuoto vuol dire che ho già settato l'inventory sul prodotto
            */
            if(selectedAdUnitId != null && inventory.isEmpty()){
                Inventory_Target__c inventoryTarget = new Inventory_Target__c();        
                inventoryTarget.Ad_Unit__c = selectedAdUnitId;
                inventoryTarget.includeDescendants__c = true;
                inventoryTarget.LineItem__c = li.id;
                inventoryTarget.isLineItemModified__c = true;
                inventoryTarget.InventoryTargetingType__c = 'targeted';  
                inventoryToInsert.add(inventoryTarget);
            }else if(selectedAdUnitId != null && inventory.size() > 1){  //per i cpd non posso avere più di un inventory target
                throw new AddProductException('Errore nella creazione di un line item per il prodotto '+p.name+ '.\nProdotto non configurato correttamente');
            }
            system.debug([select id from inventory_target__c where product__c =: p.id]);
            
            
            for(Inventory_Target__c it : inventory){
                it.lineITem__c = li.id;
                it.product__c = null;
            }
            
            if(p.Family == 'DEM'){
                Inventory_Target__c it = new Inventory_Target__c();
                it.Ad_Unit__c = adu.id;
                it.includeDescendants__c = true;
                it.InventoryTargetingType__c = 'targeted';
                it.lineITem__c = li.id;
                it.product__c = null;
                inventory.add(it);
            } 
            
            for(TechnologyTargeting__c tt : techno){
                tt.lineITem__c = li.id;
                tt.product__c = null;
            }
    
            for(PlacementTargeting__c pt : placements){
                pt.line_Item__c = li.id;
                pt.product__c = null;
            }
                        
            for(AppliedLabel__c al : labels){
                al.line_Item__c = li.id;
                al.product__c = null;
            }
            
            for(SectionOasTargeted__c sot : sections){
                sot.lineItem__c = li.id;
                sot.product__c = null;
            }
            
            for(CookieSearchOasTargeted__c cst : cookieSearch){
                cst.lineItem__c = li.id;
                cst.product__c = null;
            }

            for(Geography__c geo : geography){
                geo.LineItem__c = li.id;
                geo.Product__c = null;
            }
            
            fCapsToInsert.addAll(fCaps);
            dayPartToInsert.addAll(dayPart);
            inventoryToInsert.addAll(inventory);
            technoToInsert.addAll(techno);
            placementsToInsert.addAll(placements);        
            appliedLabelsToInsert.addAll(labels);
            sectionToInsert.addAll(sections);
            cookieSearchToInsert.addAll(cookieSearch);
            geographyToInsert.addAll(geography);
        }
        
        LineItemTriggerHandler.skipUpdateLineItem = false; //per calcolare inventory_target_string__c
        insert inventoryToInsert;
        LineItemTriggerHandler.skipUpdateLineItem = true;
        insert fCapsToInsert;
        insert dayPartToInsert;
        insert technoToInsert;
        insert placementsToInsert;
        insert appliedLabelsToInsert;
        insert sectionToInsert;
        insert cookieSearchToInsert;
        insert geographyToInsert;
        
        

        map<id,CustomCriteriaSet__c> customCriteriaSetMap = new map<id,CustomCriteriaSet__c>(
                                                            [Select id,logicalOperator__c, Product__c, LineItem__c, 
                                                             (Select Custom_Targeting_Key__c, keyId__c, operator__c, valueIds__c,values__c From Custom_Criteria__r) 
                                                             From CustomCriteriaSet__c where Product__c in : prods]
                                                        );
        
        /*
            lista con i custom criteria set che ho clonato, lo stesso ccs può esserci due volte se ho un pacchetto con lo stesso prodotto ripetuto
            mi serve per poi andare a clonare anche i custom criteria
        */
        List<CustomCriteriaSet__c> customCriteriaSets = new List<CustomCriteriaSet__c>();                                                         
                                                         
        List<CustomCriteriaSet__c> customSetToInsert = new List<CustomCriteriaSet__c>();
        
        for(CustomCriteriaSet__c ccs : customCriteriaSetMap.values()){
            for(lineitem__c li : lineitems){
                CustomCriteriaSet__c cssNew = ccs.clone(false,true,false,false);
                if(ccs.product__c == li.product__c){
                    cssNew.lineITem__c = li.id;
                    cssNew.product__c = null;
                    customSetToInsert.add(cssNew);
                    customCriteriaSets.add(ccs);
                }
            }
        }
        insert customSetToInsert;
        
        List<Custom_Criteria__c> customCriteriaToInsert = new List<Custom_Criteria__c>();
        for(Integer i=0;i< customSetToInsert.size();i++){
            for(Custom_Criteria__c cc : customCriteriaSets.get(i).Custom_Criteria__r){
                Custom_Criteria__c ccCloned = cc.clone();   
                ccCloned.Custom_Criteria_Set__c = customSetToInsert.get(i).id;
                customCriteriaToInsert.add(ccCloned);
            }
        }
        insert customCriteriaToInsert;

        return lineitems;       
    }
    
    public PageReference addProduct(){
        system.debug('prodId = '+prodId);
        
        //TODO test and use utilproduct.getProductsByIds(...)
        /*
        Product2 p = [select Type__c,Size__c,Priority__c,Portale__c,Delivery_Model__c,formato__c,Target_platform__c,id,name,BasePrice__c,Breakeven_cost__c,family,
                          Day_Part_Targeting_Type__c,Impressions_stimate__c,goal__c,
                          (Select Id From PricebookEntries),
                          (Select dayOfWeek__c, Start_Hour__c, End_Hour__c, Start_Minute__c, End_Minute__c, LineItem__c, Product__c From Day_Part_Targeting__r),
                          (Select LineItem__c, Product__c, maxImpressions__c, numTimeUnits__c, timeUnit__c From Frequency_Caps__r),
                          (Select Ad_Unit__c, Product__c, includeDescendants__c, InventoryTargetingType__c, LineItem__c From Inventory_Target__r),
                          (Select Product__c, LineItem__c, Type__c, isTargeted__c, valueIds__c, Values__c From Technology_Targeting__r),
                          (Select Product__c, Line_Item__c, Placement__c From PlacementTargeting__r),
                          (Select Product__c, Line_Item__c,Label__c From AppliedLabel__r)
                      from product2 
                      where id =: prodId];
        */

        Product2 p = UtilProduct.getProductsByIds(new set<id>{prodId}).get(0);
                      
        list<lineItem__c> li = addProducts(new list<Product2>{p},null,oppId);
        
        PageReference editLI = Page.EditLineItem;
        editLI.getParameters().put('id', li[0].id);
        editLI.getParameters().put('firstTime', '1');
        editLI.getParameters().put('parentLineItem', parentLineItem);
        return editLI;
    }
    
    public PageReference checkCpd() {
        Product2 p = UtilProduct.getProductsByIds(new set<id>{prodId}).get(0);
        if(p.Delivery_Model__c == 'CPD' && p.CalcolaCPDconImprStimate__c) {
            impressionsStimateList = [SELECT
                AdUnit__c, 
                Feriali__c, 
                Festive__c, 
                Attivo__c, 
                AdUnit__r.Path__c, 
                AdUnit__r.Level__c 
                FROM Impressions_Stimate__c
                WHERE Product__c = :p.Id
                AND Attivo__c = true 
                ORDER BY AdUnit__r.Level__c ASC
            ];
            PageReference selectAdu = Page.SelectAdUnitForCpd;
        //    selectAdu.getParameters().put('parentLineItem', parentLineItem);
            return selectAdu;
        } else {
            return addProduct();    
        }
    }
    
    public PageReference addProductCpd(){
        Product2 p = UtilProduct.getProductsByIds(new set<id>{prodId}).get(0);
        list<lineItem__c> li = addProducts(
            new list<Product2>{p},
            null,
            oppId,
            new Impressions_Stimate__c(adUnit__c=selectedAdUnitId,Feriali__c = selectedFeriali,festive__c = selectedFestive)
        );

        PageReference editLI = Page.EditLineItem;
        editLI.getParameters().put('id', li[0].id);
        editLI.getParameters().put('firstTime', '1');
        editLI.getParameters().put('parentLineItem', parentLineItem);
        return editLI;
    }
    
    public PageReference backToAddProduct() {
        return Page.addProduct;
    }
    
    public PageReference addAdUnitForCpd() {
        return Page.addProduct;
    }
    
    public PageReference checkInventory() {
        Product2 p = [SELECT Id, CanalePrimario__c FROM Product2 WHERE Id = :prodId];
        Inventory_Target__c[] itL = [SELECT Id, Ad_Unit__c FROM Inventory_Target__c WHERE Product__c = :prodId];
        if(itL.size() == 1 && p.CanalePrimario__c == 'TimInternet') {
            this.selectedAdUnitId = itL[0].Ad_Unit__c;
            Impressions_Stimate__c[] is = [SELECT Feriali__c, Festive__c FROM Impressions_Stimate__c WHERE Product__c = :prodId AND AdUnit__c = :this.selectedAdUnitId];
            this.selectedFeriali = is.get(0) != null ? is.get(0).Feriali__c : 0;
            this.selectedFestive = is.get(0) != null ? is.get(0).Festive__c : 0;
            return addProductCpd();
        }
        return null;
    }
    
     @isTest
     public static void testController() {        
       utilityTest.createFattoreCorrettivoFasce();
         
         Product2 prod = new Product2(Family = 'DEM');
         prod.name = 'Test prod';
         insert prod;

        AdUnit__c adUnit1 = new AdUnit__c(
            Name = 'TestAD1',
            IdDfp__c = 'test1'  
        );
        insert adUnit1;
                 
        /* PriceBook2 pb = new PriceBook2(Name = 'Standard Price Book', Description = 'Price Book', IsActive = true);
         insert pb;
         
         PricebookEntry pbe = new PricebookEntry();
         pbe.UnitPrice = 10;
         pbe.Product2Id = prod.Id;
         pbe.Pricebook2Id = pb.Id;
         pbe.is
         insert pbe;
        */
         Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
         insert o;
         
         ApexPages.StandardController sc = new ApexPages.standardController(o);
         ExtensionAddProduct controller = new ExtensionAddProduct(sc);
         
         controller.search();
         controller.prodId = prod.Id;
         controller.addProduct();
         controller.getItems(Account.SobjectType.getDescribe().fields.getMap().get('Name')); 
         controller.searchPacchettoCombo();   
         controller.addPacchettoCombo();       
         
         controller.prodId = utilityTest.createBannerOas().id;      
         controller.addProduct(); 
    }

}