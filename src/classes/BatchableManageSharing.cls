global class BatchableManageSharing implements Database.Batchable<SObject>, Database.Stateful {
    private Account[] accs; 
    private Map<Id, Id> oldCentroMediaOwnerMap = new Map<Id, Id>();
    private Boolean updateAll = false;

    private String query = 'SELECT Id,OwnerCentroMediaId__c,Centro_Media__c FROM Opportunity';
        
    public BatchableManageSharing(Account[] accs, Map<Id,Id> oldCentroMediaOwnerMap) {
        this.accs = accs;
        this.oldCentroMediaOwnerMap = oldCentroMediaOwnerMap;
        query += ' WHERE Centro_Media__c IN :accs OR AccountId IN :accs';
    }
    
    public BatchableManageSharing() {
        this.updateAll = true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        OpportunityTriggerHandler.manageSharing((Opportunity[]) scope, null, oldCentroMediaOwnerMap, updateAll);
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    
    //Testing
    static Account brand;
    static Account cm1;
    static Account cm2;
    static Opportunity o;
    
    static void createTestData() {
        Provincia__c prov = new Provincia__c(
            Name = 'Sondrio',
            Sigla__c = 'SO',
            Regione__c = 'Lombardia');
        insert prov;
                
        RecordType brandRT = [select Id from RecordType where DeveloperName = 'Brand' AND SobjectType = 'Account'];
        RecordType cmRT = [select Id from RecordType where DeveloperName = 'Centro_Media' AND SobjectType = 'Account'];
        
        brand = new Account(
            Name = 'Test Account',
            RecordTypeId = brandRT.Id,
            BillingStreet = 'via Dolzino 114',
            BillingCity = 'Sondrio',
            BillingState = 'SO',
            BillingPostalCode = '23022',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test Brand',
            Codice_fiscale__c = '80090012345');
        insert brand;
        
        cm1 = new Account(
            Name = 'Test CM',
            RecordTypeId = cmRT.Id,
            BillingStreet = 'via Dolzino 114',
            BillingCity = 'Sondrio',
            BillingState = 'SO',
            BillingPostalCode = '23022',
            Tipo_Centro_Media__c = 'Centro Media',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test CM',
            Codice_fiscale__c = '80090012346');
        insert cm1;        
        
        cm2 = new Account(
            Name = 'Test CM2',
            RecordTypeId = cmRT.Id,
            BillingStreet = 'via Dolzino 114',
            BillingCity = 'Sondrio',
            BillingState = 'SO',
            BillingPostalCode = '23022',
            Tipo_Centro_Media__c = 'Centro Media',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test CM2',
            Codice_fiscale__c = '80090012347');
        insert cm2;        
        
        //Test inserimento opp con centro media        
        o = new Opportunity(
            Name = 'Test',
            AccountId = brand.Id,
            Canale_di_vendita__c = 'CM',
            Centro_Media__c = cm1.Id,
            StageName = '0%',
            CloseDate = Date.today()
        );
        insert o;       
    }
    
    @isTest
    static void testSharing1() {        
        createTestData();
        
        //Test cambio centro media
        o.Centro_Media__c = cm2.Id;
        update o;
        
        //Test cambio owner centro media
        cm2 = [SELECT Id, OwnerId FROM Account WHERE Id = :cm2.Id];
        User u = [SELECT Id FROM User WHERE Id <> :cm2.OwnerId and isActive = true LIMIT 1];
        
        cm2.OwnerId = u.Id;
        Test.startTest();
        update cm2;
        Test.stopTest();
    }
    
    @isTest
    static void testSharing2() {
        createTestData();

        //Test oppTeamMemberr
        User u = [SELECT Id FROM User WHERE Id <> :cm2.OwnerId and isActive = true LIMIT 1];
        OpportunityTeamMember otm = new OpportunityTeamMember(
            OpportunityId = o.Id,
            UserId = u.Id
        );
        Test.startTest();
        insert otm;
        Test.stopTest();
    }
}