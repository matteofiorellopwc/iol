@isTest
public class testTrigger{

    public static testMethod void testupdateAgenziaOnProvincia(){
        Provincia__c p = new Provincia__c(Name='test',Sigla__c='tes',Regione__c='test');
        insert p;
    }
    public static testMethod void testafterDeleteProduct(){
        Product2 p = new Product2(Name='test');
        insert p;
        delete p;
    }
    public static testMethod void testafterDeleteLineItem(){
        
        Date dataOdierna = Date.today();
        Date dataChiusuraRicavoDate = Date.newInstance(dataOdierna.year(),dataOdierna.month(),1);
        dataChiusuraRicavoDate = dataChiusuraRicavoDate.addYears(-8).addDays(-1);
        
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = dataChiusuraRicavoDate;
        insert dataChiusuraRicavo;
        
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c();
        dataChiusuraRicavoLocal.Name = 'local';
        dataChiusuraRicavoLocal.data__c = dataChiusuraRicavoDate;
        insert dataChiusuraRicavoLocal;
        
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        lineitem__c li = new lineitem__c(opportunity__c=o.id);
        insert li;
        revenue_application__c ra = new revenue_application__c(Mese__c='Gennaio',Anno__c='2013',line_item__c=li.id,percentuale_applicata__c = 100,valore__c=0);
        insert ra;
        ricavo__c ri = new ricavo__c(Mese__c='Gennaio',Anno__c='2013',line_item__c=li.id,percentuale_applicata__c = 100,valore__c=0);
        insert ri;
        
        
        update li;
        
        delete li;
        
        delete o;
    }
    public static testMethod void testupdateAgenziaOnRegione(){
        Regione__c r = new Regione__c(Name='test');
        insert r;
    }
    public static testMethod void testcheckprovinciaQuote(){
        //inactive
    }
    public static testMethod void testonBeforeAccount(){
        Provincia__c p = new Provincia__c(Name='test',Sigla__c='tes',Regione__c='test');
        insert p;
        Account a = new account(Name='test',billingState = 'tes',shippingState='tes');
        insert a;
    }
    
    public static testMethod void testOnAfterRevenueApplication(){
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        lineitem__c li = new lineitem__c(opportunity__c=o.id);
        insert li;
        
        Revenue_application__c ra = new Revenue_application__c(line_item__c=li.id);
        insert ra;
        delete ra;
        
    }
    
    @isTest
    public static void testPacchettiCombo(){
        PacchettoCombo__c pc = new PacchettoCombo__c(name='test');
        insert pc;
        Product2 p = new Product2(Name='test',delivery_model__c = 'CPM');
        insert p;
        Pacchetto_Combo_Prodotto__c pcp = new Pacchetto_Combo_Prodotto__c();
        pcp.PacchettoCombo__c = pc.id;
        pcp.Product__c = p.id;
        pcp.quantita__c = 1000;
        pcp.goal__c = 1;
        pcp.start_date__c=date.today();
        pcp.end_date__c=date.today();
        pcp.listino__c = 1;
        insert pcp;
        pc = [select totale__c from pacchettoCombo__c where id =: pc.id];
        system.assertEquals(1,pc.totale__c);
        
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        
        Pacchetto_Combo_Opportunity__c pco = new Pacchetto_Combo_Opportunity__c(Opportunity__c=o.id,PacchettoCombo__c=pc.id);
        insert pco;
        
        delete pco;
    }
    
/*    
    @isTest(seeAllData=true)
    public static void testafterDeleteOpportunityLineItem(){
        Opportunity o = new Opportunity();
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        Product2 p = new Product2(Name='test');
        insert p;
        PricebookEntry pbe = [select id from PricebookEntry where Product2Id =: p.id];
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.id,PricebookEntryId=pbe.id,quantity=1,unitprice=100);
        insert oli;
        delete oli;
    }
*/                   


}