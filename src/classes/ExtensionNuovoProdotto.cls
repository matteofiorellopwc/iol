public class ExtensionNuovoProdotto {

    public ExtensionNuovoProdotto(ApexPages.StandardController controller) {

    }
    
    public PageReference overrideNome(){
        PageReference p = new PageReference('/01t/e');
        Map<string,string> currentParams = ApexPages.CurrentPage().getParameters();
        for(String s : currentParams.keySet()){
            system.debug(s);
            if(s != 'sfdc.override' && s != 'save_new'){
                p.getParameters().put(s,currentParams.get(s));
            }
        }
        p.getParameters().put('Name','Nuovo prodotto');
        p.getParameters().put('nooverride','1');
        return p;
    }
    
    public static testMethod void testExtensionNuovoProdotto(){
        ExtensionNuovoProdotto ext = new ExtensionNuovoProdotto(null);
        ext.overrideNome();
    }

}