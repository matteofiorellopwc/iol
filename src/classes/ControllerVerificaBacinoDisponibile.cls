public class ControllerVerificaBacinoDisponibile {

    public ForecastCPM forecast {get;set;}

    public Boolean isRunning {get;set;}

    public LineItem__c lineItem {get;set;} 

    public String idLineItem {get;set;}

    public ControllerVerificaBacinoDisponibile() {
        isRunning = false;
    }

    /*
        Crea finti line item, li carica in memoria e fa subito il rollback.
        In questo modo non sono salvati sul DB ma si possono sfruttare i metodi già esistenti per il forecast.
        Non si possono fare subito le callout allora si mette sono isRunning = true
    */
    public void startCPMAvailability(){
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
                    WHERE Id = :idLineItem
                    ];

        LineItem__c[] lis = new LineItem__c[]{lineItem};
        string query = Util.getFieldsSOQL('LineItem__c',' id in : lis ',false,UtilityLineItemIntegration.getAdditionaFields(),false);
        lis = database.query(query);
        if(lis.size()>0){
            LineItem__c li = lis[0];
            forecast = new ForecastCPM(li,'intero periodo');
        }

        isRunning = true;
    }

    public void processForecast(){
        System.debug('called processForecast');
        if(isRunning){
            DfpIntegration dfp = new DfpIntegration();
            if(!forecast.processed){
                forecast.processForecast(dfp);
            }
            isRunning = false;
        }
    }

    public class ForecastCPM{
        public Boolean processed {get;set;}
        public LineItem__c li {get;set;}
        public String error {get;set;}
        public String key {get;set;}
        public ControllerForecast.Forecast forecast {get;set;}
        public ForecastCPM(LineItem__c li,String key){
            this.processed = false;
            error = null;
            this.li = li;
            this.key = key;         
            this.forecast = new ControllerForecast.Forecast();
        }
        public void processForecast(DfpIntegration dfp){
            try{
            	Date tomorrow = Date.today().addDays(1);
            	if(li.Start_Date__c < tomorrow){
	                li.Start_Date__c = tomorrow;
	            }
                forecast = ControllerForecast.staticCheckAvailability(dfp,li);

            }catch(exception e){
                error = e.getMessage();
                System.debug(e.getStackTraceString());
            }
            processed = true;
        }
    }


}