/**
 *  Date:   2017/01/19
 *  Description:    Test for BatchableDeleteRicaviNulli
 *  Author: Claudio Arado
 */
 
 
@isTest
private class BatchableDeleteRicaviNulliTest {
	
	
public static testMethod void Test_nodate()
{
        preparedata();
      	Test.startTest();              
        BatchableDeleteRicaviNulli batch = new BatchableDeleteRicaviNulli();
    	Id batchprocessId = Database.executeBatch(batch,2000);
		Test.stopTest();        	    	       
     	list<ricavo__c> rprova = [select id,valore__c, Percentuale_applicata__c, Data_ultimo_mese__c from ricavo__c];
       
        system.debug('Numero record presenti oggetto Ricavo dopo test_nodate ' + rprova.size());

        for(ricavo__c r:rprova){
        system.debug('valore= '+r.valore__c + 'Percentuale ' + r.Percentuale_applicata__c + ' Data_ultimo_mese__c '+r.Data_ultimo_mese__c);}
    	
        System.assert(rprova.size()==4);

}

public static testMethod void Test_interval_openleft()
{

		preparedata();

		integer anno = Date.today().year()+1;
		//string datalimite1 = (anno+'-04-30');
		string datalimite1='';
		string datalimite2 = (anno+'-05-31');
		Test.startTest();				  
        BatchableDeleteRicaviNulli batch = new BatchableDeleteRicaviNulli(datalimite1,datalimite2);
    	Id batchprocessId = Database.executeBatch(batch);
        Test.stopTest();       	  	       
        list<ricavo__c> rprova = [select id,valore__c, Percentuale_applicata__c, Data_ultimo_mese__c from ricavo__c];
        system.debug('Numero record presenti oggetto Ricavo dopo test_interval_openleft ' + rprova.size());

        for(ricavo__c r:rprova){
        system.debug('valore= '+r.valore__c + 'Percentuale ' + r.Percentuale_applicata__c +' Data_ultimo_mese__c '+r.Data_ultimo_mese__c);}
     
        System.assert(rprova.size()==5);

}

public static testMethod void Test_interval_openright()
{

		preparedata();
		
		integer anno = Date.today().year()+1;
		string datalimite1 = (anno+'-05-31');
		string datalimite2 = ('');
		Test.startTest();		          
        BatchableDeleteRicaviNulli batch = new BatchableDeleteRicaviNulli(datalimite1,datalimite2);
    	Id batchprocessId = Database.executeBatch(batch);
		Test.stopTest();       	    	       
        list<ricavo__c> rprova = [select id,valore__c, Percentuale_applicata__c, Data_ultimo_mese__c from ricavo__c];
        system.debug('Numero record presenti oggetto Ricavo dopo test_interval_openright ' + rprova.size());

        for(ricavo__c r:rprova){
        system.debug('valore= '+r.valore__c + 'Percentuale ' + r.Percentuale_applicata__c +' Data_ultimo_mese__c '+r.Data_ultimo_mese__c);}
      
        System.assert(rprova.size()==6);
	
}


public static testMethod void Test_interval()
{

		preparedata();

		integer anno = Date.today().year()+1;
		string datalimite1 = (anno+'-05-01');
		string datalimite2 = (anno+'-05-31');
		Test.startTest();				  
        BatchableDeleteRicaviNulli batch = new BatchableDeleteRicaviNulli(datalimite1,datalimite2);
    	Id batchprocessId = Database.executeBatch(batch, 10);
        Test.stopTest();      	
    	       
        list<ricavo__c> rprova = [select id,valore__c, Percentuale_applicata__c, Data_ultimo_mese__c from ricavo__c];
        system.debug('Numero record presenti oggetto Ricavo dopo test_interval ' + rprova.size());

        for(ricavo__c r:rprova){
        system.debug('valore= '+r.valore__c + 'Percentuale ' + r.Percentuale_applicata__c +' Data_ultimo_mese__c '+r.Data_ultimo_mese__c);}

        System.assert(rprova.size()==6);
        
}


private static void setDataChiusuraRicavi(integer anno, integer mese, integer giorno){
        Date dataChiusuraRicavi = date.newInstance(anno,mese,giorno);
                
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = dataChiusuraRicavi;
        insert dataChiusuraRicavo;
        system.debug('Data chiusura ricavi' + dataChiusuraRicavi);
        
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c();
        dataChiusuraRicavoLocal.Name = 'local';
        dataChiusuraRicavoLocal.data__c = dataChiusuraRicavi;
        insert dataChiusuraRicavoLocal;
    }


private static void preparedata(){

		//string query = 'SELECT id FROM ricavo__c WHERE Valore__c =0 and MinorRicavo__c = false and Percentuale_applicata__c = 0 and Is_FineComp_sup_LiEndDate__c = true';
		
		//PREPARE DATA:
        
        EmailLog__c el = new EmailLog__c(name='AmministratoriSistema',emails__c='test@test.com');
        insert el;
        
        integer anno = Date.today().year();
        setDataChiusuraRicavi(2016,01,01);


        //insert data: Client, Opportunity, Product and Line Item:
        Product2 testProd = new Product2(
            Name='Advertorial - 300x250 - TestLibero - TEST CPM TELNEXT',
            ConsentiModificaSeMesiChiusi__c = false,
            Family='Banner',
            Ad_Server__c='DFP',         
            Target_platform__c='WEB',
            Size__c='300x250',
            Delivery_Model__c='CPM',
            Formato__c='Advertorial',
            Categoria_libero__c='Rich media',
            Canale_Primario__c='TestLibero',
            BasePrice__c=0.5555,
            Breakeven_cost__c=0.011,
            Modificabile_in_line_item__c='Inventory Target Exclude; Inventory Target Include; Day Part Targeting; Frequency Caps; Custom Criteria; Technology Targeting; Type DFP; Priority',
            Priority__c='8',
            Type__c='STANDARD'
        );
        insert testProd;
        
        Account a = new Account(
            Name='Pippo',
            Ragione_sociale__c='Pippo S.r.l.'
        );
        insert a;
        
        Opportunity x = new Opportunity(
            Name='test',
            CloseDate=Date.today(),
            Probability=75,
            StageName='75%',
            Account=a,
            Canale_di_vendita__c='DIRETTA',
            Commissione_Agenzia__c = 0          
        );
        insert x;
        
        LineItemTriggerHandler.skipValidationTotali = true;
        
        LineItem__c li_1 = new LineItem__c(Product__c=testProd.id,
            Quantita__c=100000,
            Opportunity__c=x.id,
            Type_DFP__c = 'STANDARD',
            Delivery_Model__c = 'CPM',
            NonIntegratoAdServer__c = false,
            Start_Date__c = Date.newinstance(anno+1,1,1),
            End_Date__c = Date.newinstance(anno+1,6,30),
            Somma_valore_revenue_application__c = 100,
            End_Hour__c = '0',
            End_Minute__c = '0',
            Ultima_modifica_prezzo__c='Totale',
            ModalitaEditRicavo__c = 'Valore',
            Totale__c = 1000,
            Formato_prodotto__c = 'Total'
        );
 /*    
        LineItem__c li_2 = new LineItem__c(Product__c=testProd.id,
            Quantita__c=100000,
            Opportunity__c=x.id,
            Type_DFP__c = 'STANDARD',
            Delivery_Model__c = 'CPM',
            NonIntegratoAdServer__c = false,
            Start_Date__c = Date.newinstance(anno+1,1,1),
            End_Date__c = Date.newinstance(anno+1,1,1),
            Somma_valore_revenue_application__c = 100,
            End_Hour__c = '0',
            End_Minute__c = '0',
            Ultima_modifica_prezzo__c='Totale',
            ModalitaEditRicavo__c = 'Valore',
            Totale__c = 0,
            Formato_prodotto__c = 'Total'
        );
*/
        insert li_1;
	//	insert li_2;

        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(li_1);
        ctrlRevenue.setParentValues(li_1);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();

        ControllerRicavi ctrlRicavi = new ControllerRicavi(li_1);
        ctrlRicavi.setParentValues(li_1);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();
/*        
        ControllerRevenueApplication ctrlRevenue_2 = new ControllerRevenueApplication(li_2);
        ctrlRevenue_2.setParentValues(li_2);
        ctrlRevenue_2.creaRevenueApplicationDaDate();
        ctrlRevenue_2.customSave();

        ControllerRicavi ctrlRicavi_2 = new ControllerRicavi(li_2);
        ctrlRicavi_2.setParentValues(li_2);
        ctrlRicavi_2.creaRicaviDaDate();
        ctrlRicavi_2.customSave();
*/		
		li_1.End_Date__c = Date.newinstance(anno+1,3,10);  //Simula lo spostamento indietro della data di chiusura. Si generano quindi righe con ricavo nullo
		update li_1;
		ctrlRicavi.setParentValues(li_1);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();
		
	
		setDataChiusuraRicavi(Date.today().year()+2,Date.today().month(),Date.today().day());
		list<ricavo__c> rprova = [select id,valore__c, Percentuale_applicata__c, Data_ultimo_mese__c from ricavo__c];
        system.debug('Numero record presenti oggetto Ricavo INIZO' + rprova.size());

        for(ricavo__c r:rprova){
        system.debug('valore= '+r.valore__c + 'Percentuale ' + r.Percentuale_applicata__c +' Data_ultimo_mese__c '+r.Data_ultimo_mese__c);}
}


}