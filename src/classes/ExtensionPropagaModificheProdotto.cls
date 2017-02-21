public class ExtensionPropagaModificheProdotto {

    public Product2 prod {get;set;}
    public List<LineItemWrapper> lineItemProdotto {get;set;}
    public PropagationOptions propagationOptions {get;set;}
    public integer numDaysEnded {get;set;}
    
    private DfpIntegration dfp;
    private LineItem__c[] liToUpdate;
    private Map<Id,LineItem__c> liToPropagate;

    private Integer counter = 0;
    private LineItem__c getNextLiToPropagate() {        
        if(liToUpdate == null || counter >= liToUpdate.size()) {
            counter = 0;
            return null;
        }
        return liToUpdate[counter++];
    }    
    public Boolean dfpUpdateFinished {get; private set;}
    private Product2 p;    
    private Map<Id, LineItemWrapper> id2LiWrapperMap = new Map<Id, LineItemWrapper>();

    public ExtensionPropagaModificheProdotto(ApexPages.StandardController controller) {
        prod = (Product2) controller.getRecord();
        propagationOptions = new PropagationOptions();
        propagationOptions.propagateInventory = true;
        propagationOptions.propagatePriority = false;
        propagationOptions.propagateLabels = false;

        dfp = new DfpIntegration();
        dfpUpdateFinished = true;

        numDaysEnded = 0;
        search();
    }
    
    public void search(){        
        lineItemProdotto = new LineItemWrapper[]{};
         for(LineItem__c a : [SELECT
            Opportunity__r.ownerId,
            Opportunity__r.owner.Name,
            Opportunity__r.name,
            name,
            nome_dfp__c,
            Name_Dfp__c,
            start_date__c,
            priority__c,
            end_date__c,
            id_oas__c,
            id_dfp__c,
            CreatedDate,
            CreatedById
            FROM LineItem__c 
            WHERE Product__r.id =: prod.id 
            AND end_date__c >= : date.today().addDays(-numDaysEnded) 
            AND NonIntegratoAdServer__c = false
         ]){
            lineItemProdotto.add(new LineItemWrapper(a));
         }        
    }
    
    public PageReference startPropagation(){
        p = [SELECT
            Id,
            Priority__c, 
            Priority_oas__c,
            (SELECT Ad_Unit__c, Product__c, IncludeDescendants__c, InventoryTargetingType__c,
            		LineItem__c,SectionOas__c,adUnitIdDfp__c 
             FROM Inventory_Target__r),
            (SELECT Line_Item__c,Product__c,Placement__c FROM PlacementTargeting__r),
            (SELECT SectionOas__c, Product__c, LineItem__c FROM SectionsOasTargeted__r),
            (Select Label__c,idDfp__c From AppliedLabel__r)
            FROM Product2 
            WHERE Id =: prod.id
        ];
        
        liToUpdate = new LineItem__c[]{};
        liToPropagate = new Map<Id, LineItem__c>();
        id2LiWrapperMap = new Map<Id, LineItemWrapper>();
        for(LineItemWrapper t : lineItemProdotto) {
            id2LiWrapperMap.put(t.li.id, t);
            t.message = null;
            t.finished = false;
            t.hasErrors = false;

            if(t.selected){
                liToUpdate.add(t.li);
                if(t.li.id_dfp__c > 0) liToPropagate.put(t.li.id, t.li);
            }
        }        
       
        dfpUpdateFinished = false;
        return null;
    }
	
    public void propagaModifiche() {   
        LineItem__c li = getNextLiToPropagate();

        if(li == null) {
            dfpUpdateFinished = true;
            return;
        }

        LineItemWrapper liWrapper = id2LiWrapperMap.get(li.id);
        liWrapper.finished = true;
        liWrapper.message = '';
        
        String imgok = '<img src="/img/msg_icons/confirm16.png" /> ';
        String imgko = '<img src="/img/msg_icons/error16.png" /> ';
        
        
        if(liToPropagate.containsKey(li.id)) {
            try {
                //DfpLineItemService.LineItem dfpLi = dfp.lineItemService.getLineItem((Long) li.id_dfp__c);
                DfpLineItemService.LineItem dfpLi = UtilityLineItemIntegration.getLineItemsByIds(new decimal[]{(Long)li.Id_DFP__c},dfp).results[0];
                UtilityLineItemIntegration.prepareDfpLineItemForUpdate(dfpLi);
                UtilityLineItemIntegration.fillDfpLineItem(
                    dfpLi, 
                    propagationOptions.propagatePriority ? li.priority__c : null,
                    propagationOptions.propagateInventory ? p.Inventory_Target__r : null,
                    propagationOptions.propagateInventory ? p.PlacementTargeting__r : null,
                    propagationOptions.propagateLabels ? p.AppliedLabel__r : null
                );
                dfp.lineItemService.updateLineItems(new DfpLineItemService.LineItem[]{dfpLi});
                liWrapper.message = imgok+'Propagazione su DFP ok<br/>';
                liWrapper.messageForEmail = 'Propagazione su DFP ok<br/>';
            } catch(Exception e) {
                String msg = e.getMessage(); // + '. ' + e.getLineNumber() + '.' +  e.getStackTraceString();
                liWrapper.message = imgko+'Propagazione su DFP fallita:';
                liWrapper.message += '<br/>' + msg.escapeHtml4() + '<br/>';
                liWrapper.messageForEmail = 'Propagazione su DFP fallita:';
                liWrapper.messageForEmail += '<br/>' + msg.escapeHtml4() + '<br/>';
                liWrapper.hasErrors = true;                            
            }
            
        }

        System.SavePoint sp = Database.setSavepoint();
        try {
            propagaSuSfdc(li);
        } catch(Exception e) {
            Database.rollBack(sp);
            String msg = e.getMessage(); // + '. ' + e.getLineNumber() + '.' +  e.getStackTraceString();
            liWrapper.message += imgko+'Propagazione su SFDC fallita: <br/>' + msg.escapeHtml4();
            liWrapper.messageForEmail += 'Propagazione su SFDC fallita: <br/>' + msg.escapeHtml4();
            liWrapper.hasErrors = true;            
            return;
        }

        liWrapper.message += imgok+'Propagazione su SFDC ok';
        liWrapper.messageForEmail += 'Propagazione su SFDC ok';
    }
	
	
    private void propagaSuSfdc(LineItem__c li) {               
        Inventory_Target__c[] inventoryToInsert = new Inventory_target__c[]{};
        PlacementTargeting__c[] placementsToInsert = new PlacementTargeting__c[]{};
        SectionOasTargeted__c[] sectionOasToInsert = new SectionOasTargeted__c[]{};
        AppliedLabel__c[] labelsToInsert = new AppliedLabel__c[]{};

        Boolean mustDeleteInventory = false;
                
        if(propagationOptions.propagatePriority){
            li.priority__c = p.priority__c;
            li.priority_oas__c = p.priority_oas__c;                
        }                
        if(propagationOptions.propagateInventory && (!p.Inventory_Target__r.isEmpty() || !p.PlacementTargeting__r.isEmpty() || !p.SectionsOasTargeted__r.isEmpty())) {                
            for(Inventory_Target__c it : p.Inventory_Target__r){
                it.lineitem__c = li.id;
                it.product__c = null;
                inventoryToInsert.add(it.clone());
            }
            for(PlacementTargeting__c pt : p.PlacementTargeting__r){
                pt.line_item__c = li.id;
                pt.product__c = null;
                placementsToInsert.add(pt.clone());
            }
            for(SectionOasTargeted__c sot : p.SectionsOasTargeted__r){
                sot.lineitem__c = li.id;
                sot.product__c = null;
                sectionOasToInsert.add(sot.clone());
            }    
        }
        if(propagationOptions.propagateLabels) {
            for(AppliedLabel__c al : p.AppliedLabel__r) {
                al.line_item__c = li.id;
                al.product__c = null;
                labelsToInsert.add(al.clone());
            }
        }
       
        SavePoint sp = Database.setSavepoint();
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipValidationAdServer = true;

        if(propagationOptions.propagatePriority){
            update liToUpdate;
        }
        if(propagationOptions.propagateInventory){
            delete [SELECT Id FROM Inventory_Target__c WHERE LineItem__c = :li.Id];
            delete [SELECT Id FROM PlacementTargeting__c WHERE Line_Item__c = :li.Id];
            delete [SELECT Id FROM SectionOasTargeted__c WHERE LineItem__c = :li.Id];
            insert placementsToInsert;
            insert inventoryToInsert;
            insert sectionOasToInsert;
        }   
        if(propagationOptions.propagateLabels) {
            delete [SELECT Id FROM AppliedLabel__c WHERE Line_Item__c = :li.Id];
            insert labelsToInsert;
        }        
    }
    
    /* Send mail to Marketing users */
    public void sendMailToMktg() {
    	List<User> mktgUsers = [SELECT Email FROM User WHERE Profile.Name = 'Libero - Marketing'];
    	
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(getEmailAddresses(mktgUsers));
		
		//For Debug
		//email.setToAddresses(new List<String>{'massimiliano.colombi@italiaonline.it'});
        //email.setCCAddresses(new List<String>{'raffaello.lacontana@telnext.com'});
		
		email.setSubject('Propagazione modifiche: ' + prod.Name);
		email.setHtmlBody(buildMailBody());
		emails.add(email);

		//Send emails
		Messaging.sendEmail(emails);
    }
    
    /* Given the list of users, return their email addresses */
    private List<String> getEmailAddresses(List<User> users) {
        List<String> mailToAddresses = new List<String>();
        for(User u: users) {
            mailToAddresses.add(u.Email);
        }
        return mailToAddresses;
    }
    
    /* Method that builds the body of the email */
    private String buildMailBody() {
    	String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm();
    	String tableStyle = 'border-collapse:collapse; border: 1px solid #E0E3E5;';
    	String thStyle = 'background: #F2F3F3; border: 1px solid #E0E3E5; border-bottom: 2px solid #E0E3E5;';
    	String tdStyle = 'border: 1px solid #E0E3E5; padding: 2px;';
    	String checkboxStyle = 'vertical-align: middle; margin-right: 10px;';
    	String sectionStyle = 'font-size: 1.2em; font-weight: bold; margin-top: 30px; margin-bottom: 2px;'; 
    	String separatorStyle = 'height: 3px; background: #8E9DBE; margin-bottom: 10px;';              
        String body = '';
        
        body += '<div style="' + sectionStyle + '">Nome prodotto:</div>';
        body += '<div style="' + separatorStyle + '"></div>';
        body += '<a href="' + sfdcUrl + '/' + prod.Id + '">'+ prod.Name +'</a>';
        
        body += '<div style="' + sectionStyle + '">Modifiche propagate:</div>';
        body += '<div style="' + separatorStyle + '"></div>';
        
        if(propagationOptions.propagateInventory){
 			body += '<input type="checkbox" disabled="disabled" checked="checked" style="' + checkboxStyle + '">';
        } else {
        	body += '<input type="checkbox" disabled="disabled" style="' + checkboxStyle + '">';	
        }
        body += 'Inventory (DFP), Pages/Section (OAS)<br/>';
        
        if(propagationOptions.propagatePriority){
	 		body += '<input type="checkbox" disabled="disabled" checked="checked" style="' + checkboxStyle + '">';
	    } else {
	    	body += '<input type="checkbox" disabled="disabled" style="' + checkboxStyle + '">';	
	    }
	    body += 'Priority<br/>';
	    
        if(propagationOptions.propagateLabels){
 			body += '<input type="checkbox" disabled="disabled" checked="checked" style="' + checkboxStyle + '">';
	    } else {
	    	body += '<input type="checkbox" disabled="disabled" style="' + checkboxStyle + '">';
        }
        body += 'Labels<br/>';
        
        body += '<div style="' + sectionStyle + '">Line item aggiornati:</div>';
        body += '<div style="' + separatorStyle + '"></div>';
        body += '<table style="' + tableStyle + '">';
        body += '<tr><th style="' + thStyle + '">Campagna</th>';
        body += '<th style="' + thStyle + '">Line Item</th>';
        body += '<th style="' + thStyle + '">Data inizio</th>';
        body += '<th style="' + thStyle + '">Data fine</th>';
        body += '<th style="' + thStyle + '">Data creazione</th>';
        body += '<th style="' + thStyle + '">Id DFP</th>';
        body += '<th style="' + thStyle + '">Id OAS</th>';
        body += '<th style="' + thStyle + '">Titolare campagna</th>';
        body += '<th style="' + thStyle + '">Stato avanzamento</th></tr>';
        for(LineItemWrapper liWrap : lineItemProdotto) {
        	if(liWrap.selected) {
				body += '<tr>';
				body += '<td style="' + tdStyle + '">' + liWrap.li.Opportunity__r.Name + '</td>';
				body += '<td style="' + tdStyle + '">' + liWrap.li.Name_Dfp__c + '</td>';
				body += '<td style="' + tdStyle + '">' + liWrap.li.Start_Date__c.format() + '</td>';
				body += '<td style="' + tdStyle + '">' + liWrap.li.End_Date__c.format() + '</td>';
				body += '<td style="' + tdStyle + '">' + liWrap.li.createdDate.format() + '</td>';
				if(liWrap.li.Id_DFP__c != null) {
					body += '<td style="' + tdStyle + '">' + liWrap.li.Id_DFP__c + '</td>';
				} else {
					body += '<td style="' + tdStyle + '"></td>';	
				}
				if(liWrap.li.Id_oas__c != null) {
					body += '<td style="' + tdStyle + '">' + liWrap.li.Id_oas__c + '</td>';
				} else {
					body += '<td style="' + tdStyle + '"></td>';	
				}
				body += '<td style="' + tdStyle + '">' + liWrap.li.Opportunity__r.owner.Name + '</td>';
				body += '<td style="' + tdStyle + '">' + liWrap.messageForEmail + '</td>';
				body += '</tr>';
        	}		
        }
        
        body += '</table>';
        return body;
    }
    
    public PageReference customCancel(){
        return new PageReference('/' + prod.id);
    }   
    
     public class LineItemWrapper{
        public LineItem__c li{get; set;}
        public Boolean selected {get; set;}
        public Boolean finished {get;set;}
        public Boolean hasErrors {get;set;}
        public String message {get; set;}
        public String messageForEmail {get; set;}         
        public LineItemWrapper(LineItem__c a){
            li = a;
            selected = false;
            finished = false;
            hasErrors = false;
            message = '';
            messageForEmail = '';
        }
    }
    
    public class PropagationOptions {
        public Boolean propagateInventory {get; set;} 
        public Boolean propagatePriority {get; set;}
        public Boolean propagateLabels {get;set;}
    }

    public static testMethod void testPropagaModifiche() {       
         Product2 prod = new Product2();
         prod.name = 'Test prod';
         insert prod;
        
         Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
         insert o;        
         
         LineItem__c li = new LineItem__c();
         li.Product__c = prod.id;
         li.Opportunity__c = o.id;
         li.Start_Date__c = date.today();
         li.end_Date__c = date.today();
         li.status__c = 'DRAFT';
         insert li;
         
         LineItem__c li2 = li.clone(false);
         li2.status__c = 'DRAFT';
         insert li2;
         
         ApexPages.StandardController sc = new ApexPages.standardController(prod);
         ExtensionPropagaModificheProdotto controller = new ExtensionPropagaModificheProdotto(sc);
         
         for(LineItemWrapper a : controller.lineItemProdotto){
             a.selected = true;
         }        
         
         controller.startPropagation();
         controller.customCancel();       
    }

}