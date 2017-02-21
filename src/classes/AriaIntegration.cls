public class AriaIntegration{
    public class AriaIntegrationException extends Exception {}
    private static final String ARIA_AUTHORIZATION_HEADER;
    private static final String ARIA_ENDPOINT;       
    static {
        if(Test.isRunningTest()) {
            ARIA_AUTHORIZATION_HEADER = 'BASIC ';        
            ARIA_ENDPOINT = 'http://www.test.com';                      
        } else {
            BasicAuthApplication__c cs = BasicAuthApplication__c.getInstance('itNet');
            Blob headerValue = Blob.valueOf(cs.username__c + ':' + cs.password__c);
            ARIA_AUTHORIZATION_HEADER = 'BASIC ' + EncodingUtil.base64Encode(headerValue);        
            ARIA_ENDPOINT = cs.endpoint__c;         
        } 
    }
    
    private static HttpResponse makeAriaCall(String queryString) {
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint(ARIA_ENDPOINT + '?' + queryString);
        r.setHeader('Authorization', ARIA_AUTHORIZATION_HEADER);
        r.setMethod('GET');        
        r.setTimeOut(30000);
        if(Test.isRunningTest()) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"cod":0,"desc":""}');
            return res;
        } else return h.send(r);          
    }
    
    public static Map<String, Object> changeAccountStatus(String accountId, String ariaKey) {
        HttpResponse res = makeAriaCall(
            'output_format=json'                               +
            '&cmd=AriaChangeAccountStatus'                     +
            '&aria_account_number=' + ariaKey                  +
            '&sf_user_id=' + accountId                         +
            '&status=cancel'
        );
        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    }
    
    public static Map<String, Object> createOrder(String accountId, Decimal amount, String ariaKey, Id contractId) {
        try { 
        
            HttpResponse res = makeAriaCall(
                'output_format=json'                               +
                '&cmd=AriaCreateOrder'                             +
                '&aria_account_number=' + ariaKey                  +
                '&sf_user_id=' + accountId                         +
                '&amount=' + String.valueOf(amount)                +
                (contractId != null ? '&contract_number=' + contractId : '')
            );
            system.debug(res.getBody());
               
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody().replace('[', '{').replace(']', '}'));
        } catch(Exception e) {
            throw new AriaIntegrationException('ERRORE DURANTE LA CHIAMATA AD ARIA: ' + e);
        }
    }
}