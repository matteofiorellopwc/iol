@isTest
private class PagesSectionsControllerTest {

    static testMethod void myUnitTest() {
        //Crea prodotto
        Product2 prod = new Product2(Name = 'Test1', Family = 'Banner');
        insert prod;
        //Crea pagine
        AdUnit__c pag1 = new AdUnit__c(Name = 'testtelnext.virgilio.it/Sport/Altro', PageOAS__c = 'testtelnext.virgilio.it/Sport/Altro'); 
        AdUnit__c pag2 = new AdUnit__c(Name = 'testtelnext.virgilio.it/Sport/Calcio', PageOAS__c = 'testtelnext.virgilio.it/Sport/Calcio');
        AdUnit__c pag3 = new AdUnit__c(Name = 'testtelnext.virgilio.it/Musica/Altro', PageOAS__c = 'testtelnext.virgilio.it/Musica/Altro'); 
        AdUnit__c pag4 = new AdUnit__c(Name = 'testtelnext.virgilio.it/Musica/Home', PageOAS__c = 'testtelnext.virgilio.it/Musica/Home');
        insert pag1;
        insert pag2;
        insert pag3;
        insert pag4;
        //Crea sezioni
        SectionOas__c sec1 = new SectionOas__c(Name = 'Sports', idOas__c = '11111', Pages__c = 'testtelnext.virgilio.it/Sport/Altro\ntesttelnext.virgilio.it/Sport/Calcio');
        SectionOas__c sec2 = new SectionOas__c(Name = 'Music', idOas__c = '22222', Pages__c = 'testtelnext.virgilio.it/Musica/Altro\ntesttelnext.virgilio.it/Musica/Home');
        insert sec1;
        insert sec2;

        //Aggiungi una sezione ad un prodotto
        SectionOasTargeted__c sot = new SectionOasTargeted__c(Product__c = prod.Id, SectionOas__c = sec2.Id);
        
    	PageReference testPage = Page.PagesSections;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        ApexPages.currentPage().getParameters().put('sobjectName', 'Product__c');
        PagesSectionsController controller = new PagesSectionsController();
        
        //Includi una pagina
        controller.adUnitL1[0].checked = true;
        controller.includePages();
        System.assertEquals(controller.itL.size(), 1);
        
        //Rimuovi dall'inclusione una pagina
        controller.selectedInventoryTarget = controller.itL[0].Id;
        controller.removePages();
        System.assertEquals(controller.itL.size(), 0);
        
        //Escludi una pagina
        controller.adUnitExL1[0].checked = true;
        controller.excludePages();
        System.assertEquals(controller.itExL.size(), 1);
        
        //Rimuovi dall'esclusione una pagina
        controller.selectedInventoryTargetEx = controller.itExL[0].Id;
        controller.removePagesEx();
        System.assertEquals(controller.itExL.size(), 0);
        
        //Aggiungi due sezioni
        controller.sectionOasL[0].checked = true;
        controller.sectionOasL[1].checked = true;
        controller.includeSections();
        System.assertEquals(controller.sotWL.size(), 2);
        
        //Rimuovi una sezione
        controller.selectedSectionOasTargeted = controller.sotWL[1].sectionOasTargeted.Id;
        controller.removeSections();
        System.assertEquals(controller.sotWL.size(), 1);
        
        //Mostra le pagine di una sezione ed escludine una
        controller.selectedSectionOasTargeted = controller.sotWL[0].sectionOasTargeted.Id;
        controller.selectedSectionOas = controller.sotWL[0].sectionOasTargeted.SectionOas__c;
        controller.showPagesInSection();
        controller.pagesInSection[0].checked = true;
        controller.excludePagesInSection();
        System.assertEquals(controller.sotWL[0].exludedPages.size(), 1);
        
        //Mostra le pagine di una sezione ed clicca sul pulsante annulla
        controller.selectedSectionOasTargeted = controller.sotWL[0].sectionOasTargeted.Id;
        controller.selectedSectionOas = controller.sotWL[0].sectionOasTargeted.SectionOas__c;
        controller.showPagesInSection();
        controller.hidePagesInSection();
        System.assertEquals(controller.sotWL[0].exludedPages.size(), 1);
        System.assertEquals(controller.showPagesInSection, false);
        
        //Reincludi la pagina precedentemente esclusa
        controller.selectedExcludedPage = controller.sotWL[0].exludedPages[0].Id;
        controller.removeExcludePagesInSection();
        System.assertEquals(controller.sotWL[0].exludedPages.size(), 0);
    }        
}