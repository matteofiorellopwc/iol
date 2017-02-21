public class ExtensionImpressionStimateNew {
    public String code {get;set;}
    public String level {get;set;}
    public String targetPlatform {get;set;}
    public String canalePrimario {get;set;}
    
    public string prodname {get;set;}
    public string family {get;set;}
    public string size {get;set;}
    public string formato {get;set;}
    public boolean soloAttivi {get;set;}
    
    public SelectOption[] canaliPrimari { get { return Util.getItems(AdUnit__c.CanalePrimario__c); } }
    public SelectOption[] targetPlatforms { get { return Util.getItems(AdUnit__c.Target_Platform__c); } }
    public SelectOption[] famiglie { get { return Util.getItems(Product2.family); } }
    public SelectOption[] sizes { get { return Util.getItems(Product2.size__c); } }
    public SelectOption[] formati { get { return Util.getItems(Product2.formato__c); } }

    public Long jobId {get;set;}    
    public Boolean isActionPollerEnabled {get;set;}
    
    private Map<Decimal, Boolean> adUnitExplictyMap = new Map<Decimal, Boolean>();
    public ImpressionsStimate[] impressionsStimate {get;set;}
    
    // La lista impressionStimate viene splittata in due per visualizzare fino a 2000 elementi
    public ImpressionsStimate[] impressionsStimate1 {get;set;}
    public ImpressionsStimate[] impressionsStimate2 {get;set;}
    
    public class ImpressionsStimate {
        public Boolean checked {get;set;}
        public Impressions_Stimate__c au {get;set;}
        public Impressions_Stimate__c auTmp {get;set;}
    }   
        
    public ExtensionImpressionStimateNew(ApexPages.StandardController controller) {                         
        impressionsStimate = new ImpressionsStimate[]{};
        isActionPollerEnabled = false;
        downloadFinished = false;
        soloAttivi = true;
    }
                    
    public void search(){                                                    
        string query = 'Select a.Product__r.Id, a.Product__r.Size__c, a.Product__r.Formato__c, a.Product__r.multisize__c, a.AdUnit__r.ExplicitlyTargeted__c, a.Product__r.Name, a.AdUnit__r.Website_partner__c, a.AdUnit__r.idDfp__c, a.AdUnit__r.Target_platform__c, a.AdUnit__r.Level__c, a.AdUnit__r.Id, a.AdUnit__r.Path__c, a.AdUnit__r.CanalePrimario__c, a.Festive__c, a.Feriali__c, a.Product__r.IsActive From Impressions_Stimate__c a ' +
        ' where attivo__c = true AND AdUnit__r.Path__c like \'%'+code+'%\'';
        
        if(Util.notVoid(level)){
            try {
                query += ' and AdUnit__r.level__c = '+ level;   
            } catch(Exception e) {}            
        }
        
        if(Util.notVoid(targetPlatform)){
            query += ' and AdUnit__r.target_Platform__c = \''+ targetPlatform +'\'';
        }
        if(Util.notVoid(canalePrimario)){
            query += ' and Product__r.canalePrimario__c = \''+ canalePrimario +'\'';
        }
        
        if(Util.notVoid(prodname)){
            query += ' and Product__r.Name LIKE \'%'+ prodname +'%\'';
        }
        
        if(Util.notVoid(size)){
            query += ' and Product__r.Size__c = \''+ size +'\'';
        }
        
        if(Util.notVoid(formato)){
            query += ' and Product__r.Formato__c = \''+ formato +'\'';
        }
        
        if(soloAttivi){
            query += ' and Product__r.IsActive = true';
        }
                        
        query += ' ORDER BY Product__r.Id, AdUnit__r.Path__c, Product__r.Size__c';
        
        Integer i = 0;    
        impressionsStimate = new ImpressionsStimate[]{};
        impressionsStimate1 = new ImpressionsStimate[]{};
        impressionsStimate2 = new ImpressionsStimate[]{};
        for(Impressions_Stimate__c au : Database.query(query)){
            impressionsStimate is = new ImpressionsStimate();
            is.checked = false;
            is.au = au;
            is.auTmp = new Impressions_Stimate__c(Feriali__c = au.Feriali__c, Festive__c = au.Festive__c);
            impressionsStimate.add(is);
            if(i < 1000) {
                impressionsStimate1.add(is);
            } else {
                impressionsStimate2.add(is);    
            }
            i++;
        }
    }
            
    public void startReportGeneration() {           
        if(!impressionsMap.isEmpty()) {
            downloadFinished = true;
            return;
        }   
        
        for(AdUnit__c au : [SELECT IdDfp__c, ExplicitlyTargeted__c FROM AdUnit__c WHERE Ad_Server__c = 'DFP']) {
            adUnitExplictyMap.put(Decimal.valueOf(au.IdDfp__c), au.explicitlyTargeted__c);
        }       
        
        isActionPollerEnabled = true;
        DfpIntegration dfp = new DfpIntegration();
        //dfp.reportService.RequestHeader.networkCode = '5180';
        
        DfpReportService.ReportQuery q = new DfpReportService.ReportQuery();
        q.dimensions = new list<String>{
            'AD_UNIT_ID',                        
            'MONTH',
            'DAY',
            'CREATIVE_SIZE'
        };
        q.adUnitView = 'HIERARCHICAL'; // 'FLAT' OR 'TOP_LEVEL'
        q.dateRangeType = 'LAST_MONTH';
        q.columns = new list<String>{
            'AD_SERVER_IMPRESSIONS'
        };

        DfpReportService.ReportJob job = new DfpReportService.ReportJob();
        job.reportQuery = q;
        
        if(!Test.isrunningtest()) {
        	job = dfp.reportService.runReportJob(job);
            
        }
        else {
            job.id = 123;    
        }
        jobId = job.id;

        
    }
           
    public void checkIfReportIsComplete() {     
        DfpIntegration dfp = new DfpIntegration();
        //dfp.reportService.RequestHeader.networkCode = '5180';
        if(!Test.isrunningtest()) {
        	isActionPollerEnabled = dfp.reportService.getReportJobStatus(jobId) != 'COMPLETED';
				        
        }
        else {
            isActionPollerEnabled = false;
        }
    }
    
    Map<Decimal, Map<String, Decimal[]>> impressionsMap = new Map<Decimal, Map<String, Decimal[]>>(); // AdUnitId => Size => Impressions feriali [0] / Impressions festive [1];
    String remainingBody = null;
    public Boolean downloadFinished {get;set;}
    public void downloadReport() {
        String body = null;
        Integer i = 0;
        if(impressionsMap.isEmpty()) {                  
            DfpIntegration dfp = new DfpIntegration();
            //dfp.reportService.RequestHeader.networkCode = '5180';
            DfpReportService.ReportDownloadOptions opts = new DfpReportService.ReportDownloadOptions();
            opts.exportFormat = 'CSV_DUMP';
            opts.includeReportProperties = false;
            opts.includeTotalsRow = false;
            opts.useGzipCompression = false;
            String url = null;
            
            if(!Test.isrunningtest()) {
            	url = dfp.reportService.getReportDownloadUrlWithOptions(jobId,opts);
            }
            else {
                url = 'https://www.pippo.com';
            }
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
			
			HttpResponse res;
            if(!Test.isrunningtest()) {
            	res = h.send(req);
                body = res.getBody();
            }
            else {
                body = ExtensionImpressionStimateNewTest.getResponseBody();
            }          
        } else {
            body = remainingBody;
            i = 1;
        }
                
        String row = '';
        while(body.indexOf('\n') > 0){
            if(i > 2000) {
                remainingBody = body;
                return;
            }
            row = body.substring(0,body.indexOf('\n')+1);
            //row = adUnitLevel1,adUnitLevel2,adUnitLevel3,adUnitLevel4,currentDay,size,______,impressions
            if(i>0){
                list<string> fields = row.split(',');
                
                //Get adunit id
                Decimal adUnitLevel1 = fields[0] != '-' ? Decimal.valueOf(fields[0]) : null;
                Decimal adUnitLevel2 = fields[1] != '-' ? Decimal.valueOf(fields[1]) : null;
                Decimal adUnitLevel3 = fields[2] != '-' ? Decimal.valueOf(fields[2]) : null;
                Decimal adUnitLevel4 = fields[3] != '-' ? Decimal.valueOf(fields[3]) : null;

                Boolean hasLevel4 = adUnitLevel4 != null;
                Boolean hasLevel3 = (adUnitLevel4 == null || !adUnitExplictyMap.get(adUnitLevel4));
                Boolean hasLevel2 = adUnitLevel3 == null || (!adUnitExplictyMap.get(adUnitLevel3) && hasLevel3);
                Boolean hasLevel1 = adUnitLevel2 == null || (!adUnitExplictyMap.get(adUnitLevel2) && hasLevel2);

                if(hasLevel1 && !impressionsMap.containsKey(adUnitLevel1)) impressionsMap.put(adUnitLevel1, new Map<String, Decimal[]>());
                if(hasLevel2 && !impressionsMap.containsKey(adUnitLevel2)) impressionsMap.put(adUnitLevel2, new Map<String, Decimal[]>());
                if(hasLevel3 && !impressionsMap.containsKey(adUnitLevel3)) impressionsMap.put(adUnitLevel3, new Map<String, Decimal[]>());
                if(hasLevel4 && !impressionsMap.containsKey(adUnitLevel4)) impressionsMap.put(adUnitLevel4, new Map<String, Decimal[]>());
                
                //Get size
                String size = fields[6].replace(' ', '');
                if(hasLevel1 && !impressionsMap.get(adUnitLevel1).containsKey(size)) impressionsMap.get(adUnitLevel1).put(size, new Decimal[]{0, 0});
                if(hasLevel2 && !impressionsMap.get(adUnitLevel2).containsKey(size)) impressionsMap.get(adUnitLevel2).put(size, new Decimal[]{0, 0});
                if(hasLevel3 && !impressionsMap.get(adUnitLevel3).containsKey(size)) impressionsMap.get(adUnitLevel3).put(size, new Decimal[]{0, 0});
                if(hasLevel4 && !impressionsMap.get(adUnitLevel4).containsKey(size)) impressionsMap.get(adUnitLevel4).put(size, new Decimal[]{0, 0});
                                
                //Get impressions
                //if(!adUnit2Impression.containsKey(adUnitId)) adUnit2Impression.put(adunitId, new Decimal[]{0, 0});
                Decimal impressionStimate = Decimal.valueOf(fields[fields.size() - 1].replace('\n', ''));
                Decimal currentDay = Decimal.valueOf(fields[5]);
                
                if(currentDay == 6 || currentDay == 7) {
                    if(hasLevel1) impressionsMap.get(adUnitLevel1).get(size)[1] = impressionsMap.get(adUnitLevel1).get(size)[1] + impressionStimate;
                    if(hasLevel2) impressionsMap.get(adUnitLevel2).get(size)[1] = impressionsMap.get(adUnitLevel2).get(size)[1] + impressionStimate;
                    if(hasLevel3) impressionsMap.get(adUnitLevel3).get(size)[1] = impressionsMap.get(adUnitLevel3).get(size)[1] + impressionStimate;
                    if(hasLevel4) impressionsMap.get(adUnitLevel4).get(size)[1] = impressionsMap.get(adUnitLevel4).get(size)[1] + impressionStimate;
                } else {
                    if(hasLevel1) impressionsMap.get(adUnitLevel1).get(size)[0] = impressionsMap.get(adUnitLevel1).get(size)[0] + impressionStimate;
                    if(hasLevel2) impressionsMap.get(adUnitLevel2).get(size)[0] = impressionsMap.get(adUnitLevel2).get(size)[0] + impressionStimate;
                    if(hasLevel3) impressionsMap.get(adUnitLevel3).get(size)[0] = impressionsMap.get(adUnitLevel3).get(size)[0] + impressionStimate;
                    if(hasLevel4) impressionsMap.get(adUnitLevel4).get(size)[0] = impressionsMap.get(adUnitLevel4).get(size)[0] + impressionStimate;
                }
                
                System.debug('IMPRESSION STIMATE!!! ' + impressionStimate);                
            }
            body = body.substringAfter('\n');
            i++;
        } 
        
        downloadFinished = true;       
    }
        

    public PageReference finalize() {
        Date d = Date.today().addMonths(-1).toStartOfMonth();       
        Decimal numFeriali = 0;
        Decimal numFestivi = 0;
        Decimal currentMonth = d.month();
        while(d.month() == currentMonth) {
            Datetime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt.format('EEEE'); 
            System.debug('Day : ' + dayOfWeek);                                             
            if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') numFestivi++;
            else numFeriali++;
            d = d.addDays(1);
        }
                        
        Impressions_Stimate__c[] isToUpdate = new Impressions_Stimate__c[]{};
        for(ImpressionsStimate is : impressionsStimate) {
            String[] sizes = new String[]{};
            Decimal key = Decimal.valueOf(is.au.AdUnit__r.idDfp__c);                                            
            if(is.au.Product__r.Size__c == 'Multisize') {
                sizes = is.au.Product__r.multisize__c.split(';');                   
            } else {
                sizes.add(is.au.Product__r.Size__c.replace(' ', ''));
            }
            
            is.auTmp.Feriali__c = 0;
            is.auTmp.Festive__c = 0;
            for(String size : sizes) {
                if(impressionsMap.containsKey(key) && impressionsMap.get(key).containsKey(size)) {                      
                    is.auTmp.Feriali__c += Math.round(impressionsMap.get(key).get(size)[0] / numFeriali);                       
                    is.auTmp.Festive__c += Math.round(impressionsMap.get(key).get(size)[1] / numFestivi);
                } else {
                    is.auTmp.Feriali__c = 0;
                    is.auTmp.Festive__c = 0;                    
                }                   
            }
            
            isToUpdate.add(is.au);
        }
        
        System.debug(isToUpdate);
        update isToUpdate;        
        jobId = null;
        isActionPollerEnabled = false;
        downloadFinished = false;
        return null;        
    }
    
    public PageReference save() {
        Impressions_Stimate__c[] isToUpdate = new Impressions_Stimate__c[]{};
        for(ImpressionsStimate is : impressionsStimate) {
            if(is.checked) {
                is.au.Feriali__c = is.auTmp.Feriali__c;
                is.au.Festive__c = is.auTmp.Festive__c;
                isToUpdate.add(is.au);
            }
            is.auTmp.Feriali__c = is.au.Feriali__c;
            is.auTmp.Festive__c = is.au.Festive__c;
        }   
        update isToUpdate;
        
        return null;
    }
}