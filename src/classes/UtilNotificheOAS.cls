public class UtilNotificheOAS{
    private static GenericObject mylogger= new GenericObject(new UtilNotificheOAS());

    //CSS
    public static String colBlue = 'color: #2D4C98;';
    public static String marTop20 = 'margin-top: 20px;';
    public static String tableStyle = 'margin-bottom : 10px; width: 100%;';
    public static String thStyle = 'color: #2D4C98; padding: 6px; font-size: 1.2em';
    public static String tdLabelStyle = 'font-weight: bold; width: 185px;';
    public static String tdArrowStyle = 'text-align: center';
    public static String oldValueStyle = 'min-height: 16px;background: #FCA7A4; padding: 3px 5px; border-radius: 5px;';
    public static String newValueStyle = 'min-height: 16px;background: #DCFBDC; padding: 3px 5px; border-radius: 5px;';
    public static String divHrStyle = 'width: 80%; height: 1px; border: 0; background-color: #D4D4D4; margin: 20px auto; clear: both;';
    public static String divFieldStyle = 'float:left; margin: 0px 5% 10px 0px; width: 45%;';
    public static String divValueStyle = 'min-height: 16px;background: #E4F2F6; padding: 3px 5px; border-radius: 5px;';
    public static String divLabelStyle = 'font-size: 0.7em; font-weight:bold; padding: 2px 5px; color: #4A4A56;';        

    public static boolean isChagend(Opportunity oldOpp,Opportunity newOpp){
        if(
            newOpp.Account != oldOpp.Account ||
            newOpp.Centro_Media__c != oldOpp.Centro_Media__c ||
            newOpp.Agenzia_creativa__c != oldOpp.Agenzia_creativa__c ||
            newOpp.Riferimenti_agenzia_creativa__c != oldOpp.Riferimenti_agenzia_creativa__c ||
            newOpp.Email_agenzia_creativa__c != oldOpp.Email_agenzia_creativa__c ||
            newOpp.Description != oldOpp.Description
        ){
            return true;
        }
        return false;
    }

    public static string getBodyModificaOpp(Opportunity oldOpp,Opportunity newOpp){
        String head = 'La seguente opportunità è stata modificata: <b>'+newOpp.Name+'</b><div style="'+divHrStyle+'"/>';
        String body = '<table border="0" style="'+tableStyle+'"><thead><th style="'+thStyle+'">Campo</th><th style="'+thStyle+'">Vecchio valore</th><th></th><th style="'+thStyle+'">Nuovo valore</th></thead><tbody>';

        //Check if any field below has changed
        if(newOpp.Account != oldOpp.Account)
            body = body+'<tr><td style="'+tdLabelStyle+'">Brand</td><td><div style="'+oldValueStyle +'">'+oldOpp.nome_brand__c+'</div></td><td style="'+tdArrowStyle+'">&#8658;</td><td><div style="'+newValueStyle +'">'+newOpp.nome_brand__c+'</div></td><tr/>';
        if(newOpp.Centro_Media__c != oldOpp.Centro_Media__c)
            body = body+'<tr><td style="'+tdLabelStyle+'">Centro media</td><td><div style="'+oldValueStyle +'">'+oldOpp.nome_Centro_Media__c+'</div></td><td style="'+tdArrowStyle+'">&#8658;</td><td><div style="'+newValueStyle +'">'+newOpp.nome_Centro_Media__c+'</div></div></td><tr/>';
        if(newOpp.Agenzia_creativa__c != oldOpp.Agenzia_creativa__c)
            body = body+'<tr><td style="'+tdLabelStyle+'">Agenzia creativa</td><td><div style="'+oldValueStyle +'">'+oldOpp.Agenzia_creativa__c+'</div></td><td style="'+tdArrowStyle+'">&#8658;</td><td><div style="'+newValueStyle +'">'+newOpp.Agenzia_creativa__c+'</div></td><tr/>';
        if(newOpp.Riferimenti_agenzia_creativa__c != oldOpp.Riferimenti_agenzia_creativa__c)
            body = body+'<tr><td style="'+tdLabelStyle+'">Riferimenti agenzia creativa</td><td><div style="'+oldValueStyle +'">'+oldOpp.Riferimenti_agenzia_creativa__c+'</div></td><td>&#8658;</td><td><div style="'+newValueStyle +'">'+newOpp.Riferimenti_agenzia_creativa__c+'</div></td><tr/>';
        if(newOpp.Email_agenzia_creativa__c != oldOpp.Email_agenzia_creativa__c)
            body = body+'<tr><td style="'+tdLabelStyle+'">Email agenzia creativa</td><td><div style="'+oldValueStyle +'">'+oldOpp.Email_agenzia_creativa__c+'</div></td><td style="'+tdArrowStyle+'">&#8658;</td><td><div style="'+newValueStyle +'">'+newOpp.Email_agenzia_creativa__c+'</div></td><tr/>';
        if(newOpp.Description != oldOpp.Description)
            body = body+'<tr><td style="'+tdLabelStyle+'">Descrizione</td><td><div style="'+oldValueStyle +'">'+oldOpp.Description+'</div></td><td style="'+tdArrowStyle+'">&#8658;</td><td><div style="'+newValueStyle +'">'+newOpp.Description+'</div></td><tr/>';
        String clear = '<div style="'+divHrStyle+'"/><h3 style="'+colBlue+marTop20+'">Riepilogo dati</h3>';
        
        String fields = '' +
            '<div style="'+divFieldStyle+'">' +
                '<div class="value" style="'+divValueStyle+'">' +
                    newOpp.nome_brand__c +
                '</div>' +
                '<div class="label" style="'+divLabelStyle+'">' +
                    'Cliente' +
                '</div>' +
            '</div>' +
            
            '<div style="'+divFieldStyle+'">' +
                '<div class="value" style="'+divValueStyle+'">' +
                    newOpp.nome_Centro_Media__c +
                '</div>' +
                '<div class="label" style="'+divLabelStyle+'">' +
                    'Centro Media' +
                '</div>' +
            '</div>' +
            
            '<div style="'+divFieldStyle+'">' +
                '<div class="value" style="'+divValueStyle+'">' +
                    newOpp.Agenzia_creativa__c +
                '</div>' +
                '<div class="label" style="'+divLabelStyle+'">' +
                    'Agenzia creativa' +
                '</div>' +
            '</div>' +
            
            '<div style="'+divFieldStyle+'">' +
                '<div class="value" style="'+divValueStyle+'">' +
                    newOpp.Riferimenti_agenzia_creativa__c +
                '</div>' +
                '<div class="label" style="'+divLabelStyle+'">' +
                    'Riferimenti agenzia creativa' +
                '</div>' +
            '</div>' +
            
            '<div style="'+divFieldStyle+'">' +
                '<div class="value" style="'+divValueStyle+'">' +
                    newOpp.Email_agenzia_creativa__c +
                '</div>' +
                '<div class="label" style="'+divLabelStyle+'">' +
                    'Email agenzia creativa' +
                '</div>' +
            '</div>' +
            
            '<div style="'+divFieldStyle+'">' +
                '<div class="value" style="'+divValueStyle+'">' +
                    newOpp.Description +
                '</div>' +
                '<div class="label" style="'+divLabelStyle+'">' +
                    'Descrizione' +
                '</div>' +
            '</div>';    
                
         return head+body+'</tbody></table>'+clear+fields;
    }
    
    public static set<string> liFieldToTrack = new set<string>{'Name','dataorainizio__c','dataorafine__c','Quantita__c','Note_commerciali__c',
                                                                 'Goal_delivery__c','Prodotto__c'
                                                               };
    public static boolean isChagendLineItem(LineItem__c oldLi,LineItem__c newLi){
        for(string s : liFieldToTrack){
            if(newLi.get(s) != oldLi.get(s)){
                return true;
            }
        }

        return false;
    }
    
    public static string getBodyModificaLineItem(LineItem__c oldLi,LineItem__c newLi){
        String head = 'Il seguente Line Item è stato modificato: <b>'+newLi.Name+'</b><div style="'+divHrStyle+'"/>';
        String body = '<table border="0" style="'+tableStyle+'"><thead><th style="'+thStyle+'">Campo</th><th style="'+thStyle+'">Vecchio valore</th><th></th><th style="'+thStyle+'">Nuovo valore</th></thead><tbody>';

        Map<String, Schema.SObjectField> fieldMap = LineItem__c.getSObjectType().getDescribe().fields.getMap();
        //Check if any field below has changed
        for(string s : liFieldToTrack){
            if(newLi.get(s) != oldLi.get(s)){
                body = body+'<tr><td style="'+tdLabelStyle+'">'+fieldMap.get(s).getDescribe().getLabel()+'</td><td><div style="'+oldValueStyle +'">'+oldLi.get(s)+'</div></td><td style="'+tdArrowStyle+'">&#8658;</td><td><div style="'+newValueStyle +'">'+newLi.get(s)+'</div></td><tr/>';
            }
        }
        
        String clear = '<div style="'+divHrStyle+'"/><h3 style="'+colBlue+marTop20+'">Riepilogo dati</h3>';
        
        String fields = '';
        for(string s : liFieldToTrack){
            fields += '<div style="'+divFieldStyle+'">' +
                         '<div class="value" style="'+divValueStyle+'">' +
                             newLi.get(s) +
                         '</div>' +
                         '<div class="label" style="'+divLabelStyle+'">' +
                             fieldMap.get(s).getDescribe().getLabel() +
                         '</div>' +
                      '</div>';
        }
        body = head+body+'</tbody></table>'+clear+fields;
        body = body.replace('null','');
        return body;
    }
    
    public static Messaging.SingleEmailMessage getMessage(id tempid,id targetObjectid,id whatid){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(tempid);
        mail.setTargetObjectId(TargetObjectId);
        mail.setWhatId(whatid);
        return mail;
    }
    
    public static void sendEmails(list<Messaging.SingleEmailMessage> emails,string[] ccEmails){
        try{
            if(!emails.isEmpty()){
                for(Messaging.SingleEmailMessage e : emails){
                    e.setCcAddresses(ccEmails);
                }
                Messaging.SendEmailResult [] r = Messaging.sendEmail(emails); 
            }
        }catch(exception e){
            UtilExceptionIntegration.sendEmail('Errore durante la notifica ',e+'');
        }
    }

    public static void sendEmails(list<Messaging.SingleEmailMessage> emails){
        mylogger.logDebug('sendEmails isEmpty '+ emails.isEmpty()+' size '+emails.size());
       // 
       /*
       16:40:18:616 USER_DEBUG [192]|DEBUG|errore durante l invio mailSystem.EmailException: SendEmail failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Missing target address (target, to, cc, bcc): []
       */

        try{
            if(!emails.isEmpty()){
                mylogger.logDebug(emails.get(0));
                Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
                mylogger.logDebug(r);

                /*
                for(Messaging.SendEmailResult msg:r ){
                    if (!r.isSuccess()) {
                           System.StatusCode statusCode = r.getErrors()[0].getStatusCode();
                             String errorMessage = r.getErrors()[0].getMessage();
                    }
                }*/

            }
        }catch(exception e){
            mylogger.logDebug('errore durante l invio mail'+e);
            UtilExceptionIntegration.sendEmail('Errore durante la notifica ',e+'');
        }
    }


    
    public static testMethod void testUtiNotificheOAS(){
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        
        Opportunity o1 = new Opportunity();
        //Name, StageName, CloseDate
        o1.name = 'Opportunity Test';
        o1.stageName = 'Open';
        o1.closeDate = date.today();
        insert o1; 
        list<opportunity> opps = [ select name,Account.name,nome_brand__c,nome_centro_media__c,Centro_Media__c,Agenzia_creativa__c,Riferimenti_agenzia_creativa__c,
                                          Email_agenzia_creativa__c,Description 
                                   from opportunity
                                   where id =: o1.id OR id =: o.id ];
        UtilNotificheOAS.isChagend(opps[0],opps[1]);
        UtilNotificheOAS.getBodyModificaOpp(opps[0],opps[1]);
        
        
        lineitem__c l1 = new lineitem__c(opportunity__c = o.id);
        insert l1;
        lineitem__c l2 = new lineitem__c(opportunity__c = o.id);
        insert l2;
        list<lineitem__c> lis = [select Name,dataorainizio__c,dataorafine__c,Quantita__c,Note_commerciali__c,Goal_delivery__c,Prodotto__c from lineitem__c];
        UtilNotificheOAS.isChagendLineItem(lis[0],lis[1]);
        UtilNotificheOAS.getBodyModificaLineItem(lis[0],lis[1]);
        
        UtilNotificheOAS.getMessage(null,null,null);
        
    }

    
    public static Map<String, EmailTemplate> oasTemplates;
    public static Contact oasContact;     	       
    static {    	
		oasTemplates = new Map<String, EmailTemplate>();
    	for(EmailTemplate et : [SELECT id, DeveloperName FROM EmailTemplate WHERE developerName IN ('Notifica_aggiunta_LineItem_OAS','Notifica_eliminazione_LineItem_OAS','Notifica_lavorazione_OAS','Notifica_eliminazione_OAS')]) {
			oasTemplates.put(et.DeveloperName, et);    		
    	}
    	if(Test.isRunningTest()) {
    		Contact c = new Contact(LastName = 'Libero OAS', Email = 'libero@telnext.com');
    		insert c;
    	}
    	oasContact = [SELECT Id,Email_in_cc__c,Email FROM Contact WHERE Name = 'Libero OAS'];    	
    }    

 public static Map<String, EmailTemplate> adwordsTemplates;
    public static Contact adwordsContact;              
    static {        
        adwordsTemplates = new Map<String, EmailTemplate>();
        for(EmailTemplate et : [SELECT id, DeveloperName FROM EmailTemplate WHERE developerName IN ('Notifica_aggiunta_LineItem_OAS','Notifica_eliminazione_LineItem_OAS','Notifica_lavorazione_OAS','Notifica_eliminazione_OAS')]) {
            adwordsTemplates.put(et.DeveloperName, et);         
        }
        if(Test.isRunningTest()) {
            Contact c = new Contact(LastName = 'IOL ADWORDS', Email = 'libero@telnext.com');
            insert c;
        }
        adwordsContact = [SELECT Id,Email_in_cc__c,Email FROM Contact WHERE Name = 'IOL ADWORDS'];       
    }   



}