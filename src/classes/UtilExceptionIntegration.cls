public class UtilExceptionIntegration{

    public class FriendlyMessage{
        public string message {get;set;}
        public integer index {get;set;}
    }

    public static list<FriendlyMessage> getFriendlyMessage(String message){
        list<FriendlyMessage> messages = new list<FriendlyMessage>();
        try{
            messages.addAll(checkMessage(message.substring(message.IndexOf('[')+1,message.lastIndexOf(']'))));
        }catch(exception e){
            FriendlyMessage fm = new FriendlyMessage();
            fm.message = message;
            if(!message.contains('Autenticazione DFP non effettuata!')){
                sendEmail('Libero Sfdc: eccezione non gestita',message);
            }
            messages.add(fm);
        }
        return messages;
    }
    
    public static list<FriendlyMessage> checkMessage(string message){
        system.debug('checkMessage = ' + message);
        list<FriendlyMessage> fMlist = new list<FriendlyMessage>();
        for(string sComma : message.split(',')){
            string typeError = '';
            string at = '';
            string trig = '';
            for(string s : sComma.split(';')){
                if(s.contains('@')){
                    typeError = s.split('@')[0];
                    at = s.split('@')[1];
                }
                if(s.contains('trigger')){
                    trig = s.split(':')[1];
                }
            }
            fMlist.add(checkError(typeError,at,trig));
        }
        return fMlist;
    }
    
    public static FriendlyMessage checkError(string typeError,string at,string trig){
        system.debug('checkError');
        system.debug('typeError = '+typeError);
        system.debug('at = '+at);
        system.debug('trig = '+trig);
        FriendlyMessage fm = new FriendlyMessage();
        fm.message = '';
        string s = '';
       
        if(typeError.contains('UniqueError.NOT_UNIQUE')){
            fm.message = at + ' = ' + trig + ' già esistente. Il valore deve essere unico';
            fm.index = getFirstIndex(at);
        }else if(typeError.contains('LineItemFlightDateError.START_DATE_TIME_IS_IN_PAST')){
            fm.message = 'Data di inizio non valida per il lineitem ';
            fm.index = getFirstIndex(at);            
        }else if(typeError.contains('LineItemFlightDateError.END_DATE_TIME_IS_IN_PAST')){
            fm.message = 'Data di fine non valida per il lineitem ';
            fm.index = getFirstIndex(at);            
        }else if(typeError.contains('LineItemError.ALREADY_STARTED')){
            fm.message = 'Impossibile modificare il seguente lineitem perchè già partito: ';
            fm.index = getFirstIndex(at);
        }else if(typeError.contains('RequiredError.REQUIRED')){
            fm.message = at + ' obbligatorio ';
            fm.index = getFirstIndex(at);
        }else if(typeError.contains('CompanyError.CANNOT_UPDATE_COMPANY_TYPE')){
            fm.message = 'Impossibile modificare il campo ' + at + ' = ' + trig;    
        }else if(typeError.contains('CommonError.CANNOT_UPDATE')){
            fm.message = 'Impossibile modificare il campo ' + at;
        }
        /*
        else if(typeError.contains('RequiredNumberError.TOO_SMALL_WITH_DETAILS')){
            fm.message = 'Valore non consentivo per il campo  '+getLastDotToken(at)+' per il lineitem ';
            fm.index = getFirstIndex(at);                    
        }*/
        else if(typeError.contains('RequiredNumberError.TOO_SMALL')){
            fm.message = 'Valore non consentito per il campo  '+getLastDotToken(at).replace('unitsBought','quantità')+' per il lineitem ';
            fm.index = getFirstIndex(at);
        }else if(typeError.contains('ForecastingError.NO_FORECAST_YET')){        
            fm.message = 'Dati di Forecasting non disponibili';
            fm.index = getFirstIndex(at);
        }else if(typeError.contains('ForecastingError.NOT_ENOUGH_INVENTORY')){        
            fm.message = 'Disponibilità non sufficiente';
            fm.index = getFirstIndex(at);
        } else if(typeError.contains('LineItemOperationError.CANNOT_DELETE_DELIVERED_LINE_ITEM')){
            fm.message = 'Impossibile eliminare un lineitem deliverato';
            fm.index = getFirstIndex(at);
        } else if(typeError.contains('OrderActionError.CANNOT_DELETE_ORDER_WITH_DELIVERED_LINEITEMS')){
            fm.message = 'Impossibile eliminare un ordine contenente lineitem deliverati';
            fm.index = getFirstIndex(at);        
        }else{
            throw new CustomException();
        }
        
        return fm;
    }
    
    public class CustomException extends Exception{}
    
    public static integer getFirstIndex(string s){
        integer i = -1;
        Pattern pat = Pattern.compile('\\[(.*?)\\]');
        Matcher mat = pat.matcher(s);
        if(mat.find()){
            i = Integer.valueOf(mat.group(1));
        }
        return i;
    }
    
    public static string getLastDotToken(string s){
        list<string> dotTokens = s.split('\\.');
        system.debug('dotTokens = ' +dotTokens);
        return dotTokens[dotTokens.size()-1];
    }
    
    public static string getExceptionMessage(exception e){
        String s = '';
        s += 'Message: '+e.getMessage();
        s += '\nStackTrace: '+e.getStackTraceString();
        return s;
    }
    
    public static void sendEmailToCustomEmailLog(string subject,string body, string customSettingEmailLog){
        EmailLog__c el = EmailLog__c.getInstance(customSettingEmailLog);
        sendEmail(subject,body,el.emails__c.split(','),false);
    }
    
    public static void sendHtmlEmailToCustomEmailLog(string subject,string body, string customSettingEmailLog){
        EmailLog__c el = EmailLog__c.getInstance(customSettingEmailLog);
        sendEmail(subject,body,el.emails__c.split(','),true);
    }

    public static void sendEmail(string subject,string body){
        sendEmail(subject,body,'libero@telnext.com');
    }
    
    public static void sendEmail(string subject,string body,string emailAddress){
        sendEmail(subject,body,new list<string>{emailAddress},false);
    }
    
    public static void sendEmail(string subject,string body,list<string> emailAddresses,boolean ishtml){
        list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = emailAddresses; 
        email.setSubject( subject );
        email.setToAddresses( toAddresses );
        if(ishtml){
            email.setHtmlBody(body);
        }else{
            email.setPlainTextBody(body);
        }
        
        emails.add(email);
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails); 
        }catch(Exception e){
            System.debug('Erroring sending email: '+e);
        }
    }
    public static testMethod void testUtilExceptionIntegration(){
        system.assertEquals(0, UtilExceptionIntegration.getFirstIndex('lineItem[0].startDateTime'));
        system.assertEquals('startDateTime',UtilExceptionIntegration.getLastDotToken('lineItem[0].startDateTime'));
    
        string s = '[UniqueError.NOT_UNIQUE @ name; trigger:\'test\']';
        list<FriendlyMessage> fms = UtilExceptionIntegration.getFriendlyMessage(s);
        system.debug(s + ' -> ' + fms);        
        s = '[LineItemFlightDateError.START_DATE_TIME_IS_IN_PAST @ lineItem[0].startDateTime]';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);
        system.debug(s + ' -> ' + fms);        
        s = '[RequiredNumberError.TOO_SMALL_WITH_DETAILS @ lineItem[0].unitsBought; trigger:\'0\'; errorDetails:1, LineItemFlightDateError.START_DATE_TIME_IS_IN_PAST @ lineItem[1].startDateTime]';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);
        system.debug(s + ' -> ' + fms);    
        s = '[ForecastingError.NO_FORECAST_YET @ ]';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);
        system.debug(s + ' -> ' + fms);                    
        s = '[ForecastingError.NOT_ENOUGH_INVENTORY @]';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);
        system.debug(s + ' -> ' + fms);        
        s = '[RequiredNumberError.TOO_SMALL @ lineItem[1].creativePlaceholders[0].size.width, RequiredNumberError.TOO_SMALL @ lineItem[1].creativePlaceholders[0].size.height]';        
        fms = UtilExceptionIntegration.getFriendlyMessage(s);    
        system.debug(s + ' -> ' + fms);      
        s = '[UniqueError.NOT_UNIQUE @ [0].name; trigger:\'brand\']';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);    
        system.debug(s + ' -> ' + fms);      
        s = '[RequiredError.REQUIRED @ targeting.inventoryTargeting]';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);    
        system.debug(s + ' -> ' + fms);  
        s = '[CompanyError.CANNOT_UPDATE_COMPANY_TYPE @ type; trigger:\'ADVERTISER\']';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);    
        system.debug(s + ' -> ' + fms);
        s = '[CommonError.CANNOT_UPDATE @ advertiser.advertiserId; trigger:\'22911308\']';
        fms = UtilExceptionIntegration.getFriendlyMessage(s);    
        system.debug(s + ' -> ' + fms);
    }
}