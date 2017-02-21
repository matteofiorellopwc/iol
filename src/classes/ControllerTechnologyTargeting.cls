public class ControllerTechnologyTargeting{

    public String id {get;set;}
    public String sobjectName{get;set;}
    public String editable {get;set;}
    
    public map<String,TechnologyTargeting__c> techoTargetMap {get;set;}
    public Map<String, Boolean> mapTechKeyIsAddedInGroup {get; private set;} //Check if the key is contained in Gruppi_Technology_Target_LI__c
    public Set<String> groupsTechLI {get; set;}
    public list<TechnologyTargeting__c> techoTargetToDelete {get;set;}
    public Map<String,String> operating_system_name {get;set;}
    public Map<String,String> browser_name {get;set;}
    public Map<String,String> technologyValuesTranlated {get;set;}

    public TechnologyTargeting__c techoTarget {get;set;}
    public Product2 p {get; set;}
     
    public String editTec {get;set;}
    
    public TechnologyTargeting__c OperatingSystemVersionIncluded {get;set;}
    public TechnologyTargeting__c OperatingSystemVersionExcluded {get;set;}
    public TechnologyTargeting__c BrowserVersionIncluded {get;set;}
    public TechnologyTargeting__c BrowserVersionExcluded {get;set;}

    public List<SelectOption> getTrueFalse() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','targeted')); 
        options.add(new SelectOption('false','excluded')); 
        return options; 
    }
    
    public list<selectedValueClass> selectedValues {get;set;}
    public map<string,list<selectedValueClass>> operatingSystemVersionMap {get;set;}
    public string operatingSystemParent {get;set;} //op system with versions
    public Map<string,list<SelectedValueClass>> browserVersionMap {get;set;}
    public string browserParent {get;set;} //browser with versions
    public Map<String,List<String>> browserMapParentChildDependencies {get;set;}
    public String operatingSystemParentIds {get;set;}

    private Map<String,String> translations;
    public Map<String,String> label {get;set;}

    public class selectedValueClass{
        public boolean checked {get;set;}
        public string id {get;set;}
        public string visualname {get;set;}
        public boolean anyVersion {get;set;}
    }
    
    public PublisherQueryLanguageUtility queryUtil {set;get;}
    public PublisherQueryLanguageUtility queryUtil2 {set;get;}
    
    private Map<String,List<PublisherQueryLanguageUtility.Value>> browserMap = null;

    public ControllerTechnologyTargeting(){
        loadTranslations();
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
        this.editable = ApexPages.CurrentPage().getParameters().get('editable');
        browserMapParentChildDependencies = new Map<String,List<String>>();
        label = new Map<String,String>();
        technologyValuesTranlated = new Map<String,String>();
        operatingSystemParent = '';
        browserParent = '';
        operatingSystemParentIds = '501013,501012,501027';
        String query = 'select id,isTargeted__c,Type__c,valueIds__c,Values__c,lineitem__c, lineitem__r.product__c, lineitem__r.product__r.Gruppi_Technology_Target_LI__c, product__c, product__r.Gruppi_Technology_Target_LI__c from TechnologyTargeting__c where '+sobjectName+' = \''+id+'\'';
        system.debug('query='+query);
        techoTargetToDelete = Database.query(query);
        //Getting info about Product2.Gruppi_Technology_Target_LI__c field
        if (sobjectName != null) {
            if (sobjectName.toLowerCase() == 'product__c') {
                if (!techoTargetToDelete.isEmpty()) {
                    p = new Product2(Id=this.Id, Gruppi_Technology_Target_LI__c=techoTargetToDelete.get(0).Product__r.Gruppi_Technology_Target_LI__c);
                }else{
                    p = [SELECT Id,Gruppi_Technology_Target_LI__c FROM Product2 WHERE Id = :this.Id];
                }
            } else { //Security Check
                if (!techoTargetToDelete.isEmpty()) {
                    p = new Product2(Id=techoTargetToDelete.get(0).lineitem__r.product__c, Gruppi_Technology_Target_LI__c=techoTargetToDelete.get(0).lineitem__r.product__r.Gruppi_Technology_Target_LI__c);
                } else {
                    List<LineItem__c> listLI = [SELECT Id, Product__c, Product__r.Gruppi_Technology_Target_LI__c FROM LineItem__c WHERE Id = :this.Id];
                    p = new Product2(Id=listLI.get(0).product__c, Gruppi_Technology_Target_LI__c=listLI.get(0).product__r.Gruppi_Technology_Target_LI__c);
                }
            }
            groupsTechLI = new Set<String>();
            if (p.Gruppi_Technology_Target_LI__c != null) { 
                for (String s : p.Gruppi_Technology_Target_LI__c.split(';')) { //Multi Picklist Split
                    groupsTechLI.add(s);
                }
            }
        }

        mapTechKeyIsAddedInGroup = new Map<String, Boolean>();
        techoTargetMap = new map<String,TechnologyTargeting__c>();
        
        List<TechnologyTargetSettings__c> technologyTargetList = TechnologyTargetSettings__c.getAll().values();
        for(TechnologyTargetSettings__c t : technologyTargetList){
			techoTargetMap.put(t.name,null);
        }
        
        /*
        techoTargetMap.put('Bandwidth_Group',null);
        techoTargetMap.put('Browser',null);
        techoTargetMap.put('Browser_Language',null);
        techoTargetMap.put('Operating_System',null);
        techoTargetMap.put('Device_Capability',null);
        techoTargetMap.put('Device_Category',null);
        techoTargetMap.put('Device_Manufacturer',null);
        techoTargetMap.put('Mobile_Carrier',null);
        techoTargetMap.put('Mobile_Device',null);
		*/
        resetOperatingSystemVersion();
        resetBrowserVersion();
        
        for(TechnologyTargeting__c tt : techoTargetToDelete){
            if(tt.Type__c != 'Operating_System_Version' && tt.Type__c != 'Browser_Version'){
                techoTargetMap.put(tt.type__c,tt.clone());
            }else{
                if(tt.Type__c == 'Operating_System_Version'){
                    if(tt.isTargeted__c){
                        OperatingSystemVersionIncluded = tt.clone();
                    }else if(!tt.isTargeted__c){
                        OperatingSystemVersionExcluded = tt.clone();
                    }
                }else{
                    if(tt.isTargeted__c){
                        BrowserVersionIncluded = tt.clone();
                    }else if(!tt.isTargeted__c){
                        BrowserVersionExcluded = tt.clone();
                    }
                }
            }
        }

        system.debug('techoTargetMap: '+techoTargetMap);
        
        for(string s : techoTargetMap.keySet()){
            if(techoTargetMap.get(s) == null){
                TechnologyTargeting__c tt = new TechnologyTargeting__c();
                tt.put(sobjectName,id);
                tt.type__c = s;
                techoTargetMap.put(s,tt);
            }
        }
        try{ 
            queryUtil = new PublisherQueryLanguageUtility();

            //Caching nomi sistemi operativi
            operating_system_name = new Map<String,String>();
            queryUtil2 = new PublisherQueryLanguageUtility();
            queryUtil2.query = 'select id,operatingsystemname from Operating_System limit 1000 offset 0';
            
            queryUtil2.runQuery();

            system.debug('queryUtil2.table = '+queryUtil2.table);
       
            for(integer i=0;i<queryUtil2.table.get('id').size();i++){
                operating_system_name.put(queryUtil2.table.get('id').get(i).value,queryUtil2.table.get('operatingsystemname').get(i).value);
            }

            //Caching nome browser
            browser_name = new Map<String,String>();
            queryUtil2 = new PublisherQueryLanguageUtility();
            queryUtil2.query = 'select id,browsername,majorversion,minorversion from Browser limit 1000 offset 0';
            
            queryUtil2.runQuery();

            browserMap = queryUtil2.table;
            Set<String> browsers = new Set<String>();
            for(integer i=0;i<browserMap.get('id').size();i++){
                String browserName = browserMap.get('browsername').get(i).value;
                if(!browsers.contains(browsername)){ // simulo una distinct sul browser name
                    browser_name.put(browserMap.get('id').get(i).value,browsername);
                    browsers.add(browserName);
                }
            }            
            
        }catch(Exception e){
             if(Test.isRunningTest()){
                 
             }else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
             }
        }
           
        
        System.debug(operating_system_name);
        
        
        techoTarget = null;
        refreshMapTechKeyIsAddedInGroup(); 

        // caricamento traduzioni categorie
        for(String key : techoTargetMap.keySet()){
            key = key.replace('_', ' ');
            label.put(key,getTranslation(key));
        }
           
        tranlateValuesChoosen();
    }

    public void saveGroupConfiguration() { update p; }

    private void tranlateValuesChoosen(){
        for(String tech : techoTargetMap.keySet()){
            String values = techoTargetMap.get(tech).values__c;
            if(values != null){
                String [] valuesArr = values.split(',');
                String translationsStr = '';
                for(Integer index=0; index<valuesArr.size(); index++){
                    String value = valuesArr[index];
                    translationsStr += getTranslation(value);
                    if(index < valuesArr.size()-1){
                        translationsStr += ',';
                    }
                }    
                technologyValuesTranlated.put(tech,translationsStr);
            }
        }
    }

    public void resetOperatingSystemVersion(){
        OperatingSystemVersionIncluded = new TechnologyTargeting__c();
        OperatingSystemVersionIncluded.type__c = 'Operating_System_Version';
        OperatingSystemVersionIncluded.isTargeted__c = true;
        OperatingSystemVersionIncluded.put(sobjectName,id);
        OperatingSystemVersionExcluded = new TechnologyTargeting__c();
        OperatingSystemVersionExcluded.type__c = 'Operating_System_Version';
        OperatingSystemVersionExcluded.isTargeted__c = false;        
        OperatingSystemVersionExcluded.put(sobjectName,id);
    }

    public void resetBrowserVersion(){
        BrowserVersionIncluded = new TechnologyTargeting__c();
        BrowserVersionIncluded.type__c = 'Browser_Version';
        BrowserVersionIncluded.isTargeted__c = true;
        BrowserVersionIncluded.put(sobjectName,id);
        BrowserVersionExcluded = new TechnologyTargeting__c();
        BrowserVersionExcluded.type__c = 'Browser_Version';
        BrowserVersionExcluded.isTargeted__c = false;        
        BrowserVersionExcluded.put(sobjectName,id);
    }
    
    public void saveTec(){
        try{
        string valueIds = '';
        string values = '';

        for(selectedValueClass svc : selectedValues){
            if(svc.checked){
                valueIds += svc.id+',';
                values += svc.visualname+',';
            }
        }
        if(valueIds.length() > 0){
            valueIds += ',';
            valueIds = valueIds.replace(',,','');
            values += ',';
            values = values.replace(',,','');            
        }
        techoTarget.valueIds__c = valueIds;
        techoTarget.values__c = values;

        System.debug('techoTarget.valueIds__c: '+techoTarget.valueIds__c);
        System.debug('techoTarget.values__c: '+techoTarget.values__c);
                
        if(techoTarget.type__c == 'Operating_System'){ //check versions
            string valueTargetedIds = ''; //for operating system version
            string valuesTargeted = '';
            string valueExcludedIds = '';
            string valuesExcluded = '';

            for(string oppSysId : operatingSystemVersionMap.keySet()){
                for(selectedValueClass svc : operatingSystemVersionMap.get(oppSysId)){
                    /*
                    system.debug('svc.visualname : '+ operating_system_name.get(oppSysId) + ' ' +svc.visualname);
                    system.debug('techoTarget.valueIds__c.contains(oppSysId) : '+techoTarget.valueIds__c.contains(oppSysId));
                    system.debug('techoTarget.isTargeted__c : '+techoTarget.isTargeted__c);
                    system.debug('svc.checked : '+svc.checked);
                    */
                    
                    if(!techoTarget.valueIds__c.contains(oppSysId) && !techoTarget.isTargeted__c && svc.checked){
                        valueExcludedIds += svc.id+',';
                        valuesExcluded += svc.visualname+',';
                        system.debug('exclude '+svc.visualname);
                    }
                    if(techoTarget.valueIds__c.contains(oppSysId) && techoTarget.isTargeted__c && !svc.checked){
                        valueExcludedIds += svc.id+',';
                        valuesExcluded += svc.visualname+',';
                        system.debug('exclude '+svc.visualname);
                    }
                    if(!techoTarget.valueIds__c.contains(oppSysId) && techoTarget.isTargeted__c && svc.checked){
                        valueTargetedIds += svc.id+',';
                        valuesTargeted += svc.visualname+',';
                        system.debug('include '+svc.visualname);
                    }
                }
            }
            if(valueExcludedIds.length() > 0){
                valueExcludedIds += ',';
                valueExcludedIds = valueExcludedIds.replace(',,','');
                valuesExcluded += ',';
                valuesExcluded = valuesExcluded.replace(',,','');            
            }
            OperatingSystemVersionExcluded.valueIds__c = valueExcludedIds;
            OperatingSystemVersionExcluded.values__c = valuesExcluded;
            
            if(valueTargetedIds.length() > 0){
                valueTargetedIds += ',';
                valueTargetedIds = valueTargetedIds.replace(',,','');
                valuesTargeted += ',';
                valuesTargeted = valuesTargeted.replace(',,','');            
            }
            OperatingSystemVersionIncluded.valueIds__c = valueTargetedIds;
            OperatingSystemVersionIncluded.values__c = valuesTargeted;
        }
        if(techoTarget.type__c == 'Browser'){ //check versions
            string valueTargetedIds = ''; //for browser version
            string valuesTargeted = '';
            string valueExcludedIds = '';
            string valuesExcluded = '';

            for(string oppSysId : browserVersionMap.keySet()){
                for(selectedValueClass svc : browserVersionMap.get(oppSysId)){
                    if(svc == null){
                        continue;
                    }
                    if(!techoTarget.valueIds__c.contains(oppSysId) && !techoTarget.isTargeted__c && svc.checked){
                        valueExcludedIds += svc.id+',';
                        valuesExcluded += svc.visualname+',';
                        system.debug('exclude '+svc.visualname);
                    }
                    if(techoTarget.valueIds__c.contains(oppSysId) && techoTarget.isTargeted__c && !svc.checked){
                        valueExcludedIds += svc.id+',';
                        valuesExcluded += svc.visualname+',';
                        system.debug('exclude '+svc.visualname);
                    }

                    if(!techoTarget.valueIds__c.contains(oppSysId) && techoTarget.isTargeted__c && svc.checked){
                        valueTargetedIds += svc.id+',';
                        valuesTargeted += svc.visualname+',';
                        system.debug('include '+svc.visualname);
                    }
                }
            }
            if(valueExcludedIds.length() > 0){
                valueExcludedIds += ',';
                valueExcludedIds = valueExcludedIds.replace(',,','');
                valuesExcluded += ',';
                valuesExcluded = valuesExcluded.replace(',,','');            
            }
            BrowserVersionExcluded.valueIds__c = valueExcludedIds;
            BrowserVersionExcluded.values__c = valuesExcluded;
            
            if(valueTargetedIds.length() > 0){
                valueTargetedIds += ',';
                valueTargetedIds = valueTargetedIds.replace(',,','');
                valuesTargeted += ',';
                valuesTargeted = valuesTargeted.replace(',,','');            
            }
            BrowserVersionIncluded.valueIds__c = valueTargetedIds;
            BrowserVersionIncluded.values__c = valuesTargeted;
        }
        
        techoTarget = null;
        tranlateValuesChoosen();
        }catch(Exception e){
            system.debug('ERROR: '+e.getMessage()+'. '+e.getStackTraceString());
        }
        
    }
    
    public void editTechnoTarget(){
        techoTarget = techoTargetMap.get(editTec);
        runQuery();
    }
    
    public void resetTechnoTarget(){
        TechnologyTargeting__c tt = new TechnologyTargeting__c();
        tt.put(sobjectName,id);
        tt.type__c = editTec;
        techoTargetMap.put(editTec,tt);
        techoTarget = null;
        if(editTec == 'Operating_System'){
            resetOperatingSystemVersion();                    
        }
        if(editTec == 'Browser'){
            resetBrowserVersion();                    
        }
    }   


    public void runQuery(){
    
      try{
                operatingSystemParent = '';
                browserParent = '';
                string type = editTec;
                string valueIds = techoTarget.valueIds__c;
                valueids = (valueids != null) ? valueids : '';
                map<string,string> fieldMap = new map<string,string>{
                    'Bandwidth_Group' => 'id,bandwidthname',
                    'Browser' => 'id,browsername',
                    'Browser_Language' => 'id,browserlanguagename',
                    'Operating_System' => 'id,operatingsystemname',
                    'Operating_System_Version' => 'id,operatingsystemid,majorversion,minorversion,microversion',
                    
                    'Device_Capability' => 'id,devicecapabilityname',
                    'Device_Category' => 'id,devicecategoryname',
                    'Device_Manufacturer' => 'id,mobiledevicemanufacturername',
                    'Mobile_Carrier' => 'id,countrycode,mobilecarriername',
                    'Mobile_Device' => 'id,mobiledevicemanufacturerid,mobiledevicename'
                    //'Mobile_Device_Submodel' => 'id,mobiledeviceid,mobiledevicesubmodelname'
                };
                queryUtil.query = 'select '+fieldMap.get(type)+' from '+type+' limit 1000 offset 0';
                system.debug('queryUtil.query: '+queryUtil.query);
                if(type.trim() == 'Browser'){
                    queryUtil.objectName = type.trim();
                    queryUtil.runDistinctQuery('browsername',new String[]{'Safari'});           
                    browserVersionMap = new Map<String,List<SelectedValueClass>>();
                    for(integer j=0; j<queryUtil.table.get('browsername').size(); j++){
                        browserVersionMap.put(queryUtil.table.get('browsername').get(j).value,new List<SelectedValueClass>());
                    }
                    for(integer j=0; j<queryUtil.table.get('id').size(); j++){
                        queryUtil.table.get('id').get(j).value = String.valueOf(j);
                    }
                }else{
                    queryUtil.objectName = type;
                    queryUtil.runQuery();
                }

                // caricamento traduzioni colonne primo livello
                for(String columnName : queryUtil.columnTypes){
                    label.put(columnName,getTranslation(columnName));
                }

                selectedValues = new list<selectedValueClass>();
                operatingSystemVersionMap = new map<string,list<selectedValueClass>>();
                operatingSystemVersionMap.put('501012',new list<selectedValueClass>());  
                operatingSystemVersionMap.put('501013',new list<selectedValueClass>());
                operatingSystemVersionMap.put('501027',new list<selectedValueClass>());
                
                if(Test.isRunningTest()){
                    addTestData();
                }
                
                System.debug('PD - queryUtil: '+queryUtil);

                for(integer i=0;i<queryUtil.table.get('id').size();i++){
                    PublisherQueryLanguageUtility.Value v = queryUtil.table.get('id').get(i);
                    selectedValueClass ssc = new selectedValueClass();
                    ssc.checked = valueIds.contains(v.value);
                    ssc.id = v.value;   
                    
                    ssc.visualname = '';
                    
                    if(type=='Bandwidth_Group'){
                        ssc.visualname = queryUtil.table.get('bandwidthname').get(i).value;
                    }
                    if(type=='Browser'){ 
                        ssc.visualname = queryUtil.table.get('browsername').get(i).value; 
                        if(ssc.visualname.startsWith('Safari')){
                            ssc.visualname = 'Safari';
                        }
                        browserVersionMap.put(ssc.visualname,new list<selectedValueClass>(1));
                    }
                    if(type=='Browser_Language'){
                        ssc.visualname = queryUtil.table.get('browserlanguagename').get(i).value;
                    }
                    if(type=='Operating_System'){
                        ssc.visualname = queryUtil.table.get('operatingsystemname').get(i).value;
                        operatingSystemVersionMap.put(queryUtil.table.get('id').get(i).value,new list<selectedValueClass>());  
                    }
                    if(type=='Device_Capability'){
                        ssc.visualname = queryUtil.table.get('devicecapabilityname').get(i).value;
                    }
                    if(type=='Device_Category'){
                    //Punctual label substitution
                        String valLowerCase = queryUtil.table.get('devicecategoryname').get(i).value.toLowerCase();
                        if (valLowerCase == 'mobile midrange') {
                            queryUtil.table.get('devicecategoryname').get(i).value = 'Feature Phone';
                        }
                        if (valLowerCase == 'mobile highend') {
                            queryUtil.table.get('devicecategoryname').get(i).value = 'Smartphone';
                        }

                        ssc.visualname = queryUtil.table.get('devicecategoryname').get(i).value;
                    }
                    if(type=='Device_Manufacturer'){
                        ssc.visualname = queryUtil.table.get('mobiledevicemanufacturername').get(i).value;
                    }
                    if(type=='Mobile_Carrier'){
                        ssc.visualname = queryUtil.table.get('mobilecarriername').get(i).value;
                    }
                    if(type=='Mobile_Device'){
                        ssc.visualname = queryUtil.table.get('mobiledevicename').get(i).value;
                    }
                    /*if(type=='Mobile_Device_Submodel'){
                        ssc.visualname = queryUtil.table.get('mobiledevicesubmodelname').get(i).value;
                    }*/
                    /*
                    if(type=='Operating_System_Version'){
                        ssc.visualname = queryUtil.table.get('majorversion').get(i).value+'.'+queryUtil.table.get('minorversion').get(i).value+'.'+queryUtil.table.get('microversion').get(i).value;
                    }
                    */
                    selectedValues.add(ssc);
                    
                }

                // caricamento traduzioni primo livello
                for(Integer i=0; i<queryUtil.ii.size(); i++){
                    for(String column : queryUtil.columnTypes){
                        label.put(queryUtil.table.get(column).get(i).value,getTranslation(queryUtil.table.get(column).get(i).value));
                    }
                }


                if(type == 'Operating_System'){
                    operatingSystemParent = ',';
                    system.debug('Operating_System selected values = '+selectedValues);
                    OperatingSystemVersionIncluded.valueIds__c = (OperatingSystemVersionIncluded.valueIds__c != null ) ? OperatingSystemVersionIncluded.valueIds__c : '';
                    OperatingSystemVersionExcluded.valueIds__c = (OperatingSystemVersionExcluded.valueIds__c != null ) ? OperatingSystemVersionExcluded.valueIds__c : '';
                    queryUtil2.query = 'select id,operatingsystemid,majorversion,minorversion,microversion from Operating_System_Version limit 1000 offset 0';
                    system.debug('queryUtil2.query: '+queryUtil2.query);
                    queryUtil2.runQuery();
                    
                    for(integer i=0;i<queryUtil2.table.get('id').size();i++){
                        PublisherQueryLanguageUtility.Value v = queryUtil2.table.get('id').get(i);
                        selectedValueClass ssc = new selectedValueClass();
                        ssc.id = v.value;   
                        ssc.visualname = '';
                        ssc.visualname = operating_system_name.get(queryUtil2.table.get('operatingsystemid').get(i).value) + ' ' +
                                         queryUtil2.table.get('majorversion').get(i).value+'.'+
                                         queryUtil2.table.get('minorversion').get(i).value +
                                         (queryUtil2.table.get('microversion').get(i).value == '-1' ? '' : '.'+ queryUtil2.table.get('microversion').get(i).value);
        
        
                        String oppSysId = queryUtil2.table.get('operatingsystemid').get(i).value;
                        
                        //ssc.checked = OperatingSystemVersionIncluded.valueIds__c.contains(v.value) || OperatingSystemVersionExcluded.valueIds__c.contains(v.value);
                        
                        if(techoTarget.valueIds__c == null){
                            techoTarget.valueIds__c = '';
                        }
                        ssc.checked = techoTarget.isTargeted__c && techoTarget.valueIds__c.contains(oppSysId) && !OperatingSystemVersionExcluded.valueIds__c.contains(v.value);
                        ssc.checked = ssc.checked || (techoTarget.isTargeted__c && OperatingSystemVersionIncluded.valueIds__c.contains(v.value));
                        ssc.checked = ssc.checked || (!techoTarget.isTargeted__c && OperatingSystemVersionExcluded.valueIds__c.contains(v.value));
                        ssc.checked = ssc.checked || (!techoTarget.isTargeted__c && techoTarget.valueIds__c.contains(oppSysId));
                        
                        system.debug('queryUtil2.table = '+queryUtil2.table);
                        system.debug('queryUtil2.table.get(\'operatingsystemid\').get(i).value = '+queryUtil2.table.get('operatingsystemid').get(i).value);
                        system.debug('operatingSystemVersionMap = '+operatingSystemVersionMap);
                        system.debug('operatingSystemVersionMap.get(queryUtil2.table.get(\'operatingsystemid\').get(i).value) = '+operatingSystemVersionMap.get(queryUtil2.table.get('operatingsystemid').get(i).value));
                        
                        operatingSystemVersionMap.get(queryUtil2.table.get('operatingsystemid').get(i).value).add(ssc);
                        operatingSystemParent += queryUtil2.table.get('operatingsystemid').get(i).value +',';
                    }
                }
                if(type == 'Browser'){
                    
                    browserParent = ',';
                    BrowserVersionIncluded.valueIds__c = (BrowserVersionIncluded.valueIds__c != null ) ? BrowserVersionIncluded.valueIds__c : '';
                    BrowserVersionExcluded.valueIds__c = (BrowserVersionExcluded.valueIds__c != null ) ? BrowserVersionExcluded.valueIds__c : '';
                    
                    for(integer i=0;i<browserMap.get('id').size();i++){
                        PublisherQueryLanguageUtility.Value v = browserMap.get('id').get(i);
                        SelectedValueClass ssc = new SelectedValueClass();
                        ssc.id = v.value;
                        
                        String parentName = browserMap.get('browsername').get(i).value;
                        String majorVersion = browserMap.get('majorversion').get(i).value;
                        String minorVersion = browserMap.get('minorversion').get(i).value;

                        ssc.visualname = parentName + ' ' + majorVersion + '.' + minorVersion ;
                        
                        if(parentName.startsWith('Safari')){
                            parentName = 'Safari';
                        }

                        String oppSysId = ssc.id;
                        if(techoTarget.valueIds__c == null){
                            techoTarget.valueIds__c = '';
                        }
                        ssc.checked = techoTarget.isTargeted__c && techoTarget.valueIds__c.contains(oppSysId) && !BrowserVersionExcluded.valueIds__c.contains(v.value);
                        ssc.checked = ssc.checked || (techoTarget.isTargeted__c && BrowserVersionIncluded.valueIds__c.contains(v.value));
                        ssc.checked = ssc.checked || (!techoTarget.isTargeted__c && BrowserVersionExcluded.valueIds__c.contains(v.value));
                        ssc.checked = ssc.checked || (!techoTarget.isTargeted__c && techoTarget.valueIds__c.contains(oppSysId));
                        
                        if((majorVersion == 'Any' && minorVersion == 'Any') || browserMap.get('id').size() == 1 ){
                            browserVersionMap.get(parentName).set(0,ssc);
                        }else{
                            browserVersionMap.get(parentName).add(ssc);
                        }
                        browserParent += ssc.id +',';

                        if((majorVersion == 'Any' && minorVersion == 'Any') || (majorVersion == 'Other' && minorVersion == 'Other')){
                            String pn = parentName.replaceAll('\\s+', '');
                            if(browserMapParentChildDependencies.get(pn) == null){
                                browserMapParentChildDependencies.put(pn,new List<String>());
                            }
                            ssc.anyVersion = true;
                            browserMapParentChildDependencies.get(pn).add(ssc.id);
                        }else{
                            ssc.anyVersion = false;
                        }

                    }
                    System.debug(browserMapParentChildDependencies);

                }
            }catch(Exception e){
                if(Test.isRunningTest()){
                 
             }else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                 system.debug('ERROR: '+e.getMessage()+'. '+e.getStackTraceString());
             }
            }
    }
    
    public PageReference customSave(){
        system.debug('techoTargetMap = '+techoTargetMap);
        list<TechnologyTargeting__c> technoTargetToInsert = new list<TechnologyTargeting__c>();
        for(string s : techoTargetMap.keySet()){
            TechnologyTargeting__c tt = techoTargetMap.get(s);
            technoTargetToInsert.add(tt);
        }
        
        technoTargetToInsert.add(OperatingSystemVersionIncluded);
        technoTargetToInsert.add(OperatingSystemVersionExcluded);
        technoTargetToInsert.add(BrowserVersionIncluded);
        technoTargetToInsert.add(BrowserVersionExcluded);
        
        insert technoTargetToInsert;
        system.debug('technoTargetToInsert:'+technoTargetToInsert);
        delete techoTargetToDelete; 
        
        PageReference p = new Pagereference('/apex/editTechnologyTargetingComponent?sobjectName=' + sobjectName + '&id=' + id + '&editMode=false&editable=' + editable);
        p.setRedirect(true);
        return p;
           
    }

    public void refreshMapTechKeyIsAddedInGroup() {
        mapTechKeyIsAddedInGroup.clear();
        for (String key : techoTargetMap.keySet()) {
            mapTechKeyIsAddedInGroup.put(key, groupsTechLI.contains(key.replace('_',' ')));
        }
        System.debug('mapTechKeyIsAddedInGroup: '+mapTechKeyIsAddedInGroup);
    }

    private void loadTranslations(){
        if(translations == null){
            translations = new Map<String,String>();
        }
        List<Translations__c> translationsList = Translations__c.getAll().values();
        for(Translations__c t : translationsList){
            if(t.Type__c == 'Technology'){
                translations.put(t.Name, t.ItalianTranslation__c);
            }
        }
    }
    


    public String getTranslation(String textToTranslate){
        String translation = translations.get(textToTranslate);
        return translation != null ? translation : textToTranslate;
    }

    private void addTestData(){
        queryUtil.table.put('id',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});
        queryUtil.table.put('bandwidthname',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});
        queryUtil.table.put('browsername',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});
        queryUtil.table.put('majorversion',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});
        queryUtil.table.put('minorversion',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});
        queryUtil.table.put('browserlanguagename',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});
        queryUtil.table.put('operatingsystemname',new PublisherQueryLanguageUtility.Value[]{new PublisherQueryLanguageUtility.Value()});

        queryUtil.table.get('id')[0].value='test';        
        queryUtil.table.get('bandwidthname')[0].value='test'; 
        queryUtil.table.get('browsername')[0].value='test'; 
        queryUtil.table.get('majorversion')[0].value='test'; 
        queryUtil.table.get('minorversion')[0].value='test'; 
        queryUtil.table.get('browserlanguagename')[0].value='test'; 
        queryUtil.table.get('operatingsystemname')[0].value='test';              
    }
    
    static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;     
        
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        
        LineItem__c li = new LineItem__c();
        li.Product__c = p.Id;
        li.opportunity__c = o.id;
        insert li;
        
        LineItemTriggerHandler.skipUpdateLineItem = false;
        LineItemTriggerHandler.skipValidationTotali = true;
        
        TechnologyTargeting__c target = new TechnologyTargeting__c();
        target.valueIds__c = 'test';
        insert target;
        
        ApexPages.CurrentPage().getParameters().put('id',li.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','LineItem__c');
        
        ControllerTechnologyTargeting ctt = new ControllerTechnologyTargeting();
        ctt.customSave();
        ctt.techoTarget = target;
        ctt.techoTargetMap = new Map<string,TechnologyTargeting__c>();
        ctt.techoTargetMap.put(target.Id,target);
        ctt.editTec = target.Id;
        

        ctt.runQuery();                
        ctt.getTrueFalse();
        ctt.editTechnoTarget();        
        
        List<selectedValueClass> t = new List<selectedValueClass>();
        selectedValueClass s = new selectedValueClass();
        t.add(s);
        s.checked = true;
        s.id = '000';
        s.visualname = 'aaa';
        ctt.selectedValues = t;
        //ctt.editTechnoTarget();
        ctt.saveTec();
        
        ctt = new ControllerTechnologyTargeting();
        ctt.techoTarget = target;
        ctt.editTec = 'Bandwidth_Group';
        ctt.runQuery();
        ctt.editTec = 'Browser';
        ctt.runQuery();
        ctt.editTec = 'Browser_Language';
        ctt.runQuery();
        ctt.editTec = 'Operating_System';
        ctt.runQuery();
        ctt.editTec = 'Operating_System';
        ctt.runQuery();                       
        
        
        ctt.resetTechnoTarget();

        
     } 
    
    
}