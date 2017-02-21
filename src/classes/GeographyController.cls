global class GeographyController {

	/** SEARCH STUFF */
    global class Element implements Comparable{
        public Boolean checked {get;set;}
        public String nodoId {get;set;}
        public String name {get;set;}
        public String type {get;set;}
        public String parentId {get;set;}
        public String countryCode {get;set;}
        public String label {get;set;}

        public List<Element> childs {
        	get{
        		if(childs == null){
        			childs = new List<Element>();
        		}
        		return childs;
        	}
        	set;
       	}

        public Element() {
            this.checked = false;
            childs = new List<Element>();
        }

        global Integer compareTo(Object obj) {
            Element el = (Element) obj;
            return this.label.compareTo(el.label);
        }
    }
    
    public Element results {get;set;}    

	public sobject parent {get;set;} //LineItem__c or Product2 object
	public String id {get;set;}

	private String parentSobjectType;
    private Id parentId;
    
    public String includedIdsString {get;set;}
    public String excludedIdsString {get;set;}
    public Set<String> includedIds;
    public Set<String> excludedIds;
     
    public Geography__c obj {get; set;}
    public List<SelectOption> options {get;set;}
    public String mode {get;set;}
    public String searchResultJson {get;set;}

    Map<String,String> translations = new Map<String,String>();

	public GeographyController() {
        results = new Element();

        List<Translations__c> translationsList = Translations__c.getAll().values();
        for(Translations__c t : translationsList){
            if(t.Type__c == 'Geography'){
                translations.put(t.Name, t.ItalianTranslation__c);
            }
        }
        
        parentSobjectType = ApexPages.CurrentPage().getParameters().get('sobjectName'); 
        parentId = ApexPages.CurrentPage().getParameters().get('id');
        mode = ApexPages.CurrentPage().getParameters().get('mode');
        List<Geography__c> objs = Database.query('SELECT Id, IncludedValuesIds__c, matches__c, excludedValuesIds__c FROM Geography__c WHERE ' + parentSobjectType + '= :parentId');

        if(objs.isEmpty()) {
            obj = new Geography__c();
            obj.put(parentSobjectType, parentId);
            includedIdsString = '';
            excludedIdsString = '';         
        } else {
            obj = objs.get(0);
            includedIdsString = obj.IncludedValuesIds__c == null ? '' : obj.IncludedValuesIds__c;
            excludedIdsString = obj.excludedValuesIds__c == null ? '' : obj.excludedValuesIds__c;
        }
        
        includedIds = new Set<String>();
        excludedIds = new Set<String>();
        if(obj.IncludedValuesIds__c != null && obj.IncludedValuesIds__c != '') {
            includedIds.addAll(obj.IncludedValuesIds__c.split(';'));
        }               
        if(obj.excludedValuesIds__c != null && obj.excludedValuesIds__c != '') {
            excludedIds.addAll(obj.excludedValuesIds__c.split(';'));
        }           
        
        options = new List<SelectOption>();
        options.add(new SelectOption('Includi', 'Includi'));
        options.add(new SelectOption('Escludi', 'Escludi'));
        
        DfpIntegration dfp = new DfpIntegration();

        searchResultJson = '';
        String query = ' select id, CanonicalParentId, name, countrycode, type from geo_target ' +
        				' WHERE targetable = true and ' +
        				' (countrycode = \'VA\' or countrycode = \'SM\' or '+ // città del vaticano e san marino
        				'  ( countrycode = \'IT\' and (type = \'REGION\' or type = \'PROVINCE\' or type = \'COUNTRY\') ) ) ' + // oppure italia
        				' order by name limit 500 offset 0 ';
         
        DfpPublisherQueryLanguageService.Statement selectStatement = new DfpPublisherQueryLanguageService.Statement();                      
        selectStatement.query = query;
        DfpPublisherQueryLanguageService.ResultSet resultSet = null;
        if(!Test.isRunningTest()){
            resultSet = dfp.PublisherQueryLanguageService.select_x(selectStatement);
        }else{
            DfpPublisherQueryLanguageService.Row italia = new DfpPublisherQueryLanguageService.Row();
            italia.values = new DfpPublisherQueryLanguageService.Value[5];
            italia.values[0] = new DfpPublisherQueryLanguageService.Value();
            italia.values[0].value = '1';
            italia.values[1] = new DfpPublisherQueryLanguageService.Value();
            italia.values[1].value = '';
            italia.values[2] = new DfpPublisherQueryLanguageService.Value();
            italia.values[2].value = 'italia';
            italia.values[3] = new DfpPublisherQueryLanguageService.Value();
            italia.values[3].value = 'IT';
            italia.values[4] = new DfpPublisherQueryLanguageService.Value();
            italia.values[4].value = 'COUNTRY';

            DfpPublisherQueryLanguageService.Row lombardia = new DfpPublisherQueryLanguageService.Row();
            lombardia.values = new DfpPublisherQueryLanguageService.Value[5];
            lombardia.values[0] = new DfpPublisherQueryLanguageService.Value();
            lombardia.values[0].value = '2';
            lombardia.values[1] = new DfpPublisherQueryLanguageService.Value();
            lombardia.values[1].value = italia.values[0].value;
            lombardia.values[2] = new DfpPublisherQueryLanguageService.Value();
            lombardia.values[2].value = 'lombardia';
            lombardia.values[3] = new DfpPublisherQueryLanguageService.Value();
            lombardia.values[3].value = 'IT';
            lombardia.values[4] = new DfpPublisherQueryLanguageService.Value();
            lombardia.values[4].value = 'REGION';

            DfpPublisherQueryLanguageService.Row milano = new DfpPublisherQueryLanguageService.Row();
            milano.values = new DfpPublisherQueryLanguageService.Value[5];
            milano.values[0] = new DfpPublisherQueryLanguageService.Value();
            milano.values[0].value = '3';
            milano.values[1] = new DfpPublisherQueryLanguageService.Value();
            milano.values[1].value = lombardia.values[0].value;
            milano.values[2] = new DfpPublisherQueryLanguageService.Value();
            milano.values[2].value = 'milano';
            milano.values[3] = new DfpPublisherQueryLanguageService.Value();
            milano.values[3].value = 'IT';
            milano.values[4] = new DfpPublisherQueryLanguageService.Value();
            milano.values[4].value = 'PROVINCE';

            resultSet = new DfpPublisherQueryLanguageService.ResultSet();
            resultSet.rows = new DfpPublisherQueryLanguageService.Row[3];
            resultSet.rows[0] = italia;
            resultSet.rows[1] = lombardia;
            resultSet.rows[2] = milano;
        }
        
        List<Element> paesi = new List<Element>();
        List<Element> regioni = new List<Element>();
        List<Element> province = new List<Element>();
        if(resultSet.rows != null) {
            for(Integer i = 0; i < resultSet.rows.size(); i++) {
                DfpPublisherQueryLanguageService.Row row = resultSet.rows.get(i);
                Element el = new Element();
                el.nodoId = row.values[0].value;
                el.parentId = row.values[1].value;
                el.name = row.values[2].value;
                el.countryCode = row.values[3].value;
                el.label = getTranslation(el.name);
                el.type = row.values[4].value; 
                if(el.type == 'COUNTRY'){ 
	        		paesi.add(el);
	        	}
	        	if(el.type == 'REGION'){ 
	        		regioni.add(el);
	        	}
	        	if(el.type == 'PROVINCE'){ 
	        		province.add(el);
	        	}      
            }
        }

        for(Element paese : paesi){
        	for(Element regione : regioni){
        		if(regione.parentId == paese.nodoId){ // è una regione di questo paese
        			for(Element provincia : province){
        				if(provincia.parentId == regione.nodoId){ // è una provincia di questa regione
        					regione.childs.add(provincia);
        				}
        			}
        			paese.childs.add(regione);
        		}
        	}
        	results.childs.add(paese);
        }

        sortTree();
        
        searchResultJson = buildJsonResponse().replace('\'','\\\'');
        System.debug(LoggingLevel.WARN,searchResultJson);
    }

    private String buildJsonResponse (){
    	return '[' + buildJsonResponse(results) + ']';
    }

    private String buildJsonResponse (Element root){
    	String jsonChilds = '';
    	boolean hasChilds = root.childs.size() > 0;
    	for(Integer index = 0; index < root.childs.size() ; index ++){
    		jsonChilds += buildJsonResponse(root.childs.get(index));
    		if(index < root.childs.size()-1){
    			jsonChilds += ',';
    		}
    	}
    	String jsonElement = '';    	
    	if(root.nodoId != null){
    		jsonElement = 	'{"id":' + root.nodoId + ',"disabled":false,"checked":false' + 
    						',"parentId":' + (root.parentId != '' ? root.parentId : 'null') + ',"label":"' + root.label + '","name":"' + root.name + 
    						'","type":"' + root.type + '","inode":' + hasChilds + ',"checkbox":true,"radio":false' +
    						(hasChilds ? ',"branch":[' + jsonChilds + ']' : '') + '}';	
    	}else{
    		jsonElement = jsonChilds;
    	}    	
    	return jsonElement;
    }

    public PageReference goInEditMode() {
        mode = 'edit';
        return null;    
    }

    public PageReference customSave() {
        obj.IncludedValuesIds__c = includedIdsString;
        if(obj.IncludedValuesIds__c.endsWith(';')) obj.IncludedValuesIds__c = obj.IncludedValuesIds__c.substring(0, obj.IncludedValuesIds__c.length() - 1);
        obj.excludedValuesIds__c = excludedIdsString;       
        if(obj.excludedValuesIds__c.endsWith(';')) obj.excludedValuesIds__c = obj.excludedValuesIds__c.substring(0, obj.excludedValuesIds__c.length() - 1);     
        if(obj.Id != null) update obj;
        else insert obj; 
        mode = 'view';
        results = new Element();
        return null;    
    }

    private String getTranslation(String textToTranslate){
        String translation = translations.get(textToTranslate);
        return translation != null ? translation : textToTranslate;
    }

    private void sortTree(){
        sortTree(null);
    }

    private void sortTree(Element root){
        if(root == null){
            root = results;
        }else{
            root.childs.sort();
        }
        if(root.childs.size() == 0){
            return;
        }
        for(Element child : root.childs){
            sortTree(child);
        }
    }

}