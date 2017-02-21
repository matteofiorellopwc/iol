global without sharing class CPMAvailabilityControllerLocal {

    public list<SelectOption> formati {get;set;}
    public map<String,list<SelectOption>> prodotti {get;set;}

    public String formatoSelected {get;set;}
    public String prodottoSelected {get;set;}

    public String formattedStartDate {get;set;}
    public String formattedEndDate {get;set;}
    public String[] dates {get;set;}

    public Map<Id,Product2> productsMap {get;set;} //map Id -> prodotto
    public Map<Id,ForecastCPM[]> forecastMap {get;set;} //map id prodotto -> lista di forecast, 1 per data

    public Boolean isRunning {get;set;}

    public String ProductDetail {get;set;}

    public String productIdForecastDetail {get;set;}
    public String keyForecastDetail {get;set;}
    public ForecastCPM forecastDetail {get;set;}   

    public Opportunity opportunity {get;set;}
    public LineItem__c lineItem {get;set;} 
    private Id AccountId {get;set;}

    //Tab visibility
    public boolean isVisibleDayPartTab {get;set;}
    public boolean isVisibleFrequencyCapTab {get;set;}
    public boolean isVisibleInventoryTargetTab {get;set;}
    public boolean isVisibleTechnologyTargetTab {get;set;}
    public boolean isVisibleCustomCriteriaTab {get;set;}
    public boolean isVisibleCookiesTab {get;set;}
    public boolean isVisiblePagesSectionsTab {get;set;}
    public boolean isVisibleGeographyTab {get;set;}

    public boolean canEditOpportunity {get;set;}

    private final Integer MAX_FORECAST_PROCESSED_PER_ITERATION = 9; //10 - refresh token

    public CPMAvailabilityControllerLocal() {
        
        formattedStartDate = Date.today().addDays(5).Format();
        formattedEndDate = Date.today().addDays(6).Format();
        dates = new String[]{};

        prodotti = new map<String,list<SelectOption>>();
        formati = new list<SelectOption>();
        formati.add(new SelectOption('','--seleziona--'));
        
        User Utente = [SELECT Id, Visualizza_prodotti_Network__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(Utente.Visualizza_prodotti_Network__c){
            productsMap = new Map<Id,Product2>([Select Name,Id,Formato__c
                                                    from Product2 
                                                    where delivery_model__c = 'CPM'
                                                    and type__c = 'STANDARD'
                                                    and Integrato_con_DFP_formula__c = 'true'
                                                    and isActive = true
                                                    and formato__c <> null
                                                    and Local__c = true
                                                ]);
        } else {
            productsMap = new Map<Id,Product2>([Select Name,Id,Formato__c
                                                    from Product2 
                                                    where delivery_model__c = 'CPM'
                                                    and type__c = 'STANDARD'
                                                    and Integrato_con_DFP_formula__c = 'true'
                                                    and isActive = true
                                                    and formato__c <> null
                                                    and Local__c = true
                                                    and categoria_libero__c <> 'Network'
                                                ]);
        }
        
        for(Product2 p : productsMap.values()){
            if(!prodotti.containsKey(p.Formato__c)){
                prodotti.put(p.Formato__c,new list<SelectOption>());
                prodotti.get(p.Formato__c).add(new SelectOption('','--seleziona--'));   
                formati.add(new SelectOption(p.Formato__c,p.Formato__c));
            }
            prodotti.get(p.Formato__c).add(new SelectOption(p.Id,p.Name));
        }
        formati.sort();

        AccountId = [Select Id from Account where RecordType.Name = 'Brand' and Id_Dfp__c <> null limit 1].Id;

        isRunning = false;
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
        ids.add(prodottoSelected);
        lineItem = ExtensionAddProduct.addProducts(UtilProduct.getProductsByIds(ids),null,opportunity.Id)[0];
        lineItem.Ad_Server__c = [SELECT Ad_Server_formula__c FROM LineItem__c WHERE Id = :lineItem.Id].Ad_Server_formula__c;
        update lineItem;
        lineItem = [ SELECT Id,Product__c,Product__r.InventoryTargetType__c,IsInventoryTargetingInclude__c,IsInventoryTargetingExclude__c,Product__r.Size__c,
                        Product__r.Target_platform__c,Product__r.CanalePrimario__c,IsPagesSectionsInclude__c,IsPagesSectionsExclude__c,IsInventoryTargetingEdit__c,
                        Product__r.Family,Integrato_con_DFP_formula__c,Opportunity__c,Opportunity__r.DataPrimaChiusaVinta__c,Opportunity__r.Profili_blocco_dopo_prima_chiusura__c,
                        Profili_gestione_targeting_lineitem__c,IsPagesSectionsEdit__c,ProductFamily__c,Integrato_con_OAS_formula__c,NonIntegratoAdServer__c,Ad_Server__c,
                        Delivery_Model__c,Ad_Server_formula__c,IsFrequencyCapEdit__c,IsDayPartTargetingEdit__c,IsCustomCriteriaEdit__c,IsTechnologyTargetingEdit__c,
                        IsCookieSearchTermEdit__c,IsGeographyTargetEdit__c,
                        (SELECT Id FROM Inventory_Target__r),
                        (SELECT Id FROM PlacementTargeting__r),
                        (SELECT Id FROM SectionsOasTargeted__r),
                        (SELECT Id FROM Frequency_Caps__r),
                        (SELECT Id FROM Day_Part_Targeting__r),
                        (SELECT Id FROM Custom_Criteria_Set__r),
                        (SELECT Id FROM CookieSearchTermsOASTargeted__r),
                        (SELECT Id FROM Geography__r)
                    FROM LineItem__c 
                    WHERE Id = :lineItem.Id
                    ];

        isVisibleInventoryTargetTab = !(lineItem.Inventory_Target__r.isEmpty() && lineItem.PlacementTargeting__r.isEmpty());
        isVisiblePagesSectionsTab = !(lineItem.Inventory_Target__r.isEmpty() && lineItem.SectionsOasTargeted__r.isEmpty());
        isVisibleFrequencyCapTab = !lineItem.Frequency_Caps__r.isEmpty();
        isVisibleDayPartTab = !lineItem.Day_Part_Targeting__r.isEmpty();
        isVisibleCustomCriteriaTab = !lineItem.Custom_Criteria_Set__r.isEmpty();
        isVisibleCookiesTab = !lineItem.CookieSearchTermsOASTargeted__r.isEmpty();
        isVisibleGeographyTab = !lineItem.Geography__r.isEmpty();
        isVisibleTechnologyTargetTab = false;
        for(TechnologyTargeting__c tech : [SELECT Id,valueIds__c FROM TechnologyTargeting__c WHERE Id in :lineItem.Technology_Targeting__r]){
            if(tech.valueIds__c != null && tech.valueIds__c.trim().length()>0){
                isVisibleTechnologyTargetTab = true;
                break;
            }
        }

    }

    public void deleteProduct(){
        if(lineItem != null){
            delete lineItem;
            lineItem = null;
        }
        resetProductDetail();
        forecastDetail = null;
    }

    /*
        Crea finti line item, li carica in memoria e fa subito il rollback.
        In questo modo non sono salvati sul DB ma si possono sfruttare i metodi già esistenti per il forecast.
        Non si possono fare subito le callout allora si mette sono isRunning = true
    */
    public void startCPMAvailability(){

        

        if(String.isBlank(formattedStartDate) || String.isBlank(formattedEndDate) ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire data di inizio e fine'));
            return;
        }

        Date startdate,enddate;

        try{
            startdate = Date.parse(formattedStartDate);
            enddate = Date.parse(formattedEndDate);             
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire data di inizio e fine nel formato corretto'));
            return;
        }

        UtilityTrigger.skipTrigger = true;
        update lineItem;

        resetProductDetail();
        forecastMap = new Map<Id,ForecastCPM[]>();
        dates = new String[]{};

        forecastDetail = null;

        ProductDetail = prodottoSelected;

        LineItem__c[] lis = new LineItem__c[]{lineItem};
        string query = Util.getFieldsSOQL('LineItem__c',' id in : lis ',false,UtilityLineItemIntegration.getAdditionaFields(),false);
        lis = database.query(query);
        if(lis.size()>0){
            LineItem__c li = lis[0];
            forecastMap.put(li.Product__c,new ForecastCPM[]{});
            for(Date d=startdate;d<=enddate;d=d.addDays(1)){
                forecastMap.get(li.Product__c).add(new ForecastCPM(li,d,d,d.format()));
            }
            if(startDate != endDate){
                forecastMap.get(li.Product__c).add(new ForecastCPM(li,startDate,endDate,'intero periodo')); 
            }
            for(Date d=startdate;d<=enddate;d=d.addDays(1)){
                dates.add(d.format());
            }
        }

        isRunning = true;
    }

    public void resetProductDetail(){
        ProductDetail = null;
    }

    /*
        la pagina continua a richiamare questo metodo finchè ci sono forecast non processati
    */
    public void processForecast(){
        System.debug('called processForecast');
        if(isRunning){
            DfpIntegration dfp = null;//new DfpIntegration();
            if(ApexPages.currentPage().getParameters().get('fakeForecast') == null){
                dfp = new DfpIntegration();
            }
            Integer forecastProcessed = 0;

            for(Id i : forecastMap.keySet()){
                for(ForecastCPM f : forecastMap.get(i)){
                    if(!f.processed){
                        System.debug('process '+f.li);
                        f.processForecast(dfp);
                        forecastProcessed++;
                    }
                    if(forecastProcessed == MAX_FORECAST_PROCESSED_PER_ITERATION){
                        break;
                    }
                }
                if(forecastProcessed == MAX_FORECAST_PROCESSED_PER_ITERATION){
                    break;
                }   

                System.debug('forecastProcessed = '+forecastProcessed);
            }

            if(forecastProcessed < MAX_FORECAST_PROCESSED_PER_ITERATION){
                isRunning = false;
            }
        }
    }

    /*
        Carica i dettagli dei line items contending da DFP
    */
    public void showForecastDetail(){
        System.debug(productIdForecastDetail);
        System.debug(keyForecastDetail);
        for(ForecastCPM f : forecastMap.get(productIdForecastDetail)){
            if(f.key == keyForecastDetail){
                forecastDetail = f;
                break;
            }
        }
        if(!Test.isRunningTest()){
            forecastDetail.getContendingDetail();
        }
    }

    public class ForecastCPM{
        public Boolean processed {get;set;}
        public LineItem__c li {get;set;}
        public Map<Decimal,ContendingLineItem> contendingLineItems {get;set;}
        public Boolean existContendingLineItems {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String error {get;set;}
        public String key {get;set;}
        public ControllerForecast.Forecast forecast {get;set;}
        public ForecastCPM(LineItem__c li,Date startDate,Date endDate,String key){
            this.processed = false;
            error = null;
            this.li = li;
            this.startDate = startDate;
            this.endDate = endDate;
            this.key = key;         
            this.forecast = new ControllerForecast.Forecast();
        }
        public void processForecast(DfpIntegration dfp){
            try{
                li.Start_Date__c = startDate;
                li.End_Date__c = endDate;
                li.Quantita__c = 1;

                if(ApexPages.currentPage().getParameters().get('fakeForecast') != null){
                    /* fake forecast for testing **/
                    forecast = new ControllerForecast.Forecast();
                    forecast.matchedUnits = 1000000 + Math.roundToLong((1000000 * Math.random()));
                    forecast.availableUnits = (Long) (forecast.matchedUnits * 0.6);
                    forecast.contendingLineItems = new DfpForecastService.ContendingLineItem[]{
                        new DfpForecastService.ContendingLineItem(),
                        new DfpForecastService.ContendingLineItem()
                    };
                    forecast.contendingLineItems[0].lineItemId = 88269890;   
                    forecast.contendingLineItems[0].contendingImpressions = (Long) (forecast.availableUnits*0.03);

                    forecast.contendingLineItems[1].lineItemId = 87667130;
                    forecast.contendingLineItems[1].contendingImpressions = (Long) (forecast.availableUnits*0.02);
                    /**/                    
                }else{
                    forecast = ControllerForecast.staticCheckAvailability(dfp,li);
                }

                contendingLineItems = new Map<Decimal,ContendingLineItem>();
                if(forecast.contendingLineItems != null){
                    existContendingLineItems = forecast.contendingLineItems.size() > 0;
                    for(DfpForecastService.ContendingLineItem cLi : forecast.contendingLineItems){
                        contendingLineItems.put(cLi.lineItemId, new ContendingLineItem(cLi));
                    }
                }else{
                    existContendingLineItems = false;
                }
            }catch(exception e){
                error = e.getMessage();
                System.debug(e.getStackTraceString());
            }
            processed = true;
        }
        public void getContendingDetail(){
            for(DfpLineItemService.LineItem li : UtilityLineItemIntegration.getLineItemsByIds(new List<Decimal>(contendingLineItems.keySet())).results){
                contendingLineItems.get(li.id).mergeFields(li);
            } 
        }
    }
    public class ContendingLineItem{
        public Long lineItemId {get;set;}
        public Long contendingImpressions {get;set;}
        public String startDateTimeFormat {get;set;}
        public String endDateTimeFormat {get;set;}
        public String name {get;set;}
        public Decimal quantita {get;set;}
        public Integer priority {get;set;}
        public String costType {get;set;}

        public ContendingLineItem(DfpForecastService.ContendingLineItem dfpCLi){
            this.lineItemId = dfpCLi.lineItemId;
            this.contendingImpressions = dfpCLi.contendingImpressions;
        }
        public void mergeFields(DfpLineItemService.LineItem dfpLi){
            this.startDateTimeFormat = UtilityDataValue.getSalesforceDateTime(dfpLi.startDateTime).format(); 
            this.endDateTimeFormat = UtilityDataValue.getSalesforceDateTime(dfpLi.endDateTime).format();
            this.name = dfpLi.name;
            this.quantita = dfpLi.contractedunitsBought;
            this.priority = dfpLi.priority;
            this.costType = dfpLi.costType;
        }
    }

    @RemoteAction
    global static void deleteObsoleteData(){
        delete [SELECT Id FROM LineItem__c WHERE Opportunity__r.Name LIKE '%Test_CPM_availability' AND Opportunity__r.Tipo_Opportunity__c = 'Test' AND CreatedBy.Id = :UserInfo.getUserId()];
    }   
}