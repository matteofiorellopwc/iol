@isTest
public class ViewMultiReportTest{
    public static testMethod void testPrintReportController(){
        apexpages.currentpage().getparameters().put('id1','home/home.jsp');
        apexpages.currentpage().getparameters().put('id2','home/home.jsp');        
        ViewMultiReport c = new ViewMultiReport();  
        c.getReportContent();      
    }
}