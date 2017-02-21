@isTest
public class NavisionServiceClassNav2009Test{
    public static testMethod void testNavisionManageClientiNav2009(){
        NavisionManageClientiNav2009 c = new NavisionManageClientiNav2009();
        NavisionManageClientiNav2009.InserisciClienteITNET_element InserisciClienteITNET_element = new NavisionManageClientiNav2009.InserisciClienteITNET_element();
        NavisionManageClientiNav2009.HelloWorld_element HelloWorld_element = new NavisionManageClientiNav2009.HelloWorld_element();
        NavisionManageClientiNav2009.HelloWorldResponse_element HelloWorldResponse_element = new NavisionManageClientiNav2009.HelloWorldResponse_element();
        NavisionManageClientiNav2009.InserisciClienteLibero_element InserisciClienteLibero_element = new NavisionManageClientiNav2009.InserisciClienteLibero_element();
        NavisionManageClientiNav2009.InserisciClienteLiberoResponse_element InserisciClienteLiberoResponse_element = new NavisionManageClientiNav2009.InserisciClienteLiberoResponse_element();
        NavisionManageClientiNav2009.InserisciClienteITNETResponse_element InserisciClienteITNETResponse_element = new NavisionManageClientiNav2009.InserisciClienteITNETResponse_element();
        NavisionManageClientiNav2009.ManageClientiSoap soap = new NavisionManageClientiNav2009.ManageClientiSoap();
        try{
            soap.InserisciClienteITNET(new NavisionManageClientiNav2009.InserisciClienteITNET_element());
        }catch(Exception e){}
        try{
            soap.HelloWorld();
        }catch(Exception e){}
        try{
            soap.InserisciClienteLibero(new NavisionManageClientiNav2009.InserisciClienteLibero_element());
        }catch(Exception e){}
    }
    
    public static testMethod void testNavisionManageTestateVenditaNav2009(){
        NavisionManageTestateVenditaNav2009 NavisionManageTestateVenditaNav2009 = new NavisionManageTestateVenditaNav2009();
        NavisionManageTestateVenditaNav2009.HelloWorld_element HelloWorld_element  = new NavisionManageTestateVenditaNav2009.HelloWorld_element();
        NavisionManageTestateVenditaNav2009.HelloWorldResponse_element HelloWorldResponse_element  = new NavisionManageTestateVenditaNav2009.HelloWorldResponse_element();
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element InserisciTestateVenditaLibero_element = new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element();
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element InserisciTestateVenditaITNET_element = new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element();
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNETResponse_element InserisciTestateVenditaITNETResponse_element  = new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNETResponse_element();
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLiberoResponse_element InserisciTestateVenditaLiberoResponse_element  = new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLiberoResponse_element();
        
        NavisionManageTestateVenditaNav2009.ManageTestateVenditaSoap soap  = new NavisionManageTestateVenditaNav2009.ManageTestateVenditaSoap();
        try{
            soap.InserisciTestateVenditaLibero(new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element());
        }catch(Exception e){}
        try{
            soap.HelloWorld();
        }catch(Exception e){}
        try{
            soap.InserisciTestateVenditaITNET(new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element());
        }catch(Exception e){}
    }
    
    public static testMethod void testNavisionManageRigheVenditaNav2009(){
        NavisionManageRigheVenditaNav2009 n = new NavisionManageRigheVenditaNav2009();
        NavisionManageRigheVenditaNav2009.HelloWorldResponse_element HelloWorldResponse_element = new NavisionManageRigheVenditaNav2009.HelloWorldResponse_element();
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element InserisciRigheVenditaITNET_element = new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element();
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element InserisciRigheVenditaLibero_element = new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element();
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLiberoResponse_element InserisciRigheVenditaLiberoResponse_element = new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLiberoResponse_element();
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNETResponse_element InserisciRigheVenditaITNETResponse_element = new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNETResponse_element();
        
        NavisionManageRigheVenditaNav2009.ManageRigheVenditeSoap soap  = new NavisionManageRigheVenditaNav2009.ManageRigheVenditeSoap();
        try{
            soap.InserisciRigheVenditaITNET(new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element());
        }catch(Exception e){}
        try{
            soap.InserisciRigheVenditaLibero(new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element());
        }catch(Exception e){}
        try{
            soap.HelloWorld();
        }catch(Exception e){}
    }
    
    public static testMethod void NavisionManageCheckTicketsNav2009(){
      NavisionManageCheckTicketsNav2009 n = new NavisionManageCheckTicketsNav2009();
      NavisionManageCheckTicketsNav2009.Ticket ticket = new NavisionManageCheckTicketsNav2009.Ticket();
      NavisionManageCheckTicketsNav2009.TicketList ticketList = new NavisionManageCheckTicketsNav2009.TicketList();
      NavisionManageCheckTicketsNav2009.CheckTicketsLibero_element libEl = new NavisionManageCheckTicketsNav2009.CheckTicketsLibero_element();
      NavisionManageCheckTicketsNav2009.CheckTicketsLiberoResponse_element libResp = new NavisionManageCheckTicketsNav2009.CheckTicketsLiberoResponse_element();
      NavisionManageCheckTicketsNav2009.CheckTicketsItnet_element itnetEl = new NavisionManageCheckTicketsNav2009.CheckTicketsItnet_element();
      NavisionManageCheckTicketsNav2009.CheckTicketsItnetResponse_element itnetResp = new NavisionManageCheckTicketsNav2009.CheckTicketsItnetResponse_element();
      NavisionManageCheckTicketsNav2009.ManageCheckTicketsSoap soap = new NavisionManageCheckTicketsNav2009.ManageCheckTicketsSoap();
      try{
        soap.CheckTicketsLibero(ticketList);
      }catch(Exception e){}
      try{
        soap.CheckTicketsItnet(ticketList);
      }catch(Exception e){}
    }
    
}