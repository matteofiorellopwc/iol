public class ControllerTestCreationTicket {

    public opportunity o {get;set;}
    
    public ControllerTestCreationTicket(){
        o = new opportunity();
    }
    
    public void creaTicket(){
        ScheduledTicketCreation stc = new ScheduledTicketCreation();
        stc.createTickets(o.closeDate);
    }
    static testMethod void myTest() {
    	
    	ControllerTestCreationTicket c= new ControllerTestCreationTicket();
    	c.o.closeDate=Date.today();
    	c.creaTicket();
    	System.assertEquals(c.o.closeDate,Date.today());
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
     }
    
}