public class ExtensionMassImportAccount {

    public list<account> accounts {get;set;}
    recordType recordTypeBrand;
    recordType recordTypeCM;
    DfpIntegration dfp;
    map<id,account> accountMap;
    map<decimal,account> accountIdDfpMap;
    map<string,account> accountNameMap;
    public map<string,string> accountErrorMap{get;set;}
    string idSfdcList;
    string idDfpList;
    string nameList;
    
    public void init(){
        recordTypeBrand = [select id,developername from recordtype where sobjectType = 'Account' and developername = 'Brand'];
        recordTypeCM = [select id,developername from recordtype where sobjectType = 'Account' and developername = 'Centro_Media'];
        dfp = new DfpIntegration();
    }
    
    public ExtensionMassImportAccount(ApexPages.StandardSetController controller) {
        init();
        if(controller.getSelected().size() > 0){
            accounts = [select id,name,recordTypeId,Id_DFP__c,phone,fax,Description,Company_DFP_Type__c from account
                    where id in : controller.getSelected() and
                    (recordTypeId =: recordTypeBrand.id or recordTypeId =: recordTypeCM.id)
            ];
        }else{
            accounts = [select id,name,recordTypeId,Id_DFP__c,phone,fax,Description,Company_DFP_Type__c from account
                    where (recordTypeId =: recordTypeBrand.id or recordTypeId =: recordTypeCM.id)
            ];
        }
    }

    public class MassImportException extends Exception{}
    public void initMap(){
        accountMap = new map<id,account>();
        accountErrorMap = new map<string,string>();
        accountNameMap = new map<string,account>();
        accountIdDfpMap = new map<decimal,account>();
        idSfdcList = '';
        idDfpList = '';
        nameList = '';
        for(account a : accounts){
            accountErrorMap.put(a.id,'');
        }
        for(account a : accounts){
            idSfdcList += '\''+a.id+'\',';
            string s = a.name;
            s = s.replace('\'','\'\'');
            nameList += '\''+s+'\',';
            if(a.id_dfp__c != null && a.id_dfp__c > 0){
                idDfpList += ''+a.id_dfp__c+',';
                accountIdDfpMap.put(a.id_Dfp__c,a);
            }
            accountMap.put(a.id,a);
            if(accountNameMap.get(a.name) != null){
                throw new MassImportException('Trovato duplicato per anagrafica '+a.name);
            }
            accountNameMap.put(a.name.toLowerCase() ,a);
        }

        idSfdcList += ',';
        idSfdcList = idSfdcList.replace(',,','');
        idDfpList += ',';
        idDfpList = idDfpList.replace(',,','');
        nameList += ',';
        nameList = nameList.replace(',,','');        
    }
    
    public void findCompanies(){
        try{
            initMap();
            string query = 'WHERE externalid in ('+idSfdcList+') LIMIT 1000 OFFSET 0';   
            for(DfpCompanyService.Company c : getCompanies(query)){
                accountMap.get(c.externalid).id_dfp__c = c.id;
                accountMap.get(c.externalid).Company_DFP_Type__c = c.type_x;            
            }
            update accounts;
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }
    
    public void findCompaniesByName(){
        try{
            initMap();
            string query = 'WHERE name in ('+nameList+') LIMIT 1000 OFFSET 0';   
            for(DfpCompanyService.Company c : getCompanies(query)){
                if(accountNameMap.get(c.name.toLowerCase()) != null){
	                if(accountNameMap.get(c.name.toLowerCase()).id_dfp__c == null || accountNameMap.get(c.name.toLowerCase()) .id_dfp__c <= 0){
	                    accountNameMap.get(c.name.toLowerCase()).id_dfp__c = c.id;
	                    accountNameMap.get(c.name.toLowerCase()).Company_DFP_Type__c = c.type_x;
	                }
                }else{
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,c.name+' non è stato trovato e verrà ignorato'));
                }
            }
            update accounts;
            system.debug(accounts);
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }    
    
    public void updateCompanies(){
        try{
            initMap();
            string query = 'WHERE id in ('+idDfpList+') LIMIT 1000 OFFSET 0';   
            list<DfpCompanyService.Company> companiesToUpdate = getCompanies(query);
            for(DfpCompanyService.Company c : companiesToUpdate){
                syncAccountCompany(accountIdDfpMap.get(c.id),c);
            }
            dfp.companyService.updateCompanies(companiesToUpdate);
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }        
    
    public void createCompanies(){
        string whereError = '';
        list<DfpCompanyService.Company> companiesToInsert;
        try{
            initMap();
            companiesToInsert = new list<DfpCompanyService.Company>();
            for(account a : accounts){
                if(a.id_dfp__c == null || a.id_dfp__c <= 0){
                    DfpCompanyService.Company c = new DfpCompanyService.Company();
                    syncAccountCompany(a,c);
                    companiesToInsert.add(c);
                }
            }
            whereError = 'createCompany';
            companiesToInsert = dfp.companyService.createCompanies(companiesToInsert);
            for(DfpCompanyService.Company c : companiesToInsert){
                accountMap.get(c.externalid).id_dfp__c = c.id;
                accountMap.get(c.externalid).Company_DFP_Type__c = c.Type_x;
            }
            whereError = 'updateAccounts';
            update accounts;
        }catch(exception e){
            string error = '';
            for(UtilExceptionIntegration.FriendlyMessage fm : UtilExceptionIntegration.getFriendlyMessage(e.getMessage())){
                if(fm.index >= 0){
                    if(whereError == 'createCompany'){
                        accountErrorMap.put(companiesToInsert[fm.index].externalid,fm.message);
                        error += '<a href="/'+companiesToInsert[fm.index].externalid+'">'+companiesToInsert[fm.index].name+'</a> ';
                    }
                    if(whereError == 'updateAccounts'){
                        accountErrorMap.put(accounts[fm.index].id,fm.message);
                        error += '<a href="/'+accounts[fm.index].id+'">'+accounts[fm.index].name+'</a> ';
                    }
                }
                error += fm.message+'<br />';
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione:<br />'+error));
        }
    }
    
    
    public list<DfpCompanyService.Company> getCompanies(string query){
        DfpCompanyService.Statement filterStatement = new DfpCompanyService.Statement();
        filterStatement.query = query;
        system.debug(query);
        DfpCompanyService.CompanyPage companyPage = dfp.companyService.getCompaniesByStatement(filterStatement);
        return companyPage.results;
    }
    
    public void syncAccountCompany(account a,DfpCompanyService.Company company){
        company.Name = a.Name;
        company.externalId = a.id;
        if(a.recordTypeId == recordTypeBrand.id){
            company.Type_x = 'ADVERTISER';
        }else if(a.recordTypeId == recordTypeCM.id){
            company.Type_x = 'AGENCY';
        }
        /*
        company.primaryPhone = a.Phone;
        company.faxPhone = a.fax;
        company.comment = a.description;
        */
    }
    
    public static testMethod void testExtensionMassImportAccount(){
        recordtype recordTypeBrand = [select id,developername from recordtype where sobjectType = 'Account' and developername = 'Brand'];
        Provincia__c p = new Provincia__c(Name='test',Sigla__c='tes',Regione__c='test');
        insert p;
        Account a = new account(Name='test',billingState = 'tes',shippingState='tes',recordTypeid=recordTypeBrand.id);
        insert a;        
        ExtensionMassImportAccount ext = new ExtensionMassImportAccount(new ApexPages.StandardSetController(new list<account>{a}));
        ext.createCompanies();
        ext.findCompanies();
        ext.findCompaniesByName();
        ext.updateCompanies();
    }
        
}