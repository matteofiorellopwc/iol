public class ControllerAssetReportService {
    dfpintegration dfp;
    public jobClass j {get;set;}
    public long jobid {get;set;}
    public string adUnitView {get;set;}
    public string dateInMonth {get;set;}
    date d;
    
    public class jobClass{
        public string month {get;set;}
        public long id {get;set;}
        public string status {get;set;}
        public string url {get;set;}
        public DfpReportService.ReportJob job {get;set;}
        public AsyncApexJob aaj {get;set;}
    }
    
    map<string,id> adUnitMap = new map<string,id>();

    public  ControllerAssetReportService(){
        dfp = new dfpintegration();
        dfp.reportService.RequestHeader.networkCode = '5180';
        j = new jobClass();
        jobid = 1995187007;
        for(AdUnit__c adu : [select id,idDfp__c from adunit__c]){
            adUnitMap.put(adu.idDfp__c,adu.id);
        }
        adUnitView = 'TOP_LEVEL';
        dateInMonth = '';
    }
    
    public void runReport(){
        DfpReportService.ReportQuery q = new DfpReportService.ReportQuery();
        q.dimensions = new list<String>{'AD_UNIT_ID','LINE_ITEM_ID','MONTH'}; //'PLACEMENT','ORDER_ID'
        q.adUnitView = 'FLAT';
        q.columns = new list<String>{'TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS',
                                       'TOTAL_LINE_ITEM_LEVEL_CLICKS',
                                       'TOTAL_LINE_ITEM_LEVEL_CPM_AND_CPC_REVENUE'
                                      };

        q.dateRangeType = 'dateRangeType';

        //public String[] dimensionAttributes;
        //public Long[] customFieldIds;
        d = date.today();
        if(dateInMonth != ''){
            d = date.parse(dateInMonth);
        }
        q.startDate = UtilityDataValue.getReportDate(d.year(), d.month(), 1);
        q.endDate = UtilityDataValue.getReportDate(d.year(), d.month(), d.addMonths(1).toStartOfMonth().addDays(-1).day());
        //public String[] dimensionFilters;
        //public DfpReportService.Statement statement; 
        q.adUnitView = adUnitView;

        j.job = new DfpReportService.ReportJob();
        j.job.reportQuery = q;        
        j.job = dfp.reportService.runReportJob(j.job);
        j.id = j.job.id;
        jobid = j.job.id;
        j.status = dfp.reportService.getReportJobStatus(j.Id);
    }
    
    public void getReport(){
    //    j.job = dfp.reportService.getReportJob(jobid);
     //   j.id = j.job.id;
      //  j.status = dfp.reportService.getReportJobStatus(jobid);        
    }
    
    public void getReportDownloadUrl(){
        DfpReportService.ReportDownloadOptions opts = new DfpReportService.ReportDownloadOptions();
        opts.exportFormat = 'CSV_DUMP';
        opts.includeReportProperties = false;
        opts.includeTotalsRow = false;
        opts.useGzipCompression = false;
        j.url = dfp.reportService.getReportDownloadUrlWithOptions(j.job.id,opts);
    }
    
    public void getCsv(){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(j.url);
        req.setMethod('GET');
        
        //req.setHeader('Authorization',dfp.reportService.inputHttpHeaders_x.get('Authorization'));
        
        HttpResponse res = h.send(req);
        string body = res.getBody();
        
        list<asset> assets = new list<asset>();
        
        /*
            Dimension.AD_UNIT_ID
            Dimension.LINE_ITEM_ID
            Dimension.MONTH
            Dimension.AD_UNIT_NAME
            Column.TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS
            Column.TOTAL_LINE_ITEM_LEVEL_CLICKS
            Column.TOTAL_LINE_ITEM_LEVEL_CPM_AND_CPC_REVENUE
        */

        string row = '';
        integer i = 0;
        set<long> lineItemIds = new set<long>();
        while(body.indexOf('\n') > 0){
            row = body.substring(0,body.indexOf('\n')+1);
            if(i>0){
                list<string> fields = row.split(',');
                lineItemIds.add(long.valueOf(fields[1]));
                asset a = new asset();
                a.SerialNumber = fields[1]; //salvo qui l'id dfp del lineitem                
                a.adunit__c = adUnitMap.get(fields[0]);
                a.month__c = fields[2];
                a.year__c = d.year()+'';
                a.Clicks__c = integer.valueOf(fields[5]);
                a.Impressions__c = integer.valueOf(fields[4]);
                a.CPM_CPC_REVENUE_DFP__c = double.valueOf(fields[6]);
                a.external_key__c = adUnitView+'_'+fields[1]+'_'+fields[0]+'_'+fields[2]+'_'+d.year(); //idlineitem_idadunit_mese_anno
                a.name = a.external_key__c;
                a.adUnitView__c = adUnitView;
                assets.add(a);
            }
            body = body.substringAfter('\n');
            i++;
        }
        
        id sfdcJobID = Database.executeBatch(new BatchableUpsertAsset(assets,lineItemIds,d),1000);
        j.aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: sfdcJobID ];
        system.debug(Logginglevel.INFO,'trovate: '+i+' righe');
        printLimits();
        
        //j.csv = j.csv.substring(0,1000);
        //Dimension.MONTH,Dimension.AD_UNIT_ID,Dimension.LINE_ITEM_ID,Column.TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS,Column.TOTAL_LINE_ITEM_LEVEL_CLICKS,Column.TOTAL_LINE_ITEM_LEVEL_CTR,Column.TOTAL_LINE_ITEM_LEVEL_CPM_AND_CPC_REVENUE        
    }
    
    public void printLimits(){
        system.debug(Logginglevel.INFO,'getHeapSize: '+Limits.getHeapSize());
        system.debug(Logginglevel.INFO,'getLimitHeapSize: '+Limits.getLimitHeapSize());
        system.debug(Logginglevel.INFO,'getScriptStatements: '+Limits.getScriptStatements());
        system.debug(Logginglevel.INFO,'getLimitScriptStatements: '+Limits.getLimitScriptStatements());
    }
    
    public void parseCsv(){
       // j.job = dfp.reportService.getReportJob(jobid);
        //j.id = j.job.id;
        j.status = dfp.reportService.getReportJobStatus(jobid);
        if(j.status == 'COMPLETED'){
            getReportDownloadUrl();
        }
        getCsv();
    }
    
    public void getSfdcJobStatus(){
        j.aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: j.aaj.id ];
    }
    
    public static testMethod void testControllerAssetReportService(){
        ControllerAssetReportService c = new ControllerAssetReportService();
        try{ c.runReport(); }catch(Exception e){}
        try{ c.getReport(); }catch(Exception e){}
        try{ c.getReportDownloadUrl(); }catch(Exception e){}
        try{ c.getCsv(); }catch(Exception e){}
        try{ c.printLimits(); }catch(Exception e){}
        try{ c.parseCsv(); }catch(Exception e){}
        try{ c.getSfdcJobStatus(); }catch(Exception e){}
    }
    
    
}