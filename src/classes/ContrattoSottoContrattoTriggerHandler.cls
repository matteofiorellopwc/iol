public class ContrattoSottoContrattoTriggerHandler{
    public static map<id,sottoContratto__c> scToClose;
    public static map<id,sottoContratto__c> scToSuspend;
    public static map<id,Contratto__c> cToClose;
    public static map<id,Contratto__c> cToSuspend;
    
    static{
        scToClose = new map<id,sottoContratto__c>();
        scToSuspend = new map<id,sottoContratto__c>();
        cToClose = new map<id,Contratto__c>();
        cToSuspend = new map<id,Contratto__c>();
    }
}