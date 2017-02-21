public class ControllerMiniLineItem {
    
    public lineitem__c li {get;set;}
    public String adUnitIncluded {get;private set;}
    public String adUnitExcluded {get;private set;}

    public ControllerMiniLineItem(){
        li = [SELECT
            id,
            name,
            opportunity__r.name,
            opportunity__r.venditore__c,
            opportunity__r.stageName,
            start_date__c,
            end_date__c,
            Prezzo_net_net__c,
            quantita__c,
            goal__c,
            totale__c,
            product__c,
            (SELECT Path__c, inventoryTargetingType__c FROM Inventory_Target__r)
            FROM lineitem__c 
            WHERE id =: ApexPages.currentPage().getParameters().get('id')
        ];

        adUnitIncluded = '';
        adUnitExcluded = '';
        for(Inventory_Target__c it : li.Inventory_Target__r) {
            if(it.inventoryTargetingType__c == 'targeted') {
                adUnitIncluded += '- ' + it.Path__c.escapeHtml4() + '<br/>';
            } else if(it.inventoryTargetingType__c == 'excluded') {
                adUnitExcluded += '- ' + it.Path__c.escapeHtml4() + '<br/>';
            }
        }
    }
    
    public static testMethod void testControllerMiniLineItem(){
        Opportunity o = new Opportunity();
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        lineitem__c li = new lineitem__c(opportunity__c=o.id);
        insert li;
        ApexPages.currentPage().getParameters().put('id',li.id);
        ControllerMiniLineItem c = new ControllerMiniLineItem();
    }

}