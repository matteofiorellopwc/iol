public with sharing class ExtensionInvestimentiAnni {
    public map<String,String> investimenti {get;set;}
    public list<string> anni {get;set;}

    public ExtensionInvestimentiAnni(ApexPages.StandardController controller) {
        investimenti = new map<String,String>();
        anni = new list<string>();
        id accId = controller.getId();
        for(integer i = 2010;i<2020;i++){
            investimenti.put(i+'','no');
            //anni.add(i+'');
        }
        for(integer i = 2010;i<2015;i++){
            anni.add(i+'');
            anni.add(i+5+'');
        }        
        for(opportunity o : [select Anno_chiusura__c from opportunity where AccountId =: accId and isWon = true]){
            investimenti.put(o.Anno_chiusura__c,'si');
        }
    }

}