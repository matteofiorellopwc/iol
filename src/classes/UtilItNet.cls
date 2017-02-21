public class UtilItNet{

    public static final Id itNetAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente ItNet').getRecordTypeId();
    public static final Id itNetProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('ItNet').getRecordTypeId();

    public static id checkListini(string canale_di_vendita,date data_decorrenza,list<rigalistino__c> righelistini){
        system.debug('canale_di_vendita = '+canale_di_vendita);
        system.debug('data_decorrenza = '+data_decorrenza);
        system.debug('righelistini = '+righelistini);
        for(rigalistino__c l : righelistini){
            if(l.listino__r.canale_di_vendita__c == canale_di_vendita && data_decorrenza >= l.Data_inizio_validita__c && (data_decorrenza <= l.Data_fine_validita__c || l.Data_fine_validita__c == null)){
                return l.id;                
            }
        }
        return null;
    }

}