public class ReportLoggerIterable implements Iterable<Asset>{

    public Iterator<Asset> Iterator(){
        return new ReportLoggerIterator();
    }

    public class ReportLoggerIterator implements Iterator<Asset>{
    
        private list<reportLogger__c> reports;
        private String body;
        private integer i;
    
        public ReportLoggerIterator(){
            i = 0;
            reports = [SELECT Name, Stato__c, Tipo__c, Download_url__c, AdUnitView__c, Data_generazione__c FROM ReportLogger__c WHERE Stato__c = 'READY'];
            if(reports.size() > 0){
                body = getBody();
            }
        }
    
        public boolean hasNext(){
            return i < reports.size(); 
        }
    
    
    /*
        Dimension.AD_UNIT_ID
        Dimension.LINE_ITEM_ID
        Dimension.MONTH -> se giornaliero non ha il valore corretto
        Dimension.AD_UNIT_NAME
        Column.TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS
        Column.TOTAL_LINE_ITEM_LEVEL_CLICKS
        Column.TOTAL_LINE_ITEM_LEVEL_CPM_AND_CPC_REVENUE
    */
        public Asset next(){
        
            String row;
            system.debug('body = ' + body);
            
            if(body.indexOf('\n') > 0){
                row = body.substring(0,body.indexOf('\n')+1);
                body = body.substringAfter('\n');
            }else{
                row = body;
                body = '';
            }
            if(row.contains('Dimension.AD_UNIT_ID')){ //csv header
                row = body.substring(0,body.indexOf('\n')+1);
                body = body.substringAfter('\n');
            }
            
            system.debug('row = ' + row);
            
            list<string> fields = row.split(',');
            ReportLogger__c rl = reports[i];
            
            
    
    
            asset a = new asset();
            a.SerialNumber = fields[1]; //salvo qui l'id dfp del lineitem                
            a.adunit__r = new adunit__c(iddfp__c = fields[0]);
            if(rl.Tipo__c == 'Giornaliero') {
                a.Tipo__c = 'Erogato DFP Giornaliero';
                a.Day__c = rl.Data_generazione__c;
            } else {
                /*
                    fields[2] dovrebbe contenere solo il numero del mese ma con le nuove API contiene yyyy-mm, 
                    facciamo il controllo così se torna a funzionare correttamente continua a funzionare anche qui
                */
                if(fields[2].length() == 7){ 
                    a.Month__c = Integer.valueOf(fields[2].split('-')[1]) + '';
                }else{
                    a.Month__c = fields[2];
                }

                a.year__c = rl.Data_generazione__c.year()+'';
                a.tipo__c = 'Erogato DFP Mensile';
            }
            a.Clicks__c = integer.valueOf(fields[5]);
            a.Impressions__c = integer.valueOf(fields[4]);
            a.CPM_CPC_REVENUE_DFP__c = double.valueOf(fields[6]);
    
            a.external_key__c = rl.AdUnitView__c+'_'+fields[1]+'_'+fields[0]+'_'+rl.Data_generazione__c.month()+'_'+rl.data_generazione__c.year(); //idlineitem_idadunit_mese_anno
            if(rl.Tipo__c == 'Giornaliero') a.external_key__c += '_' + rl.data_generazione__c.day();
            a.name = a.external_key__c;
            a.adUnitView__c = rl.AdUnitView__c;
    
            
            
            if(body == ''){
                rl.stato__c = 'COMPLETED';
                update rl;
                i++;
                if(i < reports.size()){
                    body = getBody();
                }
            }
            
            return a;
        }
    
        
        private string getBody(){
            list<Attachment> atts = [select body,name from Attachment where name = 'assets.csv' and parentid =: reports[i].id];
            return atts[0].body.toString();
        }
    }
}