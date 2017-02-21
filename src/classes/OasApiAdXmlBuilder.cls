public class OasApiAdXmlBuilder {
            
    /*
    * This function builds the AdXML request to list an OAS Entity (Campaign, Insertion Order etc)
    * @param takes a String Id of the OAS Object ID and a String of Entity (OAS Object) Type
    * @return Returns AdXML as string.
    */
    public String listOperation(String id, String entity){
        String adXml = OasApiAdXmlTemplate.listRequest;
        Map<String, String> inputMap = new Map<String, String>();
        if(id != null && entity != null){
            inputMap.put('@@ID@@', id);
            inputMap.put('@@TYPE@@', entity);
        }
        adXml = dtGen(adXml, inputMap);
        adXml = '<AdXML>' + adXml + '</AdXML>';         //wrap request in <AdXML>   
        System.debug(Logginglevel.INFO, adXml);
        return adXml;
    } 
    
    /*
        Build AdXml request for read or list
        action: read or list
        typex: OAS table (Campaign, Section, ...)
        requestType: Database or OAS Table
        searchCriteria: name of searchCriteria tag
        searchValues: map searchCriteria key => value
    */
    public String readListRequest(String action, String typex,String requestType,String searchCriteria, string[] searchKeys, string[] searchValues){
        String adXml = OasApiAdXmlTemplate.readListRequest;
        Map<String, String> inputMap = new Map<String, String>();

        inputMap.put('@@ACTION@@', action);
        inputMap.put('@@TYPE@@', typex);
        inputMap.put('@@REQUESTTYPE@@', requestType);
        string[] searchParam = searchCriteria.split(' ');
        inputMap.put('@@SEARCHCRITERIA@@', searchParam.remove(0));
        inputMap.put('@@SEARCHCRITERIAPARAM@@', string.join(searchParam,' '));
        
        if(searchValues != null){
            String searchVal = '';
            for(integer i=0;i<searchKeys.size();i++){
                string key = searchKeys.get(i);
                string endKey = key.split(' ')[0];
                string value = searchValues.get(i);
                    
                    searchVal += '<'+key+'>'+value+'</'+endKey+'>';
            }
            inputMap.put('@@SEARCHVALUES@@', searchVal);
        }

        adXml = dtGen(adXml, inputMap);
        adXml = '<AdXML>' + adXml + '</AdXML>';         //wrap request in <AdXML>   
        System.debug(Logginglevel.INFO, adXml);
        return adXml;
    }
    
    /*
        Utility function based on readListRequest
    */
    public String readCampaignById(String id){
        return readListRequest('read', 'Campaign','Campaign','Overview', new string[]{'Id'},new string[]{id});
    }
        
    public String readSectionById(String id){
        return readListRequest('read', 'Section','Database','Section',new string[]{'Id'},new string[]{id});
    }
    
    /* doesn't work. 
    public String listCampaginsByIds(String[] ids){
        return readListRequest('list', 'Campaign','Campaign','SearchCriteria',new Map<string,string[]>{ 'Id' => ids });        
    }
    */
    
    public String listCampaignsByOrderId(String ioid){
        return readListRequest('list', 'Campaign','Campaign','SearchCriteria',new string[]{'InsertionOrderId'},new string[]{ioid});
    }
    
    public String listPages(){
        return readListRequest('list', 'Page','Database','SearchCriteria' , null,null);
    }
    
    public String listPages(integer pageIndex){
        return readListRequest('list', 'Page','Database','SearchCriteria pageIndex="'+pageIndex+'"' , null,null);
    }
    
    public String listSections(){
        return readListRequest('list', 'Section','Database','SearchCriteria' , null,null);
    }
    
    public String listCampaignsByDate(date startDate,date endDate){
        return readListRequest('list', 'Campaign','Campaign','SearchCriteria',new string[]{'StartDate condition="LE"','EndDate condition="GE"'},new string[]{formatDate(startDate),formatDate(endDate)}); 
    }


    /*
        Build AdXml request to upsert Agency or Advertiser from Account
    */
    public String syncSfToOasAcc(Account a,String operation){
        String adXml = OasApiAdXmlTemplate.addUpdateCompany; 
        adXml = adXml.replace('@@TYPE@@',a.oasType__c);
        adXml = adXml.replace('@@OPERATION@@',operation);
        adXml = adXml.replace('@@ID@@',a.Id_Oas__c);
        adXml = adXml.replace('@@ORGANIZATION@@',a.Name.left(32)); //OAS limit, 32 chars
        
        return adXml;
    }
    
    /*
        Build AdXml request to upsert Insertion Order from Opportunity
    */
    public String syncSFtoOasOpp(Opportunity o,String[] campaignsId, String operation){
        String adXml= OasApiAdXmlTemplate.addUpdateIo;

        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('@@OPERATION@@', operation);
        inputMap.put('@@ID@@', o.id_oas__c);
        inputMap.put('@@CAMBY@@', 'A');
        inputMap.put('@@ADVERTISER@@', o.account.id_oas__c);
        if(o.centro_media__r.id_oas__c != null){
            inputMap.put('@@AGENCY@@', o.centro_media__r.id_oas__c);
        }else{
            inputMap.put('@@AGENCY@@', 'unknown_agency');            
        }
        inputMap.put('@@START_DATE@@', formatDate(o.data_inizio__c));
        inputMap.put('@@END_DATE@@', formatDate(o.data_fine__c));
        inputMap.put('@@STATUS@@',o.status_oas__c);
        inputMap.put('@@DESCRIPTION@@',o.name.left(64)); //OAS limit, 64 chars
        inputMap.put('@@SALESPERSON@@','adm_IO');
        
        string campaigns = '';
        for(string s : campaignsId){
            campaigns += '<CampaignId>'+s+'</CampaignId>';
        }
        
        inputMap.put('@@CAMPAIGNS@@',campaigns);
        
        
        adXml = dtGen(adXml, inputMap);
        adXml = '<AdXML>' + adXml + '</AdXML>';     //wrap in <AdXML>
        System.debug(Logginglevel.INFO, adXml);
        return adXml;
    }

    /*
        Build AdXml request to upsert Campaigns from Line Item list
    */
    public String syncSfToOasLineItems(LineItem__c[] lis,String operation){
        String adXml= '';
        if(lis.size() < 50){
            for(LineItem__c li : lis){
                String template = OasApiAdXmlTemplate.addUpdateCamp;
                
                Map<String, String> inputMap = new Map<String, String>();
                
                //Overview
                inputMap.put('@@OPERATION@@', operation);             
                inputMap.put('@@NAME@@', li.id_oas__c);
                inputMap.put('@@ID@@', li.id_oas__c);
                inputMap.put('@@DESCRIPTION@@', li.name_dfp__c.left(100));               
                inputMap.put('@@ADVERTISER@@', li.opportunity__r.account.id_oas__c);
                if(li.opportunity__r.centro_media__r.id_oas__c != null){
                    inputMap.put('@@AGENCY@@', li.opportunity__r.centro_media__r.id_oas__c);
                }else{
                    inputMap.put('@@AGENCY@@', 'unknown_agency');            
                }
                inputMap.put('@@PRODUCT@@', 'default-product');
                
                template = template.replace('<Status>@@STATUS@@</Status>',''); //upsert operation doesn't change status. it's changed with specific calls
                
                //Schedule
                inputMap.put('@@IMPRESSIONS@@', li.delivery_model__c == 'CPM' ? string.valueOf(li.quantita__c) : '');
                inputMap.put('@@CLICK@@', li.delivery_model__c == 'CPC' ? string.valueOf(li.quantita__c) : '');
                inputMap.put('@@PRIORITY@@', li.Priority_oas__c);
                inputMap.put('@@COMPLETION@@',li.Completion_oas__c);
                inputMap.put('@@START_DATE@@', formatDate(li.start_date__c));
                inputMap.put('@@START_HOUR@@', formatHour(li.start_hour__c));
                inputMap.put('@@END_DATE@@', formatDate(li.end_date__c));
                inputMap.put('@@END_HOUR@@', formatHour(li.end_hour__c));                
                inputMap.put('@@REACH@@', li.reach_oas__c);
                inputMap.put('@@DAILYIMPR@@', string.valueOf(li.Daily_Impressions__c));
                inputMap.put('@@DAILYCLICK@@', string.valueOf(li.Daily_clicks__c));
                inputMap.put('@@SMOOTHORASAP@@', li.SmoothOrAsap_oas__c);
                inputMap.put('@@IMPOVERRUN@@', '0');
                
                //Frequency cap
                inputMap.put('@@OasPrimaryFrequencyClickPerVisitor@@',getFrequencyDefault(li.OasPrimaryFrequencyClickPerVisitor__c) );
                inputMap.put('@@OasPrimaryFrequencyImpPerVisitor@@',getFrequencyDefault(li.OasPrimaryFrequencyImpPerVisitor__c) );
                inputMap.put('@@OasSecondaryFrequencyImpPerVisitor@@',getFrequencyDefault(li.OasSecondaryFrequencyImpPerVisitor__c) );
                inputMap.put('@@OasPrimaryFreqScope@@',getFrequencyDefault(li.OasPrimaryFreqScope__c) );
                inputMap.put('@@OasSecondaryFreqScope@@',getFrequencyDefault(li.OasSecondaryFreqScope__c) );
                
                //DAY PART TARGETING
                set<string> hours = new set<string>();
                set<string> days = new set<string>();
                
                for(DayPartTargeting__c dpt : li.Day_Part_Targeting__r){
                    decimal startHour = Decimal.valueOf(dpt.start_hour__c);
                    decimal endHour = Decimal.valueOf(dpt.end_hour__c);
                    for(decimal i=startHour;i<endHour;i++){
                        hours.add(formatHour(i+''));
                    }
                    days.add(dpt.dayOfWeekOas__c);
                }

                string h = '';
                for(string s : hours){
                    h += '<Hour>'+formatHour(s+'')+'</Hour>'; 
                }                
                inputMap.put('@@HOUROFDAY@@',h);
                
                string d = '';
                for(string s : days){
                    d+= '<Day>'+s+'</Day>';
                }
                inputMap.put('@@DAYOFWEEK@@',d);
                /*
                set<decimal> hours = new set<decimal>();
                set<decimal> days = new set<decimal>();
                
                for(DayPartTargeting__c dpt : li.Day_Part_Targeting__r){
                    decimal startHour = Decimal.valueOf(dpt.start_hour__c);
                    decimal endHour = Decimal.valueOf(dpt.end_hour__c);
                    for(decimal i=startHour;i<endHour;i++){
                        hours.add(i);
                    }
                    days.add(decimal.valueOf(dpt.dayOfWeekOas__c));
                }

                decimal[] hh = new list<decimal>();
                hh.addAll(hours);
                hh.sort();
                string h = '';
                for(decimal s : hh){
                    h += '<Hour>'+formatHour(s+'')+'</Hour>'; 
                }                
                inputMap.put('@@HOUROFDAY@@',h);
                
                decimal[] dd = new list<decimal>();
                dd.addAll(days);
                dd.sort();
                string d = '';
                for(decimal s : dd){
                    d+= '<Day>'+s+'</Day>';
                }
                inputMap.put('@@DAYOFWEEK@@',d);
                */
                
                //Sections
                String sections = '';
                for(SectionOasTargeted__c s : li.SectionsOasTargeted__r){
                    sections += '<SectionId>'+s.SectionOas__r.IdOas__c+'</SectionId>';
                }
                inputMap.put('@@SECTIONS@@',sections);
                
                //Pages
                String pages = '';
                for(Inventory_Target__c it : li.Inventory_Target__r){
                    if(it.InventoryTargetingType__c == 'targeted'){  pages += '<Url>'+it.Ad_Unit__r.PageOAS__c+'</Url>';    }
                }
                inputMap.put('@@PAGES@@',pages);
                
                //Target
                //inputMap.put('@@OS@@','<Code>winxp</Code><Code>unix</Code>');
                inputMap.put('@@SEARCHTYPE@@','B');
                string searchTerm = '';
                for(CookieSearchOasTargeted__c c : li.CookieSearchTermsOASTargeted__r){
                    if(c.oas_field__c == 'SearchTerm'){
                        if(searchTerm != ''){   searchTerm += 'and'; }
                        searchTerm += '('+c.Values__c.replace('__\n','or')+')';
                        /* old version
                        string[] terms = c.Values__c.split('__\n');
                        for(integer i=0;i<terms.size();i++){
                            terms[i] = '('+c.Categoria__c +'='+terms[i]+')';
                        }
                        searchTerm += string.join(terms,'or');
                        */
                    }
                }
                if(searchTerm != ''){
                    searchTerm = '('+searchTerm+')';
                }
                inputMap.put('@@SEARCHTERM@@',searchTerm);
                
                string cookie = '';
                for(CookieSearchOasTargeted__c c : li.CookieSearchTermsOASTargeted__r){
                    if(c.oas_field__c == 'Cookie Targeting'){
                        if(cookie != ''){   cookie += 'and'; }
                        cookie += '('+c.Values__c.replace('__\n','or')+')';
                    }
                }
                if(cookie != ''){
                    cookie = '('+cookie+')';
                }
                inputMap.put('@@COOKIE@@',cookie);
                
                //Exclude
                pages = '';
                for(Inventory_Target__c it : li.Inventory_Target__r){
                    if(it.InventoryTargetingType__c == 'excluded'){  pages += '<Url>'+it.Ad_Unit__r.PageOAS__c+'</Url>';    }
                }
                inputMap.put('@@PAGESEXCLUDED@@',pages);
                                  
                //Billing
                inputMap.put('@@CPM@@', li.delivery_model__c == 'CPM' ? string.valueOf(li.prezzo_net_net__c) : '0');
                inputMap.put('@@CPC@@', li.delivery_model__c == 'CPC' ? string.valueOf(li.prezzo_net_net__c) : '0');
                inputMap.put('@@PAYMENTMETHOD@@', 'C');
                inputMap.put('@@PO@@', li.name);
                inputMap.put('@@SALESREP@@', li.name);
                inputMap.put('@@NOTES@@',li.notes_dfp__c);
                inputMap.put('@@ISYELD@@', 'N');
                inputMap.put('@@BILLTO@@', 'G');
                

                adXml += dtGen(template, inputMap);  
            }
            adXml = '<AdXML>' + adXml + '</AdXML>';
            return adXml;
        }
        else{
            throw new OasApiProxy.OasException('Please add less than 50 campaigns in IO');
        }
    }
    
    /*
        Build AdXml request to change Campaigns status
    */
    public string changeCampaignsStatus(string[] ids,string newStatus){
        String adXml= '';
        for(String id : ids){
            string s = OasApiAdXmlTemplate.updateCampStatus;
            adXml += s.replace('@@STATUS@@',newStatus).replace('@@ID@@',id);
        }
        adXml = '<AdXML>' + adXml + '</AdXML>';
        return adXml;
    }
    
    /*
        Build AdXml request to change order status
    */
    public string changeOrderStatus(string[] ids,string newStatus){
        String adXml= '';
        for(String id : ids){
            string s = OasApiAdXmlTemplate.updateOrdeStatus;
            adXml += s.replace('@@STATUS@@',newStatus).replace('@@ID@@',id);
        }
        adXml = '<AdXML>' + adXml + '</AdXML>';
        return adXml;
    }
    


/*    
    public String ioReport(OasApiReportParameters params){
        String adXml=ioDeliveryReport;
        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('@@ID@@', params.getIoName());
        inputMap.put('@@START_DATE@@', formatDate(params.getStartDate()));
        inputMap.put('@@END_DATE@@', formatDate(params.getEndDate()));
        inputMap.put('@@REPORT_TABLES@@', getReportTableList(params.getReportTables()));
        
        adXml = dtGen(adXml, inputMap);
        adXml = '<AdXML>' + adXml + '</AdXML>';     
        return adXml;
    }
*/    
    
    
    
    
    /* Below are private utility functions used to build the AdXML requests */
    
    //dafule code for frequency is '0'
    private string getFrequencyDefault(string s ){
        if(s != null && s != '') return s;
        return '0';
    }
    
    private String formatHour(String h){
        if(h.length() == 1){
            h = '0'+h;
        }
        
        return h;
    }
    
    private String formatDate(Date d){
        if(d == null) return '';
        return getYear(d) + '-' + getMonth(d) + '-' + getDay(d);
    }
    private String getYear(Date d){
        return String.valueOf(d.year());
    }
    private String getMonth(Date d){
        Integer month = d.month();
        if(month < 10){//needs a leading 0 to be valid
            return '0' + d.month().format() ;
        }
        else{
            return d.month().format();
        }
    }
    private String getDay(Date d){
        Integer day = d.day();
        if(day < 10){//needs a leading 0 to be valid
            return '0' + d.day().format();
        }
        else{
            return d.day().format();
        }
    }
    
    private String removeComma(String s){
        return s.replaceAll(',', '');
    }
    
    private String dtGen(String base, Map<String,String> inputMap){
        for(String key : inputMap.keySet()){
            if(inputMap.get(key) !=null){
                base = base.replaceAll(key, inputMap.get(key));
            }
        }
        //replace any remaining snippets with empty string
        base = base.replaceAll('@@([a-zA-Z0-9_\\-]+)@@', '');
        return base;
    }
    
    /*
    private String getHourOfDay(String[] hourOfDay){
        String result ='';
        if(hourOfDay.size() >= 1){
            result = '<HourOfDay>';
            for(String s : hourOfDay){
                result += '<Hour>'+ s + '</Hour>';
            }
        result += '</HourOfDay>';
        }
        return result;
    }
    
    private String getCampaignList(String[] campList){
        String result ='<Campaigns>';
        if(campList.size() >= 1){
            for(String s : campList){
                result += '<CampaignId>'+ s + '</CampaignId>';
            }
        }
        result += '</Campaigns>';
        return result;
    }
    private String getReportTableList(String[] reportTables){
        String result='';
        if(reportTables.size() >= 1){
            for(string s : reportTables){
                result += '<Table>'+ s + '</Table>';
            }
        }
        return result;
    }
    */
}