public class ExtensionMinorRicavoParziale {

    public LineItem__c lineItem {get;set;}
    public List<Ricavo__c> ricavi {get;set;}
    public List<Ricavo__c> ricaviPositivi {get;set;}
    public List<Ricavo__c> ricaviNegativi {get;set;}
    public List<Ricavo__c> ricaviToDelete {get;set;}
    public Integer indexRicavoToDelete {get;set;}
    public Boolean errorOccurred {get;set;}
    public Boolean isLineItemSospeso {get;set;}

    ApexPages.StandardController stdController;

    public Date dataChiusuraRicavi {get;set;}


    public ExtensionMinorRicavoParziale(ApexPages.StandardController stdController) {
        this.stdController = stdController;

        init();

        dataChiusuraRicavi = RicavoTriggerHandler.getDataChiusuraRicavo(lineItem.Opportunity__r.Local__c);

        isLineItemSospeso = isLineItemSospeso();
    }

    public void init(){
        ricaviPositivi = new List<Ricavo__c>();
        ricaviNegativi = new List<Ricavo__c>();
        ricaviToDelete = new List<Ricavo__c>();

        if(!Test.isRunningTest()){
            stdController.reset();
        }   
        this.lineItem = (LineItem__c) stdController.getRecord();
        this.ricavi = [SELECT Anno__c,Anno_numero__c,Custom__c,Modificato__c, Mese__c,Mese_numero__c,Percentuale_applicata__c,Order__c,Data_primo_mese__c,
                              Valore__c,Line_Item__c,Data_ultimo_mese__c,LineItemDiRipianificazione__c,MinorRicavo__c
                        FROM Ricavo__c
                        WHERE Line_Item__c =: lineItem.Id
                        ORDER BY Anno_numero__c,Mese_numero__c ASC
                      ];

        for(Ricavo__c ricavo : ricavi){
            if(ricavo.MinorRicavo__c){
                ricavo.Valore__c = -ricavo.Valore__c;
                ricaviNegativi.add(ricavo);
            }else{
                ricaviPositivi.add(ricavo);
            }
        }
    }
 
    public PageReference customSave(){
        if(ricaviNegativi.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Non hai aggiunto nessun ricavo negativo.'));
            return null;
        }
        try{
            for(Ricavo__c ricavoNegativo : ricaviNegativi){
                if(ricavoNegativo.Valore__c > 0){
                    ricavoNegativo.Valore__c = -ricavoNegativo.Valore__c;
                }
            }
            System.debug(ricaviNegativi);
            updateRicavi(true);
            upsert ricaviNegativi;
            delete ricaviToDelete;
        }catch(Exception e){
            printException(e);
            return null;
        }finally{
            for(Ricavo__c ricavoNegativo : ricaviNegativi){
                if(ricavoNegativo.Valore__c < 0){
                    ricavoNegativo.Valore__c = -ricavoNegativo.Valore__c;
                }
            }
        }

        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Ricavi salvati.'));

        init();

        return new PageReference('/apex/MinorRicavoParziale?id='+lineItem.Id);
    }

    public PageReference goBack(){
        return new PageReference('/apex/editLineItem?id='+lineItem.Id+'&sfdc.override=1');
    }

    public PageReference bloccaLineItemMinorRicavo(){
        SavePoint sp = null;
        try{
            Boolean suspended = isLineItemSospeso;
            if(!suspended){
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
                lineItem.RimozioneParteNonErogata__c = true;
                update lineItem;
                isLineItemSospeso = true;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Il line item non può essere sospeso sull\' Ad Server.'));
            }
        }catch(Exception e){
            errorOccurred = true;
            printException(e);
            if(sp != null){
                Database.rollback(sp);
            }
        }
        return null;  
    }

    public void addRicaviCustom(){
        Ricavo__c ricavoNegativo = new Ricavo__c(Line_Item__c=lineItem.Id,Custom__c=true, Modificato__c = true, MinorRicavo__c = true);
        //if(ricaviNegativi.size()>0){
        //    ricaviNegativi.add(ricaviNegativi.size() - 1,ricavoNegativo);
        //}else{
            ricaviNegativi.add(ricavoNegativo);
        //}
        updateRicavi();
    }

    public void deleteRicaviCustom(){
        Ricavo__c ricavoNegativoToRemove = ricaviNegativi.remove(indexRicavoToDelete);
        if(ricavoNegativoToRemove.Id != null){
            ricaviToDelete.add(ricavoNegativoToRemove);
        } 
        updateRicavi();
    }

    private void printException(Exception e){
        if(e instanceof DMLException){
             ApexPages.addMessages(e);
        }else{
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()+'<br/>'+e.getStackTraceString()));
        }
    }

    private boolean isLineItemSospeso(){
        boolean sospeso = true;
        if(Test.isRunningTest()){
            return false;
        }
        if(lineItem.id_DFP__c != null){
            sospeso = false;
            if(lineItem.Status__c == 'PAUSED' || lineItem.Status__c == 'COMPLETED'){
                sospeso = true;
            }
        }else if(lineItem.Id_Oas__c != null){ // line item su OAS
            sospeso = false;
            if(lineItem.Status_oas__c == OasIntegration.OAS_STATUS.get('Suspended') || lineItem.Status_oas__c == OasIntegration.OAS_STATUS.get('Completed')){
                sospeso = true;
            }
        }
        return sospeso;
     } 

     private boolean sospendiErogazione(){
        boolean suspended = true;
        if(Test.isRunningTest()){
            return true;
        }
        try{
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
        }catch(Exception e){
            suspended = false;
            printException(e);
        }
        return suspended;
    }  

    private void updateRicavi(){
        updateRicavi(false);
    }

    private void updateRicavi(Boolean checkMandatoryFields){
        if(ricaviNegativi.isEmpty()){
            return;
        }
        for(Integer i=0; i<ricaviNegativi.size(); i++){
            ricaviNegativi[i].order__c = i;
            if(checkMandatoryFields){
                if(isblank(ricaviNegativi[i].Mese__c)){
                    ricaviNegativi[i].Mese__c.addError('Obbligatorio');
                }
                if(isblank(ricaviNegativi[i].Anno__c)){
                    ricaviNegativi[i].Anno__c.addError('Obbligatorio');
                }
            }
            if(ricaviNegativi[i].Percentuale_applicata__c == null){ 
                ricaviNegativi[i].Percentuale_applicata__c = 0;
            }
            if(ricaviNegativi[i].Valore__c == null){
                ricaviNegativi[i].Valore__c = 0;
            }
        }
    }

    public boolean isBlank(String s){
        return (s == '' || s == null);
    }
}