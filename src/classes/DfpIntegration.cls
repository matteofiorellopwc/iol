public without sharing class DfpIntegration{

    public DfpCompanyService.CompanyServiceInterfacePort companyService {get;set;}
    public DfpOrderService.orderServiceInterfacePort orderService {get;set;}
    public DfpInventoryService.InventoryServiceInterfacePort inventoryService {get;set;}
    public DfpLineItemService.lineItemServiceInterfacePort lineItemService {get;set;}
    public DfpForecastService.ForecastServiceInterfacePort forecastService {get;set;}
    public DfpCustomTargetingService.CustomTargetingServiceInterfacePort customTargetingService {get;set;}
    public DfpAudienceSegmentService.AudienceSegmentServiceInterfacePort audienceSegmentService {get;set;}
    public DfpPublisherQueryLanguageService.PublisherQueryLanguageServiceInterfacePort publisherQueryLanguageService {get;set;}    
    public DfpReportService.ReportServiceInterfacePort reportService {get;set;}    
    public DfpPlacementService.PlacementServiceInterfacePort placementService {get;set;}        
    public DfpLabelService.LabelServiceInterfacePort labelService {get;set;}            
    public DfpUserService.UserServiceInterfacePort userService {get;set;} 
    public DfpTeamService.TeamServiceInterfacePort teamService {get;set;}
     
    public Decimal currentUserId {get;set;}
 
    public DfpIntegration(){
        OAuth_Token__c oats;
        
        try{
            oats = [select id,name,DfpUserId__c from OAuth_Token__c where Use_for_all_integration__c = true limit 1]; //  where ownerid =: UserInfo.getUserId() limit 1
        }catch(Exception e){
            if(Test.isRunningTest()){
                oats = new OAuth_Token__c(name='test',DfpUserId__c=1);
            }else{
                //throw new dfpException('Autenticazione DFP non effettuata! Clicca <a href="/apex/oauth2callback?sfdc.tabName=01r200000006Epp" target="_blank">qui</a> per risolvere il problema.');
                throw new dfpException('Autenticazione DFP non effettuata!');
            }
        }
        //oats = [select id,name from OAuth_Token__c where Use_For_Anonimous__c = true limit 1]; //if UserInfo.getUserId() == null
        this.currentUserId = oats.DfpUserId__c;
        initIntegration(oats.name,null);
    }
    
    public DfpIntegration(String refreshToken){
        initIntegration(refreshToken,null);
    }
    
    public DfpIntegration(String refreshToken,String accessToken){
        initIntegration(refreshToken,accessToken);
    }

    public void initIntegration(String refreshToken,String access_token){
        companyService = new DfpCompanyService.CompanyServiceInterfacePort();
        orderService = new DfpOrderService.orderServiceInterfacePort();
        inventoryService = new DfpInventoryService.InventoryServiceInterfacePort();
        lineItemService = new DfpLineItemService.lineItemServiceInterfacePort();  
        forecastService = new DfpForecastService.ForecastServiceInterfacePort();
        customTargetingService = new DfpCustomTargetingService.CustomTargetingServiceInterfacePort();
        publisherQueryLanguageService = new DfpPublisherQueryLanguageService.PublisherQueryLanguageServiceInterfacePort();
        reportService = new DfpReportService.ReportServiceInterfacePort();
        placementService = new DfpPlacementService.PlacementServiceInterfacePort();
        labelService = new DfpLabelService.LabelServiceInterfacePort();   
        userService = new DfpUserService.UserServiceInterfacePort();   
        teamService = new DfpTeamService.TeamServiceInterfacePort();
        audienceSegmentService = new DfpAudienceSegmentService.AudienceSegmentServiceInterfacePort();

        OauthApplication__c oauthapp;
        try{
            oauthapp = [Select Scope__c, Name,RedirectUri__c, Client_secret__c, Client_ID__c, AuthorizeUrl__c, AccessTokenUrl__c, networkCode__c From OauthApplication__c where Active__c = true];
        }catch(Exception e){
            if(Test.isRunningTest()){
                oauthapp = new OauthApplication__c(Scope__c='test',Name='test',RedirectUri__c='test', Client_secret__c='test', Client_ID__c='test', AuthorizeUrl__c='test', AccessTokenUrl__c='test', networkCode__c='test');
            }else{
                throw new dfpException('Applicazione di integrazione con DFP non trovata');
            }
        }
        
        String networkCode = oauthapp.networkCode__c;
        Integer calloutTimeOut = 120000; 
        String accessToken;
        
        if(access_token == null){
            try{
                accessToken = DfpIntegration.refreshToken(oauthapp.Client_ID__c,oauthapp.Client_secret__c,refreshToken,oauthapp.AccessTokenUrl__c);
            }catch(Exception e){
                throw new dfpException('Errore durante l\'integrazione con DFP: '+e.getMessage());        
            }
        }else{
            accessToken = access_token;
        }

        companyService.inputHttpHeaders_x = new Map<String,String>();
        companyService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        companyService.RequestHeader = new DfpCompanyService.SoapRequestHeader();
        companyService.RequestHeader.applicationName = 'Salesforce DFP Integration';  
        companyService.RequestHeader.networkCode = networkCode; 
        companyService.timeout_x = calloutTimeOut;
        
        orderService.inputHttpHeaders_x = new Map<String,String>();
        orderService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        orderService.RequestHeader = new DfporderService.SoapRequestHeader();
        orderService.RequestHeader.applicationName = 'Salesforce DFP Integration';    
        orderService.RequestHeader.networkCode = networkCode; 
        orderService.timeout_x = calloutTimeOut;
        
        /*
        orderService201208.inputHttpHeaders_x = new Map<String,String>();
        orderService201208.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        orderService201208.RequestHeader = new DfporderService201208.SoapRequestHeader();
        orderService201208.RequestHeader.applicationName = 'Salesforce DFP Integration';    
        orderService201208.RequestHeader.networkCode = networkCode;         
        */
                
        inventoryService.inputHttpHeaders_x = new Map<String,String>();
        inventoryService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        inventoryService.RequestHeader = new DfpinventoryService.SoapRequestHeader();
        inventoryService.RequestHeader.applicationName = 'Salesforce DFP Integration';    
        inventoryService.RequestHeader.networkCode = networkCode; 
        inventoryService.timeout_x = calloutTimeOut;
        
        lineItemService.inputHttpHeaders_x = new Map<String,String>();
        lineItemService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        lineItemService.RequestHeader = new DfplineItemService.SoapRequestHeader();
        lineItemService.RequestHeader.applicationName = 'Salesforce DFP Integration';  
        lineItemService.RequestHeader.networkCode = networkCode; 
        lineItemService.timeout_x = calloutTimeOut;
        
        forecastService.inputHttpHeaders_x = new Map<String,String>();
        forecastService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        forecastService.RequestHeader = new DfpForecastService.SoapRequestHeader();
        forecastService.RequestHeader.applicationName = 'Salesforce DFP Integration';   
        forecastService.RequestHeader.networkCode = networkCode; 
        forecastService.timeout_x = calloutTimeOut;
        
        customTargetingService.inputHttpHeaders_x = new Map<String,String>();
        customTargetingService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        customTargetingService.RequestHeader = new DfpCustomTargetingService.SoapRequestHeader();
        customTargetingService.RequestHeader.applicationName = 'Salesforce DFP Integration';   
        customTargetingService.RequestHeader.networkCode = networkCode; 
        customTargetingService.timeout_x = calloutTimeOut;
        
        publisherQueryLanguageService.inputHttpHeaders_x = new Map<String,String>();
        publisherQueryLanguageService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        publisherQueryLanguageService.RequestHeader = new DfpPublisherQueryLanguageService.SoapRequestHeader();
        publisherQueryLanguageService.RequestHeader.applicationName = 'Salesforce DFP Integration';           
        publisherQueryLanguageService.RequestHeader.networkCode = networkCode; 
        publisherQueryLanguageService.timeout_x = calloutTimeOut;
        
        reportService.inputHttpHeaders_x = new Map<String,String>();
        reportService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        reportService.RequestHeader = new DfpReportService.SoapRequestHeader();
        reportService.RequestHeader.applicationName = 'Salesforce DFP Integration'; 
        reportService.RequestHeader.networkCode = networkCode; 
        reportService.timeout_x = calloutTimeOut;
        
        placementService.inputHttpHeaders_x = new Map<String,String>();
        placementService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        placementService.RequestHeader = new DfpPlacementService.SoapRequestHeader();
        placementService.RequestHeader.applicationName = 'Salesforce DFP Integration';       
        placementService.RequestHeader.networkCode = networkCode; 
        placementService.timeout_x = calloutTimeOut;
        
        labelService.inputHttpHeaders_x = new Map<String,String>();
        labelService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        labelService.RequestHeader = new DfpLabelService.SoapRequestHeader();
        labelService.RequestHeader.applicationName = 'Salesforce DFP Integration';   
        labelService.RequestHeader.networkCode = networkCode;                 
        labelService.timeout_x = calloutTimeOut;
       
        userService.inputHttpHeaders_x = new Map<String,String>();
        userService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        userService.RequestHeader = new DfpUserService.SoapRequestHeader();
        userService.RequestHeader.applicationName = 'Salesforce DFP Integration';                           
        userService.RequestHeader.networkCode = networkCode; 
        userService.timeout_x = calloutTimeOut;
        
        teamService.inputHttpHeaders_x = new Map<String,String>();
        teamService.inputHttpHeaders_x.put('Authorization','OAuth '+accessToken);
        teamService.RequestHeader = new DfpTeamService.SoapRequestHeader();
        teamService.RequestHeader.applicationName = 'Salesforce DFP Integration';                           
        teamService.RequestHeader.networkCode = networkCode; 
        teamService.timeout_x = calloutTimeOut;
        
        audienceSegmentService.inputHttpHeaders_x = new Map<String,String>();
        audienceSegmentService.inputHttpHeaders_x.put('Authorization', 'OAuth ' + accessToken);
        audienceSegmentService.RequestHeader = new DfpAudienceSegmentService.SoapRequestHeader();
        audienceSegmentService.RequestHeader.applicationName = 'Salesforce DFP Integration';
        audienceSegmentService.RequestHeader.networkCode = networkCode;
        audienceSegmentService.timeout_x = calloutTimeOut;
        
    }
    
    public static String refreshToken(String clientid,String clientsecret,String refreshtoken,String endpoint){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);

/*        
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        String clientid = '769580457244.apps.googleusercontent.com';
        String clientsecret = 'xTTgderW4VPY8Unagl6R1dJb';
        String refreshtoken = '1/D8JyiHX-9mq7R0XcjTP7adbVkXMkYTZ4UaIXPE3LVYs';
*/        
        
        String auth = '';
        auth += 'grant_type=refresh_token';
        auth += '&client_id='+clientid;
        auth += '&client_secret='+clientsecret;
        auth += '&refresh_token='+refreshtoken;
        
        req.setBody(auth);
        
        HttpResponse res;
        
        if(! test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"xxx","token_type":"xxx","expires_in":"123"}');
        }
        
        String response = '';
        if(res.getStatusCode() == 200){
            tokenResponse tr = (tokenResponse) JSON.deserialize(res.getBody(), tokenResponse.class);
            response = tr.access_token;
        }
        System.debug('Response from request token request: ('+res.getStatusCode()+')'+res.getBody());  
        
        return response;   
    
    }    
    
    public class dfpException extends exception{}
    
    public class tokenResponse{
        public String access_token;
        public String token_type;
        public String expires_in;
    }

}