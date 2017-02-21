public with sharing class OasApiProxy {

    public class OasApiUser{
        public String userId;
        public String password;
        public String account;
        public String oasUrl;
    }
    
    public class OasException extends Exception {}
    
    public class OasResponse {
        public boolean isException {get;set;}
        public string errorCode {get;set;}
        public string message {get;set;}
    }
    
    OasApiUser apiUser;
    
    //Read custom settings for authentication
    public OasApiProxy(){
        BasicAuthApplication__c auth = BasicAuthApplication__c.getInstance('OAS');
        apiUser = new OasApiUser();
        apiUser.userId = auth.username__c;
        apiUser.password = auth.password__c;
        apiUser.oasUrl = auth.endpoint__c;
        apiUser.account = auth.accountid__c;
    }
    //use this method to call the OAS API   
    public String callOasApi(String adXML){
        Http h = new Http();
        HttpRequest req = buildRequest(adXML);
        if(!Test.isRunningTest()){  //don't make http callout when testing
            HttpResponse res = h.send(req);
            return returnAdXml(res);
        }
        else{
            // return fake response for testing purposes. 
            return '<AdXML><Response><Test/></Response></AdXML>';
        }
        
    }
    
    //the following methods are public so they can be covered by test methods, however, you should only use callOasApi to make a request.
    public HttpRequest buildRequest(String adXML){
        system.debug('buildRequest: '+adXml);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUser.oasUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('Accept-Encoding', 'gzip,deflate' );
        req.setHeader('SOAPAction','');
        req.setTimeOut(120000);
        
        //replace <> and " for soap envelope. 
        adXML = adXML.replaceAll('<', '&lt;');
        adXML = adXML.replaceAll('>', '&gt;');
        adXML = adXML.replaceAll('"', '&quot;');
        
        String content = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:api="http://api.oas.tfsm.com/">'+
       '<soapenv:Header/>'+
            '<soapenv:Body>'+
                 '<api:OasXmlRequest>'+
                    '<String_1>' + apiUser.account + '</String_1>'+
                    '<String_2>' + apiUser.userId + '</String_2>'+
                    '<String_3>' + apiUser.password + '</String_3>'+
                    '<String_4>'+ adXML + '</String_4>'+
                '</api:OasXmlRequest>'+
            '</soapenv:Body>'+
        'soapenv:Envelope>';

        req.setHeader('Content-length', content.length().format() );
        req.setBody(content);
        
        return req;
    }
    
    
    public static OasResponse[] responses;
    /*
        getResponse method execute many scripts, set false this static boolean to skip it
    */
    public static boolean getResponses = true;
    public String returnAdXml(HttpResponse res){
        //get content between <AdXM>...</AdXML>
        if (res.getStatusCode() != 200) {
            throw new OasException('Request failed. Possible causes, API is not currently available or network failure, the endpoint URL specified for OAS is incorrect.'
                    + ' status Code='+ res.getStatusCode()
                    + ' status=' + res.getStatus()
                    + ' body=' + res.getBody()
                    );
        }
        String adXML = stripEnvelope(res.getBody());
        System.debug(Logginglevel.INFO, 'AdXML response: ' + adXML);
        //parse response
        
        if(getResponses){
            responses = getResponse(adXml);
        }
        
        if(adXML != null && adXml.contains('Exception')){
            OasApiXMLDom dom = new OasApiXMLDom(adXML);
            if(dom.getElementsByTagName('Exception').size() >= 1){
                String errMsg = dom.getElementsByTagName('Exception')[0].getAttribute('errorCode') + ': ' +  dom.getElementsByTagName('Exception')[0].nodeValue;
                System.debug(Logginglevel.ERROR, errMsg);
                throw new OasException(errMsg); 
            }else{
                if(adXML == null){
                    return '';
                }
                else{
                    return adXML;
                }
            }
        }else{
            if(adXML == null){
                return '';
            }
            else{
                return adXML;
            }
        }
    }
    
    /*
        Parse an xml like this in OasResponse[]
        <AdXML>
            <Response>
              <Campaign>Successfully added.</Campaign>
            </Response>
            <Response>
              <Campaign>
                <Exception errorCode='569'>scheduled_and_daily_impressions_not_positive</Exception>
              </Campaign>
            </Response>
        </AdXML>
    */
    public OasResponse[] getResponse(String adXml){
        OasResponse[] rr = new OasResponse[]{};
        OasApiXMLDom dom = new OasApiXMLDom(adXML);
        
        for(OasApiXMLDom.Element e : dom.getElementsByTagName('Response')){
            OasResponse r = new OasResponse();
            if(e.getElementsByTagName('Exception').size() > 0){
                r.message = e.getElementsByTagName('Exception')[0].nodeValue;
                r.errorCode = e.getElementsByTagName('Exception')[0].getAttribute('errorCode');
                r.isException = true;
            }else{
                r.message = e.firstChild().nodeValue;
                r.isException = false;
            }
            rr.add(r);
        }
        return rr;
    }
    
    private String stripEnvelope(String xml){
        xml = xml.replaceAll('&lt;', '<');
        xml = xml.replaceAll('&gt;', '>');
        xml = xml.replaceAll('&quot;', '"');
        
        //Strip off soap envelope.
        try{
            xml = xml.substring(xml.indexOf('<AdXML>'), xml.indexOf('</AdXML>') + 8);
        }
        catch(StringException e){
            System.debug(e);
            throw new OasException('Unknown Error');
        }
        return xml;
    }

}