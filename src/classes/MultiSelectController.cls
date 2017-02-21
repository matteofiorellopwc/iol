public class MultiSelectController {			
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;}

    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();	
	
	Boolean picklistValueInit = false;
	Boolean originalValuesInit = false;
	
	Map<String, SelectOption> soMap = new Map<String, SelectOption>();
	
	SelectOption[] originalValues; 
	StringCarrier picklistValue;
	
    public MultiSelectController(){
        leftselected = new List<String>();
        rightselected = new List<String>();
    }
	
	public SelectOption[] getOriginalValues() {
		return this.originalValues;
	}
	
	public void setOriginalValues(SelectOption[] ov) {
		if(originalValuesInit && picklistValueInit) return;
		this.originalValues = ov;
		for(SelectOption so : originalValues) {
			System.debug(so);
        	leftvalues.add(so.getValue());
        	soMap.put(so.getValue(), so);
		}		
		
		originalValuesInit = true;		
		if(!picklistValueInit) {			
			setPicklistValue(picklistValue);
		}
	}
	
	public StringCarrier getPicklistValue() {
		return this.picklistValue;
	}
	
	public void setPicklistValue(StringCarrier sc) {						
		this.picklistValue = sc;		
		if(!picklistValueInit && sc != null) {
			if(picklistValue.value != null && picklistValue.value != '') {
				for(String soId : picklistValue.value.split(';')) {
					leftValues.remove(soId);
					rightValues.add(soId);
				}			
			}						
			picklistValueInit = originalValuesInit;
		}
	}
					
	public String getSelectedLabels() {
		String res = '';
		if(picklistValue.value != null && picklistValue.value != '') {					
			for(String s : picklistValue.value.split(';')) {
				if(soMap.containsKey(s)) {
					res += soMap.get(s).getLabel() + ', ';
				}
			}
		}
		return res.substringBeforeLast(', ');
	}	     

    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected) {
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }


    public List<SelectOption> getunSelectedValues(){		
        List<SelectOption> options = new List<SelectOption>();
        if(!picklistValueInit || !originalValuesInit) return options;		
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList) {
            options.add(soMap.get(s));
        }
        return UtilSortSelectOptions.selectOptionSortByLabel(options);
    }


    public List<SelectOption> getSelectedValues(){		        
        List<SelectOption> options1 = new List<SelectOption>();
        if(!picklistValueInit || !originalValuesInit) return options1;		
				
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();

		picklistValue.value = '';
        for(String s : tempList) {    
        	System.debug(s);    	
			picklistValue.value += soMap.get(s).getValue() + ';';
            options1.add(soMap.get(s));
        }
        picklistValue.value = picklistValue.value.substringBeforeLast(';');
        System.debug(picklistValue);
        return UtilSortSelectOptions.selectOptionSortByLabel(options1);
    }
    
    public class CustomCriteriaSet {
        public list<Custom_Criteria__c> customCriterias {get;set;}
    }
    
    @isTest
    static void testController() {
    	Selectoption[] originalValues = new SelectOption[]{
    		new SelectOption('a', 'A'),
    		new SelectOption('b', 'B'),
    		new SelectOption('c', 'C')    		
    	};
    	
    	String selectedValues = 'a;b';
    	
		Test.startTest();    	
    	MultiSelectController msc = new MultiSelectController();
    	msc.setPicklistValue(new StringCarrier(selectedValues));
    	msc.setOriginalValues(originalValues);
    			
		System.assertEquals('A, B', msc.getSelectedLabels());
		
		SelectOption[] leftOptions = msc.getunSelectedValues();
		System.assertEquals(1, leftOptions.size());
		System.assertEquals('C', leftOptions[0].getLabel());
		    			
		SelectOption[] rightOptions = msc.getSelectedValues();
		System.assertEquals(2, rightOptions.size());
		System.assertEquals('A', rightOptions[0].getLabel());
		    			
		msc.leftselected.add('c');
		msc.selectclick();

		leftOptions = msc.getunSelectedValues();
		System.assertEquals(0, leftOptions.size());

		msc.rightselected.add('a');
		msc.unselectclick();
						   
		rightOptions = msc.getSelectedValues();
		System.assertEquals(2, rightOptions.size());
		System.assertEquals('B', rightOptions[0].getLabel());
		
		Test.stopTest();						    			
    }
}