public class BatchableAssociateOrderCampaignsOAS implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    private string errors = '';
    private string query = 'select id,id_oas__c,(select id_oas__c from Line_Items__r where id_oas__c <> null and (not id_oas__c like \'%_nosincro\')) from opportunity where id_oas__c <> null ';
    private list<id> oppIds;
    
    public BatchableAssociateOrderCampaignsOAS(){
        
    }
    
    public BatchableAssociateOrderCampaignsOAS(list<id> oppIds){
        this.oppIds = oppIds;
        query += ' and id in : oppIds';
    }
    
    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext ctx, List<Opportunity> scope) {
        String addUpdateIo = '<Request type="InsertionOrder">'+
                                 '<InsertionOrder action="update">'+ 
                                     '<Id>@@ID@@</Id>'+
                                     '<Campaigns>@@CAMPAIGNS@@</Campaigns>' + //<CampaignId>campid</CampaignId>
                                 '</InsertionOrder>'+
                             '</Request>';        

        OasIntegration oas = new OasIntegration();
                                    
        for(Opportunity o : scope){
            set<string> lis = new set<string>();
            for(lineitem__c li : o.line_items__r){
                lis.add(li.id_oas__c);
            }
        
            set<string> camps = new set<string>();
            for(oasIntegration.campaignClass c : oas.getCampaignClass(oas.listCampaignsByOrderId(o.id_oas__c))){
                camps.add(c.id);
            }
            
            system.debug('id order = '+o.id_oas__c + ', SF = ' + lis +', OAS = ' + camps + '\n');
            
            if(!camps.containsAll(lis)){
                errors += 'id order = '+o.id_oas__c + ', SF = ' + lis +', OAS = ' + camps + '\n';
            }
        }
    }
    
    public void finish(Database.BatchableContext ctx) {
        string filename = 'check associazione ordini campagne oas.csv';
        delete [SELECT Id FROM Document WHERE Name = : filename AND FolderId = :UserInfo.getUserId()];
        Document d = new Document();
        d.Name = filename;
        d.folderId = UserInfo.getUserId();
        d.body = Blob.valueOf(errors);
        insert d;
    }



}