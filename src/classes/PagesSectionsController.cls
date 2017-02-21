public class PagesSectionsController{
    
    public String sobjectName{get;set;} //LineItem__c or Product__c
    public Id sobjectId {get;set;} //Id del prodotto
    public List<Inventory_Target__c> itL {get;set;} //Pagine già incluse nel prodotto
    public List<Inventory_Target__c> itExL {get;set;} //Pagine già escluse dal prodotto
    public List<SectionOasTargeted__c> sotL {get;set;} //Sezioni già incluse nel prodotto
    public List<SectionOasTargeted> sotWL {get;set;} //Sezioni già incluse nel prodotto (Wrapper)
    
	/* Split di adUnitL in due parti. Serve perché il numero di pagine supera il limite di 1000 elementi  */
    public List<AdUnit> adUnitL1 {get;set;}
    public List<AdUnit> adUnitL2 {get;set;}
    
    /* Split di adUnitExL in due parti. Serve perché il numero di pagine supera il limite di 1000 elementi  */
    public List<AdUnit> adUnitExL1 {get;set;}
    public List<AdUnit> adUnitExL2 {get;set;}
    
    public List<SectionOas> sectionOasL {get;set;} //Sezioni disponibili
    public List<AdUnit> pagesInSection {get;set;} //Pagine che possono venire escluse da una sezione
    public Boolean showPagesInSection {get;set;}
    
    public Id selectedInventoryTarget {get;set;}
    public Id selectedInventoryTargetEx {get;set;}
    public Id selectedSectionOasTargeted {get;set;}
    public Id selectedSectionOas {get;set;}
    public Id selectedExcludedPage {get;set;}
    public Boolean error {get;set;}

    //Costruttore
    public PagesSectionsController() {
        try {
            this.sobjectId = ApexPages.CurrentPage().getParameters().get('id');
            this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
            if(sobjectId == null) {
                throw new MyException('Invalid id');
            }
            if(sobjectName == null) {
                throw new MyException('Invalid sobjectName');
            }
            
            retrievePages();
            retrievePagesEx();
            retrieveSections();
            this.showPagesInSection = false;
            this.error = false;
        }
        catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addmessage(myMsg);  
            this.error = true;      
        }      
    }
    
    //Include le pagine in un prodotto/line-item
    public void includePages() {
        this.itL = new List<Inventory_Target__c>();
        for(AdUnit au : adUnitL1) {
            if(au.checked) {
                Inventory_Target__c it = new Inventory_Target__c();
                it.put(sobjectName, sobjectId);
                it.Ad_Unit__c = au.adUnit.Id;
                it.InventoryTargetingType__c = 'targeted';
                itL.add(it);
            }           
        }
        
        for(AdUnit au : adUnitL2) {
            if(au.checked) {
                Inventory_Target__c it = new Inventory_Target__c();
                it.put(sobjectName, sobjectId);
                it.Ad_Unit__c = au.adUnit.Id;
                it.InventoryTargetingType__c = 'targeted';
                itL.add(it);
            }           
        }
        insert itL;
        retrievePages();        
    }
    
    //Esclude le pagine da un prodotto/line-item
    public void excludePages() {
        this.itExL = new List<Inventory_Target__c>();
        for(AdUnit auEx : adUnitExL1) {
            if(auEx.checked) {
                Inventory_Target__c itEx = new Inventory_Target__c();
                itEx.put(sobjectName, sobjectId);
                itEx.Ad_Unit__c = auEx.adUnit.Id;
                itEx.InventoryTargetingType__c = 'excluded';
                itExL.add(itEx);
            }           
        }
        
        for(AdUnit auEx : adUnitExL2) {
            if(auEx.checked) {
                Inventory_Target__c itEx = new Inventory_Target__c();
                itEx.put(sobjectName, sobjectId);
                itEx.Ad_Unit__c = auEx.adUnit.Id;
                itEx.InventoryTargetingType__c = 'excluded';
                itExL.add(itEx);
            }           
        }
        
        insert itExL;
        retrievePagesEx();        
    }
    
    public void removePages() {
        Inventory_Target__c it = [SELECT Name FROM Inventory_Target__c WHERE Id =:selectedInventoryTarget];
        delete it;
        retrievePages();        
    }
    
    public void removePagesEx() {
        Inventory_Target__c itEx = [SELECT Name FROM Inventory_Target__c WHERE Id =:selectedInventoryTargetEx];
        delete itEx;
        retrievePagesEx();        
    }
    
    // Recupera le pagine associate al prodotto e le pagine disponibili
    private void retrievePages() {      
        this.itL = [SELECT Name, Ad_Unit__r.Name FROM Inventory_Target__c WHERE (Product__c = :sobjectId OR LineItem__c = :sobjectId)  AND InventoryTargetingType__c = 'targeted'];
        
        //Set di pagine già incluse nel prodotto
        Set<Id> pagesIncludedId = new Set<Id>();
        for (Inventory_Target__c it : itL) {
            pagesIncludedId.add(it.Ad_Unit__c);     
        }
                
        this.adUnitL1 = new List<AdUnit>();
        this.adUnitL2 = new List<AdUnit>();
        Integer i = 0;
        
        for (AdUnit__c au : [SELECT Name FROM AdUnit__c WHERE PageOAS__c != null AND Id NOT IN :pagesIncludedId]) {
            AdUnit auTmp = new AdUnit();
            auTmp.adUnit = au;
            auTmp.checked = false;
            if(i < 1000) {
                adUnitL1.add(auTmp);
            } else {
            	adUnitL2.add(auTmp);    
            }
            i++;
        }
    }
    
    // Recupera le pagine escluse associate al prodotto e le pagine disponibili per l'esclusione
    private void retrievePagesEx() {      
        this.itExL = [SELECT Name, Ad_Unit__r.Name, SectionOas__c FROM Inventory_Target__c WHERE (Product__c = :sobjectId OR LineItem__c = :sobjectId)
                      AND InventoryTargetingType__c = 'excluded' AND SectionOas__c = ''];
        
        //Set di pagine già escluse dal prodotto
        Set<Id> pagesExcludedId = new Set<Id>();
        for (Inventory_Target__c itEx : itExL) {
            pagesExcludedId.add(itEx.Ad_Unit__c);     
        }
                
        this.adUnitExL1 = new List<AdUnit>();
        this.adUnitExL2 = new List<AdUnit>();
        Integer i = 0;
        
        for (AdUnit__c auEx : [SELECT Name FROM AdUnit__c WHERE PageOAS__c != null AND Id NOT IN :pagesExcludedId]) {
            AdUnit auExTmp = new AdUnit();
            auExTmp.adUnit = auEx;
            auExTmp.checked = false;
            if(i < 1000) {
                adUnitExL1.add(auExTmp);
            } else {
            	adUnitExL2.add(auExTmp);    
            }
            i++;
        }
    }
    
    public void includeSections() {
        this.sotL = new List<SectionOasTargeted__c>();
        for(SectionOas so : sectionOasL) {
            if(so.checked) {
                SectionOasTargeted__c sot = new SectionOasTargeted__c();
                sot.put(sobjectName, sobjectId);    
                sot.SectionOas__c = so.sectionOas.Id;
                sotL.add(sot);
            }           
        }
        insert sotL;
        retrieveSections();     
    }
    
    public void removeSections() {
        SectionOasTargeted__c sot = [SELECT Name FROM SectionOasTargeted__c WHERE Id =:selectedSectionOasTargeted];
        
        //Lista d'inventory target da rimuovere (pagine escluse)
        List<Inventory_Target__c> invertoryTargetToDelete = new List<Inventory_Target__c>();
        for(SectionOasTargeted sotW : sotWL) {
            if(sotW.sectionOasTargeted.Id == selectedSectionOasTargeted) {
                invertoryTargetToDelete = sotW.exludedPages;
            }
        }
        
        delete invertoryTargetToDelete;
        delete sot;
        retrieveSections();     
    }
    
    // Recupera le sezioni associate al prodotto e le sezioni disponibili
    private void retrieveSections() {
        this.sotL = [SELECT Name, SectionOAS__r.Name FROM SectionOasTargeted__c WHERE Product__c = :sobjectId OR LineItem__c = :sobjectId];
        
        //Set di ID delle sezioni già incluse nel prodotto
        Set<Id> sectionsIncludedId = new Set<Id>();
        for (SectionOasTargeted__c sot : sotL) {
            sectionsIncludedId.add(sot.SectionOAS__c);      
        }
        
        Map<Id, SectionOas__c> sectionsMap = new Map<Id, SectionOas__c>(
            [SELECT Name, (SELECT Name, Ad_Unit__r.Name, Product__c, LineItem__c FROM Inventory_Target__r WHERE Product__c = :sobjectId OR LineItem__c = :sobjectId)
            FROM SectionOas__c WHERE Id IN :sectionsIncludedId]
        );
        
        //Sezioni disponibili
        this.sectionOasL = new List<SectionOas>();
        for (SectionOas__c so : [SELECT Name FROM SectionOas__c WHERE Id NOT IN :sectionsIncludedId]) {
            SectionOas soTmp = new SectionOas();
            soTmp.sectionOas = so;
            soTmp.checked = false;
            sectionOasL.add(soTmp);
        }
        
        //Sezioni già incluse nel prodotto (wrapper)
        this.sotWL = new List<SectionOasTargeted>();
        for (SectionOasTargeted__c sot : sotL) {
            SectionOasTargeted sotTmp = new SectionOasTargeted();
            sotTmp.sectionOasTargeted = sot;
            sotTmp.exludedPages = sectionsMap.get(sot.SectionOas__c).Inventory_Target__r;
            sotWL.add(sotTmp);
        }        
    }
    
    public void showPagesInSection() {
        try {
            String pages = [SELECT SectionOas__r.Pages__c FROM SectionOasTargeted__c WHERE Id =:selectedSectionOasTargeted].SectionOas__r.Pages__c;
            List<String> pagesL = pages.split('\n');
            
            //Id delle pagine già escluse
            Set<Id> excludedPagesId = new Set<Id>();
            for(Inventory_Target__c it : [SELECT Ad_Unit__c, Ad_Unit__r.Name FROM Inventory_Target__c WHERE SectionOas__c = :selectedSectionOas AND (Product__c = :sobjectId OR LineItem__c = :sobjectId) AND InventoryTargetingType__c = 'excluded']){
                excludedPagesId.add(it.Ad_Unit__c);                                 
            }
            
            this.pagesInSection = new List<AdUnit>();
            for (AdUnit__c au : [SELECT Name FROM AdUnit__c WHERE Name IN :pagesL AND Id NOT IN :excludedPagesId]) {
                AdUnit auTmp = new AdUnit();
                auTmp.adUnit = au;
                auTmp.checked = false;
                pagesInSection.add(auTmp);
            }
            this.showPagesInSection = true;         
        }
        catch (Exception e) {
            this.pagesInSection = new List<AdUnit>();
            this.showPagesInSection = true;     
        }                       
    }
    
    public void hidePagesInSection(){
        this.showPagesInSection = false;    
    }
    
    public void excludePagesInSection() {
        List<Inventory_Target__c> itL = new List<Inventory_Target__c>();
        for(AdUnit pis : pagesInSection) {
            if(pis.checked) {
                Inventory_Target__c it = new Inventory_Target__c();
                it.SectionOas__c = selectedSectionOas;
                it.put(sobjectName, sobjectId); 
                it.Ad_Unit__c = pis.adUnit.Id;
                it.InventoryTargetingType__c = 'excluded';
                itL.add(it);
            }           
        }
        insert itL;
        retrieveSections();
        hidePagesInSection();  
    }
    
    public void removeExcludePagesInSection() {
        Inventory_Target__c it = [SELECT Name FROM Inventory_Target__c WHERE Id =:selectedExcludedPage];
        delete it;
        retrieveSections();     
    }
    
    //AdUnit__c Wrapper Class
    public class AdUnit{
        public AdUnit__c adUnit {get;set;}
        public boolean checked {get;set;}
    }
    
    //SectionOas__c Wrapper Class
    public class SectionOas{
        public SectionOas__c sectionOas {get;set;}
        public boolean checked {get;set;}
    }
    
    //SectionOasTargeted__c Wrapper Class
    public class SectionOasTargeted{
        public SectionOasTargeted__c sectionOasTargeted {get;set;}
        public List<Inventory_Target__c> exludedPages {get;set;}
    } 
    
    //Exception Class
    public class MyException extends Exception {}
}