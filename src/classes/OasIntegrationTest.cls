@isTest
public class OasIntegrationTest{
    public static void insertTestAuth(){
        BasicAuthApplication__c ba = new BasicAuthApplication__c(
            Name = 'OAS',
            username__c = 'test',
            password__c = 'test',
            endpoint__c = 'test',
            accountid__c = 'test'
        );
        insert ba;
    }   

    public static testMethod void testOasApiAdXmlTemplate(){
        string s;
        s = OasApiAdXmlTemplate.readListRequest;
        s = OasApiAdXmlTemplate.listRequest;
        s = OasApiAdXmlTemplate.addUpdateIo;
        s = OasApiAdXmlTemplate.addUpdateCamp;
    }
    
    public static testMethod void testOasApiXmlUtility(){
        //test fails
        string s = 'test';
        system.assertEquals(OasApiXmlUtility.getEnityListRegex(s,'Id').size(),0);
        s = '<Id>';
        system.assertEquals(OasApiXmlUtility.getEnityListRegex(s,'Id').size(),0);
        
        //test
        s = '<test><Id>id1</Id><Id>id2</Id></test>';
        set<string> ids = new set<string>();
        ids.addAll(OasApiXmlUtility.getEnityListRegex(s,'Id'));
        system.assertEquals(ids.size(),2);
        system.assert(ids.contains('id1'));
        system.assert(ids.contains('id2'));
        
        OasApiXmlUtility.getEntityList(s);
        OasApiXmlUtility.getEntityList(s,'notag');
        OasApiXmlUtility.getEntityList('<voidtag></voidtag>','voidtag');
        OasApiXmlUtility.getEntityList('noxml','notag');
        
    }
    
    public static testMethod void testOasApiProxy(){
        insertTestAuth();
        OasApiProxy oas = new OasApiProxy();
        oas.callOasApi('test');
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        try{    oas.returnAdXml(res);    }catch(OasApiProxy.OasException e){    }
        
        res.setStatusCode(200);
        res.setBody('resp');
        try{    oas.returnAdXml(res);    }catch(OasApiProxy.OasException e){    }
        
        res.setBody('<AdXML><Response><Test/></Response></AdXML>');
        oas.returnAdXml(res);
    }
    
    public static testMethod void testOasApiAdXmlBuilder(){
        OasApiAdXmlBuilder OasApiAdXmlBuilder = new OasApiAdXmlBuilder();
        OasApiAdXmlBuilder.listOperation('test','test');
        OasApiAdXmlBuilder.readCampaignById('test');
        OasApiAdXmlBuilder.readSectionById('test');
        OasApiAdXmlBuilder.listCampaignsByOrderId('test');
        OasApiAdXmlBuilder.listPages();
        OasApiAdXmlBuilder.listSections();
    }

    public static testMethod void testOasResponse(){
        insertTestAuth();
        string adXml =  '<AdXML>'+
                        '   <Response>'+
                        '     <Campaign>Successfully added.</Campaign>'+
                        '   </Response>'+
                        '   <Response>'+
                        '     <Campaign>'+
                        '       <Exception errorCode=\'569\'>scheduled_and_daily_impressions_not_positive</Exception>'+
                        '     </Campaign>'+
                        '   </Response>'+
                        '</AdXML>';
        OasApiProxy p = new OasApiProxy();
        OasApiProxy.OasResponse[] res = p.getResponse(adXml);
        system.debug('res' + res);
        system.assertEquals(res.size(),2);
        system.assertEquals(res[0].isException,false);
        system.assertEquals(res[0].message,'Successfully added.');
        system.assertEquals(res[1].isException,true);
        system.assertEquals(res[1].message,'scheduled_and_daily_impressions_not_positive');
    }
    
    public static testMethod void testOasIntegration(){
        insertTestAuth();
        OasIntegration oas = new OasIntegration();
        oas.listPages();       
        oas.listSections();
        oas.readSectionById('');
        oas.listCampaignsByOrderId('');
        oas.updateOrderStatus('id','newStatus');
        oas.updateCampaignsStatus(new string[]{},'newStatus');
        oas.deleteCampaigns(new list<string>());
        oas.deleteCampaign('idOas');
        oas.deleteOrders(new list<string>());
        oas.deleteOrder('idOas');
        oas.deleteOrders(new list<string>{''}); 
        
        OasIntegration.removeChatsFromOasId('test%%');
    }
    
    public static testMethod void testOasIntegrationBuilder(){
        utilityTest.createFattoreCorrettivoFasce();
        insertTestAuth();
        OasIntegration oas = new OasIntegration();
        
        Account a = utilityTest.insertCentroMedia();
        a = [select id,oasType__c,id_oas__c,name from account where id =: a.id];
        
        Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
        insert o;
        ApexPages.StandardController sc = new ApexPages.standardController(o);
        ExtensionAddProduct controller = new ExtensionAddProduct(sc);
        controller.prodId = utilityTest.createBannerOas().id;
        controller.addProduct(); 

        oas.syncAcc(a,'add');
         
        oas.syncLineItems(OasIntegration.getLineItemsByOppId(o.id),'add');
        oas.syncOpp(O,new String[]{'CAMP1','CAMP2'}, 'add');
    }
    
    public static testMethod void testOasIntegrationGetCampaignClass(){
        insertTestAuth();
        OasIntegration oas = new OasIntegration();
        
        String oasResponse = '<AdXML> ' + 
                 '                  <Response>' +
                 '                    <Campaign>Request OK.  Found 2 records.</Campaign>'+
                 '                    <List numberOfRows=\'2\' pageIndex=\'1\' pageSize=\'30000\' totalNumberOfEntries=\'2\'>'+
                 '                      <Campaign>'+
                 '                        <Id>LB_016299_LI_0000024042_Advertorial_CPM_320x50</Id>'+
                 '                        <Name>LB_016299_LI_0000024042_Advertorial_CPM_320x50</Name>'+
                 '                        <Status>O</Status>'+
                 '                        <StartDate>2013-05-29</StartDate>'+
                 '                        <EndDate>2013-05-30</EndDate>'+
                 '                        <ImpDelivered></ImpDelivered>'+
                 '                        <ClicksDelivered></ClicksDelivered>'+
                 '                        <WhenModified>2013-05-23 11:36:25</WhenModified>'+
                 '                      </Campaign>'+
                 '                      <Campaign>'+
                 '                        <Id>LB_016299_LI_0000024043_Advertorial_CPM_320x50</Id>'+
                 '                        <Name>LB_016299_LI_0000024043_Advertorial_CPM_320x50</Name>'+
                 '                        <Status>W</Status>'+
                 '                        <StartDate>2013-05-29</StartDate>'+
                 '                        <EndDate>2013-05-30</EndDate>'+
                 '                        <ImpDelivered></ImpDelivered>'+
                 '                        <ClicksDelivered></ClicksDelivered>'+
                 '                        <WhenModified>2013-05-23 11:36:26</WhenModified>'+
                 '                      </Campaign>'+
                 '                    </List>'+
                 '                  </Response>'+
                 '              </AdXML>';
        OasIntegration.campaignClass[] camps = oas.getCampaignClass(oasResponse);
        system.assertEquals(2,camps.size());
        system.assertEquals('LB_016299_LI_0000024042_Advertorial_CPM_320x50',camps[0].id);
    }
    
    public static testMethod void testBatchableUpsertDatamodelOas(){
        OasIntegrationTest.insertTestAuth();
        ControllerOasDataModelIntegration c = new ControllerOasDataModelIntegration();
        test.startTest();
        c.syncPagesSections();
        c.getJobStatus();
        test.stopTest();
    }
    
    public static testMethod void testUpdateOrdersFromOas(){
        utilityTest.createFattoreCorrettivoFasce();
        OasIntegrationTest.insertTestAuth();
        insertTestAuth();
        OasIntegration oas = new OasIntegration();
        
        Account a = utilityTest.insertCentroMedia();
        a = [select id,oasType__c,id_oas__c,name from account where id =: a.id];
        
        Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
        insert o;
        ApexPages.StandardController sc = new ApexPages.standardController(o);
        ExtensionAddProduct controller = new ExtensionAddProduct(sc);
        controller.prodId = utilityTest.createBannerOas().id;
        controller.addProduct(); 
        
        lineitem__c li = [select id_oas__c,start_date__c from lineitem__C where ad_server__c = 'OAS' limit 1];
        li.id_oas__c = 'test';
        LineItemTriggerHandler.skipValidationTotali = true;
        update li;
        
        UpdateOrdersFromOas.UpdateLineItemByDate(li.start_date__c,li.start_date__c);
    }
    
}