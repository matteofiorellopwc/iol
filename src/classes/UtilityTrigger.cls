public class UtilityTrigger{

    public static boolean skipTrigger = false;

    public static list<lineitem__c> getLineItems(){
        set<id> lineItemsId = new set<id>();
        if(trigger.isInsert || trigger.isUpdate){
            for(sobject so : trigger.new){
                try{
                    lineItemsId.add((id)so.get('line_item__c'));
                }catch(exception e){
                
                }
                try{
                    lineItemsId.add((id)so.get('lineitem__c'));
                }catch(exception e){
                
                }
            }
        }        
        if(trigger.isDelete){
            for(sobject so : trigger.old){
                try{
                    lineItemsId.add((id)so.get('line_item__c'));
                }catch(exception e){
                
                }
                try{
                    lineItemsId.add((id)so.get('lineitem__c'));
                }catch(exception e){
                
                }
            }
        }
    
        return [select id from lineitem__c where id in : lineItemsId];
    }

}