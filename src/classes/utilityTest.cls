@isTest
public class utilityTest{

    public static FattoreCorrettivoFasceOrarie__c createFattoreCorrettivoFasce(){
        FattoreCorrettivoFasceOrarie__c fatt = FattoreCorrettivoFasceOrarie__c.getInstance('default');
        if(fatt == null){
            fatt = new FattoreCorrettivoFasceOrarie__c(
                name = 'default',    
                Fattore_correttivo_fascia_0_12__c = 0.3,
                Fattore_correttivo_fascia_12_16__c = 0.4,
                Fattore_correttivo_fascia_16_24__c = 0.3
            );
            insert fatt;
        }
        return fatt;    
    }

    public static Product2 createBannerOas(){
        Product2 p = new Product2();
        p.name= 'test';
        p.ad_server__c = 'OAS';
        p.recordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Banner').getRecordTypeId();
        p.target_Platform__c = 'WEB';
        p.size__c = '300x250';
        p.delivery_model__c = 'CPM';
        p.formato__c = 'test';
        p.baseprice__c = 0.1;
        p.breakeven_cost__c = 0;
        p.type__c = 'STANDARD';
        p.priority_oas__c = '8';
        
        /*
        p.OasPrimaryFrequencyClickPerVisitor__c = 
        p.OasPrimaryFrequencyImpPerVisitor__c
        p.OasSecondaryFrequencyImpPerVisitor__c
        p.OasPrimaryFreqScope__c
        p.OasSecondaryFreqScope__c
        */
        insert p;
        
        AdUnit__c adu;
        //if there's no parent adunit, it is created.
        try{
            adu = [select id from AdUnit__c where level__c = 0];
        }catch(exception e){
            adu = new AdUnit__c(name='test',idDfp__c='test',status__c='ACTIVE');
            insert adu;
        }

        adu = new AdUnit__c(name='test',pageoas__c='test');
        insert adu;
        
        Inventory_target__c it = new Inventory_target__c(ad_unit__c=adu.id,product__c=p.id, InventoryTargetingType__c ='include');
        insert it;
        
        SectionOas__c sec = new SectionOas__c(name='test',idOas__c='test',pages__c='aaa\nbbb');
        insert sec;
        
        SectionOasTargeted__c soa = new SectionOasTargeted__c(Product__c=p.id,sectionOas__c=sec.id);
        insert soa;
        
        it = new Inventory_target__c(ad_unit__c=adu.id,product__c=p.id, InventoryTargetingType__c ='exclude', SectionOas__c=sec.id);
        insert it;
            
        
    
           
        CookieSearchOasTargeted__c cs = new CookieSearchOasTargeted__c(categoria__c ='test',product__c=p.id,oas_field__c='Cookie Targeting',values__c='test');
        insert cs;
               
        return p;
    }
    
    public static Product2 createBannerCPD(){
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
        insert p;
        
        AdUnit__c adu;
        //if there's no parent adunit, it is created.
        try{
            adu = [select id from AdUnit__c where level__c = 0];
        }catch(exception e){
            adu = new AdUnit__c(name='test',idDfp__c='test',status__c='ACTIVE');
            insert adu;
        }

        Inventory_target__c it = new Inventory_target__c(ad_unit__c=adu.id,product__c=p.id, InventoryTargetingType__c ='include');
        insert it;
                
        return p;   
    }
    
    public static Product2 createBannerDfp(){
        Product2 p = new Product2();
        p.name= 'test';
        p.ad_server__c = 'DFP';
        p.recordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Banner').getRecordTypeId();
        p.target_Platform__c = 'WEB';
        p.size__c = '300x250';
        p.delivery_model__c = 'CPM';
        p.formato__c = 'test';
        p.baseprice__c = 0.1;
        p.breakeven_cost__c = 0;
        p.type__c = 'STANDARD';
        insert p;
        
        
        AdUnit__c adu;
        //if there's no parent adunit, it is created.
        try{
            adu = [select id from AdUnit__c where level__c = 0];
        }catch(exception e){
            adu = new AdUnit__c(name='test',idDfp__c='test',status__c='ACTIVE');
            insert adu;
        }

                
        Inventory_target__c it = new Inventory_target__c(ad_unit__c=adu.id,product__c=p.id, InventoryTargetingType__c ='targeted');
        insert it;
        
        dayPartTargeting__c dpt = new dayPartTargeting__c(dayOfWeek__c='MONDAY', Start_Hour__c='0',Start_minute__c='0',End_Hour__c='0',end_minute__c='59',product__c=p.id);
        insert dpt;
        
        FrequencyCap__c fp = new FrequencyCap__c(maxImpressions__c=1, numTimeUnits__c=1, timeUnit__c = 'MINUTE');
        insert fp;
        
        return p;
    }
    
    public static Account insertBrand(){
        Provincia__c p = new Provincia__c(name='test', Sigla__c = 'tt');
        insert p;
        Account a = new Account();
        a.billingState = 'tt';
        a.name='test';
        a.recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        a.id_oas__c='testbrand';
        a.id_Dfp__c = 55;
        insert a;
        return a;
    }
    
    public static Account insertCentroMedia(){
        Account a = new Account();
        a.name='test';
        a.recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro Media').getRecordTypeId();
        a.id_oas__c='testbrand';
        a.id_Dfp__c = 55;
        insert a;
        return a;    
    }
    
    public static Opportunity insertDfpOasOpp(){
        createFattoreCorrettivoFasce();
        Account brand = utilityTest.insertBrand();
        
        Opportunity opp = new Opportunity(Commissione_Agenzia__c=0,Accountid=brand.id,Name='Test opp',StageName='75 %',closeDate = date.today());
        insert opp;
        
        ApexPages.StandardController oppStndCtrl = new ApexPages.standardController(opp);
        ExtensionAddProduct controller = new ExtensionAddProduct(oppStndCtrl);
        controller.prodId = utilityTest.createBannerOas().id;
        controller.addProduct(); 
        controller.prodId = utilityTest.createBannerDfp().id;
        controller.addProduct(); 
        
        return opp;
    }







}