public class ControllerOauthSalesforce {
    public String clientid {get;set;}
    public String redirecturi {get;set;}
    public String clientsecret {get;set;}
    public String authorizeUrl {get;set;}
    public String accessTokenUrl {get;set;}
    public OauthApplication__c oauthapp {get;set;}
    public tokenResponse tr {get;set;}
    
    public string refreshtoken {get;set;}
    
    public string appName {get;set;}
        
    public ControllerOauthSalesforce(){
    	appName = '%Apritisito%';
    	if(ApexPages.CurrentPage() != null && ApexPages.CurrentPage().getParameters().get('appName') != null){
    		appName = '%'+ApexPages.CurrentPage().getParameters().get('appName')+'%';
    	}
    	
        try{
            oauthapp = [Select Scope__c, Name,RedirectUri__c, Client_secret__c, Client_ID__c,RevokeTokenUrl__c, AuthorizeUrl__c, AccessTokenUrl__c From OauthApplication__c where Name like : appName];
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Applicazione non trovata' ));
        }
    
        authorizeUrl = oauthapp.AuthorizeUrl__c;
        accessTokenUrl = oauthapp.AccessTokenUrl__c;
        
        clientid = oauthapp.Client_ID__c;
        clientsecret = oauthapp.Client_secret__c;
                
        redirecturi = oauthapp.RedirectUri__c;
    }

    public String getCodeUrl(){
        String s = authorizeUrl;
        s += '?response_type=code';
        s += '&client_id='+clientid;
        s += '&redirect_uri='+EncodingUtil.urlEncode(redirecturi, 'UTF-8');
        system.debug('urlCode='+s);
        return s;
    }
    
    public String getTokenUrl(){
        String s = accessTokenUrl ;
        s += '?client_id='+clientid;
        s += '&redirect_uri='+EncodingUtil.urlEncode(redirecturi, 'UTF-8');
        return s;    
    }
    
    public PageReference getCode(){
        if(oauthapp != null){
            return new PageReference(getCodeUrl());
        }else{
            return null;
        }
    }
    
    public PageReference getToken(){
        String code = ApexPages.CurrentPage().getParameters().get('code');
        
        if(code != null){
                     
            String auth = '';
            auth += 'code='+code;
            auth += '&grant_type=authorization_code';
            auth += '&client_id='+clientid;
            auth += '&client_secret='+clientsecret;
            auth += '&redirect_uri='+EncodingUtil.urlEncode(redirecturi, 'UTF-8');
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(getTokenUrl());
            req.setBody(auth);
            
            HttpResponse res = h.send(req);
            
            tr = null;
            if(res.getStatusCode() == 200){
                tr = (tokenResponse) JSON.deserialize(res.getBody(), tokenResponse.class);
                system.debug('tokenResponse: '+tr);
            }
        }
        
        return null;
    }
    
    public void refreshToken(){
        //String clientid,String clientsecret,String refreshtoken,String endpoint
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(accessTokenUrl);
        
        String auth = '';
        auth += 'grant_type=refresh_token';
        auth += '&client_id='+clientid;
        auth += '&client_secret='+clientsecret;
        auth += '&refresh_token='+refreshtoken;
        
        req.setBody(auth);
        
        HttpResponse res;
        
        if(!test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"xxx","token_type":"xxx","expires_in":"123"}');
        }
        
        System.debug('Response from request token request: ('+res.getStatusCode()+')'+res.getBody());  
        if(res.getStatusCode() == 200){
            tr = null;
            if(res.getStatusCode() == 200){
                tr = (tokenResponse) JSON.deserialize(res.getBody(), tokenResponse.class);
                system.debug('tokenResponse: '+tr);
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,res.getBody()));
        }
    }
    
    /*
    public class tokenResponse{
        public String access_token;
        public String token_type;
        public String expires_in;
    }
    */

    
    public class tokenResponse{
        public String id {get;set;}
        public String issued_at {get;set;}
        public String scope {get;set;}
        public String instance_url {get;set;}
        public string refresh_token {get;set;}
        public string signature {get;set;}
        public string access_token {get;set;}
    }

}