public class Util{    
    
    public class UtilCloneException extends Exception {}
    
    public static SObject cloneAllFields(SObject obj) {
        return cloneAllFields((Id) obj.get('Id'));
    }
    
    public static SObject cloneAllFields(Id sobjectId) {
        String sObjectName = sobjectId.getSObjectType().getDescribe().getName();
        if(sobjectId == null) throw new UtilCloneException('sobject id can\'t be null');
        SObject objToClone = Database.query(getFieldsSOQL(sObjectName, 'Id = \'' + sobjectId + '\' LIMIT 1', false, '', true));         
        return objToClone.clone(false, true, false, false);
    }
    
    public static SObject mergeObjects(SObject master, SObject toMergeIntoMaster, Boolean modifyOriginal) {
        SObject res = modifyOriginal ? master.clone(true,true,false,false) : cloneAllFields(master);
        Schema.sObjectType sObjectType = ((Id) master.get('Id')).getSObjectType();
        for(String fieldName : sObjectType.getDescribe().fields.getMap().keySet()) {
            if(fieldName == 'Id') continue;
            Object obj = toMergeIntoMaster.get(fieldName);
            if(obj != null) res.put(fieldName, obj);
        }
        return res;
    }

    public static string getFieldsSOQL(String objectName, String whereClause, Boolean isInARelationQuery, String additionalFields,boolean onlyCreateable){        
       String selects = '';     
       if (whereClause == null || whereClause == ''){ return null; }
          
       Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
       list<string> selectFields = new list<string>();
        
       if (fMap != null){
           for (Schema.SObjectField ft : fMap.values()){ 
               Schema.DescribeFieldResult fd = ft.getDescribe();
               if(onlyCreateable){
                   if(fd.isCreateable()){ 
                       selectFields.add(fd.getName());
                   }
               }else{
                   selectFields.add(fd.getName());
               }
           }    
       }
        
       if (!selectFields.isEmpty()){
           for (string s:selectFields){
               selects += s + ',';
           }
           if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
       }
       
       if(isInARelationQuery && objectName.endsWith('__c')) objectName = objectName.replace('__c', '__r');
       if(additionalFields != null && additionalFields != '') selects += ',' + additionalFields;
       string query = 'SELECT ' + selects + ' FROM ' + objectName;
       if(whereClause != null  && whereClause != ''){
           query += ' WHERE ' + whereClause;
       }
       return query;
   	}
   
	public static boolean notVoid(String s){
        return s != null  && s != '';
    }   
   
    public static List<selectOption> getItems(Schema.sObjectField field){
       SelectOption[] options = new SelectOption[]{};
    
       Schema.DescribeFieldResult fieldResult = field.getDescribe();
       Schema.PicklistEntry[] ple = fieldResult.getPicklistValues();
         
       options.add(new SelectOption('',''));
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));
       }
       
       return options;
    }  
   
   @isTest
   static void testGetFieldsSOQL(){
       Util.getFieldsSOQL('Account', 'id <> null', false, '',false);
       Util.getFieldsSOQL('Account', 'id <> null', true, '',true);
   }
   
   @isTest
   static void testClone() {
       Account a = new Account(Name = 'Test', Phone = '034332121');
       insert a;
       Account b = (Account) cloneAllFields(a);
       System.assertEquals('034332121', b.Phone);
       System.assertEquals('Test', b.Name);
       System.assertEquals(null, b.Id);
   }

   @isTest
   static void testMerge() {
       Account a = new Account(Name = 'Test', Phone = '034332121');
       insert a;
       Account b = new Account(Name = 'Test2', Site = 'www.test.com', Phone = '033332121');
       Account c = (Account) mergeObjects(a, b, false);
       System.assertEquals('033332121', c.Phone);
       System.assertEquals('www.test.com', c.Site);
       System.assertEquals('Test2', c.Name);
       System.assertEquals(null, c.Id);
   }   
   

}