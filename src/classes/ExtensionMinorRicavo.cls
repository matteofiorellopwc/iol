public class ExtensionMinorRicavo {

    public LineItem__c lineItem {get;set;}
    public Boolean erogatoDisponibile {get;set;}
    public Boolean primoMinorRicavo {get;set;}
    public Boolean errorOccurred {get;set;}
    private Boolean lineItemModified;
    public boolean hideRipianificaButton {get;set;}
    public boolean hideRimuoviNonErogatoButton {get;set;}
    public Boolean minorRicavoMustBeApproved {
        get{
            return canMinorRicavoBeApproved() && primoMinorRicavo && (!erogatoDisponibile || stornoOverflow || erogatoSuperioreVenduto);
        }
    }
    public Boolean stornoOverflow {
        get{
            return lineItem.TotaleRipianificabileRichiesto__c > maxValueTotaleRipianificabileApproved ;
        }
    }
    public Boolean canBeApproved {
        get{
            return canMinorRicavoBeApproved();
        }
    }
    public Boolean isApprovalPendingOrRejected{
        get {
            return lineItem.ApprovazioneMinorRicavo__c == 'Rejected' || lineItem.ApprovazioneMinorRicavo__c == 'Submitted for approval';
        }
    }
    public Decimal maxValueImpressionsRipianificabile {get;set;}
    public Decimal maxValueTotaleRipianificabile {get;set;}
    public Decimal maxValueImpressionsRipianificabileApproved {get;set;}
    public Decimal maxValueTotaleRipianificabileApproved {get;set;}
    public Boolean hideButtons{
        get{
            if(lineItem.ApprovazioneMinorRicavo__c == 'Approved' || lineItem.ApprovazioneMinorRicavo__c == 'Unnecessary'){
                return lineItem.ValoreRipianificabileApprovatoFormula__c <= 0;
            }
            return false;
        }
    }
    public Boolean isQuantitaAvailable {
        get{
            if( ( LineItem.ProductFamily__c == 'DEM' || 
                LineItem.ProductFamily__c == 'Editoriali' ||
                LineItem.Type_DFP__c == 'STANDARD' ||
                LineItem.Type_DFP__c == 'BULK' ||
                LineItem.Type_DFP__c == 'PRICE_PRIORITY' ) && 
                LineItem.Delivery_Model__c <> 'CPD' && 
                (LineItem.Duration__c <> 'DAILY' || LineItem.Delivery_Model__c == 'CPM')){
                    return true;
            }
            return false;
            
        }
    }
    private Boolean erogatoSuperioreVenduto;
    private List<Revenue_application__c> revenuesFatturate;

    public ExtensionMinorRicavo(ApexPages.StandardController stdController) {
        try{
            lineItem = (LineItem__c) stdController.getRecord();
            primoMinorRicavo = isPrimoMinorRicavo();
            erogatoDisponibile = isErogatoDisponibile();
            errorOccurred = false;
            lineItemModified = false;
            hideRipianificaButton = true;
            hideRimuoviNonErogatoButton = true;
            erogatoSuperioreVenduto = false;
            revenuesFatturate = [Select Id, Anno__c, Mese__c FROM Revenue_application__c WHERE Id in :lineItem.Revenue_applications__r AND Ticket_Fatturazione__c != NULL];
            if(lineItem.Totale__c == 0){
                errorOccurred = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il valore di questo line item è 0. Non è possibile eseguire alcuna operazione'));
                return;
            }
            
            if(isLineItemIntegratoConAdServer()){
                if(!lineItem.Ripianificato__c && !lineItem.RimozioneParteNonErogata__c && !Test.isRunningTest()){ // è la prima volta che ripianifico questo LI, calcolo i campi per la ripianificazione
                    Decimal previousImpressionsErogate = lineItem.ImpressionErogateMinorRicavo__c;
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
                    if(previousImpressionsErogate != lineItem.ImpressionErogateMinorRicavo__c){
                        lineItemModified = true;    
                    }
                    erogatoSuperioreVenduto = lineItem.ImpressionErogateMinorRicavo__c > lineItem.Quantita__c;
                    /*if(lineItem.ImpressionErogateMinorRicavo__c > lineItem.Quantita__c){
                        errorOccurred = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Su questo line item il numero di impression erogate è superiore alle impressions pianificate. Non è possibile ripianificare.'));
                    }*/
                    //TODO eliminare prima del deploy
                    /*if(ApexPages.currentPage().getParameters().get('fakeStatus') != null){
                        lineItem.Status__c = ApexPages.currentPage().getParameters().get('fakeStatus');
                    }
                    if(ApexPages.currentPage().getParameters().get('fakeImpression') != null){
                        lineItem.ImpressionErogateMinorRicavo__c = Decimal.valueOf(ApexPages.currentPage().getParameters().get('fakeImpression'));
                    }
                    */
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
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Non è stato possibile calcolare la data di fine del line item'));
                        System.debug(LoggingLevel.ERROR,'ERROR:Non è stato possibile calcolare la data di fine del line item');
                        return;
                    }
                    if(dataFineLineItemSfdc != dataFineLineItemAdServer){
                        errorOccurred = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'La data di fine del Line Item su Salesforce è diversa da quella sull\' Ad Server. Verificare le date prima di procedere con la ripianificazione.'));
                        System.debug(LoggingLevel.ERROR,'ERROR: La data di fine del Line Item su Salesforce è diversa da quella sull\' Ad Server. Verificare le date prima di procedere con la ripianificazione.');
                        return;
                    }
                }
            }
            
            
            /*if(Datetime.now() > lineItem.StartDateTimeFormula__c){
                hideRimuoviNonErogatoButton = false;
                if(revenuesFatturate.size()>0 || !ControllerRicavi.isLineItemSoloSuMesiAperti(lineItem)){
                    hideRipianificaButton = false;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Attenzione: Questo line item non può essere ripianificato. <br/> E\' possibile modificare direttamente il Line Item o rimuovere la parte non erogata.'));
                    hideRipianificaButton = true;    
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Attenzione: Questo Line Item non è ancora partito.<br/>E\' possibile modificare direttamente il Line Item.'));
                hideRimuoviNonErogatoButton = true;
                hideRipianificaButton = true;
            }*/

            if(revenuesFatturate.size()>0 || !ControllerRicavi.isLineItemSoloSuMesiAperti(lineItem)){
                hideRimuoviNonErogatoButton = false;
                hideRipianificaButton = false;
            } else {
                if (Datetime.now() > lineItem.StartDateTimeFormula__c) {
                    hideRimuoviNonErogatoButton = false;
                    hideRipianificaButton = false;
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning,'Attenzione: Questo Line Item non è ancora partito.<br/>E\' possibile modificare direttamente il Line Item.'));
                }
            }

            System.debug('Primo minor ricavo? '+primoMinorRicavo);
            if(primoMinorRicavo){
                preventNull();
            }

            maxValueImpressionsRipianificabile = lineItem.Quantita__c;
            maxValueTotaleRipianificabile = lineItem.Totale__c;
            maxValueTotaleRipianificabileApproved = lineItem.TotaleRipianificabile__c;      

            if(isQuantitaAvailable){
                maxValueImpressionsRipianificabileApproved = lineItem.Quantita__c - lineItem.ImpressionErogateMinorRicavo__c;    
            }

            if(primoMinorRicavo){
                populateDefaultValuesOnLineItem();
            }
        }catch(Exception e){
            errorOccurred = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            System.debug(LoggingLevel.ERROR,'ERROR:'+e.getMessage()+','+ e.getStackTraceString());
            return;
        }

        
    }

    
    public PageReference updateLineItem(){
        ApexPages.currentPage().getParameters().put('fieldModified','TotaleRipianificabile');
        if(!errorOccurred){
            aggiornaValoriStorno();
            if(lineItemModified){
                update lineItem;
                PageReference p = new PageReference('/apex/MinorRicavo?id='+lineItem.Id);
                p.setRedirect(true);
                return p;
            }
        }
        return null;
    }
    
    
    public PageReference goBack(){
        return new PageReference('/apex/editLineItem?id='+lineItem.Id+'&sfdc.override=1');
    }
    
    
    public PageReference switchToMinorRicavoParziale(){
        PageReference pr = null;
        pr = new PageReference('/apex/MinorRicavoParziale?id='+lineItem.Id);   
        return pr;
    }
    
    
    public PageReference ripianifica(){
        if(minorRicavoMustBeApproved){
            return null;
        }
        
        PageReference pr = null;
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
            if(suspended){
                lineItem.Data_sospensione_erogazione__c = Datetime.now();
            }
            lineItem.Ripianificato__c = true;
            update lineItem;
            
            if(lineItem.ApprovazioneMinorRicavo__c == 'Unclaimed'){
                setMinorRicavoAsApproved();
            }
            return new PageReference('/apex/addProduct?id='+lineItem.Opportunity__c+'&parentLineItem='+lineItem.Id);
        }catch(Exception e){
            errorOccurred = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()+'<br/>'+e.getStackTraceString()));
            System.debug(LoggingLevel.ERROR,'ERROR: '+e.getMessage()+' - '+e.getStackTraceString());
        }
        return pr;
    }

    public PageReference rimozioneParteNonErogata(){
        if(minorRicavoMustBeApproved){
            return null;
        }
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
            
            if(lineItem.ApprovazioneMinorRicavo__c == 'Unclaimed'){
                setMinorRicavoAsApproved();
            }
            lineItem = refreshLineItem();
            ControllerRicavi ctrlRicavi = new ControllerRicavi();
            LineItem__c lineItemRipianificazione = lineItem;
            lineItemRipianificazione.Totale__c = lineItem.ValoreRipianificabileApprovatoFormula__c;
            ctrlRicavi.calcolaRicavi(lineItem, lineItemRipianificazione);

            Revenue_application__c[] revenueMinorRicavi = ControllerRevenueApplication.getMinorRicavi(lineItem);
            LineItemTriggerHandler.skipUpdateLineItem = false;
            insert revenueMinorRicavi;
            
            pr = goBack();
        }catch(Exception e){
            errorOccurred = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()+'<br/>'+e.getStackTraceString()));
            System.debug(LoggingLevel.ERROR,'ERROR: '+e.getMessage()+' - '+e.getStackTraceString());
            if(sp != null){
                Database.rollback(sp);
            }
        }
        return pr;
    }

    private void setMaxImpressionsRipianificabili(){
        lineItem.QuantitaRipianificabileRichiesta__c = maxValueImpressionsRipianificabile;
    }
    private void setMaxTotaleRipianificabile(){
        lineItem.TotaleRipianificabileRichiesto__c = maxValueTotaleRipianificabile;
        lineItem.ValoreRipianificabileRichiesto__c = lineItem.TotaleRipianificabileRichiesto__c - lineItem.Totale_ripianificato_positivo__c;
    }
    public PageReference requireApproval(){ 
        try{
            update lineItem;
            PageReference p = new PageReference('/apex/MinorRicavo?id='+lineItem.Id);
            p.setRedirect(true);
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(lineItem.id);
            if(!Test.isRunningTest()){
               Approval.ProcessResult result = Approval.process(req1);
           }
            
            return p;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            System.debug(e.getMessage());
        }
        return null;
    }
    public void setMaxValoriStorno(){
        setMaxImpressionsRipianificabili();
        setMaxTotaleRipianificabile();
    }

    public void aggiornaValoriStorno(){
        String fieldModified = ApexPages.currentPage().getParameters().get('fieldModified');
        if(fieldModified == 'TotaleRipianificabile'){
            lineItem.ValoreRipianificabileRichiesto__c = lineItem.TotaleRipianificabileRichiesto__c - lineItem.Totale_ripianificato_positivo__c;
            if(isQuantitaAvailable){
                calcolaImpressionsDaValoreTotale();
            }
        }if(fieldModified == 'ImpressionsRipianificabili'){
            calcolaValoreTotaleDaImpression();
        }
    }

    private Boolean canMinorRicavoBeApproved(){
        return lineItem.ApprovazioneMinorRicavo__c != 'Approved' && lineItem.ApprovazioneMinorRicavo__c != 'Rejected' && lineItem.ApprovazioneMinorRicavo__c != 'Submitted for approval';
    }
    private void setMinorRicavoAsApproved(){
        try{
            lineItem.QuantitaApprovata__c = lineItem.QuantitaRipianificabileRichiesta__c;
            lineItem.TotaleRipianificabileApprovato__c = lineItem.TotaleRipianificabileRichiesto__c;
            lineItem.ValoreRipianificabileApprovato__c = lineItem.ValoreRipianificabileRichiesto__c;
            lineItem.ApprovazioneMinorRicavo__c = 'Unnecessary';
            update lineItem;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }


    /**
    * Controlla se il line item ha un erogato disponibile.
    * Returns: true se line item integrato con un ad server (dfp/oas) e il prodotto è un CPM
    * false, se line item non integrato con ad server o il prodotto è CPD o CPC
    */
    private Boolean isErogatoDisponibile(){
        return isLineItemIntegratoConAdServer() && lineItem.Delivery_Model__c == 'CPM';
    }

    private Boolean isLineItemIntegratoConAdServer(){
        return (lineItem.Type_DFP__c == 'STANDARD' || lineItem.Type_DFP__c == 'BULK') &&
                (lineItem.Integrato_con_DFP_formula__c == 'true' || lineItem.Integrato_con_OAS_formula__c == 'true') &&
                !(lineItem.Id_DFP__c == null && lineItem.Id_Oas__c == null);
    }

    private void populateDefaultValuesOnLineItem(){
        if(primoMinorRicavo){
            if(isQuantitaAvailable){
                lineItem.QuantitaRipianificabileRichiesta__c = maxValueImpressionsRipianificabileApproved;
            }
            lineItem.TotaleRipianificabileRichiesto__c = maxValueTotaleRipianificabileApproved;
            lineItem.ValoreRipianificabileRichiesto__c = lineItem.TotaleRipianificabileRichiesto__c - lineItem.Totale_ripianificato_positivo__c;
        }
    }

    /**
    *   Se non hai rimosso la parte non erogata e non hai mai ripianificato allora è il primo minor ricavo.
    *   In questo caso hai la possibilità di decidere il massimo valore stornabile.
    */
    private Boolean isPrimoMinorRicavo (){
        return lineItem.ApprovazioneMinorRicavo__c == 'Unclaimed' || lineItem.ApprovazioneMinorRicavo__c == null;
    }

    private boolean isLineItemSospeso(){
        boolean sospeso = false;
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

     private boolean sospendiErogazione(){
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

    private void calcolaValoreTotaleDaImpression(){
        if(lineItem.QuantitaRipianificabileRichiesta__c == null){
            lineItem.QuantitaRipianificabileRichiesta__c = 0;
        }
        Decimal totale = lineItem.Totale__c;
        if(lineItem.Delivery_model__c == 'CPM' || LineItem.ProductFamily__c == 'DEM'){
            totale = lineItem.QuantitaRipianificabileRichiesta__c * lineItem.Prezzo_net_net__c / 1000; 
        }else if(lineItem.Delivery_model__c == 'CPC'){
            totale = lineItem.QuantitaRipianificabileRichiesta__c * lineItem.Prezzo_net_net__c;
        }
        totale = totale.setScale(2,ROUNDINGMODE.HALF_UP);
        lineItem.TotaleRipianificabileRichiesto__c = totale;
        lineItem.ValoreRipianificabileRichiesto__c = lineItem.TotaleRipianificabileRichiesto__c - lineItem.Totale_ripianificato_positivo__c;
    }

    public void calcolaImpressionsDaValoreTotale(){
        if(lineItem.TotaleRipianificabileRichiesto__c == null){
            lineItem.TotaleRipianificabileRichiesto__c = 0;
        }
        Decimal impressions = lineItem.QuantitaRipianificabileRichiesta__c;
        if(lineItem.Delivery_model__c == 'CPM' || LineItem.ProductFamily__c == 'DEM'){
            impressions = lineItem.TotaleRipianificabileRichiesto__c / lineItem.Prezzo_net_net__c;
            impressions = impressions.setScale(0,ROUNDINGMODE.DOWN);
            impressions = impressions * 1000;
        }else if(lineItem.Delivery_model__c == 'CPC'){
            impressions = lineItem.TotaleRipianificabileRichiesto__c / lineItem.Prezzo_net_net__c;
            impressions = impressions.setScale(0,ROUNDINGMODE.DOWN);
        }
        lineItem.QuantitaRipianificabileRichiesta__c = impressions;
    }

    private void preventNull(){
        Boolean flag = false;
        if(lineItem.ApprovazioneMinorRicavo__c == null || lineItem.ApprovazioneMinorRicavo__c == ''){
            lineItem.ApprovazioneMinorRicavo__c = 'Unclaimed';
            flag = true;
        }
        if(lineItem.QuantitaRipianificabileRichiesta__c == null){
            lineItem.QuantitaRipianificabileRichiesta__c = 0;
            flag = true;
        }
        if(lineItem.TotaleRipianificabileRichiesto__c == null){
            lineItem.TotaleRipianificabileRichiesto__c = 0;
            flag = true;
        }
        if(lineItem.ValoreRipianificabileRichiesto__c == null){
            lineItem.ValoreRipianificabileRichiesto__c = 0;
            flag = true;
        }
        if(lineItem.ImpressionErogateMinorRicavo__c == null){
            lineItem.ImpressionErogateMinorRicavo__c = 0;
            flag = true;
        }
        if(flag){
            lineItemModified = true;
        }
    }
    
    private LineItem__c refreshLineItem(){
        return [SELECT Id, Ripianificato__c, totaleRipianificabile__c, Totale__c,Start_Date__c,End_Date__c,Data_sospensione_erogazione__c,
                ValoreRipianificabileApprovato__c,ValoreRipianificabileApprovatoFormula__c,TotaleRipianificabileApprovato__c,Id_DFP__c,Id_oas__c,RimozioneParteNonErogata__c,End_Hour__c,End_minute__c,Nome_DFP__c, Opportunity__r.Local__c
                FROM LineItem__c 
                WHERE Id = :lineItem.Id ];
    }
}