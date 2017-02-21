public class ControllerRipianificaLineItem {
    
    public LineItem__c lineItem {get; set;}
    public boolean errorOccurred {get;set;}
    public boolean hideRipianificaButton {get;set;}
    public boolean hideMinorRicavoButton {get;set;}
    private String lineItemId; 
    private Boolean lineItemModified;
    public Boolean lineItemSoloSuMesiAperti;
    public Boolean isLineItemSospeso;
    public Boolean existRevenueFatturate;

    public void getLineItem(){
        Boolean isLocalUser = [SELECT Id, Opportunity__r.Local__c FROM LineItem__c WHERE Id =:lineItemId].Opportunity__r.Local__c;
        Date dataChiusuraRicavi = RicavoTriggerHandler.getDataChiusuraRicavo(isLocalUser);
        
        lineItem = [SELECT Id,Name_dfp__c,Start_Date__c,Prezzo_net_net__c,Quantita__c,ImpressionsDelivered__c,Totale_erogato__c,Totale__c,
                                TotaleRipianificabile__c,Opportunity__c,Id_DFP__c,Id_oas__c,End_Date__c,Totale_ripianificato__c,ValoreRipianificabile__c,
                                Totale_ripianificato_positivo__c,RimozioneParteNonErogata__c,Ripianificato__c,Data_sospensione_erogazione__c,ImpressionErogateMinorRicavo__c,
                                End_Hour__c,End_minute__c,Status__c,Status_oas__c,Line_Item_Ripianificato__c,Opportunity__r.Local__c,Opportunity__r.Id_oas__c,
                                (SELECT Id, Data_primo_mese__c, Data_ultimo_mese__c 
                                    FROM Ricavi__r 
                                    WHERE Data_primo_mese__c > :dataChiusuraRicavi
                                    AND Valore__c > 0
                                    ORDER BY Data_primo_mese__c ASC),
                                (SELECT Id,Anno__c,Mese__c,Valore__c 
                                    FROM Revenue_applications__r 
                                    WHERE Ticket_Fatturazione__c != null)
                        FROM LineItem__c
                        WHERE Id =: lineItemId];
    }
     
    public ControllerRipianificaLineItem(){
        
        errorOccurred = false;
        hideRipianificaButton = true;
        lineItemModified = false;
        hideMinorRicavoButton = false;
        try{
            lineItemId = ApexPages.currentPage().getParameters().get('id');
            getLineItem();
            if(lineItem == null){
                errorOccurred = true;
                hideMinorRicavoButton = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'LineItem non trovato'));
                System.debug(LoggingLevel.WARN,'ERROR: LineItem non trovato');
                return;
            }

            if(!lineItem.Ripianificato__c && !lineItem.RimozioneParteNonErogata__c && !Test.isRunningTest()){ // è la prima volta che ripianifico questo LI, calcolo i campi per la ripianificazione
                try{
                    if(lineItem.Id_DFP__c != null){
                        DfpLineItemService.LineItemPage dfpResult = UtilityLineItemIntegration.getLineItemsByIds(new List<Decimal>{lineItem.Id_DFP__c});
                        for (DfpLineItemService.LineItem result : dfpResult.results) {
                            if(result.id == lineItem.Id_DFP__c){
                                lineItem.ImpressionErogateMinorRicavo__c = result.stats != null ? result.stats.impressionsDelivered : 0;
                                lineItem.Status__c = result.status;
                                break;
                            }
                        }
                    }else if(lineItem.Id_oas__c != null){
                        OasIntegration oas = new OasIntegration();
                        for(oasIntegration.campaignClass c : oas.getCampaignClass(oas.listCampaignsByOrderId(lineItem.Opportunity__r.Id_oas__c),false)){ //use string methods instead of regex 
                            if(c.id == lineItem.Id_oas__c){
                                lineItem.ImpressionErogateMinorRicavo__c = decimal.valueOf(c.ImpDelivered != null && c.ImpDelivered != '' ? c.ImpDelivered : '0') ;
                                lineItem.Status__c = c.status;
                                break;
                            }
                        }
                    }
                    if(lineItem.ImpressionErogateMinorRicavo__c > lineItem.Quantita__c){
                        hideMinorRicavoButton = true;
                        hideRipianificaButton = true;
                        errorOccurred = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Su questo line item il numero di impression erogate è superiore alle impressions pianificate. Non è possibile ripianificare.'));
                    }
                    //TODO eliminare prima del deploy
                    if(ApexPages.currentPage().getParameters().get('fakeStatus') != null){
                        lineItem.Status__c = ApexPages.currentPage().getParameters().get('fakeStatus');
                    }
                    if(ApexPages.currentPage().getParameters().get('fakeImpression') != null){
                        lineItem.ImpressionErogateMinorRicavo__c = Decimal.valueOf(ApexPages.currentPage().getParameters().get('fakeImpression'));
                    }
                    lineItemModified = true;
                    
                }catch(Exception e){
                    errorOccurred = true;
                    hideMinorRicavoButton = true;
                    if(e instanceof DMLException){
                        ApexPages.addMessages(e);
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                    }
                    System.debug(LoggingLevel.ERROR,'ERROR:'+e.getStackTraceString());
                    return;
                }
            }

            lineItemSoloSuMesiAperti = ControllerRicavi.isLineItemSoloSuMesiAperti(lineItem) && (lineItem.Line_Item_Ripianificato__c == null || ControllerRicavi.isLineItemSoloSuMesiApertiStorno(lineItem));
            existRevenueFatturate = lineItem.Revenue_applications__r.size()>0;
            if(lineItemSoloSuMesiAperti && !existRevenueFatturate){ // line item con ricavi solo su mesi aperti e non ci sono revenue fatturate, non è necessaria la ripianificazione, modificare direttamente
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Attenzione: Questo Line Item ha ricavi solo su mesi aperti, non è necessario ripianificarlo creando un nuovo Line Item. E\' possibile modificare direttamente questo Line Item.'));
                hideMinorRicavoButton = true;
                return;
            }
            
            // l'erogazione del line item è stata sospesa, a prescindere dal fatto che i ricavi siano solo su mesi aperti o no, posso ripianificare      

            if(ApexPages.currentPage().getParameters().get('fakeEndDate') == null){
                Time endTime = Time.newInstance(Integer.valueOf(lineItem.End_Hour__c),Integer.valueOf(lineItem.End_Minute__c),0,0);
                Datetime dataFineLineItemSfdc = Datetime.newInstance(lineItem.End_Date__c,endTime);
                Datetime dataFineLineItemAdServer = null;
                if(!Test.isRunningTest()){
                    dataFineLineItemAdServer = ExtensionEditLineItem.getDataFineLineItem(lineItem);
                }else{ // TEST
                    String endDateLineItemAdServer = ApexPages.currentPage().getParameters().get('endDateLineItemAdServer');
                    if(endDateLineItemAdServer == 'sameOfSalesforce'){
                        dataFineLineItemAdServer = dataFineLineItemSfdc; 
                    }else if(endDateLineItemAdServer == 'notSameOfSalesforce'){
                        dataFineLineItemAdServer = dataFineLineItemSfdc.addDays(-10);
                    }
                }
                if(dataFineLineItemAdServer == null){
                    errorOccurred = true;
                    hideMinorRicavoButton = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Non è stato possibile calcolare la data di fine del line item'));
                    System.debug(LoggingLevel.ERROR,'ERROR:Non è stato possibile calcolare la data di fine del line item');
                    return;
                }
                if(dataFineLineItemSfdc != dataFineLineItemAdServer){
                    errorOccurred = true;
                    hideMinorRicavoButton = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'La data di fine del Line Item su Salesforce è diversa da quella sull\' Ad Server. Verificare le date prima di procedere con la ripianificazione.'));
                    System.debug(LoggingLevel.ERROR,'ERROR: La data di fine del Line Item su Salesforce è diversa da quella sull\' Ad Server. Verificare le date prima di procedere con la ripianificazione.');
                    return;
                }
            }

            hideRipianificaButton = lineItem.Revenue_applications__r.size()>0 && ControllerRicavi.isLineItemSoloSuMesiAperti(lineItem);
            if(hideRipianificaButton){
                String msgError = 'Attenzione: Questo Line Item ha ricavi solo su mesi aperti, non è necessario ripianificarlo creando un nuovo Line Item.<br/>E\' possibile modificare direttamente il Line Item o rimuovere la parte non erogata.';
                msgError += '<br><br><b>Queste sono le Revenue Application già fatturate:</b><ul>';
                    for(Revenue_application__c revenue :  lineItem.Revenue_applications__r){
                        if(revenue.Mese__c == 'Totale'){
                            continue;
                        }
                        msgError += '<li>'+revenue.Mese__c+'&nbsp;&nbsp;'+revenue.Anno__c+'</li>';
                    }
                msgError += '</ul>';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,msgError));
            }
            
            
        }catch(Exception e){
            errorOccurred = true;
            hideMinorRicavoButton = true;
            printException(e);
        }
    }

    public void updateLineItem(){
        if(lineItemModified && !errorOccurred){
            update lineItem;
            getLineItem();
        }
    }
    
    public PageReference ripianifica(){
        PageReference pr = null;
        try{
            Boolean suspended = false;
            if(!isLineItemSospeso()){
                suspended = sospendiErogazione();
            }
            if(suspended){
                lineItem.Data_sospensione_erogazione__c = Datetime.now();
                lineItem.Ripianificato__c = true;
                update lineItem;
            }
            return new PageReference('/apex/addProduct?id='+lineItem.Opportunity__c+'&parentLineItem='+lineItemId);
        }catch(Exception e){
            errorOccurred = true;
            printException(e);
        }
        return pr;
    }
    
    public PageReference rimozioneParteNonErogata(){
        PageReference pr = null;
        SavePoint sp = null;
        try{
            Boolean suspended = false;
            if(!isLineItemSospeso()){
                if(!Test.isRunningTest()){
                    suspended = sospendiErogazione();
                }else{
                    suspended = true;
                    lineItem.Status__c = 'PAUSED';
                }
            }
            sp = Database.setSavepoint();
            if(suspended){
                lineItem.Data_sospensione_erogazione__c = Datetime.now();
            }
            lineItem.RimozioneParteNonErogata__c = true;
            update lineItem;
            
            ControllerRicavi ctrlRicavi = new ControllerRicavi();
            //ctrlRicavi.calcolaRicavi(lineItem, new LineItem__c()); CR
            LineItem__c lineItemRipianificazione = lineItem;
            lineItemRipianificazione.Totale__c = lineItem.ValoreRipianificabile__c;
            ctrlRicavi.calcolaRicavi(lineItem, lineItemRipianificazione);

            Revenue_application__c[] revenueMinorRicavi = ControllerRevenueApplication.getMinorRicavi(lineItem);
            LineItemTriggerHandler.skipUpdateLineItem = false;
            insert revenueMinorRicavi;
            
            pr = goBack();
        }catch(Exception e){
            errorOccurred = true;
            printException(e);
            Database.rollback(sp);
        }
        return pr;
    }
    
    public PageReference goBack(){
        return new PageReference('/apex/editLineItem?id='+lineItemId+'&sfdc.override=1');
    }
     
    private void printException(Exception e){
        if(e instanceof DMLException){
             ApexPages.addMessages(e);
        }else{
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()+'<br/>'+e.getStackTraceString()));
        }
        System.debug(LoggingLevel.ERROR,'ERROR: '+e.getMessage()+' - '+e.getStackTraceString());
    }

    public boolean sospendiErogazione(){
        boolean suspended = false;
        if(lineItem.id_DFP__c != null){
            UtilityLineItemIntegration.pauseLineItems(new Decimal[]{lineItem.id_DFP__c});
            lineItem.Status__c = 'PAUSED';
            suspended = true;
        }else if(lineItem.Id_Oas__c != null){ // line item su OAS
            OasIntegration oas = new OasIntegration();
            oas.updateCampaignsStatus(new String[]{(String)lineItem.Id_Oas__c},OasIntegration.OAS_STATUS.get('Suspended'));
            lineItem.Status_oas__c = 'S';
            lineItem.Stato_lavorazione_OAS__c = 'Sospeso';
            suspended = true;
        }
        return suspended;
    }    

    public boolean isLineItemSospeso(){
        boolean sospeso = false;
        System.debug(LoggingLevel.ERROR,lineItem.id_DFP__c);
        System.debug(LoggingLevel.ERROR,lineItem.Status__c);
        if(lineItem.id_DFP__c != null){
            if(lineItem.Status__c == 'PAUSED' || lineItem.Status__c == 'COMPLETED'){
                sospeso = true;
            }
        }else if(lineItem.Id_Oas__c != null){ // line item su OAS
            if(lineItem.Status_oas__c == OasIntegration.OAS_STATUS.get('Suspended') || lineItem.Status_oas__c == OasIntegration.OAS_STATUS.get('Completed')){
                sospeso = true;
            }
        }
        return sospeso;
     }    
    
}