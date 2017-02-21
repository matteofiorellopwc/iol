public class ExtensionOpportunityIntegrationAdServer {

    private final Opportunity opp;
    private ApexPages.StandardController controller;

    public ExtensionOpportunityIntegration dfp {get;set;}
    public ExtensionOpportunityOasIntegration oas {get;set;}
    public Boolean doUpsertOas {get;set;}
    public Boolean doReserve {get;set;}
    public Boolean isrunning {get;set;}
    public String CPDErrors {get;set;}
    
    public ExtensionOpportunityIntegrationAdServer(ApexPages.StandardController controller) {
        this.controller = controller;
        this.opp = (Opportunity)controller.getRecord();
        instantiateExt();
        this.doUpsertOas = false;
        this.doReserve = false;  
        this.isrunning = false;      
    }
    
    /* It instantiates the classes that have within them the methods for synchronizing SFDC with Ad Server */
    private void instantiateExt() {
        this.dfp = new ExtensionOpportunityIntegration(this.controller);
        this.oas = new ExtensionOpportunityOasIntegration(this.controller); 
    }
    
    /*
        Save allowOverbook and skipDispoCpd whitout other control
    */
    public PageReference saveAndReload(){
        opp.allowOverbook__c = dfp.o.allowOverbook__c;
        update opp;
        return null;
    }
     
    /* It synchronizes campaign between Salesforce and DFP Ad Server */
    public void upsertSfdcToDfp() {
        this.isrunning = true;
        this.dfp = new ExtensionOpportunityIntegration(this.controller);
        doUpsertOas = false;
        
        boolean doUpsertDFP = dfp.sfdcLineItems.size() > 0 || dfp.o.id_dfp__c != null;

        if(!doUpsertDFP || dfp.upsertOrderSfdcToDfp() != null) {
            doUpsertOas = true; 
        }else{
            this.isrunning = false;
        }
    }
    
    /* It synchronizes campaign between Salesforce and OAS Ad Server */
    public void upsertSfdcToOas() {
        this.oas = new ExtensionOpportunityOasIntegration(this.controller); 
        doUpsertOas = doUpsertOas && (oas.sfdcLineItems.size() > 0 || oas.o.id_oas__c != null);
        if(this.doUpsertOas) {
            try {
                oas.upsertOrderSfdcToOas();
                if(!doReserve){
                    this.isrunning = false;                
                }
            }catch (Exception e) {
                this.doUpsertOas = false;
                this.isrunning = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            }
        }else{
            this.isrunning = false;
        }
    }
    
    /* It reserve line item on DFP*/
    public void reserveSfdcToDfp() {
        this.dfp = new ExtensionOpportunityIntegration(this.controller);
        doUpsertOas = false;
        boolean doUpsertDFP = dfp.sfdcLineItems.size() > 0 || dfp.o.id_dfp__c != null;

        if(!doUpsertDFP || dfp.reserveOrder(false) != null) { //reserve without do upsert before
            this.doUpsertOas = true; 
        }else{
            this.isrunning = false;
        }
    }
    
    /* It reserve line item on OAS*/
    public void reserveSfdcToOas() {
        this.oas = new ExtensionOpportunityOasIntegration(this.controller); 
        doUpsertOas = doUpsertOas && (oas.sfdcLineItems.size() > 0 || oas.o.id_oas__c != null);
        if(this.doUpsertOas) {
            try {
                oas.reserveOrder();     
            }
            catch (Exception e) {
                this.isrunning = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            }
        }
        this.isrunning = false;
    }

    public void rerenderError() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, CPDErrors));
    }
    
}