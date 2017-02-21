public class AdUnitsDfpCtrl {
    // Due liste di AdUnit per aggirare il limite di 1000 elementi
    public List<AdUnit> adUnitDfpList1 {get;set;}
    public List<AdUnit> adUnitDfpList2 {get;set;}
    public List<AdUnit> adUnitDfpList3 {get;set;}
    public List<AdUnit> adUnitDfpList4 {get;set;}
    
    public List<String> canaliPrimariSelected {get;set;}
    
    // Costante che determina label e valore per lo sbiancamento del canale primario
    private static final String valoreVuoto = '-------------- Nessuno ---------------';
    
    public SyncDfp syncDfp {get;set;}
    
    public AdUnitsDfpCtrl() {
        canaliPrimariSelected = new List<String>();
        retrieveAdUnits();
        syncDfp = new SyncDfp(); 
    }
    
    /* Assegna il canale primario agli AdUnit */
    public void assignCanalePrimario() {
        List<AdUnit__c> adUnitDfpList = new List<AdUnit__c>();
        //Lista 1 (Max 1000 valori)
        for(AdUnit au : adUnitDfpList1) {
            if(au.checked) {
                AdUnit__c adUnit = new AdUnit__c();
                adUnit.Id = au.adUnit.Id;
                if(canaliPrimariSelected.size() == 1 && canaliPrimariSelected[0] == valoreVuoto) {
                    adUnit.CanalePrimario__c = '';
                }
                else {
                    adUnit.CanalePrimario__c = '';
                    for(String cps : canaliPrimariSelected) {
                        if(cps != valoreVuoto) {  
                            adUnit.CanalePrimario__c = adUnit.CanalePrimario__c + cps + ';';
                        }
                    }
                }
                adUnitDfpList.add(adUnit);
            }           
        }
        //Lista 2 (Max 1000 valori)
        for(AdUnit au : adUnitDfpList2) {
            if(au.checked) {
                AdUnit__c adUnit = new AdUnit__c();
                adUnit.Id = au.adUnit.Id;
                if(canaliPrimariSelected.size() == 1 && canaliPrimariSelected[0] == valoreVuoto) {
                    adUnit.CanalePrimario__c = '';
                }
                else {
                    adUnit.CanalePrimario__c = '';
                    for(String cps : canaliPrimariSelected) {
                        if(cps != valoreVuoto) {  
                            adUnit.CanalePrimario__c = adUnit.CanalePrimario__c + cps + ';';
                        }
                    }
                }
                adUnitDfpList.add(adUnit);
            }           
        }
        
        for(AdUnit au : adUnitDfpList3) {
            if(au.checked) {
                AdUnit__c adUnit = new AdUnit__c();
                adUnit.Id = au.adUnit.Id;
                if(canaliPrimariSelected.size() == 1 && canaliPrimariSelected[0] == valoreVuoto) {
                    adUnit.CanalePrimario__c = '';
                }
                else {
                    adUnit.CanalePrimario__c = '';
                    for(String cps : canaliPrimariSelected) {
                        if(cps != valoreVuoto) {  
                            adUnit.CanalePrimario__c = adUnit.CanalePrimario__c + cps + ';';
                        }
                    }
                }
                adUnitDfpList.add(adUnit);
            }           
        }
        
        for(AdUnit au : adUnitDfpList4) {
            if(au.checked) {
                AdUnit__c adUnit = new AdUnit__c();
                adUnit.Id = au.adUnit.Id;
                if(canaliPrimariSelected.size() == 1 && canaliPrimariSelected[0] == valoreVuoto) {
                    adUnit.CanalePrimario__c = '';
                }
                else {
                    adUnit.CanalePrimario__c = '';
                    for(String cps : canaliPrimariSelected) {
                        if(cps != valoreVuoto) {  
                            adUnit.CanalePrimario__c = adUnit.CanalePrimario__c + cps + ';';
                        }
                    }
                }
                adUnitDfpList.add(adUnit);
            }           
        }
        
        
        update adUnitDfpList;
        retrieveAdUnits();
        syncDfp.syncDfpDataModel();
        
    }
    
    /* Recupera i valori di picklist dal campo CanalePrimario__c dell'AdUnit */
    public List<SelectOption> getCanaliPrimari() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = AdUnit__c.CanalePrimario__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        options.add(new SelectOption(valoreVuoto, valoreVuoto));
        return options;
    }
 
    /* Recupera le AdUnits Dfp */
    private void retrieveAdUnits() {
        this.adUnitDfpList1 = new List<AdUnit>();
        this.adUnitDfpList2 = new List<AdUnit>();
        this.adUnitDfpList3 = new List<AdUnit>();
        this.adUnitDfpList4 = new List<AdUnit>();
        Integer i = 0;
        for (AdUnit__c au : [SELECT Name, Ad_Server__c, CanalePrimario__c, Path__c, Level__c 
                             FROM AdUnit__c 
                             WHERE Ad_Server__c = 'DFP'
                             AND showAdUnitFormula__c = TRUE]) {
            AdUnit auTmp = new AdUnit();
            auTmp.adUnit = au;
            auTmp.checked = false;
            if(i < 1000) {
                adUnitDfpList1.add(auTmp);
            } else if(i >= 1000 && i<2000){
                adUnitDfpList2.add(auTmp);    
            }else if(i >= 2000 && i<3000){
                adUnitDfpList3.add(auTmp);
            }else if(i >= 3000 && i<4000){
                adUnitDfpList4.add(auTmp);        
            }
            i++;
        }
    }
    
    /* AdUnit__c Wrapper Class */
    public class AdUnit {
        public AdUnit__c adUnit {get;set;}
        public boolean checked {get;set;}
    }

    public class SyncDfp {
        public AsyncApexJob  aaj {get;set;}
        public Boolean jobIsRunning {get;set;}

        public void syncDfpDataModel() {
            id sfdcJobID = Database.executeBatch(new BatchableUpsertImpressionStimate(), 5);
            aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: sfdcJobID ];
            jobIsRunning = checkJobIsRunning(aaj.Status);
        }
    
        public void getJobStatus() {
            aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: aaj.id];
            jobIsRunning = checkJobIsRunning(aaj.Status);
        }
        
        private Boolean checkJobIsRunning(String status) {
            Boolean value;
            
            if(status == 'Queued') {
                value = true;    
            }else if(status == 'Preparing') {
                value = true;
            }else if(status == 'Processing') {
                value = true;
            } else {
                value = false;    
            }
            
            return value;
        }
    }
}