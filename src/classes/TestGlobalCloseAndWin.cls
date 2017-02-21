@isTest
public with sharing class TestGlobalCloseAndWin {


    public static testMethod void testPage() {
        
        //PREPARE DATA:

        Date dataOdierna = Date.today();
        Date dataChiusuraRicavi = Date.newInstance(dataOdierna.year(), dataOdierna.month(), 1).addMonths(-7);
        
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c(
                                Name = 'nazionale',
                                data__c = dataChiusuraRicavi 
        );
        insert dataChiusuraRicavo;
        
        // La data di chiusura dei ricavi local è creata qui solo per correttezza, non utilizzata nel test ma va in errore se tolta perché ci sono controlli su questa data
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c(
                                Name = 'local',
                                data__c = dataChiusuraRicavi 
        );
        insert dataChiusuraRicavoLocal;

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
        LineItem__c i = new LineItem__c(
            Product__c=testProd.id,
            Quantita__c=100000,
            Opportunity__c=x.id,
            Type_DFP__c = 'STANDARD',
            Delivery_Model__c = 'CPM',
            NonIntegratoAdServer__c = false,
            Start_Date__c = Date.today().addDays(20),
            End_Date__c = Date.today().addMonths(3),
            Somma_valore_revenue_application__c = 100,
            End_Hour__c = '0',
            End_Minute__c = '0',
            Ultima_modifica_prezzo__c='Totale',
            ModalitaEditRicavo__c = 'Valore',
            Totale__c = 1000,
            Formato_prodotto__c = 'Total'
        );
        insert i;
        
        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(i);
        ctrlRevenue.setParentValues(i);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();

        ControllerRicavi ctrlRicavi = new ControllerRicavi(i);
        ctrlRicavi.setParentValues(i);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();


        Boolean userCreated = false;
        User u;
        try{
            //try to get a user with a profile NOT allowed to run the "chiudi e vinci" process
            //e.g. "Libero - BackOffice"
            Profile p = [select id from profile where name='Libero - BackOffice'];
            List<User> uList = [SELECT Id FROM User WHERE ProfileId =: p.id and isActive = true LIMIT 1];
            
            if(uList.size()>0){
                u=uList.get(0);
            } else {
                u = new User(
                    isActive = true,
                    alias = 'standt', 
                    email='standarduser@testorg.com',
                    emailencodingkey='UTF-8', 
                    lastname='Testing', 
                    languagelocalekey='en_US',
                    localesidkey='en_US', 
                    profileid = p.Id,
                    timezonesidkey='America/Los_Angeles', 
                    username='standarduser@testorg.com'
                );
                //WARNING: this test requires an unused-license!!!!
                insert u;
            }
            userCreated= true;
        } catch (Exception e){
            //I don't have free licenses or anyway I don't have
            //a user with my desired profile, don't test for user part
            userCreated= false;
        }
 

        
        
        
        //PREPARE TEST ENVIRONMENT:
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.GlobalOpportunityCloseAndWin;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',(String)x.id);
        ControllerGlobalCloseAndWin controller = new ControllerGlobalCloseAndWin();
        
        controller.saveAndReload();
        //TESTING:
        Test.startTest();
            
            //emulate remote call 0, no errors:
            try{
                ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep0(x.id);
                System.debug(resp);
            } catch (exception e){
                System.debug(e);
            }

            //emulate remote call 1, no errors:
            try{
                ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep1(x.id);
                System.debug(resp);
            } catch (exception e){
                System.debug(e);                   
            }
            
            //emulate remote call 2
            try{
                ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep2(x.id);
                System.debug(resp);
            } catch (exception e){
                System.debug(e);
            }
            
            //emulate remote call 3
            try{
                ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep3(x.id);
                System.debug(resp);
            } catch (exception e){
                System.debug(e);
            }

            //emulate remote call 4
            try{
                ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep4(x.id);
                System.debug(resp);
            } catch (exception e){
                System.debug(e);
            }
            
            //emulate User profile error:
            if(userCreated)
            System.runAs(u){
                System.debug('Utente utilizzato per il chiudi e vinci: '+u);
                pageRef = Page.GlobalOpportunityCloseAndWin;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id',(String)x.id);
                controller = new ControllerGlobalCloseAndWin();
                
                //emulate remote call 0, no errors:
                Integer excpCount = 0;
                try{
                    ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep0(x.id);
                    if(resp.isError){
                        excpCount++;
                    }
                } catch (exception e){
                    excpCount++;
                    //assert that we had our custom profile-related exception
                    System.assert(e.getMessage().contains('non dispone dei privilegi per confermare questa'));              
                }

                //emulate remote call 1, no errors:
                try{
                    ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep1(x.id);
                    if(resp.isError){
                        excpCount++;
                    }
                } catch (exception e){
                    excpCount++;
                    //assert that we had our custom profile-related exception
                    System.assert(e.getMessage().contains('non dispone dei privilegi per confermare questa'));              
                }
            
                //emulate remote call 2
                try{
                    ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep2(x.id);
                    if(resp.isError){
                        excpCount++;
                    }
                } catch (exception e){
                    excpCount++;
                    //assert that we had our custom profile-related exception
                    System.assert(e.getMessage().contains('non dispone dei privilegi per confermare questa'));      
                }
            
                //emulate remote call 3
                try{
                    ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep3(x.id);
                    if(resp.isError){
                        excpCount++;
                    }
                } catch (exception e){
                    excpCount++;    
                    //assert that we had our custom profile-related exception
                    System.assert(e.getMessage().contains('non dispone dei privilegi per confermare questa'));      
                }

                //emulate remote call 4
                try{
                    ControllerGlobalCloseAndWin.stepResponse resp = ControllerGlobalCloseAndWin.chiudiEVinciStep4(x.id);
                    if(resp.isError){
                        excpCount++;
                    }
                } catch (exception e){
                    excpCount++;    
                    //assert that we had our custom profile-related exception
                    System.assert(e.getMessage().contains('non dispone dei privilegi per confermare questa'));      
                }
                
                //assert that we have three RemoveVFException:
                System.assertEquals(excpCount,4);
                
            }
            
        
        Test.stopTest();
    }

}