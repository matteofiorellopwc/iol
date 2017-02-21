public class UtilityReportIntegration {
    public static DfpIntegration dfp;
    static {
        dfp = new DfpIntegration();
    }  
        
    public static void runReport(String adUnitView, Boolean dayOrMonth, Date d) {
    
        //Avvio il report su DFP
        DfpReportService.ReportQuery q = new DfpReportService.ReportQuery();
        q.dimensions = new list<String>{
            'AD_UNIT_ID',
            'LINE_ITEM_ID',
            dayOrMonth ? 'DAY' : 'MONTH_AND_YEAR'
        };
        q.adUnitView = adUnitView; // 'FLAT' OR 'TOP_LEVEL'
        q.dateRangeType = 'CUSTOM_DATE';
        q.startDate = UtilityDataValue.getReportDate(d.year(), d.month(), dayOrMonth ? d.day() : 1);
        q.endDate = UtilityDataValue.getReportDate(d.year(), d.month(), dayOrMonth ? d.day() : d.addMonths(1).toStartOfMonth().addDays(-1).day());
        q.adUnitView = adUnitView;
        q.columns = new list<String>{
            'TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS',
            'TOTAL_LINE_ITEM_LEVEL_CLICKS',
            'TOTAL_LINE_ITEM_LEVEL_CPM_AND_CPC_REVENUE'
        };

        DfpReportService.ReportJob job = new DfpReportService.ReportJob();
        job.reportQuery = q;        
        job = dfp.reportService.runReportJob(job);

        ReportLogger__c rl = new ReportLogger__c(
            Name = String.valueOf(job.Id),
            Stato__c = dfp.reportService.getReportJobStatus(job.Id),
            Tipo__c = dayOrMonth ? 'Giornaliero' : 'Mensile',
            AdUnitView__c = adUnitView,
            Data_generazione__c = d
        );
        insert rl;    
    }

    public static String pollReportStatus(Long jobId) {
        return dfp.reportService.getReportJobStatus(jobId);
        
    }
    
    public static String getReportUrl(Long jobId) {
        DfpReportService.ReportDownloadOptions opts = new DfpReportService.ReportDownloadOptions();
        opts.exportFormat = 'CSV_DUMP';
        opts.includeReportProperties = false;
        opts.includeTotalsRow = false;
        opts.useGzipCompression = false;
        system.debug('getReportUrl jobId'+jobId);
        return dfp.reportService.getReportDownloadUrlWithOptions(jobId, opts);
    }

    @isTest
    static void test() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        Asset a = new Asset(Name = 'Test', AccountId = acc.Id);
        insert a;
    }
}