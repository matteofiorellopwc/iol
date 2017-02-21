public class ExtensionOpportunityOasIntegration {
    String oppId;
    public List<LineItem__c> sfdcLineItems {get;set;}
    private set<string> idOasOldCampaigns;
    public Opportunity o {get;set;}

    public ExtensionOpportunityOasIntegration(ApexPages.StandardController controller) {
        this.oppId = controller.getId();
        init();
    }
    
    //constructor for remote methods, takes as input only OppId
    public ExtensionOpportunityOasIntegration(String arg){
        this.oppId = arg;
        init();
    }
    
    public void init(){
        o = [select id,name,identificativo_campagna__c,account.id_oas__c,centro_media__c,centro_media__r.id_oas__c,id_oas__c,
                                data_inizio__c,data_fine__c,isWon,status_oas__c,Ultima_sincronizzazione_OAS__c
                         from opportunity where id =: oppId
                        ];
                        
        this.sfdcLineItems = OasIntegration.getLineItemsByOppId(oppId,true,true);   
        idOasOldCampaigns = new set<string>();
        for(lineitem__c li : [select id_oas__c from lineitem__c 
                              where id_oas__c <> null 
                              and Integrato_con_OAS_formula__c = 'false'
                              and (NOT id_oas__c  LIKE '%_nosincro')
                              and opportunity__c =: oppId 
                             ]){
            idOasOldCampaigns.add(li.id_oas__c);
        }
    }
    
    public void upsertSfToOas(){
        upsertSfToOas(true,null);
    }

    public void upsertSfToOas(boolean doDml){
        upsertSfToOas(doDml,null);
    }
    
    /*
        upsert opportunity and all line items from sf to oas
        if doDml is true perform update in salesforce
    */
    public void upsertSfToOas(boolean doDml, OasIntegration oas){
        //skip commercial check on line item
        LineItemTriggerHandler.skipValidationTotali = true;
        
        if(oas == null){
            oas = new OasIntegration();
        }

        if(o.account.id_oas__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il brand deve essere sincronizzato con oas'));
            return;
        }
        if(o.centro_media__c != null && o.centro_media__r.id_oas__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Il centro media deve essere sincronizzato con oas'));        
            return;
        }

        lineItem__c[] lis = sfdcLineItems;
        
        lineitem__c[] liToInsert = new lineItem__c[]{}; //to insert on oas
        lineitem__c[] liToUpdate = new lineItem__c[]{}; //to update on oas
        
        lineitem__c[] liToUpdateSf = new lineitem__c[]{}; //to update on sf
        
        string[] campaignsIdOas = new string[]{};
        campaignsIdOas.addAll(idOasOldCampaigns);
        
        map<string,oasIntegration.campaignClass> campMap;
        
        if(o.id_oas__c != null){
            campMap = getCampaignMap();
        }
        system.debug('campMap: '+campMap);
        
        for(lineitem__c li : lis){
            
            if(li.id_oas__c == null){
                //NB The status for a new Campaign must be W (Work in Progress) or T (Template)
                li.status_oas__c = 'W';
                li.id_oas__c = o.Identificativo_Campagna__c+'_'+li.name+'_'+li.Formato_formula__c+'_'+li.product__r.size__c;
                li.Id_oas__c = OasIntegration.removeChatsFromOasId(li.Id_oas__c);
                li.Id_oas__c = li.Id_oas__c.left(64); //limits 64 chars for oas id
                liToInsert.add(li);
            }else{
                if(campMap != null && campMap.get(li.id_oas__c) != null && campMap.get(li.id_oas__c).status == 'L'){
                    li.status_oas__c = 'L';
                }
                liToUpdate.add(li);  
                campaignsIdOas.add(li.id_oas__c);       
            }
        }
        
        system.debug('dopo :' + lis);
        
        boolean doUpdateO = false;
        
        try{
            if(liToInsert.size()> 0){
                oas.syncLineItems(liToInsert, 'add');
            }
        }catch(exception e){
        }finally{
            try{
                for(integer i=0;i<liToInsert.size();i++){
                    if(!OasApiProxy.responses.get(i).isException){
                        liToUpdateSf.add(liToInsert.get(i));
                        campaignsIdOas.add(liToInsert.get(i).id_oas__c);
                    }else{                  
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la creazione di '+liToInsert.get(i).name_dfp__c+' su OAS: '+OasApiProxy.responses.get(i).message));
                    }
                }
            }catch(exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la creazione dei nuovi line item'));
            }
        }
        
        try{
            if(liToUpdate.size() > 0){
                oas.syncLineItems(liToUpdate, 'update');
            }
        }catch(exception e){
        }finally{
            try{
                for(integer i=0;i<liToUpdate.size();i++){
                    if(!OasApiProxy.responses.get(i).isException){
                        liToUpdateSf.add(liToUpdate.get(i));
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante l\'aggiornamento di '+liToUpdate.get(i).name_dfp__c+' su OAS: '+OasApiProxy.responses.get(i).message));
                    }
                }
            }catch(exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante l\'aggiornamento dei line item'));
            }
        }

        string oOperation = 'update'; //add or update
        if(o.Id_Oas__c == null){
            o.id_oas__c = o.account.id_oas__c.left(54) + '_' + o.identificativo_campagna__c; //limits 64 chars for OAS id (54+10)
            if(o.status_oas__c == null){
                o.status_oas__c = 'P';
            }
            oOperation = 'add';
        }

        try{
            system.debug('campaignsIdOas ' + campaignsIdOas);
            oas.syncOpp(o,campaignsIdOas,oOperation);
            doUpdateO = true;
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore durante la sincronizzazione dell\'ordine su OAS '+e.getMessage()));
        }
        
        
        if(o.id_oas__c != null && doUpdateO){ //if no errors in order sync

            //read status for all campagins
            campMap = getCampaignMap();
            
            for(lineitem__c li : liToUpdateSf){
                if(li.id_oas__c != null && campMap.get(li.id_oas__c) != null){
                    li.status_oas__c = campMap.get(li.id_oas__c).status;
                }
            }
        }
        
        if(doDml){
            update liToUpdateSf;
            if(doUpdateO){
                o.Ultima_sincronizzazione_OAS__c = system.now();
                update o;
            }
        }
        init();
    }
    
    public void confirmOrder(){
        confirmOrder(true);
    }
    
    public void confirmOrder(boolean doDml){
        OasIntegration oas = new OasIntegration();
        
        map<string,oasIntegration.campaignClass> campMap = getCampaignMap();
        
        string[] lis = new string[]{};
        for(LineItem__c li : sfdcLineItems){
            li.status_oas__c = 'R';
            if(campMap != null && campMap.get(li.id_oas__c) != null && campMap.get(li.id_oas__c).status == 'L'){
                li.status_oas__c = 'L';
            }else{
                lis.add(li.id_oas__c);
            }
        }
        system.debug(lis);
        oas.updateCampaignsStatus(lis,'R');
        o.status_oas__c = 'A';
        oas.updateOrderStatus(o.id_oas__c,'A');
        if(doDml){
            update o;
            update sfdcLineItems;
        }
    }
    
    public void reserveOrder(){
        reserveOrder(true);
    }
    
    public void reserveOrder(boolean doDml){
        OasIntegration oas = new OasIntegration();
        string[] lis = new string[]{};
        
        map<string,oasIntegration.campaignClass> campMap = getCampaignMap();
        
        
        for(LineItem__c li : sfdcLineItems){
            //change status only if it's work in progress 
            //otherwise it's already changed on OAS
            if(Test.isRunningTest() || campMap.get(li.id_oas__c).status == 'W'){ 
                li.status_oas__c = 'O';
                li.reservationStatus__c = 'RESERVED';
                lis.add(li.id_oas__c);
            }
        }
        oas.updateCampaignsStatus(lis,'O');
        if(doDml){
            update sfdcLineItems;
        }
    }
        
    public PageReference upsertOrderSfdcToOas() {
        system.debug('upsertOrderSfdcToOas');
        upsertSfToOas();
        return null;
    }

    public PageReference upsertOrderSfdcToOas(OasIntegration oas) {
        system.debug('upsertOrderSfdcToOas');
        upsertSfToOas(true,oas);
        return null;
    }
    
    /*
        get campaigns from OAS
    */
    public map<string,oasIntegration.campaignClass> getCampaignMap(){
        OasIntegration oas = new OasIntegration();
        map<string,oasIntegration.campaignClass> campMap = new map<string,oasIntegration.campaignClass>(); 
        for(oasIntegration.campaignClass c : oas.getCampaignClass(oas.listCampaignsByOrderId(o.id_oas__c))){
            campMap.put(c.id,c);
        }
        return campMap;
    }


}