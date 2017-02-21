@isTest
public class testingNavisionServiceClass{
    public static testMethod void testNavisionManageClienti(){
        insertBasicAuth();
        NavisionManageClienti c = new NavisionManageClienti();
        NavisionManageClienti.InserisciClienteITNET_element InserisciClienteITNET_element = new NavisionManageClienti.InserisciClienteITNET_element();
        NavisionManageClienti.HelloWorld_element HelloWorld_element = new NavisionManageClienti.HelloWorld_element();
        NavisionManageClienti.HelloWorldResponse_element HelloWorldResponse_element = new NavisionManageClienti.HelloWorldResponse_element();
        NavisionManageClienti.InserisciClienteLibero_element InserisciClienteLibero_element = new NavisionManageClienti.InserisciClienteLibero_element();
        NavisionManageClienti.InserisciClienteLiberoResponse_element InserisciClienteLiberoResponse_element = new NavisionManageClienti.InserisciClienteLiberoResponse_element();
        NavisionManageClienti.InserisciClienteITNETResponse_element InserisciClienteITNETResponse_element = new NavisionManageClienti.InserisciClienteITNETResponse_element();
        NavisionManageClienti.ManageClientiSoap soap = new NavisionManageClienti.ManageClientiSoap();
        try{
            soap.InserisciClienteITNET(new NavisionManageClienti.InserisciClienteITNET_element());
        }catch(Exception e){}
        try{
            soap.HelloWorld();
        }catch(Exception e){}
        try{
            soap.InserisciClienteLibero(new NavisionManageClienti.InserisciClienteLibero_element());
        }catch(Exception e){}
    }
    
    public static testMethod void testNavisionManageTestateVendita(){
        insertBasicAuth();
        NavisionManageTestateVendita NavisionManageTestateVendita = new NavisionManageTestateVendita();
        NavisionManageTestateVendita.HelloWorld_element HelloWorld_element  = new NavisionManageTestateVendita.HelloWorld_element();
        NavisionManageTestateVendita.HelloWorldResponse_element HelloWorldResponse_element  = new NavisionManageTestateVendita.HelloWorldResponse_element();
        NavisionManageTestateVendita.InserisciTestateVenditaLibero_element InserisciTestateVenditaLibero_element = new NavisionManageTestateVendita.InserisciTestateVenditaLibero_element();
        NavisionManageTestateVendita.InserisciTestateVenditaITNET_element InserisciTestateVenditaITNET_element = new NavisionManageTestateVendita.InserisciTestateVenditaITNET_element();
        NavisionManageTestateVendita.InserisciTestateVenditaITNETResponse_element InserisciTestateVenditaITNETResponse_element  = new NavisionManageTestateVendita.InserisciTestateVenditaITNETResponse_element();
        NavisionManageTestateVendita.InserisciTestateVenditaLiberoResponse_element InserisciTestateVenditaLiberoResponse_element  = new NavisionManageTestateVendita.InserisciTestateVenditaLiberoResponse_element();
        
        NavisionManageTestateVendita.ManageTestateVenditaSoap soap  = new NavisionManageTestateVendita.ManageTestateVenditaSoap();
        try{
            soap.InserisciTestateVenditaLibero(new NavisionManageTestateVendita.InserisciTestateVenditaLibero_element());
        }catch(Exception e){}
        try{
            soap.HelloWorld();
        }catch(Exception e){}
        try{
            soap.InserisciTestateVenditaITNET(new NavisionManageTestateVendita.InserisciTestateVenditaITNET_element());
        }catch(Exception e){}
    }
    
    public static testMethod void testNavisionManageRigheVendita(){
        insertBasicAuth();
        NavisionManageRigheVendita n = new NavisionManageRigheVendita();
        NavisionManageRigheVendita.HelloWorldResponse_element HelloWorldResponse_element = new NavisionManageRigheVendita.HelloWorldResponse_element();
        NavisionManageRigheVendita.InserisciRigheVenditaITNET_element InserisciRigheVenditaITNET_element = new NavisionManageRigheVendita.InserisciRigheVenditaITNET_element();
        NavisionManageRigheVendita.InserisciRigheVenditaLibero_element InserisciRigheVenditaLibero_element = new NavisionManageRigheVendita.InserisciRigheVenditaLibero_element();
        NavisionManageRigheVendita.InserisciRigheVenditaLiberoResponse_element InserisciRigheVenditaLiberoResponse_element = new NavisionManageRigheVendita.InserisciRigheVenditaLiberoResponse_element();
        NavisionManageRigheVendita.InserisciRigheVenditaITNETResponse_element InserisciRigheVenditaITNETResponse_element = new NavisionManageRigheVendita.InserisciRigheVenditaITNETResponse_element();
        
        NavisionManageRigheVendita.ManageRigheVenditeSoap soap  = new NavisionManageRigheVendita.ManageRigheVenditeSoap();
        try{
            soap.InserisciRigheVenditaITNET(new NavisionManageRigheVendita.InserisciRigheVenditaITNET_element());
        }catch(Exception e){}
        try{
            soap.InserisciRigheVenditaLibero(new NavisionManageRigheVendita.InserisciRigheVenditaLibero_element());
        }catch(Exception e){}
        try{
            soap.HelloWorld();
        }catch(Exception e){}
    }
    
     public static void insertBasicAuth(){
        BasicAuthApplication__c cs = new BasicAuthApplication__c(name='Ticketing_Advertising',username__c='test',password__c='test',endpoint__c='test');
        insert cs;
     }

}