public with sharing class OpportunityViewExtension {
    
    private final Opportunity opty; //Opportunity
    public List<LineItem__c> lineItemL {get;set;} //Lista di line items
    public Boolean showRelatedListLI {get;set;}
    public Boolean canEditLineItem {get;set;} //True se si ha accesso in scrittura al record
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
                sortExp = value;
            }
        }
    
    public Boolean ticketNotHidden {get;set;} //Visibilità lista correlata ticket
    public Boolean quoteNotHidden {get;set;} //Visibilita lista correlata quote
        
    
    public OpportunityViewExtension(ApexPages.StandardController stdController) {
		this.opty = (Opportunity)stdController.getRecord();
        
        
        
        //Controlla che venga passato il parametro Id alla pagina
        if(opty.Id == null) {
            this.showRelatedListLI = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Id.');
            ApexPages.addMessage(myMsg);           
        }
        else {
        	this.showRelatedListLI = true;    
        }
        
        //Controlla visibilità sulle liste correlate;
        checkRelatedListVisibiliy();
        
        //Query sui LineItem dell'Opportunity
        this.lineItemL = [SELECT Name, Name_Dfp__c, Pacchetto_Combo_Opportunity__c, ProductFamily__c, Delivery_Model__c, Start_Date__c, End_Date__c,
                          Prezzo_net__c, Quantita__c, Totale__c, Breakeven_check__c
                          FROM LineItem__c WHERE Opportunity__c = :opty.Id AND Personalizzato__c = true];
	    
        if(this.lineItemL.size() > 0) {    
			this.canEditLineItem = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() and RecordId =: lineItemL[0].Id].HasEditAccess;
        }
    }
    
    public String getSortDirection() {
        //se nessuna colonna è selezionata
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
    }

    public void setSortDirection(String value) {  
        sortDirection = value;
    }
    
    public void viewData() {
        //costruisce l'espressione per l'ordinamento
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        //query basata sull'espressione di ordinamento
        this.lineItemL = Database.query('SELECT Name, Name_Dfp__c, Pacchetto_Combo_Opportunity__c, ProductFamily__c, Delivery_Model__c, Start_Date__c, End_Date__c, Prezzo_net__c, Quantita__c, Totale__c, Breakeven_check__c FROM LineItem__c WHERE Opportunity__c = \''+ opty.Id + '\' AND Personalizzato__c = true ORDER BY ' + sortFullExp + ' LIMIT 1000'); 
    }
    
    //Controlla visibilità sulle liste correlate
    private void checkRelatedListVisibiliy() {
        Schema.DescribeFieldResult ticketField = Ticket_Fatturazione__c.Name.getDescribe();
		this.ticketNotHidden = ticketField.isAccessible();
        Schema.DescribeFieldResult quoteField = Quote.Name.getDescribe();
		this.quoteNotHidden = quoteField.isAccessible();
    }
    
    @isTest
    static void testController() {        
        Product2 p1 = new Product2( Name = 'Test1', Family = 'Banner',BasePrice__c = 0,Breakeven_cost__c = 0);
        Product2 p2 = new Product2( Name = 'Test2', Family = 'Banner',BasePrice__c = 0,Breakeven_cost__c = 0);
        insert p1;
        insert p2;
        
        Account a = utilityTest.insertBrand();

        Opportunity opp = new Opportunity( Name = 'Test opp', AccountId = a.id, StageName = 'Closed', CloseDate = System.today());
        insert opp;          
        
        LineItem__c li1 = new LineItem__c(
            Product__c = p1.Id,
            Opportunity__c = opp.Id,
            Start_Date__c = Date.today().addDays(3),
            End_Date__c = Date.today().addMonths(4),  
            quantita__c = 1,      
            Ultima_modifica_prezzo__c='Totale',
            Personalizzato__c = true
        );
        LineItem__c li2 = new LineItem__c(
            Product__c = p2.Id,
            Opportunity__c = opp.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addMonths(2),
            quantita__c = 1,        
            Ultima_modifica_prezzo__c='Totale',
            Personalizzato__c = true
        );
        insert li1;
        insert li2;
 
        
        PageReference pref = Page.OpportunityView;
    	pref.getParameters().put('id', opp.Id);
    	Test.setCurrentPage(pref);
        ApexPages.StandardController con = new ApexPages.StandardController(opp);
    	OpportunityViewExtension ext = new OpportunityViewExtension(con);
  
        System.assert(ext.lineItemL[0].Start_Date__c > ext.lineItemL[1].Start_Date__c);
        System.assertEquals(ext.getSortDirection(), 'ASC');
        
        ext.sortExpression = 'Start_Date__c';
        ext.ViewData();

        System.assert(ext.lineItemL[0].Start_Date__c < ext.lineItemL[1].Start_Date__c);
		System.assertEquals(ext.getSortDirection(), 'ASC');
        
		ext.sortExpression = 'Start_Date__c';
        ext.ViewData();
        System.assert(ext.lineItemL[0].Start_Date__c > ext.lineItemL[1].Start_Date__c);
    }

}