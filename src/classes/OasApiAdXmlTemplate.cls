/*
    Template for OAS Request
    http://www.247realmedia.com/EN-US/oas11-help/Default.htm
*/

public class OasApiAdXmlTemplate {
    /* 
        LIST PAGE
        <AdXML>
            <Request type="Page">
                <Database action="list">
                    <SearchCriteria>
                        <Domain>mySite</Domain>
                        <Url>001</Url>
                    </SearchCriteria>
                </Database>
            </Request>
        </AdXML>
        
        LIST CAMPAIGN
        <AdXML> 
            <Request type="Campaign"> 
                  <Campaign action="list"> 
                      <SearchCriteria> 
                            <Status>W</Status>
                            <Id>api%01</Id>
                       </SearchCriteria>
                  </Campaign>
             </Request>
        </AdXML>
    
      READ EXAMPLE
        AdXML>
              <Request type="Page">
                    <Database action="read">
                          <Page>
                                <Url>www.mySite.com/page</Url>
                          </Page>
                    </Database>
              </Request>
        </AdXML>    
        
        <AdXML>
            <Request type="Campaign">
                <Campaign action="read">
                    <Overview>
                        <Id>123</Id>
                    </Overview>
                </Campaign>
            </Request>
        </AdXML>
        
    */
    
    /*
        Generic read or list
    */
    public static final string readListRequest = 
        '<Request type="@@TYPE@@">'+  //@@TYP@@ is entity type, ie InsertionOrder, Campagin etc
            '<@@REQUESTTYPE@@ action="@@ACTION@@">'+
                '<@@SEARCHCRITERIA@@ @@SEARCHCRITERIAPARAM@@>'+
                    '@@SEARCHVALUES@@'+
                '</@@SEARCHCRITERIA@@>'+
            '</@@REQUESTTYPE@@>'+
        '</Request>';
        
        
    /*
        list by Id
    */
    public static final string listRequest = 
        '<Request type="@@TYPE@@">'+  //@@TYP@@ is entity type, ie InsertionOrder, Campagin etc
            '<@@TYPE@@ action="list">'+
                '<SearchCriteria>'+
                    '<Id exact="true">@@ID@@</Id>'+  //@@ID@@ is the entity ID that we are searching for
                '</SearchCriteria>'+
            '</@@TYPE@@>'+
        '</Request>';        

    /*
        Insertion Order
    */
    public static final String addUpdateIo =
        '<Request type="InsertionOrder">'+
            '<InsertionOrder action="@@OPERATION@@">'+          //@@OPERATION@@ is either an "add" or "update"
                '<Id>@@ID@@</Id>'+                              //@@ID@@ is the insertion order Id
                '<Description>@@DESCRIPTION@@</Description>'+
                '<CampaignsBy>@@CAMBY@@</CampaignsBy>'+         //@@CAMBY@@ is campaigns by which is either "A" for Advertiser or "G" for agency
                '<AdvertiserId>@@ADVERTISER@@</AdvertiserId>'+
                '<AgencyId>@@AGENCY@@</AgencyId>'+
                '<Status>@@STATUS@@</Status>'+
                '<StartDate>@@START_DATE@@</StartDate>'+
                '<EndDate>@@END_DATE@@</EndDate>'+
                '<SalesPerson>@@SALESPERSON@@</SalesPerson>'+
                '<BookedRevenue></BookedRevenue>'+                                    
                '<Campaigns>@@CAMPAIGNS@@</Campaigns>' + //<CampaignId>campid</CampaignId>
                //'<InternalQuickReport>short</InternalQuickReport>'+
                //'<ExternalQuickReport>standard</ExternalQuickReport>'+
            '</InsertionOrder>'+
        '</Request>';
    
    /*
        Campaign
    */
    public static final String addUpdateCamp =
        '<Request type="Campaign">'+
            '<Campaign action="@@OPERATION@@">'+
                '<Overview>'+
                    '<Id>@@ID@@</Id>'+                    
                    '<AdvertiserId>@@ADVERTISER@@</AdvertiserId>'+
                    '<Name>@@NAME@@</Name>'+       
                    '<AgencyId>@@AGENCY@@</AgencyId>'+
                    '<Description>@@DESCRIPTION@@</Description>'+
                    '<ProductId>@@PRODUCT@@</ProductId>'+
                    '<Status>@@STATUS@@</Status>'+  
                '</Overview>'+
                '<Schedule>'+
                    '<Impressions>@@IMPRESSIONS@@</Impressions>'+
                    '<Clicks>@@CLICKS@@</Clicks>'+
                    '<PriorityLevel>@@PRIORITY@@</PriorityLevel>'+
                    '<Completion>@@COMPLETION@@</Completion>'+
                    '<StartDate>@@START_DATE@@</StartDate>'+
                    '<StartTime>@@START_HOUR@@:00</StartTime>'+ //always XX:00
                    '<EndDate>@@END_DATE@@</EndDate>'+
                    '<EndTime>@@END_HOUR@@:59</EndTime>'+ //always XX:59
                    '<Reach>@@REACH@@</Reach>'+
                    '<DailyImp>@@DAILYIMPR@@</DailyImp>'+
                    '<DailyClicks>@@DAILYCLICK@@</DailyClicks>'+
                    '<SmoothOrAsap>@@SMOOTHORASAP@@</SmoothOrAsap>'+
                    '<ImpOverrun>@@IMPOVERRUN@@</ImpOverrun>'+
                    '<PrimaryFrequency>'+
                        '<ImpPerVisitor>@@OasPrimaryFrequencyImpPerVisitor@@</ImpPerVisitor>'+
                        '<ClickPerVisitor>@@OasPrimaryFrequencyClickPerVisitor@@</ClickPerVisitor>'+
                        '<FreqScope>@@OasPrimaryFreqScope@@</FreqScope>'+
                    '</PrimaryFrequency>'+
                    '<SecondaryFrequency>'+
                        '<ImpPerVisitor>@@OasSecondaryFrequencyImpPerVisitor@@</ImpPerVisitor>'+
                        '<FreqScope>@@OasSecondaryFreqScope@@</FreqScope>'+
                    '</SecondaryFrequency>'+
                    '<HourOfDay>'+
                        '@@HOUROFDAY@@'+ //<Hour>00</Hour><Hour>01</Hour>'<Hour>23</Hour>
                    '</HourOfDay>'+                   
                    '<DayOfWeek>'+
                        '@@DAYOFWEEK@@' +   //<Day>2</Day><Day>3</Day>  // 1 = Monday
                    '</DayOfWeek>'+
                    '<UserTimeZone>N</UserTimeZone>'+
                    '<Sections>'+
                        '@@SECTIONS@@' +    //<SectionId>SectionABC</SectionId><SectionId>SectionABC</SectionId>
                    '</Sections>'+
                '</Schedule>'+
                '<Pages>'+
                    '@@PAGES@@' +   // <Url>www.mySite.com/p1</Url><Url>www.mySite.com/p1</Url>
                '</Pages>'+
                '<Target>'+
                    '<ExcludeTargets>N</ExcludeTargets>'+
                //  '<TopLevelDomain>'+
                //      '<Code>US</Code>'+
                //  '</TopLevelDomain>'+
                //  '<Domain>aol.com,earthlink.com</Domain>'+
                //  '<Continent>'+
                //      '<Code>AS</Code>'+
                //  '</Continent>'+
                //  '<Country>'+
                //      '<Code>US</Code>'+
                //  '</Country>'+
                //  '<State>'+
                //      '<Code>AL:BERAT</Code>'+
                //      '<Code>AL:FIER</Code>'+
                //  '</State>'+
                //  '<AreaCode>'+
                //      '<Code>US:609</Code>'+
                //  '</AreaCode>'+
                //  '<Msa>'+
                //      '<Code>0240</Code>'+
                //  '</Msa>'+
                //  '<Dma>'+
                //      '<Code>507</Code>'+
                //  '</Dma>'+
                //  '<City>'+
                //      '<Code>AF:FARYAB:MAIMANA</Code>'+
                //  '</City>'+
                //  '<Zip>'+
                //      '<Code>US:08030</Code>'+
                //  '</Zip>'+
                //    '<Os>'+
                //        '@@OS@@' + //<Code>winxp</Code><Code>unix</Code>
                //    '</Os>'+
                //  '<Browser>'+
                //      '<Code>msie</Code>'+
                //      '<Code>netscape</Code>'+
                //      '<Code>mozilla</Code>'+
                //  '</Browser>'+
                //  '<BrowserV>'+
                //      '<Code>explorer6</Code>'+
                //  '</BrowserV>'+
                    '<SearchType>@@SEARCHTYPE@@</SearchType>'+ //Any One Term -> A,All Terms -> L,Boolean Expression -> B
                    '<SearchTerm>@@SEARCHTERM@@</SearchTerm>'+ //   use “,” to separate multiple values
                    '<Cookie>'+'@@COOKIE@@'+'</Cookie>'+
                //  '<AgeFrom>13</AgeFrom>'+
                //  '<AgeTo>18</AgeTo>'+
                //  '<Gender>'+
                //      '<Code>M</Code>'+
                //  '</Gender>'+
                //  '<IncomeFrom>30</IncomeFrom>'+
                //  '<IncomeTo>300</IncomeTo>'+
                //  '<SubscriberCode>TEST</SubscriberCode>'+
                //  '<PreferenceFlags>'+
                //      '012345678911234567892123456789312345678941234567895123456789612'+
                //  '</PreferenceFlags>'+
                //  '<Cluster>'+
                //      '<SegmentType>A</SegmentType>'+
                //      '<Segment>HockeyFans</Segment>'+
                //      '<Segment>FootballFans</Segment>'+
                //      '<Segment>HomeElectronicsBuyers</Segment>'+
                //  '</Cluster>'+
                '</Target>'+
                '<Exclude>'+
                //  '<Sites>'+
                //      '<SiteId>mySite</SiteId>'+
                //      '<SiteId>yourSite</SiteId>'+
                //  '</Sites>'+
                    '<Pages>'+
                        '@@PAGESEXCLUDED@@' + // <Url>www.mySite.com/p1</Url><Url>www.mySite.com/p1</Url>
                    '</Pages>'+
                '</Exclude>'+
                '<Billing>'+
                    '<Cpm>@@CPM@@</Cpm>'+
                    '<Cpc>@@CPC@@</Cpc>'+
                    '<PaymentMethod>@@PAYMENTMETHOD@@</PaymentMethod>'+
                    '<PurchaseOrder>@@PO@@</PurchaseOrder>'+
                    '<SalesRepresentative>@@SALESREP@@</SalesRepresentative>'+
                    '<Notes>@@NOTES@@</Notes>'+
                    '<IsYieldManaged>@@ISYELD@@</IsYieldManaged>'+
                    '<BillTo>@@BILLTO@@</BillTo>'+
                '</Billing>'+
            '</Campaign>'+
        '</Request>';

    /*
        Agency or Advertiser
    */
    public static final String addUpdateCompany = 
        '<AdXML><Request type="@@TYPE@@">'+
        '   <Database action="@@OPERATION@@">'+
        '       <@@TYPE@@>'+
        '           <Id>@@ID@@</Id>'+
        '           <Organization>@@ORGANIZATION@@</Organization>'+
        '       </@@TYPE@@>'+
        '   </Database>'+
        '</Request></AdXML>';
        
    /*
        Campaign status
    */
    public static final String updateCampStatus =
        '<Request type="Campaign">'+
            '<Campaign action="update">'+
                '<Overview>'+
                    '<Id>@@ID@@</Id>'+
                    '<Status>@@STATUS@@</Status>'+
                '</Overview>'+
            '</Campaign>'+
        '</Request>';     
        
    /*
        Insertion Order status
    */
    public static final String updateOrdeStatus =
        '<Request type="InsertionOrder">'+
            '<InsertionOrder action="update">'+          //@@OPERATION@@ is either an "add" or "update"
                '<Id>@@ID@@</Id>'+                              //@@ID@@ is the insertion order Id
                '<Status>@@STATUS@@</Status>'+
            '</InsertionOrder>'+
        '</Request>';
    
    /*
    public static final String ioDeliveryReport =
        '<Request type="Report">'+
            '<Report type="InsertionOrder">'+
                '<Id>@@ID@@</Id>'+
                '<StartDate>@@START_DATE@@</StartDate>'+
                '<EndDate>@@END_DATE@@</EndDate>'+
                '@@REPORT_TABLES@@'+
            '</Report>'+
        '</Request>';
    */
}