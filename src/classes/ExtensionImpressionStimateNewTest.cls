@isTest
public class ExtensionImpressionStimateNewTest {
    
    public static String getResponseBody(){
        StaticResource sr = [Select  s.Name, s.Id, s.Body From StaticResource s  where name ='TEST'];
        blob tempBlob = sr.Body;
        String tempString = tempBlob.toString();
        tempString = tempSTring.replace('"', '');
        return tempString;
    }
    
    public static Product2 createBannerCPD(){
        AdUnit__c au0 = new AdUnit__c(name='test',idDfp__c='1',status__c='ACTIVE', sizes__c = '300x250', CanalePrimario__c = 'Home page');
        insert au0;
        AdUnit__c au1 = new AdUnit__c(name='test',idDfp__c='2',status__c='ACTIVE', sizes__c = '300x250', CanalePrimario__c = 'Home page', ParentAdUnit__c = au0.Id, target_Platform__c = 'test');
        insert au1;
        AdUnit__c au2 = new AdUnit__c(name='test',idDfp__c='3',status__c='ACTIVE', sizes__c = '300x250', CanalePrimario__c = 'Home page', ParentAdUnit__c = au1.Id, target_Platform__c = 'test');
        insert au2;
        
        Product2 p = new Product2();
        p.name= 'test';
        p.ad_server__c = 'DFP';
        p.recordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Banner').getRecordTypeId();
        p.target_Platform__c = 'WEB';
        p.size__c = '300x250';
        p.delivery_model__c = 'CPD';
        p.formato__c = 'test';
        p.baseprice__c = 0.1;
        p.breakeven_cost__c = 0;
        p.type__c = 'SPONSORSHIP';
        p.IsActive = true;
        p.CalcolaCPDconImprStimate__c = true;
        p.Modificabile_in_line_item__c = 'Fascia Oraria';
        p.CanalePrimario__c = 'Home page';
        insert p;
        
        Inventory_target__c it = new Inventory_target__c(ad_unit__c= au1.id, product__c = p.id, InventoryTargetingType__c ='include');
        insert it;
                
        return p;   
    }

    static testMethod void myUnitTest() {
        Product2 p = ExtensionImpressionStimateNewTest.createBannerCPD();
        System.debug('MioDebug: ' + [SELECT Name, Size__c, Family, Delivery_Model__c, CalcolaCPDconImprStimate__c, canalePrimario__c, Formato__c FROM Product2]);
        System.debug('MioDebug: ' + [SELECT Sizes__c, showAdUnitFormula__c, Level__c, SublevelSizes__c, CanalePrimario__c, Path__c, target_Platform__c FROM AdUnit__c WHERE Level__c = 1]);
        System.debug('MioDebug: ' + [SELECT AdUnit__r.Path__c, AdUnit__r.level__c, AdUnit__r.target_Platform__c, Product__r.canalePrimario__c, Product__r.Name, Product__r.Size__c, Product__r.Formato__c, Product__r.IsActive FROM Impressions_stimate__c]);
        
        AdUnit__c au = new AdUnit__c(Name = 'Test', status__c = 'ACTIVE', idDfp__c = '123456789');
        insert au;
        
        ApexPages.StandardController sc = new ApexPages.standardController(au);
        ExtensionImpressionStimateNew ext = new ExtensionImpressionStimateNew(sc);
        
        ext.code = 'test  >  test';
        ext.level = '1';
        ext.targetPlatform = 'test';
        ext.canalePrimario = 'Home page';
        ext.prodname = 'test - 300x250 - Home page -';
        ext.family = 'Banner';
        ext.size = '300x250';
        ext.formato = 'test';
        ext.soloAttivi = true;
        ext.search();
          
        ext.impressionsStimate[0].checked = true;
        ext.save();
        ext.startReportGeneration();
        ext.checkIfReportIsComplete();
        ext.downloadReport();
        ext.finalize();
    }
}