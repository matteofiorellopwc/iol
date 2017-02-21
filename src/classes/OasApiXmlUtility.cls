/*
    Utility for OAS Integration
*/

public class OasApiXmlUtility {

    /*
        Get list of <tagName></tagName> content in xml using OasApiXmlDom
    */
    public static List<String> getEntityList(String xml,String tagName){
        
        OasApiXmlDom dom = new OasApiXmlDom(xml);
        List<String> entityList = new List<String>();
        try{
            if(dom.getElementsByTagName(tagName)[0].nodeValue == '' || dom.getElementsByTagName(tagName)[0].nodeValue == null){
                return entityList;
            }
            else{
                for(Integer i =0; i < dom.getElementsByTagName(tagName).size(); i++ ){
                    entityList.add(dom.getElementsByTagName(tagName)[i].nodeValue);
                }
                return entityList;
            }
        }
        catch(System.ListException e){
            System.debug(Logginglevel.ERROR, e.getMessage());
            return entityList;
        }
        catch(System.XmlException e){
            System.debug(Logginglevel.ERROR, e.getMessage());
            return entityList;
        }   
    }
    
    /*
        Get list of <tagName></tagName> content in xml using string methods.
        It doesn't work for xml like: <tagName>...<tagName></tagName>...</tagName>
    */    
    public static List<String> getEnityListString(String xml,String tagName){
        String[] entities = new string[]{};
        String tag = '<'+tagName+'>';
        String endTag = '</'+tagName+'>';

        while(xml.indexOf(tag) > 0){
            entities.add(xml.substring(xml.indexOf(tag)+tag.length(),xml.indexOf(endTag)));
            xml = xml.substringAfter(endTag);
        }        
        return entities;
    }
    
    /*
        Get list of <tagName></tagName> content in xml using regex
    */    
    public static List<String> getEnityListRegex(String xml,String tagName){
        String regExpr = '<'+tagName+'>(.*?)</'+tagName+'>'; 
        Matcher mat = Pattern.compile(regExpr).matcher(xml);
        
        String[] entities = new string[]{};
        while(mat.find()){
            entities.add(mat.group(1));
        }
        
        return entities;
    }
    
    /*
        Get list of <Id></Id> content in xml
    */
    public static List<String> getEntityList(String xml){
        return getEntityList(xml,'Id');
    }
    
    /*
        Get first <tagName></tagName> content in xml using regex
    */
    public static string getFirstEnityRegex(String xml,String tagName){
        list<string> ent = getEnityListRegex(xml,tagName);
        if(ent.size() > 0){
            return getEnityListRegex(xml,tagName)[0];
        }else{
            return null;
        }
    }
    
/*    
    public List<OasApiReportTable> getReportTables(String xml){

        XmlStreamReader reader = new XmlStreamReader(xml);
        List<OasApiReportTable> reportTables = new List<OasApiReportTable>();
        
        while(reader.hasNext()){
            if(reader.getEventType() ==  XmlTag.START_ELEMENT){             
                if(reader.getLocalName() == 'reportTable'){
                    //get table name
                    OasApiReportTable reportTable = new OasApiReportTable();
                    reportTable.setTableId(reader.getAttributeValue(null, 'name'));
                    reportTable.setTableName(reader.getAttributeValue(null, 'title'));
                    
                    //get the rows
                    reader.nextTag();
                    while(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() =='row'){
                        reportTable.addRow(getReportRow(reader));
                        reader.nextTag();
                    }
                    //get the column names from the first row element
                    if(reportTable.getRows().size() > 0){
                        reportTable.setColumnNames(reportTable.getRows()[0].getColumnNames().split(':'));
                    }
                    else{//report table is empty, place no records found result
                        OasApiReportRow emptyRow = New OasApiReportRow();
                        emptyRow.addColumnValue('No records found');
                        reportTable.addRow(emptyRow);
                    } 
                    reportTables.add(reportTable);
                }
            }
            reader.next();
        }
        return reportTables;
    }
    private OasApiReportRow getReportRow(XmlStreamReader reader){
        //create the row
        OasApiReportRow row = new OasApiReportRow();
        String reportHeaders = '';
        while(reader.hasNext()){            
            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() !='row') {
                //get the header for the column
                reportHeaders += reader.getLocalName() + ':';   
                while(reader.getEventType() != XmlTag.CHARACTERS){
                    reader.next();
                }
                row.addColumnValue(reader.getText());
            }
            else if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() =='row' ){
                row.setColumnNames(reportHeaders);
                return row;
            }
            reader.next();
        }
        row.setColumnNames(reportHeaders);
        return row;
    }
*/    
}