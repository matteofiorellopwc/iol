/*
    Utility class for OasIntegration.
    Combine methods from OasApiProxy,OasApiAdXmlBuilder to simplify integration
*/

public class OasIntegration{

    private OasApiProxy p;
    private OasApiAdXmlBuilder builder;

    public static Map<String,String> OAS_STATUS = new Map<String,String>{
        'Work in Progress' => 'W',
        'Live' => 'L',
        'Waiting for Approval' => 'P',
        'Ordered' => 'O',
        'Completed' => 'C',
        'Reserved' => 'R',
        'Rejected' => 'J',
        'Cancelled' => 'X',
        'Suspended' => 'S',
        'Archived' => 'A',
        'RLC Decline' => 'D',
        'Template' => 'T'
    };

    public class OasIntegrationException extends Exception{}
    
    public OasIntegration(){
        p = new OasApiProxy();
        builder = new OasApiAdXmlBuilder();
    }
    
    //get all pages
    public string listPages(){
        string s = p.callOasApi(builder.listPages());
        if(Test.isRunningTest()){
            s = '<AdXML>'+
                '<Response>'+
                '  <Pages>Request OK.  Found 185 records.</Pages>'+
                '  <List numberOfRows=\'185\' pageIndex=\'1\' pageSize=\'1000\' totalNumberOfEntries=\'185\'>'+
                '    <Page>'+
                '      <Url>testtelnext.virgilio.it</Url>'+
                '      <Site>testtelnext.virgilio.it</Site>'+
                '     <SiteId>testtelnext.virgilio.it</SiteId>'+
                '      <Description/>'+
                '      <LocationKey>3117</LocationKey>'+
                '    </Page>'+
                '    <Page>'+
                '      <Url>testtelnext.virgilio.it/Home_Page</Url>'+
                '      <Site>testtelnext.virgilio.it</Site>'+
                '      <SiteId>testtelnext.virgilio.it</SiteId>'+
                '      <Description></Description>'+
                '      <LocationKey>3118</LocationKey>'+
                '    </Page>'+
                '  </List>'+
                '</Response>'+
                '</AdXML>';
        }
        return s;
    }
    
    //get pages for pageIndex = index
    public string listPages(integer index){
        string s = p.callOasApi(builder.listPages(index));
        return s;
    }
        
    //get all sections
    public string listSections(){
        string s = p.callOasApi(builder.listSections());
        if(Test.isRunningTest()){
            s = '<Response> '+
                   '   <Section> '+
                   '     <Id>SectionName</Id> '+
                   '     <Pages> '+
                   '       <Url>testtelnext.site.it/Sport/Home</Url> '+
                   '       <Url>testtelnext.site.it/Sport/Tennis</Url> '+
                   '     </Pages> '+
                   '     <InternalQuickReport>to-date</InternalQuickReport> '+
                   '     <ExternalQuickReport>short</ExternalQuickReport> '+
                   '     <WhoCreated>realmedia</WhoCreated> '+
                   '     <WhenCreated>02/20/2013 00:00:00</WhenCreated> '+
                   '     <WhoModified>mpanzeri</WhoModified> '+
                   '     <WhenModified>04/22/2013 10:47:24</WhenModified> '+
                   '   </Section> '+
                   ' </Response>';
        }
        return s;
    }
    
    //get section by id oas
    public string readSectionById(string idOas){
        return p.callOasApi(builder.readSectionById(idOas)); 
    }

    //get campaign by id
    public string readCampaignById(string idOas){
        return p.callOasApi(builder.readCampaignById(idOas));
    }
    
    //get campaigns by order id
    public string listCampaignsByOrderId(string idOas){
        return p.callOasApi(builder.listCampaignsByOrderId(idOas));
    }
    
    public string listCampaignByDate(date minStartDate,date maxEndDate){
        string s = p.callOasApi(builder.listCampaignsByDate(minStartDate,maxEndDate));
        if(Test.isRunningTest()){
            s = '<AdXML> '+
                '    <Response> '+
                '      <Campaign>Request OK.  Found 2 records.</Campaign> '+
                '      <List numberOfRows=\'2\' pageIndex=\'1\' pageSize=\'30000\' totalNumberOfEntries=\'2\'> '+
                '        <Campaign> '+
                '          <Id>test</Id> '+
                '          <Name>LB_016299_LI_0000024042_Advertorial_CPM_320x50</Name> '+
                '          <Status>O</Status> '+
                '          <StartDate>2013-05-29</StartDate> '+
                '          <EndDate>2013-05-30</EndDate> '+
                '          <ImpDelivered>1000</ImpDelivered> '+
                '          <ClicksDelivered>1000</ClicksDelivered> '+
                '          <WhenModified>2013-05-23 11:36:25</WhenModified> '+
                '        </Campaign> '+
                '      </List> '+
                '    </Response> '+
                '</AdXML>';
        }
        return s;
    }
    
    public string syncAcc(Account a,String operation){ 
        return p.callOasApi(builder.syncSfToOasAcc(a,operation));
    }
    
    //add or update a line item list
    public string syncLineItems(LineItem__c[] lis,string operation){
        return p.callOasApi(builder.syncSfToOasLineItems(lis,operation));
    }
    
    //add or update an opportunity
    public string syncOpp(Opportunity o,String[] campaignsId, String operation){
        return p.callOasApi(builder.syncSFtoOasOpp(o,campaignsId,operation));
    }
    
    //change order status 
    public string updateOrderStatus(string id, string newStatus){
        return p.callOasApi(builder.changeOrderStatus(new string[]{id},newStatus));
    }
        
    //change multiple campaign status 
    public string updateCampaignsStatus(string[] ids, string newStatus){
        if(ids.size() > 0){
            return p.callOasApi(builder.changeCampaignsStatus(ids,newStatus));
        }else{
            return '';
        }
    }
        
    //change multiple campaign status to CANCELLED. Cannot delete records from OAS API
    public string deleteCampaigns(list<string> ids){
        return updateCampaignsStatus(ids,'X');
    }
    
    //change campaign status to CANCELLED. Cannot delete records from OAS API
    public string deleteCampaign(string idOas){
        return deleteCampaigns(new list<string>{idOas});
    }
    
    //change all campaigns status in orders.
    public string deleteOrders(list<string> ids){
        string[] campIds = new string[]{};
        for(lineItem__c li : [select id_oas__c from lineitem__c where id_oas__c != null and opportunity__r.id_oas__c in : ids]){
            campIds.add(li.id_oas__c);
        }
        if(campIds.size() > 0){
            return deleteCampaigns(campIds);
        }
        return '';
    }
    
    //change all campaigns status in order
    public void deleteOrder(string idOas){
        deleteOrders(new list<string>{idOas});
    }
    
    //Add relationships to dynamic query
    public static String getAdditionaFields(){
        return  'product__r.Categoria_libero__c,Product__r.Fascia_Oraria__c,'+
                'product__r.formato__c,product__r.canale_primario__c,opportunity__r.status__c,'+
                ' opportunity__r.account.id_oas__c, opportunity__r.centro_media__r.id_oas__c,product__r.size__c,' +
                '(select InventoryTargetingType__c,Ad_Unit__r.PageOAS__c from Inventory_Target__r),' +
                '(select Values__c,oas_field__c from CookieSearchTermsOASTargeted__r),' +
                '(select SectionOas__r.IdOas__c from SectionsOasTargeted__r),' +
                '(Select dayOfWeek__c,dayOfWeekOas__c, Start_Hour__c, End_Hour__c, Start_Minute__c, End_Minute__c From Day_Part_Targeting__r) ';
    }
    
    public static List<Lineitem__c> getLineItemsByOppId(Id oppId) {
        return getLineItemsByOppId(oppId, true);
    }
    
    public static List<Lineitem__c> getLineItemsByOppId(Id oppId, Boolean onlyBanner) {
        return getLineItemsByOppId(oppId,onlyBanner,false);
    }
    public static List<Lineitem__c> getLineItemsByOppId(Id oppId, Boolean onlyBanner, Boolean onlyNotDeletedLineItems) {
        String whereClause = ' Opportunity__c = \''+oppId+'\' ';
        if(onlyBanner){
            whereClause += ' And Integrato_con_OAS_formula__c = \'true\'';
        }
        if(onlyNotDeletedLineItems){
            whereClause += ' AND Cancellato__c <> true ';
        }
        String query = Util.getFieldsSOQL('LineItem__c', whereClause, false, getAdditionaFields(), false);
        return database.query(query);       
    }
    
    public static string removeChatsFromOasId(string idoas){
        string[] chars = new string[]{' ','%','/','\'','"','-'};
        string ret = idoas;
        for(String s : chars){
            ret = ret.replace(s,'_');
        }
        return ret;
    }
    
    public class campaignClass{
        public string id;
        public string name;
        public string status;
        public string StartDate;
        public string EndDate;
        public string ImpDelivered;
        public string ClicksDelivered;
        public string WhenModified;
    }
    
    /*
        get a list of campaignClass for a response like this
        <AdXML>
            <Response>
              <Campaign>Request OK.  Found 2 records.</Campaign>
              <List numberOfRows='2' pageIndex='1' pageSize='30000' totalNumberOfEntries='2'>
                <Campaign>
                  <Id>LB_016299_LI_0000024042_Advertorial_CPM_320x50</Id>
                  <Name>LB_016299_LI_0000024042_Advertorial_CPM_320x50</Name>
                  <Status>O</Status>
                  <StartDate>2013-05-29</StartDate>
                  <EndDate>2013-05-30</EndDate>
                  <ImpDelivered></ImpDelivered>
                  <ClicksDelivered></ClicksDelivered>
                  <WhenModified>2013-05-23 11:36:25</WhenModified>
                </Campaign>
                <Campaign>
                  <Id>LB_016299_LI_0000024043_Advertorial_CPM_320x50</Id>
                  <Name>LB_016299_LI_0000024043_Advertorial_CPM_320x50</Name>
                  <Status>W</Status>
                  <StartDate>2013-05-29</StartDate>
                  <EndDate>2013-05-30</EndDate>
                  <ImpDelivered></ImpDelivered>
                  <ClicksDelivered></ClicksDelivered>
                  <WhenModified>2013-05-23 11:36:26</WhenModified>
                </Campaign>
              </List>
            </Response>
        </AdXML>
    */
    /*
        default use regex to parse xml response
    */
    public list<campaignClass> getCampaignClass(String oasResponse){
        return getCampaignClass(oasResponse,true);
    }    
    public list<campaignClass> getCampaignClass(String oasResponse,Boolean useRegex){
        system.debug('oasResponse = '+oasResponse);
        list<string> campTag = new list<string>();
        
        if(useRegex){
            campTag = OasApiXmlUtility.getEnityListRegex(oasResponse.replaceAll('\n',''), 'Campaign');
        }else{
            campTag = OasApiXmlUtility.getEnityListString(oasResponse.replaceAll('\n',''), 'Campaign');        
        }
        
        system.debug('camp tag:' + campTag);
        list<campaignClass> campaigns = new list<campaignClass>();
        for(string c : campTag){
            
            if(c.contains('<Id>')){
                campaignClass cc = new campaignClass();
                cc.id = OasApiXmlUtility.getFirstEnityRegex(c,'Id');  
                cc.name = OasApiXmlUtility.getFirstEnityRegex(c,'Name');
                cc.status = OasApiXmlUtility.getFirstEnityRegex(c,'Status');
                cc.StartDate = OasApiXmlUtility.getFirstEnityRegex(c,'StartDate');
                cc.EndDate = OasApiXmlUtility.getFirstEnityRegex(c,'EndDate');
                cc.ImpDelivered = OasApiXmlUtility.getFirstEnityRegex(c,'ImpDelivered');
                cc.ClicksDelivered = OasApiXmlUtility.getFirstEnityRegex(c,'ClicksDelivered');
                cc.WhenModified = OasApiXmlUtility.getFirstEnityRegex(c,'WhenModified');
                campaigns.add(cc);
            }
        }
        return campaigns;
    }

    
}