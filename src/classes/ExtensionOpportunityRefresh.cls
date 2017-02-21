public class ExtensionOpportunityRefresh {
    id oppid;
    public ExtensionOpportunityRefresh(ApexPages.StandardController controller) {
        oppid = controller.getId();
    }
    
    public PageReference refresh(){
        Pagereference p = new Pagereference('/'+oppid+'?nooverride=1');
        p.setRedirect(true);
        return p;
    }

}