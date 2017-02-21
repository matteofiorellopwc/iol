public class ControllerOauth2 {
    OAuth_Token__c oat {get;set;}
    OauthApplication__c oauthapp {get;set;}
    public decimal tokenNumber {get;set;}
    public dfpUser currentUser {get;set;}    
    public string error {get;set;}

    public ControllerOauth2(){
        error = '';
        currentUser = null;
        list<OAuth_Token__c> oats = [select id,name from OAuth_Token__c where ownerid =: UserInfo.getUserId()];
        tokenNumber = oats.size();
        if(tokenNumber == 1){
            oat = oats.get(0);
        }
        
        try{
            oauthapp = [Select Scope__c, Name,RedirectUri__c, Client_secret__c, Client_ID__c,RevokeTokenUrl__c, AuthorizeUrl__c, AccessTokenUrl__c From OauthApplication__c where Active__c = true];
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deve esserci un\'unica applicazione attiva!' ));
        }
    }
    
    public void testAuth(){
        error = '';
        try{
            DfpIntegration dfp = new DfpIntegration();
            getCurrentUser(dfp);
        }catch(Exception e){
            error = e.getMessage();
        }
    }
    
    public void getCurrentUser(DfpIntegration dfp){
        DfpUserService.User_x u = dfp.userService.getCurrentUser();
        system.debug('DfpUserService.currentuser: '+u);
        currentUser = new dfpUser();
        currentUser.id = u.id;
        currentUser.name = u.name;
        currentUser.email = u.email;
        currentUser.UserRecord_Type =''; // u.UserRecord_Type;
        system.debug('currentUser: '+currentUser);    
    }
    
    public PageReference resetAuth(){
    
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(oauthapp.revokeTokenUrl__c+'?token='+oat.name);

        HttpResponse res = h.send(req);
        response = 'Response from revoking token: ('+res.getStatusCode()+')'+res.getBody();  
            
        system.debug('response: ' + response); 
            
        delete oat;
        PageReference p = new PageReference('/apex/oauth2callback');
        p.setRedirect(true);
        return p;
    }
    
    public class dfpUser{
        public Long id {get;set;}
        public String name {get;set;}
        public String email {get;set;}
        public String UserRecord_Type {get;set;}
    }
    
    public PageReference getCode(){
        return new PageReference(getCodeUrl());
    }    
    
    public String getCodeUrl(){
        String s = oauthapp.authorizeUrl__c;
        s += '?response_type=code';
        s += '&access_type=offline';   //per avere anche refresh token     
        s += '&client_id='+oauthapp.client_id__c;
        if(oauthapp.scope__c != null){
            s += '&scope='+oauthapp.scope__c;
        }
        s += '&redirect_uri='+EncodingUtil.urlEncode(oauthapp.RedirectUri__c, 'UTF-8');
        return s;
    }
    
    public String getTokenUrl(){
        String s = oauthapp.accessTokenUrl__c ;
        s += '?client_id='+oauthapp.client_id__c;
        s += '&redirect_uri='+EncodingUtil.urlEncode(oauthapp.RedirectUri__c, 'UTF-8');
        return s;    
    }
    
    public string response {get;set;}
    
    public PageReference getToken(){
        PageReference p = null;
        String code = ApexPages.CurrentPage().getParameters().get('code');
        
        if(code != null){
            String auth = '';
            auth += 'code='+code;
            auth += '&grant_type=authorization_code';
            auth += '&client_id='+oauthapp.client_id__c;
            auth += '&client_secret='+oauthapp.client_secret__c;
            auth += '&redirect_uri='+EncodingUtil.urlEncode(oauthapp.RedirectUri__c, 'UTF-8');
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(getTokenUrl());
            req.setBody(auth);

            HttpResponse res = h.send(req);
            response = 'Response from request token request: ('+res.getStatusCode()+')'+res.getBody();  
            
            system.debug('response: ' + response); 
            
            if(res.getStatusCode() == 200){
                tokenResponse tr = (tokenResponse) JSON.deserialize(res.getBody(), tokenResponse.class);
                system.debug('tokenResponse: '+tr);
                oat = new OAuth_Token__c(name=tr.refresh_token);
                /**Get User Id**/
                DfpIntegration dfp = new DfpIntegration(tr.refresh_token,tr.access_token);
                getCurrentUser(dfp);
                oat.DfpUserId__c = currentUser.id;
                insert oat;
                p = new PageReference('/apex/oauth2callback');
                p.setRedirect(true);
            }    
        }
        
        return p;
    }
    
    public class tokenResponse{
        public String access_token;
        public String token_type;
        public String expires_in;
        public String refresh_token;
    }    
    
    public static testMethod void testControllerOauth2(){
        ControllerOauth2 c = new ControllerOauth2();
        try{ c.testAuth(); }catch(exception e){}
        try{ c.getCurrentUser(null); }catch(exception e){}
        try{ c.resetAuth(); }catch(exception e){}
        ControllerOauth2.dfpUser dfpUser = new ControllerOauth2.dfpUser();
        try{ c.getCode(); }catch(exception e){}
        try{ c.getCodeUrl(); }catch(exception e){}
        try{ c.getTokenUrl(); }catch(exception e){}
        ApexPages.CurrentPage().getParameters().put('code','code');
        try{ c.getToken(); }catch(exception e){}
        ControllerOauth2.tokenResponse tokenResponse = new ControllerOauth2.tokenResponse();
    }
}