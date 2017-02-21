global class BatchableCreateRicavi implements Database.Batchable<SObject>, Database.Stateful{

    private static String query = 'SELECT Line_Item__c, Anno__c, Mese__c, Percentuale_applicata__c, Valore__c,LiStartDateStorico__c,LiEndDate__c,LiSconto__c,LiScontoTotale__c,LiPrezzoNetNet__c,LiTotale__c,RaValore__c,RaPercentuale_applicata__c,RaAnno__c,RaMese__c,RaDataPrimoMeseStorico__c,RaTipoAccountDirettaStorico__c,RaCapoGruppoCentroMediaStorico__c,OpVenditoreBrandPortafoglioStorico__c,LiSottoClasseStorico__c,OpCentroMediaStorico__c,OpVenditoreBrandStoricoStorico__c,OpVenditoreCMStoricoStorico__c,OpAgenziaDiRiferimentoStoricoStorico__c,OpAgenziaRiferimentoPortafoglioStorico__c,LiQuantitStorico__c,LiClasseProdottoStorico__c,OpVenditoreCMPortafoglioStorico__c,OpTipoOpportunityStorico__c,OpCanaleDiVenditaStorico__c FROM Revenue_application__c';
    private String errorCsv = '';
    
    global Database.Querylocator start(Database.BatchableContext BC) {
        errorCsv = 'ErrorMessage,StatusCode,Fields\n';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        List<Ricavo__c> ricavi = new List<Ricavo__c>();
        for(sObject sObjRevenue : scope){
            Revenue_application__c revenue = (Revenue_application__c) sObjRevenue;
            Ricavo__c ricavo = new Ricavo__c();
            ricavo.Line_Item__c = revenue.Line_Item__c;
            ricavo.Anno__c = revenue.Anno__c;
            ricavo.Mese__c = revenue.Mese__c;
            ricavo.Percentuale_applicata__c = revenue.Percentuale_applicata__c;
            ricavo.Valore__c = revenue.Valore__c;
            ricavo.Modificato__c = true;
            
            ricavo.LiStartDateStorico__c = revenue.LiStartDateStorico__c;
            ricavo.LiEndDate__c = revenue.LiEndDate__c;
            ricavo.LiSconto__c = revenue.LiSconto__c;
            ricavo.LiScontoTotale__c = revenue.LiScontoTotale__c;
            ricavo.LiPrezzoNetNet__c = revenue.LiPrezzoNetNet__c;
            ricavo.LiTotale__c = revenue.LiTotale__c;
            ricavo.RiValore__c = revenue.RaValore__c;
            ricavo.RiPercentuale_applicata__c = revenue.RaPercentuale_applicata__c;
            ricavo.RiAnno__c = revenue.RaAnno__c;
            ricavo.RiMese__c = revenue.RaMese__c;
            ricavo.RiDataPrimoMeseStorico__c = revenue.RaDataPrimoMeseStorico__c;
            ricavo.RiTipoAccountDirettaStorico__c = revenue.RaTipoAccountDirettaStorico__c;
            ricavo.RiCapoGruppoCentroMediaStorico__c = revenue.RaCapoGruppoCentroMediaStorico__c;
            ricavo.OpVenditoreBrandPortafoglioStorico__c = revenue.OpVenditoreBrandPortafoglioStorico__c;
            ricavo.LiSottoClasseStorico__c = revenue.LiSottoClasseStorico__c;
            ricavo.OpCentroMediaStorico__c = revenue.OpCentroMediaStorico__c;
            ricavo.OpVenditoreBrandStoricoStorico__c = revenue.OpVenditoreBrandStoricoStorico__c;
            ricavo.OpVenditoreCMStoricoStorico__c = revenue.OpVenditoreCMStoricoStorico__c;
            ricavo.OpAgenziaDiRiferimentoStoricoStorico__c = revenue.OpAgenziaDiRiferimentoStoricoStorico__c;
            ricavo.OpAgenziaRiferimentoPortafoglioStorico__c = revenue.OpAgenziaRiferimentoPortafoglioStorico__c;
            ricavo.LiQuantitStorico__c = revenue.LiQuantitStorico__c;
            ricavo.LiClasseProdottoStorico__c = revenue.LiClasseProdottoStorico__c;
            ricavo.OpVenditoreCMPortafoglioStorico__c = revenue.OpVenditoreCMPortafoglioStorico__c;
            ricavo.OpTipoOpportunityStorico__c = revenue.OpTipoOpportunityStorico__c;
            ricavo.OpCanaleDiVenditaStorico__c = revenue.OpCanaleDiVenditaStorico__c;
            
            ricavi.add(ricavo);
        }
        LineItemTriggerHandler.skipValidationTotali = true;
        UtilityTrigger.skipTrigger = true;
        Database.SaveResult[] result = Database.insert(ricavi,false);
        LineItemTriggerHandler.skipValidationTotali = false;
        System.debug(result);
        for (Database.SaveResult sr : result) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    errorCsv += err.getMessage()+','+err.getStatusCode()+','+err.getFields()+'\n';
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        Document d = new Document();
        d.Name = 'Report ricavi non creati'+Datetime.now()+'.csv';
        d.folderId = UserInfo.getUserId();
        d.body = Blob.valueOf(errorCsv);
        insert d;
    }
}