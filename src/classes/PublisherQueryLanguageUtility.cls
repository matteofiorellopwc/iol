public class PublisherQueryLanguageUtility{
    public String query{get;set;}
    public List<String> columnTypes{get;set;}
    public Map<String,List<Value>> table{get;set;}
    public List<Integer> ii {get;set;}
    public String objectName {get;set;}

    public void runQuery(){
        try{
            DfpIntegration dfp = new DfpIntegration();
            DfpPublisherQueryLanguageService.Statement selectStatement = new DfpPublisherQueryLanguageService.Statement();
            selectStatement.query = query;
            DfpPublisherQueryLanguageService.ResultSet resultSet = dfp.PublisherQueryLanguageService.select_x(selectStatement);
            columnTypes = new List<String>();
            table = new Map<String,List<Value>>();
            for(DfpPublisherQueryLanguageService.ColumnType ct : resultSet.columnTypes){
                columnTypes.add(ct.labelName);
                table.put(ct.labelName,new List<Value>());
            }
            
            ii = new List<integer>();
            for(integer i=0;i<resultSet.rows.size();i++){
                ii.add(i);
            }
            
            for(DfpPublisherQueryLanguageService.Row row : resultSet.rows){
                
                for(integer i=0;i<row.values.size();i++){
                    Value v = new Value();
                    v.value = row.values[i].value;
                    v.type = row.values[i].value_type;
                    table.get(columnTypes.get(i)).add(v);
                }
            }
            
            system.debug('table: '+table);
        }catch(exception e){
            columnTypes = new List<String>();
            table = new Map<String,List<Value>>();        
            ii = new List<integer>();
            System.debug(LoggingLevel.ERROR,e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e+''));
        }      
    }

    public void runDistinctQuery(String key, String [] groupings){
        try{
            DfpIntegration dfp = new DfpIntegration();
            DfpPublisherQueryLanguageService.Statement selectStatement = new DfpPublisherQueryLanguageService.Statement();
            selectStatement.query = query;
            DfpPublisherQueryLanguageService.ResultSet resultSet = dfp.PublisherQueryLanguageService.select_x(selectStatement);
            columnTypes = new List<String>();
            table = new Map<String,List<Value>>();
            for(DfpPublisherQueryLanguageService.ColumnType ct : resultSet.columnTypes){
                columnTypes.add(ct.labelName);
                table.put(ct.labelName,new List<Value>());
            }
            
            ii = new List<integer>();
            Set<String> names = new Set<String>();
            for(DfpPublisherQueryLanguageService.Row row : resultSet.rows){
                boolean isBrowserAccepted = false;
                for(integer i=0;i<row.values.size();i++){
                    if(columnTypes.get(i) == key){
                        Value v = new Value();
                        v.value = row.values[i].value; 
                        for(String groupName : groupings){
                            if(v.value.startsWith(groupName)){
                                v.value = groupName;
                                break;
                            }
                        }
                        if(!names.contains(v.value)){
                            names.add(v.value);
                            isBrowserAccepted = true;
                            break;
                        }
                    }
                }
                if(isBrowserAccepted){
                    for(integer i=0;i<row.values.size();i++){
                        Value v = new Value();
                        v.value = row.values[i].value; 
                        for(String groupName : groupings){
                            if(v.value.startsWith(groupName)){
                                v.value = groupName;
                                break;
                            }
                        }
                        v.type = row.values[i].value_type;
                        table.get(columnTypes.get(i)).add(v);        
                    }    
                }
            }
            

            for(integer i=0;i<names.size();i++){
                ii.add(i);
            }
                        
            system.debug('table: '+table);
        }catch(exception e){
            columnTypes = new List<String>();
            table = new Map<String,List<Value>>();        
            ii = new List<integer>();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e+''));
        }      
    }

    public class Value{
        public String value{get;set;}
        public String type{get;set;}
    }
    
   
}