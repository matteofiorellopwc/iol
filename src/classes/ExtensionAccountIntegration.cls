public class ExtensionAccountIntegration {
    public Account a {get;set;}
    public Boolean successDfp {get;set;}
    public Boolean successOas {get;set;}

    public ExtensionAccountIntegration(ApexPages.StandardController controller) {
        a = [select id,name,fax,phone,description,id_dfp__c,recordTypeId,
                    id_oas__c,oasType__c,Codice_fatturazione_Autonumber__c
             from account 
             where id =: controller.getId()];      
        successDfp = false;
        successOas = false;
    }
    
    public void upsertCompanyDfp(){
        try{    
            DfpIntegration dfp = new DfpIntegration();
            RecordType accountRecordType = [select id,developername from recordtype where id =: a.recordTypeId];
            DfpCompanyService.Statement filterStatement = new DfpCompanyService.Statement();
            filterStatement.query = 'WHERE (id = \''+a.id_dfp__c+'\' OR Name = \'' + a.Name.replace('\'','\'\'') + '\') LIMIT 500 OFFSET 0';
            DfpCompanyService.CompanyPage companyPage = dfp.companyService.getCompaniesByStatement(filterStatement);
            DfpCompanyService.Company company = new DfpCompanyService.Company();
            if(companyPage.totalResultSetSize == 1){
                company = companyPage.results[0];
            }
            company.Name = a.Name;
            company.externalId = a.id;
            company.primaryPhone = a.Phone;
            company.faxPhone = a.fax;
            if(accountRecordType.developername == 'Brand'){
                company.Type_x = 'ADVERTISER';
            }else{
                company.Type_x = 'AGENCY';
            }
            company.comment = a.description;
            
            DfpCompanyService.Company c;
            if(company.id != null){
                company = dfp.companyService.updateCompanies(new DfpCompanyService.Company[]{company})[0];
            }else{
                company.creditStatus = 'ACTIVE';
                company = dfp.companyService.createCompanies(new DfpCompanyService.Company[]{company})[0];
            }
            
            a.Company_DFP_Type__c = company.Type_x;
            a.id_dfp__c = company.id;
            update a;
            successDfp = true;
        }catch(Exception e){
            successDfp = false;
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                error += fm.message+'<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione:<br />'+error));
        }
    }
    
    public void upsertCompanyOas(){
        OasIntegration oas = new OasIntegration();
        String operation = 'update';
        if(a.id_oas__c == null){
            operation = 'add';
            //id oas limits 64 chars 
            a.id_oas__c = 'NIU_'; //4 chars
            a.id_oas__c += deleteSpecialCharsId(a.name); //max 59 chars
            a.id_oas__c = a.id_oas__c.left(53);
            a.id_oas__c += '_'+ a.Codice_fatturazione_Autonumber__c; //11 chars
        }
        try {
            String name = a.name;
            a.name = deleteSpecialChars(a.name);
            oas.syncAcc(a,operation);
            a.name = name;
            update a;
            successOas = true;
        }
        catch(Exception e) {
            successOas = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione'+e.getMessage()));
        }
    }
    
    private string deleteSpecialChars(String s){
        return s.replace('\'','').replace('"','').replace('/','').replace('&','').replace(',','');
    }
    
    private string deleteSpecialCharsId(String s){
        return deleteSpecialChars(s).replace(' ','');
    }    
    
    //EXCEPTION
    public class ExtensionAccountIntegrationException extends Exception{ }

}