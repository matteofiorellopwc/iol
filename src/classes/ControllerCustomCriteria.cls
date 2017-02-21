public class ControllerCustomCriteria{

    public String id {get;set;}
    public String sobjectName{get;set;}
    
    public integer indexSet {get;set;}
    public integer indexCC {get;set;}
    
    public boolean showAction {get;set;}
    public boolean edit {get;set;}
    public Boolean showGroupOptions {get; set;}
    public Boolean disableGroupSelection {get; set;}
    
    list<CustomCriteriaSet__c> setToDelete;
    
    public Custom_Criteria__c customCriteria {get;set;}
    public List<CustomCriteriaSet> CustomCriteriaSets {get;set;}
    public List<String> selectedValues {get;set;}
    

    public List<SelectOption> keys {get;set;}
    public List<SelectOption> values {get; set;}
    public Map<String, List<SelectOption>> mapKeyGroupOptions {get; set;} //Key Name -> Group with Options
    public Map<String, String> mapValueIdGroup {get; set;}
    public List<SelectOption> groups {get;set;} //Groups for some keys
    public String groupSelected {get; set;}
    public String keysString {get;set;} //stringa con le chiavi editabili
    public List<SelectOption> keysWithoutNone {get;set;}
    public Map<id,String> visualKeyMap {get;set;}
    
    public Map<string,string> idsValueMap  {get;set;}
    public String editable {get;set;}
    public String selectedEditableKeys {get;set;}
    public StringCarrier selectedEditableKeysCarrier {get;set;}

    public static Set<String> setKeyWithGroups = new Set<String>{'Audience Segment'}; //keys who use groups
    public static final String GROUP_DIVIDER = '/'; //Group character divider -> Group[DIVIDER]Name
    public static final String OTHER_GROUP_NAME = 'Altri'; //Default Group name for uncategorized items


    public ControllerCustomCriteria(){
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
        this.editable = ApexPages.CurrentPage().getParameters().get('editable');
         
         //Selected EDITABLE KEYS
         if(this.sobjectName.equalsIgnoreCase('product__c')) {
           Product2 p = [SELECT Targeting_Keys_Editabili__c FROM Product2 WHERE Id = :id];
           this.selectedEditableKeys = p.Targeting_Keys_Editabili__c;
         } else {
           LineItem__c l = [SELECT Product__r.Targeting_Keys_Editabili__c FROM LineItem__c WHERE Id = :id];
           this.selectedEditableKeys = l.Product__r.Targeting_Keys_Editabili__c;           
         }
                    
        selectedEditableKeysCarrier = new StringCarrier(selectedEditableKeys);
                                    
        String query = 'select id,logicalOperator__c,';
        query += '(select Custom_Targeting_Key__r.visual_name__c,operator__c,valueIds__c,values__c from Custom_Criteria__r)';
        query += ' from CustomCriteriaSet__c where '+sobjectName+' = \''+id+'\'';

        Map<Decimal,String> customTargetingValueMap = new Map<Decimal,String>();
        for(CustomTargetingValue__c ctv : [select Iddfp__c,Group_Formula__c from CustomTargetingValue__c]){
            customTargetingValueMap.put(ctv.idDfp__c,ctv.Group_Formula__c);
        }
        
        CustomCriteriaSets = new List<CustomCriteriaSet>();
        setToDelete = DataBase.query(query);
        
        for(CustomCriteriaSet__c ccs : setToDelete){
            CustomCriteriaSet ccset = new CustomCriteriaSet();
            ccset.customCriterias = new list<Custom_Criteria__c>();
            for(Custom_Criteria__c cc : ccs.custom_criteria__r){
                Custom_Criteria__c ccClone = cc.clone();
                for(String k : cc.valueIds__c.split(',')){
                    ccClone.group__c = customTargetingValueMap.get(Decimal.valueOf(k));
                }
                ccset.customCriterias.add(ccClone);
            }
            CustomCriteriaSets.add(ccset);
        }
        
        
        keys = new SelectOption[]{};
        keysWithoutNone = new SelectOption[]{};
        visualKeyMap = new Map<id,String>();

        Set<String> keyFilter = new Set<String>();
        Boolean hasKeyFilter = !sobjectName.equalsIgnoreCase('product__c') && this.selectedEditableKeys != null && this.selectedEditableKeys != '';
        if(hasKeyFilter) {
            keyFilter.addAll((String[]) this.selectedEditableKeys.split(';'));
        }
        
        for(CustomTargetingKey__c ctk : [select id,Name,displayName__c,visual_name__c from CustomTargetingKey__c order by visual_name__c desc]){
            visualKeyMap.put(ctk.id,ctk.visual_name__c);
            if(!hasKeyFilter || keyFilter.contains(ctk.Id)){ 
                keysWithoutNone.add(new SelectOption(ctk.id,ctk.visual_name__c));  
            } else if(this.selectedEditableKeys.contains(ctk.Id)){ //selectedEditableKeys contiene anche le chiavi customtargetingkey+grouppo
                //lo aggiungo tra le chiavi modificabili ma
                keys.add(new SelectOption(ctk.id,ctk.visual_name__c));  
            }
        }                    

        map<string,string> groupKeys = new map<string,string>();
        for(CustomTargetingValue__c ctv : [select Group_Formula__c,CustomTargetingKey__c,CustomTargetingKey__r.visual_name__c from CustomTargetingValue__c where Status__c != 'INACTIVE' and Group_Formula__c <> null]){
                groupKeys.put((ctv.CustomTargetingKey__c+ctv.Group_Formula__c).left(40),ctv.CustomTargetingKey__r.visual_name__c+' / '+ctv.Group_Formula__c);
        }

        keys.addAll(keysWithoutNone);

        //solo per la multi select delle chiavi editabili, aggiungo i gruppi
        for(String g : groupKeys.keySet()){
            if(!hasKeyFilter || keyFilter.contains(g)){
                keysWithoutNone.add(new SelectOption(g,groupKeys.get(g)));
            }
        }
    
        keysString = selectOptionToString(keysWithoutNone);
    
        keysWithoutNone = UtilSortSelectOptions.selectOptionSortByLabel(keysWithoutNone);
        keys = UtilSortSelectOptions.selectOptionSortByLabel(keys);
        if(keys.size() > 0){
            keys.add(0, new SelectOption('','--none--'));            
        }else{
            keys.add(new SelectOption('','--none--'));            
        }
        
        customCriteria = null;
        showAction = true;
        edit = true;

        values = new List<SelectOption>();
    }
    
    public void deleteSet(){
        CustomCriteriaSets.remove(indexSet);   
    }
    
    public void addSet(){
        CustomCriteriaSet ccset = new CustomCriteriaSet();
        ccset.customCriterias = new list<Custom_Criteria__c>();
        CustomCriteriaSets.add(ccset);
        groupSelected = '';
    }
    
    public void deleteCustomCriteria(){
        CustomCriteriaSets.get(indexSet).customCriterias.remove(indexCC);
    }
    
    public void addCustomCriteria(){
        customCriteria = new Custom_Criteria__c();
        showAction = false;
        edit = false;
        groupSelected = '';
        values.clear();
    }
    
    public void editCustomCriteria(){
        customCriteria = CustomCriteriaSets.get(indexSet).customCriterias.get(indexCC);
        selectedValues = new List<String>();
        String values = customCriteria.valueIds__c;
        System.Debug('PuntoDebug - customCriteria: '+customCriteria);
        System.Debug('PuntoDebug - values: '+values);
        if(values != null){
            selectedValues = values.split(',');
        }
        showAction = false;
        edit = true;
        getKeyValues();

        if (showGroupOptions) {
            groupSelected = getGroupFromCriteria();
            populateOptions();
            disableGroupSelection = true;
        }
    }
    
    public void saveCustomCriteria(){
        string valueIds = '';
        string values = '';
        System.Debug('PuntoDebug - selectedValues: '+selectedValues);     
        if(selectedValues.size() > 0){
            for(string s : selectedValues){
                valueIds += s+',';
                values += idsValueMap.get(s)+',';
            }
            valueIds += ',';
            valueIds = valueIds.replace(',,','');
            values += ',';
            values = values.replace(',,','');            
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'E\' necessario selezionare almeno un valore'));
            System.Debug('PuntoDebug - Nessun elemento selezionato');
            return;
        } 
        customCriteria.valueIds__c = valueIds;
        customCriteria.values__c = values;
        
        if(!edit){
            CustomCriteriaSets.get(indexSet).customCriterias.add(customCriteria);
        }
        customCriteria = null;
        showAction = true;
        showGroupOptions = false;
    }
    
    public void cancelCustomCriteria(){
        customCriteria = null;
        showAction = true;
        showGroupOptions = false;
    }    
    
    public void resetKey(){
        customCriteria.Custom_Targeting_Key__c = null;
        getKeyValues();
    }    
    
    
 public Pagereference customSave(){
        System.debug('selectedEditableKeysCarrier.value = '+selectedEditableKeysCarrier.value);
        LineItemTriggerHandler.SkipUpdateLineItem = true;
        if(selectedEditableKeysCarrier.value != null && sobjectName.equalsIgnoreCase('product__c')) {
            Product2 p = new Product2(Id = id, Targeting_Keys_Editabili__c = selectedEditableKeysCarrier.value);
            update p;
        }
        
        list<CustomCriteriaSet__c> sets = new list<CustomCriteriaSet__c>();
        for(CustomCriteriaSet s : CustomCriteriaSets ){
            CustomCriteriaSet__c ss = new CustomCriteriaSet__c(logicalOperator__c='AND');
            ss.put(sobjectName,id);
            sets.add(ss);
        }
        system.debug('insert sets');
        insert sets;
        list<Custom_Criteria__c> customCriterias = new list<Custom_Criteria__c>();
        for(integer i=0;i<sets.size();i++){
            CustomCriteriaSet__c ss = sets.get(i);
            for(Custom_Criteria__c cc : CustomCriteriaSets.get(i).customCriterias){
                cc.Custom_Criteria_Set__c = ss.id;
                customCriterias.add(cc);
            }
        }

        system.debug('insert customCriterias');
        insert customCriterias;
        
        system.debug('delete setToDelete');
        delete setToDelete;
        
        //Forza ricalcolo campo custom criteria
        if (sobjectName.equalsIgnoreCase('lineitem__c')) {
            LineItemTriggerHandler.skipValidationTotali = true;
            update new LineItem__c(Id=id, Bacino_modificato__c=true);
        }

        Pagereference p = new PageReference('/apex/editCustomCriteriaComponent?sobjectName=' + sobjectName + '&id=' + id + '&editMode=false&editable=' + editable);
        p.setRedirect(true);
        return p;
    }
    
    public List<SelectOption> getIsNot() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('IS','È'));
        options.add(new SelectOption('IS_NOT','NON È'));        
        return options;
    }
    
    public void changeValues(){
        System.debug('Change values ');
        //throw new nullpointerexception();
        //getValues();
    }
    
    public void getKeyValues() {
        idsValueMap = new Map<String,String>();

        List<SelectOption> options = new List<SelectOption>();
        id key = customCriteria.Custom_Targeting_Key__c;
        System.debug('Get values of ' + key);

        List<CustomTargetingValue__c> listCTValue = [select id,visual_name__c,idDfp__c, Group_Formula__c, CustomTargetingKey__r.displayName__c from CustomTargetingValue__c where CustomTargetingKey__c =: key and status__c != 'INACTIVE'];
        String keyName = null;
        if (!listCTValue.isEmpty()) { keyName = listCTValue.get(0).CustomTargetingKey__r.displayName__c; } //Same value for every value in the list
        System.Debug('PuntoDebug - keyName: '+keyName);

        if (keyName != null && setKeyWithGroups.contains(keyName)) { //Populating another list option
             showGroupOptions = true;
             disableGroupSelection = false;
             mapKeyGroupOptions = new Map<String, List<SelectOption>>(); 
             mapValueIdGroup = new Map<String, String>();
             for(CustomTargetingValue__c ctv : listCTValue){
                System.Debug('PuntoDebug - ctv.Group_Formula__c: '+ctv.Group_Formula__c);
                System.Debug('PuntoDebug - ctv.visual_name__c: '+ctv.visual_name__c);
                //Default value, no group
                String groupName = OTHER_GROUP_NAME;
                String visualName = ctv.visual_name__c;
                //Check if there's group and name based on divider
                if (visualName != null && ctv.Group_Formula__c != null) {
                    groupName = ctv.Group_Formula__c;
                    visualName = visualName.replace(ctv.Group_Formula__c+GROUP_DIVIDER, '');
                }
                //Populating the Map

                //keysString contiene anche le chiavi customtargetingkey+grouppo
                //se è altri devo aver inserito la chiave tra quelle editabili, se no devo aver inserito chiave+gruppo
                if((groupName == OTHER_GROUP_NAME && !keysString.contains(key+';')) || (groupName != OTHER_GROUP_NAME && !keysString.contains(key+groupName))){
                    continue;
                }

                if (mapKeyGroupOptions.get(groupName) == null) { //Map Initialization
                    mapKeyGroupOptions.put(groupName, new List<SelectOption>());    
                }
                mapKeyGroupOptions.get(groupName).add(new SelectOption(ctv.idDfp__c+'',visualName));
                idsValueMap.put(ctv.idDfp__c+'',ctv.visual_name__c);
                mapValueIdGroup.put(ctv.idDfp__c+'', groupName);
            }
            populateGroups();
            System.Debug('PuntoDebug - mapKeyGroupOptions: '+mapKeyGroupOptions);
        } else { //Populating option directly (AS IS)
            showGroupOptions = false;
            for(CustomTargetingValue__c ctv : listCTValue){
                options.add(new SelectOption(ctv.idDfp__c+'',ctv.visual_name__c));
                idsValueMap.put(ctv.idDfp__c+'',ctv.visual_name__c);
            }
        }

        System.Debug('PuntoDebug - showGroupOptions: '+showGroupOptions);
        system.debug(options);
        values = UtilSortSelectOptions.selectOptionSortByLabel(options);
    }

    /*This function populate the Select Option groups*/
    private void populateGroups() {
        groups = new List<SelectOption>();
        SelectOption soOthers;
        groups.add(new SelectOption('','--none--')); //Default, not selected
        //Creating list for sort elements
        List<String> groupsSorted = new List<String>();
        groupsSorted.addAll(mapKeyGroupOptions.keySet());
        groupsSorted.sort();
        for (String groupName : groupsSorted) {
            SelectOption so = new SelectOption(groupName, groupName);
            System.Debug('PuntoDebug - current group to parse: '+so);
            if (groupName == OTHER_GROUP_NAME) {
                soOthers = so;
            } else {
                groups.add(so);
            }
        }
        //Adding the Other groups SelectOption at the end of the list
        groups.add(soOthers);

        System.Debug('PuntoDebug - groups: '+groups);
    }

    /* This function pupulate options list from group selected */
    public void populateOptions() {
        System.Debug('PuntoDebug - mapKeyGroupOptions in populateOptions: '+mapKeyGroupOptions);
        System.debug('groupSelected = '+groupSelected);
        List<SelectOption> optionsFromGroup = new List<SelectOption>();
        if(!String.isBlank(groupSelected)){
            optionsFromGroup.addAll(mapKeyGroupOptions.get(groupSelected));
            System.Debug('PuntoDebug - optionsFromGroup: '+optionsFromGroup);
            values = new List<SelectOption>();
            if (optionsFromGroup != null) {
                values = UtilSortSelectOptions.selectOptionSortByLabel(optionsFromGroup);
            }
        }else{
            values = new List<SelectOption>();
        }
        System.Debug('PuntoDebug - values: '+values);
    }

    /*Get the Group from value selected*/
    public String getGroupFromCriteria() {
        String groupReturned = null;
        for (String s : selectedValues) {
            if (mapValueIdGroup.containsKey(s)) {
                groupReturned = mapValueIdGroup.get(s);
                break;
            }
        }

        return groupReturned;
    }

    public string selectOptionToString(list<selectOption> selects){
        String ss = ';';
        for(selectOption s : selects){
            ss += s.getValue()+';';
        }
        return ss;
    }
    
    public class CustomCriteriaSet {
        public list<Custom_Criteria__c> customCriterias {get;set;}
    }
    
    static testMethod void testController() {       
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;
        
        CustomTargetingKey__c ct = new CustomTargetingKey__c();
        ct.Name = 'Test';
        insert ct;
        
        CustomTargetingValue__c cv = new CustomTargetingValue__c();
        cv.Name = 'Test';
        cv.CustomTargetingKey__c = ct.Id;
        insert cv;
        
        List<String> sVal = new List<String>();
        sVal.add('1234');    
        
        ApexPages.CurrentPage().getParameters().put('id',p.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','Product__c');   
       
        ControllerCustomCriteria cp = new ControllerCustomCriteria();
        cp.idsValueMap = new Map<String,String>{'1234' => '1234'}; 
        cp.indexSet = 0;
        cp.selectedValues = sVal;
        
        cp.addSet();
        cp.addCustomCriteria();
        cp.customCriteria.Custom_Targeting_Key__c = ct.Id;
        cp.saveCustomCriteria();
        cp.customSave();
       
        cp = new ControllerCustomCriteria();
        cp.selectedValues = sVal;
        cp.indexSet = 0;
        cp.indexCC = 0;
        
        cp.editCustomCriteria();
        cp.deleteCustomCriteria();
        cp.deleteSet();
        cp.getIsNot();
        //cp.key = ct.Id;
        cp.getKeyValues();
        cp.resetKey();
        cp.cancelCustomCriteria();
        
       
       
     }

}