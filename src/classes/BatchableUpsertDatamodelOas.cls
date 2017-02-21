/*
    This class upsert pages and sections from OAS.
*/

global class BatchableUpsertDatamodelOas implements Database.AllowsCallouts,Database.Batchable<SObject> {
    
    /*
        Select all pages and sections from OAS and save them in AdUnit__c and SectionOas__c.
    */
    public static void getPagesSection(){
        OasIntegration oas = new OasIntegration();
        OasApiProxy.getResponses = false; //to skip
        adUnit__c[] pages = new adUnit__c[]{};
        string res = '';
        
        integer index = 1;
        integer pagesize = 1000;
        boolean stop = false;
        do{
            try{
                res = oas.listPages(index);
            }catch(exception e){
                res = '';
                stop = true;
            }
            string[] urls = OasApiXmlUtility.getEnityListRegex(res,'Url');
            for(string s : urls){
                pages.add(
                    new adUnit__c(
                        Name = s,
                        PageOAS__c = s,
                        HideAdUnit__c = true
                    )
                );
            }
            if(urls.size() >= pageSize){
                index++;
            }else{
                stop = true;
            }
        }while(!stop);
        
        
        res = oas.listSections();
        sectionOas__c[] sections = new sectionOas__c[]{};
        for(string s : OasApiXmlUtility.getEnityListRegex(res,'Id')){
            sections.add(
                new sectionOas__c(
                    Name = s,
                    idOas__c = s
                )
            );
        }

        upsert pages PageOas__c;
        upsert sections idOas__c;      
    }

    /*
        We need a batch because is not possible read all sections and directly get the pages associated,
        so for each section we make a callout
    */
    global list<SObject> start(Database.BatchableContext BC) {
        return [select idOas__c,Pages__c from sectionOas__c];    
    }

    global void execute(Database.BatchableContext BC, Object[] scope) {
        OasIntegration oas = new OasIntegration();
        list<sectionOas__c> ss = (list<sectionOas__c>) scope;
        for(sectionOas__c s : ss){
            string res = oas.readSectionById(s.idOas__c);
            list<string> pages = OasApiXmlUtility.getEnityListRegex(res,'Url');
            s.pages__c = String.join(pages,'\n');
        }
        
        update ss;
    }
    
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
/*
    READ SECTION RESPONSE
    <Response>
      <Section>
        <Id>SectionName</Id>
        <Pages>
          <Url>testtelnext.site.it/Sport/Home</Url>
          <Url>testtelnext.site.it/Sport/Tennis</Url>
        </Pages>
        <InternalQuickReport>to-date</InternalQuickReport>
        <ExternalQuickReport>short</ExternalQuickReport>
        <WhoCreated>realmedia</WhoCreated>
        <WhenCreated>02/20/2013 00:00:00</WhenCreated>
        <WhoModified>mpanzeri</WhoModified>
        <WhenModified>04/22/2013 10:47:24</WhenModified>
      </Section>
    </Response>
*/
    
}