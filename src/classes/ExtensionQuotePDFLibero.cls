public class ExtensionQuotePDFLibero {
    public list<lineitem__c> lineitems {get;set;}
    public list<pacchetto_combo_opportunity__c> pacchetti {get;set;}

    public ExtensionQuotePDFLibero(ApexPages.StandardController controller){
        Quote q = (quote)controller.getRecord();
        
        string whereClause = ' Opportunity__c = \''+q.opportunity.id+'\' ';
        whereClause += ' And  Pacchetto_Combo_Opportunity__c = null ';
        string query = Util.getFieldsSOQL('LineItem__c', whereClause, false,UtilityLineItemIntegration.getAdditionaFields(),false);
        lineitems = database.query(query);
        pacchetti = [select Nome_pacchetto__c,Data_fine__c,Data_inizio__c,Quantita_totale__c,Sconto__c,
                            Totale__c,Totale_net__c,Listino_formula__c,CPM_net__c,CPM_net_net__c from pacchetto_combo_opportunity__c where opportunity__c =: q.opportunity.id];
    }

}