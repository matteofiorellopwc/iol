public class UtilityLineItemIntegration{
    public static final Set<String> statiNonModificabili = new Set<String>{
        'DELIVERING',
        'READY',
        'PAUSED',
        'PAUSED_INVENTORY_RELEASED',
        'COMPLETED',
        'CANCELED'
    };

    public static void reserveLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();    
        performeLineItemAction(ids,'ReserveLineItems',dfp);   
    }

    public static void reserveLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ReserveLineItems',dfp);
    }
    
    public static void releaseLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration(); 
        performeLineItemAction(ids,'ReleaseLineItems',dfp);   
    }
    
    public static void releaseLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ReleaseLineItems',dfp);    
    }    
    
    public static void deleteLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'DeleteLineItems',dfp);
    }
    
    public static void deleteLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'DeleteLineItems',dfp);
    }

    public static void activateLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'ActivateLineItems',dfp);
    }
    
    public static void activateLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ActivateLineItems',dfp);
    }

    public static void archiveLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'ArchiveLineItems',dfp);
    }
    
    public static void archiveLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ArchiveLineItems',dfp);
    }

    public static void pauseLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'PauseLineItems',dfp);
    }
    
    public static void pauseLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'PauseLineItems',dfp);
    }

    public static void reserveAndOverbookLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'ReserveAndOverbookLineItems',dfp);
    }
    
    public static void reserveAndOverbookLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ReserveAndOverbookLineItems',dfp);
    }
    
    public static void resumeLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'ResumeLineItems',dfp);
    }
    
    public static void resumeLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ResumeLineItems',dfp);
    }
    
    public static void resumeAndOverbookLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'ResumeAndOverbookLineItems',dfp);
    }
    
    public static void resumeAndOverbookLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'ResumeAndOverbookLineItems',dfp);
    }
    
    public static void unarchiveLineItems(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,'UnarchiveLineItems',dfp);
    }
    
    public static void unarchiveLineItems(List<decimal> ids,dfpintegration dfp){
        performeLineItemAction(ids,'UnarchiveLineItems',dfp);
    }

    
    public static void performeLineItemAction(List<decimal> ids,string lineItemAction){
        dfpintegration dfp = new dfpintegration();
        performeLineItemAction(ids,lineItemAction,dfp);
    }
    
    public static void performeLineItemAction(List<decimal> ids,string lineItemAction,dfpintegration dfp){
        try{
            DfpLineItemService.Statement lineItemFilterStatement = new DfpLineItemService.Statement();
            lineItemFilterStatement.query = 'WHERE id in ('+ListToString(ids)+') LIMIT 1000 OFFSET 0';
            DfpLineItemService.LineItemAction action = new DfpLineItemService.LineItemAction();
            action.type = lineItemAction;
            dfp.lineitemservice.performLineItemAction(action,lineItemFilterStatement);
        }catch(Exception e){
            throw new IntegrationException(e.getMessage());
        }  
    }        
    
    public static string ListToString(List<decimal> ids){
        string s = '';
        for(decimal d : ids){
            s += d+',';
        }
        s += ',';
        s = s.replace(',,','');
        return s;
    }
    
    public class IntegrationException extends Exception{}
    
    
    public static string getAdditionaFields(){
        return  ' Opportunity__r.id_dfp__c,Product__r.Targeting_Keys_Editabili__c,Product__r.CalcolaCPDconImprStimate__c,product__r.isActive, product__r.Categoria_libero__c,opportunity__r.status__c,Product__r.family,Product__r.Fascia_Oraria__c,opportunity__r.Totale_senza_sconto__c,'+
                'product__r.formato__c,product__r.size__c,product__r.Priority__c,product__r.Priority_oas__c,product__r.canale_primario__c,product__r.CanalePrimario__c,product__r.Impressions_Stimate__c,Product__r.BasePrice__c,'+
                'product__r.Breakeven_cost__c,product__r.isAspectRatio__c,product__r.multisize__c,product__r.templateDFP__c,'+
                '(Select Type__c, Values__c, isTargeted__c, valueIds__c From Technology_Targeting__r), '+
                '(Select Venditore_obiettivo__c, Valore_di_commisioning__c, Valore__c, Tipo_obiettivo__c, Tipo_Revenue_Application__c, '+
                '    Prodotto__c, Percentuale_applicata__c, Order__c, Opportunity_Stage__c, Obiettivo__c, Numero_impression__c, '+
                '    Numero_giorni__c, Numero_click__c, Mese_numero__c, Mese__c, Line_Item__c, Id, Data_primo_mese__c, Custom__c, ClosedWon__c, '+
                '    Centro_Media_obiettivo__c, Categoria_Libero_obiettivo__c, Canale_di_vendita_obiettivo__c, Anno__c, Agenzia_territoriale_obiettivo__c'+
                ' From Revenue_applications__r),'+
                '(Select Placement__c,placementId__c From PlacementTargeting__r), '+
                '(Select Incremento_calcolato_prodotto__c,Incremento_calcolato_lineitem__c, Quantita__c, Tipo__c, UniqueKey__c, incremento__c From Optionals__r), '+
                '(Select SectionOas__c, Product__c,adUnitIdDfp__c,Ad_Unit__c, InventoryTargetingType__c, includeDescendants__c, isLineItemModified__c From Inventory_Target__r), '+
                '      (Select Product__c, LineItem__c,SectionOas__c From SectionsOasTargeted__r),'+
                '(Select maxImpressions__c, numTimeUnits__c, timeUnit__c From Frequency_Caps__r), '+
                '(Select dayOfWeek__c, Start_Hour__c, End_Hour__c, Start_Minute__c, End_Minute__c From Day_Part_Targeting__r), '+
                '(Select Id, logicalOperator__c From Custom_Criteria_Set__r), '+
                '(Select IncludedValuesIds__c,matches__c, ExcludedValuesIds__c FROM Geography__r),'+
                '(Select Label__c,idDfp__c From AppliedLabel__r) ';
    }
    
    public static LineItem__c getLineItemBySfdcId(id sfdcid){
        string query = Util.getFieldsSOQL('LineItem__c', ' id = \''+sfdcid+'\'', false,getAdditionaFields(),false);
        return database.query(query);
    }
    
    public static list<lineitem__c> getLineItemsByOppId(id oppId){
        return getLineItemsByOppId(oppId,true,false);
    }

    public static list<lineitem__c> getLineItemsByOppId(id oppId,boolean onlyBanner){
        return getLineItemsByOppId(oppId,onlyBanner,false);   
    }

    public static list<lineitem__c> getLineItemsByOppId(id oppId,boolean onlyBanner, boolean onlyNotDeletedLineItems){
       
        string whereClause = ' Opportunity__c = \''+oppId+'\' ';
        if(onlyBanner){
            whereClause += ' And Integrato_con_DFP_formula__c = \'true\'';
        }
        if(onlyNotDeletedLineItems){
            whereClause += ' AND Cancellato__c <> true ';
        }
        string query = Util.getFieldsSOQL('LineItem__c', whereClause, false,getAdditionaFields(),false);
        return database.query(query);
    }        


    public static DfpLineItemService.LineItemPage getLineItemsByIds(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();    
        return getLineItemsByIds(ids,dfp);
    }
    
    public static DfpLineItemService.LineItemPage getLineItemsByIds(List<decimal> ids,dfpintegration dfp){
        try{
            DfpLineItemService.Statement LineItemFilterStatement = new DfpLineItemService.Statement();
            LineItemFilterStatement.query = 'WHERE id in ('+ListToString(ids)+') LIMIT 1000 OFFSET 0';
            system.debug('query = '+LineItemFilterStatement.query);
            return dfp.LineItemservice.getLineItemsByStatement(LineItemFilterStatement);
        }catch(Exception e){
            throw new IntegrationException(e.getMessage());
        }
        return null;
    }    
    
    public static void syncDfpToSfdcLineItems(list<lineitem__c> lineitems){
        dfpintegration dfp = new dfpintegration();
        syncDfpToSfdcLineItems(lineitems,dfp);
    }
    public static void syncDfpToSfdcLineItems(list<lineitem__c> lineitems,dfpintegration dfp){
        Map<decimal,lineitem__c> lisMap = new Map<decimal,lineitem__c>();
        for(lineitem__c li : lineitems){
            if(li.id_dfp__c != null){
                lisMap.put(li.id_dfp__c,li);
            }
        }
        
        list<decimal> lineItemList = new list<decimal>();
        lineItemList.addAll(lisMap.keySet());
        if(lineItemList.size() > 0){
            DfpLineItemService.LineItemPage lineItemPage = UtilityLineItemIntegration.getLineItemsByIds(LineItemList,dfp);
            if(LineItemPage.totalResultSetSize > 0){
                for(DfpLineItemService.LineItem l : LineItemPage.results){
                    LineItem__c li = lisMap.get(l.id);
                    if(li != null){
                        UtilityLineItemIntegration.syncDfpToSfdcLineItem(li,l);
                    }
                }
            }
        }
    }
    
    public static void syncDfpToSfdcLineItem(LineItem__c sfdcLi,DfpLineItemService.LineItem dfpLi){
        sfdcLi.status__c = dfpLi.status; 
        if(dfpLi.costType != 'CPD'){ //in dfp i cpd anche dopo averli confermati hanno reservationstatus = UNRESERVED,in sfdc no
            sfdcLi.reservationStatus__c = dfpLi.reservationStatus;   
        }
        if(dfpLi.stats != null){
            sfdcLi.impressionsDelivered__c = dfpLi.stats.impressionsDelivered; 
            sfdcLi.clicksDelivered__c = dfpLi.stats.clicksDelivered;
        }
       
        
    }
    
    /*
        for not ovverride technology target for mobile.
        from api doc:
            "Technology.Type  xsd:string Indicates that this instance is a subtype of Technology. 
             Although this field is returned in the response, it is ignored on input and cannot be selected. 
             Specify xsi:type instead."
    */
    public static void setTechnologyType(LIST<DfpLineItemService.Technology> tecs){
        if(tecs != null && tecs.size() > 0){
            for(DfpLineItemService.Technology t : tecs){
                t.type = t.Technology_Type;
            }
        }
    }
    
    /*
        for not ovverride geo target.
        from api doc:
            "Location.Type, Although this field is returned in the response, 
            it is ignored on input and cannot be selected. Specify xsi:type instead"
    */
    public static void setGeoType(LIST<DfpLineItemService.Location> locs){
        if(locs != null && locs.size() > 0){
            for(DfpLineItemService.Location l : locs){
                l.type = l.Location_Type;
            }
        }
    }
    
    /*
        for not ovverride custom criteria.
        from api doc:
            "CustomCriteriaNode.Type, Indicates that this instance is a subtype of CustomCriteriaNode. 
            Although this field is returned in the response, it is ignored on input and cannot be selected. 
            Specify xsi:type instead."
    */
    public static void setCustomCriteriaType(DfpLineItemService.CustomCriteriaNode node){
        node.type = node.CustomCriteriaNode_Type;
        if(node.children != null){
            for(DfpLineItemService.CustomCriteriaNode n : node.children){
                setCustomCriteriaType(n);
            }
        }
    }
    
    public static Map<Id,List<CustomCriteriaSet__c>> getCustomCriteriaMap(Id oppId){
        Map<Id,List<CustomCriteriaSet__c>> mp = new Map<Id,List<CustomCriteriaSet__c>>();
        for(CustomCriteriaSet__c cs : [select id,LineItem__c,logicalOperator__c,
                                                (Select keyId__c, operator__c, valueIds__c, isAudienceSegment__c 
                                                    From Custom_Criteria__r) 
                                          from CustomCriteriaSet__c
                                          where LineItem__r.Opportunity__r.Id = : oppId]){
            if(!mp.containsKey(cs.LineItem__c)){
                mp.put(cs.LineItem__c,new List<CustomCriteriaSet__c>());
            }
            mp.get(cs.LineItem__c).add(cs);
        }
        return mp;                                                    
    }
    
    public static void syncSfdcToDfpLineItem(LineItem__c sfdcLi,DfpLineItemService.LineItem dfpLi,Long orderid){
        syncSfdcToDfpLineItem(sfdcLi,dfpLi,orderid,null);      
    }
    
    public static void syncSfdcToDfpLineItem(LineItem__c sfdcLi,DfpLineItemService.LineItem dfpLi,Long orderid,List<CustomCriteriaSet__c> customCriteriaList){
    
        system.debug('sfdcLi: '+sfdcLi);
        system.debug('dfpLi prima sync: '+dfpLi);
        
        
        
        /*
        if(dfpLi.CustomFieldValues != null){
            for(DfpLineItemService.BaseCustomFieldValue cf : dfpLi.customFieldValues){
                cf.value = 'asdasd';
            }
        } */
        
        dfpLi.costType = sfdcLi.Delivery_Model__c;
        DfpLineItemService.Goal gl = new DfpLineItemService.Goal();
        gl.goalType = sfdcLi.type_dfp__c == 'PRICE_PRIORITY' ? sfdcLi.duration__c : null;
        gl.unitType = 'IMPRESSIONS';
        gl.units = (long) sfdcLi.Quantita__c;
        
        
        
        
        
        if(dfpLi.costType == 'CPC' && (sfdcLi.type_dfp__c == 'STANDARD' || sfdcLi.type_dfp__c == 'BULK' || sfdcLi.type_dfp__c == 'PRICE_PRIORITY')){
            gl.unitType = 'CLICKS';
        }
        if(sfdcLi.type_dfp__c == 'SPONSORSHIP' || sfdcLi.type_dfp__c == 'HOUSE' || sfdcLi.type_dfp__c == 'NETWORK'){
            gl.units = (long) sfdcLi.goal_delivery__c;
        
        }
        
        
        
        if(sfdcLi.disableSameAdvertiserCompetitiveExclusio__c != null){
            dfpLi.disableSameAdvertiserCompetitiveExclusion = sfdcLi.disableSameAdvertiserCompetitiveExclusio__c;
        }
        
        if(sfdcLi.Size_prodotto__c != null && sfdcLi.Size_prodotto__c.endsWith('v') == true){
            dfpLi.environmentType = 'VIDEO_PLAYER';
        }else{
            dfpLi.environmentType = 'BROWSER';
        }
       
       // dfpLi.targetPlatform = sfdcLi.target_platform__c;
        dfpLi.allowOverbook = sfdcLi.allowOverbook__c;

       if(dfpLi.costPerUnit != null){
            dfpLi.costPerUnit.microAmount = (long) (sfdcLi.Prezzo_net_net__c*1000000);
            system.debug('@@@a ' + dfpLi.costPerUnit.microAmount);
        }else{
            dfpLi.costPerUnit = UtilityDataValue.getLineItemMoney((long)(sfdcLi.Prezzo_net_net__c*1000000));
            system.debug('@@@b ' + dfpLi.costPerUnit.microAmount);
        }
        
        if(sfdcLi.roadblockingType__c != null && sfdcLi.roadblockingType__c != ''){
            dfpLi.roadblockingType = sfdcLi.roadblockingType__c;
        }
        if(sfdcLi.creativeRotationType__c != null && sfdcLi.creativeRotationType__c != ''){
            dfpLi.creativeRotationType = sfdcLi.creativeRotationType__c;
        }
        if(sfdcLi.deliveryRateType__c != null && sfdcLi.deliveryRateType__c != ''){
            dfpLi.deliveryRateType = sfdcLi.deliveryRateType__c;
        }
        
        if(sfdcLi.autoExtensionDays__c != null){
            dfpLi.autoExtensionDays = (integer) sfdcLi.autoExtensionDays__c;
        }
        dfpLi.contractedunitsBought = sfdcLi.type_dfp__c != 'AD_ECHANGE' ? (long) sfdcLi.Quantita__c : 1;
        
                
        if(sfdcLi.type_dfp__c == 'AD_EXCHANGE' || sfdcLi.type_dfp__c == 'ADSENSE'){
            dfpLi.contractedunitsBought = 1;
            if(dfpLi.webPropertyCode == null){
                system.debug('set web prop code');
                dfpLi.webPropertyCode = sfdcLi.webPropertyCode__c;
            }else{
                system.debug('no set web prop code');            
            }
        } else if(sfdcLi.type_dfp__c == 'SPONSORSHIP' || sfdcLi.type_dfp__c == 'NETWORK' || sfdcLi.type_dfp__c == 'HOUSE'){
            dfpLi.contractedunitsBought = (long) sfdcLi.goal_delivery__c;
            /*
                su dfp il rate deve essere comunque il prezzo giornaliero
            */
            if(sfdcLi.CalcolaCPDconImpStimate__c){ 
                dfpLi.costPerUnit = UtilityDataValue.getLineItemMoney((long)(sfdcLi.Totale__c*1000000/sfdcLi.Quantita__c));
            }else{
                dfpLi.costPerUnit = UtilityDataValue.getLineItemMoney((long)(sfdcLi.Prezzo_net_net__c*1000000*dfpLi.contractedunitsBought/100));
            }
            
            /*
                su salesforce abbiamo net net = totale, se lo passiamo a DFP ci sono errori nei report.
                passiamo 0 e si guardano i valori economici si salesforce
            */
            
              system.debug('prezzo net '+sfdcLi.Prezzo_net_net__c+'sfdcLi.Delivery_Model__c  '+sfdcLi.Delivery_Model__c +' sfdcLi.Type_DFP__c '+sfdcLi.Type_DFP__c+' costPerUnit '+dfpLi.costPerUnit+' dfpLi.contractedunitsBought '+dfpLi.contractedunitsBought);
            
            if(sfdcLi.Delivery_Model__c != 'CPD' && !((sfdcLi.Delivery_Model__c == 'CPM'&&sfdcLi.Type_DFP__c == 'SPONSORSHIP')))
            {
                dfpLi.costPerUnit = UtilityDataValue.getLineItemMoney(0);
                
            }else if (sfdcLi.Delivery_Model__c == 'CPM' && sfdcLi.Type_DFP__c == 'SPONSORSHIP'){
   	            dfpLi.costPerUnit.microAmount = (long) (sfdcLi.Prezzo_net_net__c*1000000);
	            system.debug(' costPerUnit '+dfpLi.costPerUnit+' dfpLi.contractedunitsBought '+dfpLi.contractedunitsBought);
            }
        }
        
        if(sfdcLi.type_dfp__c == 'STANDARD'){
            dfpLi.contractedunitsBought = null;
        }
        
        //questo campo in realtà è inutile e dannoso. Lo impostiamo NULL alla fine, in attesa di sistemare il codice
        dfpLi.contractedunitsBought = null;
        
        dfpLi.notes = sfdcLi.Notes_dfp__c;
        
        if(sfdcLi.Priority_formula__c != null && sfdcLi.Priority_formula__c > 0){
            dfpLi.priority = (integer) sfdcLi.Priority_formula__c;
        }
        
        
        dfpLi.primaryGoal = gl;
        
        dfpLi.discountType = 'PERCENTAGE'; //= sfdcLi.Discount_Type__c; mettono o il net net o lo sconto %
        dfpLi.discount = 0; //metto già il prezzo net net 
        
        dfpLi.startDateTime = UtilityDataValue.getLineItemDateTime(sfdcLi.Start_Date__c, sfdcLi.Start_Hour__c, sfdcLi.Start_Minute__c, '0');
        dfpLi.endDateTime = UtilityDataValue.getLineItemDateTime(sfdcLi.End_Date__c, sfdcLi.End_Hour__c, sfdcLi.End_Minute__c, '0');
        dfpLi.lineItemType = sfdcLi.Type_DFP__c;
        //dfpLi.lineItemType = null;
        dfpLi.name = sfdcLi.Name_Dfp__c;
        dfpLi.orderId = (long) orderid;
        
        dfpLi.externalid = sfdcLi.id;
        
        dfpLi.creativePlaceholders = new List<DfpLineItemService.CreativePlaceholder>();
       
        
        
   
        if(sfdcLi.width__c != null && sfdcLi.height__c != null && sfdcLi.multisize__c == null){
            DfpLineItemService.CreativePlaceholder creativePlaceHolder = new DfpLineItemService.CreativePlaceholder();
            creativePlaceHolder.size = new DfpLineItemService.Size();
            creativePlaceHolder.size.width =  (integer) sfdcLi.width__c;
            creativePlaceHolder.size.height = (integer) sfdcLi.height__c;
            creativePlaceHolder.size.isAspectRatio = false; //TODO, verificare
            if(creativePlaceHolder.size.width == 1 && creativePlaceHolder.size.height == 1){
                creativePlaceHolder.creativeSizeType = 'INTERSTITIAL';
            }
            if(sfdcLi.product__r.isAspectRatio__c){
                creativePlaceHolder.size.isAspectRatio = true;
                creativePlaceHolder.creativeSizeType = 'ASPECT_RATIO';
            }
            
            if(sfdcLi.product__r.templateDFP__c != null){
               creativePlaceHolder.creativeSizeType = 'NATIVE';
               creativePlaceHolder.creativeTemplateId=integer.ValueOf(sfdcLi.product__r.templateDFP__c);
            }


                           /* modifica label luca */
       
         if(!sfdcLi.AppliedLabel__r.isEmpty()){
       
                    for(AppliedLabel__c l : sfdcLi.AppliedLabel__r){
                        try{
                            Label__c typeLabel =[Select lab.type__c, lab.id From Label__c lab where lab.idDfp__c = :l.idDfp__c];
                            system.debug('label type: '+typeLabel.type__c);
                            if(typeLabel.type__c == 'AD_UNIT_FREQUENCY_CAP')
                            {
                            DfpLineItemService.AppliedLabel creativeAppLabels = new DfpLineItemService.AppliedLabel();
                            creativeAppLabels.labelId = (long) l.idDfp__c;
                            creativeAppLabels.isNegated = false; //TODO, verificare
                            creativePlaceHolder.appliedLabels = new List<DfpLineItemService.AppliedLabel>();
                            
                            creativePlaceHolder.appliedLabels.add(creativeAppLabels);
                            }else{
                                system.debug('non è una label di tipo ad unit freq ');
                            }
                            
                        }catch (Exception e ){
                            system.debug(e.getMessage());
                        }
              }
         }
            
            
            
            dfpLi.creativePlaceholders.add(creativePlaceHolder);
        }else if(sfdcLi.multisize__c != null){
            for(string s : sfdcLi.multisize__c.replace(' ','').split(';')){
                DfpLineItemService.CreativePlaceholder creativePlaceHolder = new DfpLineItemService.CreativePlaceholder();
                creativePlaceHolder.size = new DfpLineItemService.Size();
                creativePlaceHolder.size.width =  integer.valueOf(s.split('x')[0]);
                creativePlaceHolder.size.height = integer.valueOf(s.split('x')[1]);
                creativePlaceHolder.size.isAspectRatio = false; //TODO, verificare
                if(creativePlaceHolder.size.width == 1 && creativePlaceHolder.size.height == 1){
                    creativePlaceHolder.creativeSizeType = 'INTERSTITIAL';
                }
                if(sfdcLi.product__r.isAspectRatio__c){
                    creativePlaceHolder.size.isAspectRatio = true;
                    creativePlaceHolder.creativeSizeType = 'ASPECT_RATIO';
                }
                if(sfdcLi.product__r.templateDFP__c != null){
                    creativePlaceHolder.creativeSizeType = 'NATIVE';
                    creativePlaceHolder.creativeTemplateId=integer.ValueOf(sfdcLi.product__r.templateDFP__c);
                }
                dfpLi.creativePlaceholders.add(creativePlaceHolder);
            }
        }


// List <DfpLineItemService.AppliedLabel> creativePlaceHolder.appliedLabels= new List <DfpLineItemService.AppliedLabel>();
        

        





        DfpLineItemService.GeoTargeting geoTargeting;
        DfpLineItemService.UserDomainTargeting userDomainTargeting;
        DfpLineItemService.ContentTargeting contentTargeting;
        DfpLineItemService.VideoPositionTargeting videoPositionTargeting;
        DfpLineItemService.TechnologyTargeting technologyTargeting;
        
        if(dfpLi.targeting != null){
            //questi targeting non sono gestiti su sfdc quindi non vanno sovrascritti su DFP
            if(dfpLi.targeting.geoTargeting != null){
                geoTargeting = dfpLi.targeting.geoTargeting;
                setGeoType(geoTargeting.targetedLocations);
                setGeoType(geoTargeting.excludedLocations);
            }
            if(dfpLi.targeting.userDomainTargeting != null){
                userDomainTargeting = dfpLi.targeting.userDomainTargeting;
            }
            if(dfpLi.targeting.contentTargeting != null){
                contentTargeting = dfpLi.targeting.contentTargeting;
            }
            if(dfpLi.targeting.videoPositionTargeting != null){
                videoPositionTargeting = dfpLi.targeting.videoPositionTargeting;
            }
            if(dfpLi.targeting.technologyTargeting != null){ // && dfpLi.targetPlatform == 'MOBILE'
                technologyTargeting = dfpLi.targeting.technologyTargeting;
                if(technologyTargeting.bandwidthGroupTargeting != null){
                    setTechnologyType(technologyTargeting.bandwidthGroupTargeting.bandwidthGroups);
                }
                if(technologyTargeting.BrowserTargeting != null){
                    setTechnologyType(technologyTargeting.browserTargeting.browsers );
                }
                if(technologyTargeting.browserLanguageTargeting != null){
                    setTechnologyType(technologyTargeting.browserLanguageTargeting.browserLanguages );
                }
                if(technologyTargeting.deviceCapabilityTargeting != null){
                    setTechnologyType(technologyTargeting.deviceCapabilityTargeting.targetedDeviceCapabilities );
                    setTechnologyType(technologyTargeting.deviceCapabilityTargeting.excludedDeviceCapabilities );
                }
                if(technologyTargeting.deviceCategoryTargeting != null){
                    setTechnologyType(technologyTargeting.deviceCategoryTargeting.targetedDeviceCategories );
                    setTechnologyType(technologyTargeting.deviceCategoryTargeting.excludedDeviceCategories );
                }
                if(technologyTargeting.deviceManufacturerTargeting!= null){
                    setTechnologyType(technologyTargeting.deviceManufacturerTargeting.deviceManufacturers );
                }
                if(technologyTargeting.mobileCarrierTargeting != null){
                    setTechnologyType(technologyTargeting.mobileCarrierTargeting.mobileCarriers );
                }
                if(technologyTargeting.mobileDeviceTargeting != null){
                    setTechnologyType(technologyTargeting.mobileDeviceTargeting.targetedMobileDevices);
                    setTechnologyType(technologyTargeting.mobileDeviceTargeting.excludedMobileDevices);
                }
                if(technologyTargeting.mobileDeviceSubmodelTargeting != null){
                    setTechnologyType(technologyTargeting.mobileDeviceSubmodelTargeting.targetedMobileDeviceSubmodels );
                    setTechnologyType(technologyTargeting.mobileDeviceSubmodelTargeting.excludedMobileDeviceSubmodels );                    
                }
                if(technologyTargeting.operatingSystemTargeting != null){
                    setTechnologyType(technologyTargeting.operatingSystemTargeting.operatingSystems );
                }
                if(technologyTargeting.operatingSystemVersionTargeting != null){
                    setTechnologyType(technologyTargeting.operatingSystemVersionTargeting.targetedOperatingSystemVersions );
                    setTechnologyType(technologyTargeting.operatingSystemVersionTargeting.excludedOperatingSystemVersions );
                }
            }
        }

        dfpLi.targeting = new DfpLineItemService.Targeting();
        
        
        if(userDomainTargeting != null){
            dfpLi.targeting.userDomainTargeting = userDomainTargeting;
        }
        if(contentTargeting != null){
            dfpLi.targeting.contentTargeting = contentTargeting;
        }
        if(videoPositionTargeting != null){
            dfpLi.targeting.videoPositionTargeting = videoPositionTargeting;
        }
        /*
        if(geoTargeting != null){
            dfpLi.targeting.geoTargeting = geoTargeting;
        } 
        */       

        if(!sfdcLi.Geography__r.isEmpty()){
            Geography__c g = sfdcLi.Geography__r.get(0);
            DfpLineItemService.GeoTargeting gt = new DfpLineItemService.GeoTargeting();
            DfpLineItemService.Location[] targetedLocations = new List<DfpLineItemService.Location>();
            DfpLineItemService.Location[] excludedLocations = new List<DfpLineItemService.Location>();          
            if(g.IncludedValuesIds__c != null) {
                for(String id : g.IncludedValuesIds__c.split(';')) {
                    DfpLineItemService.Location l = new DfpLineItemService.Location();
                    l.id = Long.valueOf(id.split('\\|')[2]); 
                    targetedLocations.add(l);               
                }
            }
            if(g.excludedValuesIds__c != null) {
                for(String id : g.excludedValuesIds__c.split(';')) {
                    DfpLineItemService.Location l = new DfpLineItemService.Location();
                    l.id = Long.valueOf(id.split('\\|')[2]); 
                    excludedLocations.add(l);               
                }                           
            }
            gt.targetedLocations = targetedLocations;
            gt.excludedLocations = excludedLocations;
            dfpLi.targeting.geoTargeting = gt;  
        }
        

        /*
            tech targeting NON sovrascritti
                deviceCapabilityTargeting
                deviceCategoryTargeting
                deviceManufacturerTargeting
                mobileCarrierTargeting
                mobileDeviceTargeting
                mobileDeviceSubmodelTargeting
            tech targeting sovrascritti
                bandwidthGroupTargeting
                browserTargeting
                browserLanguageTargeting
                operatingSystemTargeting
                operatingSystemVersionTargeting
        */
        dfpLi.targeting.technologyTargeting = technologyTargeting != null ? technologyTargeting : new DfpLineItemService.TechnologyTargeting();

        dfpLi.targeting.technologyTargeting.bandwidthGroupTargeting = new DfpLineItemService.bandwidthGroupTargeting();      
        dfpLi.targeting.technologyTargeting.browserTargeting = new DfpLineItemService.browserTargeting();  
        dfpLi.targeting.technologyTargeting.browserLanguageTargeting = new DfpLineItemService.browserLanguageTargeting();    
        dfpLi.targeting.technologyTargeting.operatingSystemTargeting = new DfpLineItemService.operatingSystemTargeting();  
        dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting = new DfpLineItemService.operatingSystemVersionTargeting(); 
        dfpLi.targeting.technologyTargeting.deviceCapabilityTargeting = new DfpLineItemService.deviceCapabilityTargeting();
        dfpLi.targeting.technologyTargeting.deviceCategoryTargeting = new DfpLineItemService.deviceCategoryTargeting();
        dfpLi.targeting.technologyTargeting.deviceManufacturerTargeting = new DfpLineItemService.deviceManufacturerTargeting();
        dfpLi.targeting.technologyTargeting.mobileCarrierTargeting = new DfpLineItemService.mobileCarrierTargeting();
        dfpLi.targeting.technologyTargeting.mobileDeviceTargeting = new DfpLineItemService.mobileDeviceTargeting();
        if(!sfdcLi.Technology_Targeting__r.isEmpty()){

            for(TechnologyTargeting__c tt : sfdcLi.Technology_Targeting__r){
                list<DfpLineItemService.Technology> techs = new list<DfpLineItemService.Technology>();
                tt.valueIds__c = tt.valueIds__c == null ? '' : tt.valueIds__c;
                if(tt.valueIds__c != ''){               
                    for(String s : tt.valueIds__c.split(',')){
                        DfpLineItemService.Technology t = new DfpLineItemService.Technology();
                        t.id =  long.valueof(s);
                        techs.add(t);
                    }
                    if(tt.Type__c == 'Bandwidth_Group'){
                        dfpLi.targeting.technologyTargeting.bandwidthGroupTargeting.isTargeted = tt.isTargeted__c;   
                        dfpLi.targeting.technologyTargeting.bandwidthGroupTargeting.bandwidthGroups = techs;        
                    }else if(tt.Type__c == 'Browser'){
                        dfpLi.targeting.technologyTargeting.browserTargeting.isTargeted = tt.isTargeted__c;
                        dfpLi.targeting.technologyTargeting.browserTargeting.browsers = techs;
                    }else if(tt.Type__c == 'Browser_Language'){
                        dfpLi.targeting.technologyTargeting.browserLanguageTargeting.isTargeted = tt.isTargeted__c;
                        dfpLi.targeting.technologyTargeting.browserLanguageTargeting.browserLanguages = techs;
                    }else if(tt.Type__c == 'Operating_System'){
                        dfpLi.targeting.technologyTargeting.operatingSystemTargeting.isTargeted = tt.isTargeted__c;
                        dfpLi.targeting.technologyTargeting.operatingSystemTargeting.operatingSystems = techs;
                    }else if(tt.Type__c == 'Operating_System_Version'){
                        if(tt.isTargeted__c){
                            dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting.targetedOperatingSystemVersions = techs;
                        }else{
                            dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting.excludedOperatingSystemVersions = techs;
                        }
                    }else if(tt.Type__c == 'Device_Capability'){
                        if(tt.isTargeted__c){
                            dfpLi.targeting.technologyTargeting.deviceCapabilityTargeting.targetedDeviceCapabilities = techs;
                        }else{
                            dfpLi.targeting.technologyTargeting.deviceCapabilityTargeting.excludedDeviceCapabilities = techs;
                        }
                    }else if(tt.Type__c == 'Device_Category'){
                        if(tt.isTargeted__c){
                            dfpLi.targeting.technologyTargeting.deviceCategoryTargeting.targetedDeviceCategories = techs;
                        }else{
                            dfpLi.targeting.technologyTargeting.deviceCategoryTargeting.excludedDeviceCategories = techs;
                        }
                    }else if(tt.Type__c == 'Device_Manufacturer'){
                        dfpLi.targeting.technologyTargeting.deviceManufacturerTargeting.isTargeted = tt.isTargeted__c;
                        dfpLi.targeting.technologyTargeting.deviceManufacturerTargeting.deviceManufacturers = techs;
                    }else if(tt.Type__c == 'Mobile_Carrier'){
                        dfpLi.targeting.technologyTargeting.mobileCarrierTargeting.isTargeted = tt.isTargeted__c;
                        dfpLi.targeting.technologyTargeting.mobileCarrierTargeting.mobileCarriers = techs;
                    }else if(tt.Type__c == 'Mobile_Device'){
                        if(tt.isTargeted__c){
                            dfpLi.targeting.technologyTargeting.mobileDeviceTargeting.targetedMobileDevices = techs;
                        }else{
                            dfpLi.targeting.technologyTargeting.mobileDeviceTargeting.excludedMobileDevices = techs;
                        }
                    }
                }
            }
        }
        
        dfpLi.targeting.inventoryTargeting = new DfpLineItemService.InventoryTargeting();
        dfpLi.targeting.inventoryTargeting.targetedAdUnits = new List<DfpLineItemService.AdUnitTargeting>();
        dfpLi.targeting.inventoryTargeting.excludedAdUnits = new List<DfpLineItemService.AdUnitTargeting>();
        dfpLi.targeting.inventoryTargeting.targetedPlacementIds = new List<Long>();
        
        for(Inventory_Target__c it : sfdcLi.Inventory_Target__r){
            DfpLineItemService.AdUnitTargeting adUnitTargeting = new DfpLineItemService.AdUnitTargeting();
            adUnitTargeting.adUnitId  = it.adUnitIdDfp__c;
            adUnitTargeting.includeDescendants  = it.includeDescendants__c;
            if(it.InventoryTargetingType__c == 'targeted'){
                dfpLi.targeting.inventoryTargeting.targetedAdUnits.add(adUnitTargeting);
            }else{
                dfpLi.targeting.inventoryTargeting.excludedAdUnits.add(adUnitTargeting);
            }
        }
        for(PlacementTargeting__c pt : sfdcLi.PlacementTargeting__r){
            dfpLi.targeting.inventoryTargeting.targetedPlacementIds.add( (long) pt.placementId__c );
        }


        DayPartTargeting__c[] dptList = sfdcLi.Day_Part_Targeting__r; 
        if(sfdcLi.isFasciaOrariaEdit__c){
            dptList = new DayPartTargeting__c[]{};
            ExtensionEditLineItem.getDayPartBand(sfdcLi,new Set<String>(),dptList);
        }
        system.debug('dptList = '+dptList);
        if(! dptList.isEmpty()){
            dfpLi.targeting.dayPartTargeting = new DfpLineItemService.DayPartTargeting();
            dfpLi.targeting.dayPartTargeting.timeZone = sfdcLi.TimeZoneDay__c;
            dfpLi.targeting.dayPartTargeting.dayParts = new List<DfpLineItemService.DayPart>();
            for(DayPartTargeting__c dp : dptList){
                DfpLineItemService.DayPart d = new DfpLineItemService.DayPart();
                d.dayOfWeek = dp.dayOfWeek__c;
                d.startTime = UtilityDataValue.getLineItemTimeOfDay(dp.Start_Hour__c,dp.Start_Minute__c);
                d.endTime = UtilityDataValue.getLineItemTimeOfDay(dp.End_Hour__c,dp.End_Minute__c);
                dfpLi.targeting.dayPartTargeting.dayParts.add(d);
            }
        }
        
        dfpLi.frequencyCaps = new list<DfpLineItemService.FrequencyCap>();
        if(!sfdcLi.Frequency_Caps__r.isEmpty()){
            for(FrequencyCap__c fc : sfdcLi.Frequency_Caps__r){
                DfpLineItemService.FrequencyCap f = new DfpLineItemService.FrequencyCap();
                f.maxImpressions = (Integer) fc.maxImpressions__c;
                f.numTimeUnits = (Integer) fc.numTimeUnits__c;
                f.timeUnit = fc.timeUnit__c;
                dfpLi.frequencyCaps.add(f);
            }
        }
         
        list<CustomCriteriaSet__c> criteriaSets = new list<CustomCriteriaSet__c>();
        if(!sfdcLi.Custom_Criteria_Set__r.isEmpty() && customCriteriaList==null){
            for(CustomCriteriaSet__c ccs : [select id,logicalOperator__c,
                                                            (Select keyId__c, operator__c, valueIds__c, isAudienceSegment__c 
                                                                From Custom_Criteria__r) 
                                                      from CustomCriteriaSet__c
                                                      where id in : sfdcLi.Custom_Criteria_Set__r]){
                if(! ccs.Custom_Criteria__r.isEmpty()){
                    criteriaSets.add(ccs);
                }
            }
        }else if(!sfdcLi.Custom_Criteria_Set__r.isEmpty() && customCriteriaList!=null){
            for(CustomCriteriaSet__c ccs : customCriteriaList){
                if(! ccs.Custom_Criteria__r.isEmpty()){
                    criteriaSets.add(ccs);
                }
            }
        }
        
        if(!criteriaSets.isEmpty()){
            dfpLi.targeting.customTargeting = new DfpLineItemService.CustomCriteriaNode();        
            dfpLi.targeting.customTargeting.type = 'CustomCriteriaSet';
            dfpLi.targeting.customTargeting.logicalOperator = 'OR';
            dfpLi.targeting.customTargeting.children = new List<DfpLineItemService.CustomCriteriaNode>();
            for(CustomCriteriaSet__c ccs : criteriaSets){
                DfpLineItemService.CustomCriteriaNode criteriaSet = new DfpLineItemService.CustomCriteriaNode();
                criteriaSet.type = 'CustomCriteriaSet';
                criteriaSet.logicalOperator = ccs.logicalOperator__c; //sempre 'AND'
                criteriaSet.children = new List<DfpLineItemService.CustomCriteriaNode>();
                for(Custom_Criteria__c cc : ccs.Custom_Criteria__r){
                    DfpLineItemService.CustomCriteriaNode CustomCriteria = new DfpLineItemService.CustomCriteriaNode();
                    CustomCriteria.type = cc.isAudienceSegment__c ? 'AudienceSegmentCriteria' : 'CustomCriteria';
                    CustomCriteria.operator = cc.operator__c;                    
                    cc.valueIds__c = cc.valueIds__c == null ? '' : cc.valueIds__c;
                    if(!cc.isAudienceSegment__c) {            
                        CustomCriteria.keyId = (long) cc.keyId__c;                
                        CustomCriteria.valueIds = new List<long>();            
                        for(string valueId : cc.valueIds__c.split(',')){
                            CustomCriteria.valueIds.add(Long.valueOf(valueId)); 
                        }
                    } else {
                        CustomCriteria.audienceSegmentIds = new List<long>();            
                        for(string valueId : cc.valueIds__c.split(',')){
                            CustomCriteria.audienceSegmentIds.add(Long.valueOf(valueId)); 
                        }                        
                    }
                    criteriaSet.children.add(CustomCriteria);
                }

                dfpLi.targeting.customTargeting.children.add(criteriaSet);              
            }
        }
        System.debug(dfpLi.targeting.customTargeting);
        dfpLi.appliedLabels = new list<DfpLineItemService.AppliedLabel>();
        if(!sfdcLi.AppliedLabel__r.isEmpty()){
            for(AppliedLabel__c l : sfdcLi.AppliedLabel__r){
                try{
                        Label__c typeLabel =[Select lab.type__c, lab.id From Label__c lab where lab.idDfp__c = :l.idDfp__c];
                            system.debug('label type: '+typeLabel.type__c);
                    if(typeLabel.type__c != 'AD_UNIT_FREQUENCY_CAP'){
                            DfpLineItemService.AppliedLabel al = new DfpLineItemService.AppliedLabel();
                     al.labelId = (long) l.idDfp__c;
                     al.isNegated = false; //TODO, verificare
                     dfpLi.appliedLabels.add(al);
                    }
                    }catch (Exception e){
                        system.debug(e);
                }
            }            
        }
        system.debug('@@@c ' + dfpLi.costPerUnit.microAmount);        
        system.debug('dfpLi dopo sync: '+dfpLi);
        
    }

    public static DfpLineItemService.LineItem getAdditionalCriterias(DfpLineItemService.LineItem dfpLi){
        Map<Integer,Map<String,List<String>>> groups = new Map<Integer,Map<String,List<String>>>();
        List<CustomCriteriaFilters__c> cs = CustomCriteriaFilters__c.getall().values();
        for(CustomCriteriaFilters__c cc : cs){
            Integer groupId = cc.Group__c.intValue();
            String type = cc.Type__c;
            String value = cc.Name;
            if(groups.get(groupId) == null){
                groups.put(groupId,new Map<String,List<String>>());
            }
            if(groups.get(groupId).get(type) == null){
                groups.get(groupId).put(type,new List<String>());
            }
            groups.get(groupId).get(type).add(value);
        }

        List<DfpLineItemService.CustomCriteriaNode> result = new List<DfpLineItemService.CustomCriteriaNode>();
        for(Integer groupId : groups.keySet()){
            Map<String,List<String>> groupcs = groups.get(groupId);
            DfpLineItemService.CustomCriteriaNode customCriteria = new DfpLineItemService.CustomCriteriaNode();
            customCriteria.type = 'CustomCriteria';
            customCriteria.operator = 'IS_NOT';
            customCriteria.keyId = Long.valueOf(groupcs.get('CriteriaName')[0]);                
            customCriteria.valueIds = new List<long>();            
            customCriteria.valueIds.add(Long.valueOf(groupcs.get('CriteriaValue')[0]));
            result.add(customCriteria);    
        }

        if(dfpLi.targeting.customTargeting == null || dfpLi.targeting.customTargeting.children.size()==0){ // AND Passback is not TRUE
            dfpLi.targeting.customTargeting = new DfpLineItemService.CustomCriteriaNode();
            dfpLi.targeting.customTargeting.type = 'CustomCriteriaSet';
            dfpLi.targeting.customTargeting.logicalOperator ='AND';
            dfpLi.targeting.customTargeting.children = new List<DfpLineItemService.CustomCriteriaNode>();
            dfpLi.targeting.customTargeting.children.addAll(result);
        }else{
            for(DfpLineItemService.CustomCriteriaNode child : dfpLi.targeting.customTargeting.children){
                child.children.addAll(result);
            }
        }
        return dfpLi;
    }
    
    /*
    public class SalesforceCustomTargeting{
        public CustomCriteriaSet__c CustomCriteriaSet = new CustomCriteriaSet__c();
        public list<Custom_Criteria__c> CustomCriteria = new list<Custom_Criteria__c>();
    }
    
    public class SalesforceLineItem{
        public LineItem__c lineItem = new LineItem__c();
        public list<Inventory_Target__c> inventoryTargeting = new list<Inventory_Target__c>();
        public list<PlacementTargeting__c> targetedPlacement = new list<PlacementTargeting__c>();
        public list<FrequencyCap__c> frequencyCaps = new list<FrequencyCap__c>();
        public list<dayparttargeting__c> dayPartTargeting = new list<dayparttargeting__c>();
        public list<SalesforceCustomTargeting> customTargeting = new list<SalesforceCustomTargeting>();
        public list<AppliedLabel__c> appliedLabels = new list<AppliedLabel__c>();
        public list<TechnologyTargeting__c> technologyTargeting = new list<TechnologyTargeting__c>();
        
        public void insertAll(){
            insert lineItem;
            for(Inventory_Target__c it : inventoryTargeting){
                it.LineItem__c = lineItem.id;
            }
            insert inventoryTargeting;
            
            for(PlacementTargeting__c pt : targetedPlacement){
                pt.Line_Item__c = lineItem.id;
            }
            insert targetedPlacement;
            
            for(FrequencyCap__c fc : frequencyCaps){
                fc.LineItem__c = lineItem.id;
            }
            insert FrequencyCaps;
            
            for(dayparttargeting__c dpt : dayPartTargeting){
                dpt.lineitem__c = lineItem.id;
            }
            insert dayPartTargeting;
            
            list<CustomCriteriaSet__c> ccsToInsert = new list<CustomCriteriaSet__c>();
            for(SalesforceCustomTargeting sct : customTargeting){
                sct.CustomCriteriaSet.LineItem__c = lineItem.id;
                ccsToInsert.add(sct.CustomCriteriaSet);
            }
            insert ccsToInsert;
            list<Custom_Criteria__c> ccToInsert = new list<Custom_Criteria__c>();
            for(SalesforceCustomTargeting sct : customTargeting){
                for(Custom_Criteria__c cc : sct.CustomCriteria){
                    cc.Custom_Criteria_Set__c = sct.CustomCriteriaSet.id;
                    ccToInsert.add(cc);
                }
            }
            insert ccToInsert;
            
            for(AppliedLabel__c al : appliedLabels){
                al.Line_Item__c = lineItem.id;
            }
            insert appliedLabels;
            
            for(TechnologyTargeting__c tt : technologyTargeting){
                tt.LineItem__c = lineItem.id;
            }
            insert technologyTargeting;
            
        }
    }
    
    public static SalesforceLineItem syncDfpToSfdcLineItem(DfpLineItemService.LineItem dfpLi,LineItem__c sfdcLi){
        SalesforceLineItem salesforceLineItem = new SalesforceLineItem();
        if(sfdcLi != null){
            salesforceLineItem.lineItem = sfdcLi;
        }
        
        salesforceLineItem.lineItem.Delivery_Model__c = dfpLi.costType;
        sfdcLi.allowOverbook__c = dfpLi.allowOverbook;
        
        salesforceLineItem.lineItem.target_platform__c = dfpLi.targetPlatform;
        
        salesforceLineItem.lineItem.Prezzo_net_net__c = dfpLi.costPerUnit.microAmount / 1000000;

        salesforceLineItem.lineItem.Quantita__c = dfpLi.contractedunitsBought;
        salesforceLineItem.lineItem.Notes_dfp__c = dfpLi.notes;
        salesforceLineItem.lineItem.Priority__c = dfpLi.priority+'';
        salesforceLineItem.lineItem.Discount_Type__c = dfpLi.discountType; 
        if(dfpLi.discountType == 'PERCENTAGE'){ //noi gestiamo solo sconto percent
            salesforceLineItem.lineItem.sconto__c = dfpLi.discount; 
        }else{
            salesforceLineItem.lineItem.sconto__c = 0;
            salesforceLineItem.lineItem.Prezzo_net_net__c -= dfpLi.discount;
        }
        
        salesforceLineItem.lineItem.Start_Date__c = Date.newInstance(dfpLi.startDateTime.date_x.year, dfpLi.startDateTime.date_x.month , dfpLi.startDateTime.date_x.day);
        salesforceLineItem.lineItem.Start_Hour__c = dfpLi.startDateTime.hour+'';
        salesforceLineItem.lineItem.Start_Minute__c = dfpLi.startDateTime.minute+'';
        
        salesforceLineItem.lineItem.End_Date__c = Date.newInstance(dfpLi.EndDateTime.date_x.year, dfpLi.EndDateTime.date_x.month , dfpLi.EndDateTime.date_x.day);
        salesforceLineItem.lineItem.End_Hour__c = dfpLi.EndDateTime.hour+'';
        salesforceLineItem.lineItem.End_Minute__c = dfpLi.EndDateTime.minute+'';
        
        salesforceLineItem.lineItem.Status__c = dfpLi.status;
        salesforceLineItem.lineItem.reservationStatus__c = dfpLi.reservationStatus;
        
        salesforceLineItem.lineItem.Type_DFP__c = dfpLi.lineItemType; 
        //salesforceLineItem.lineItem.Name_Dfp__c = dfpLi.name; //formula
        //IT DOESN'T WORK FOR MULTISIZE
        for(DfpLineItemService.CreativePlaceholder creativePlaceHolder : dfpLi.creativePlaceholders){ //noi ne gestiamo solo uno
            salesforceLineItem.lineItem.Width__c = creativePlaceHolder.size.width; 
            salesforceLineItem.lineItem.Height__c = creativePlaceHolder.size.height;
        }
        
        Map<string,adUnit__c> adUnitMap = new Map<string,adUnit__c>();
        for(AdUnit__c ad : [select id,idDfp__c from AdUnit__c WHERE IdDfp__c <> NULL]){
            adUnitMap.put(ad.idDfp__c,ad);
        }
        Map<decimal,placement__c> placementMap = new Map<decimal,placement__c>();
        for(Placement__c p : [select id,idDfp__c from Placement__c]){
            placementMap.put(p.idDfp__c,p);
        }
            
        if(dfpLi.targeting.inventoryTargeting.targetedAdUnits != null){
            for(DfpLineItemService.AdUnitTargeting adUnitTargeting  : dfpLi.targeting.inventoryTargeting.targetedAdUnits){
                Inventory_Target__c it = new Inventory_Target__c();
                it.Ad_Unit__c = adUnitMap.get(adUnitTargeting.adUnitId).id;
                it.includeDescendants__c = adUnitTargeting.includeDescendants;
                it.InventoryTargetingType__c = 'targeted';
                salesforceLineItem.inventoryTargeting.add(it);
            }
        }
        
        if(dfpLi.targeting.inventoryTargeting.excludedAdUnits != null){
            for(DfpLineItemService.AdUnitTargeting adUnitTargeting  : dfpLi.targeting.inventoryTargeting.excludedAdUnits){
                Inventory_Target__c it = new Inventory_Target__c();
                it.Ad_Unit__c = adUnitMap.get(adUnitTargeting.adUnitId).id;
                it.includeDescendants__c = adUnitTargeting.includeDescendants;
                it.InventoryTargetingType__c = 'excluded';
                salesforceLineItem.inventoryTargeting.add(it);
            }
        }
        
        if(dfpLi.targeting.inventoryTargeting.targetedPlacementIds != null){
            for(Long l : dfpLi.targeting.inventoryTargeting.targetedPlacementIds){
                salesforceLineItem.targetedPlacement.add(new PlacementTargeting__c(Placement__c=placementMap.get(l).id));
            }
        }

        if(dfpLi.targeting.dayPartTargeting.dayParts != null){
            for(DfpLineItemService.DayPart dpt : dfpLi.targeting.dayPartTargeting.dayParts){
                DayPartTargeting__c dp = new DayPartTargeting__c();
                dp.dayOfWeek__c = dpt.dayOfWeek;
                dp.Start_Hour__c = dpt.startTime.hour+'';
                dp.Start_Minute__c = dpt.startTime.minute;
                dp.End_Hour__c = dpt.endTime.hour+'';
                dp.End_Minute__c = dpt.endTime.minute;
                salesforceLineItem.dayPartTargeting.add(dp);
            }
        }
        
        if(dfpLi.frequencyCaps != null){
            for(DfpLineItemService.FrequencyCap f : dfpLi.frequencyCaps){
                FrequencyCap__c fc = new FrequencyCap__c();
                fc.maxImpressions__c = f.maxImpressions;
                fc.numTimeUnits__c = f.numTimeUnits;
                fc.timeUnit__c = f.timeUnit;
                salesforceLineItem.frequencyCaps.add(fc);
            }
        }
        
        
        Map<Decimal,CustomTargetingKey__c> customTargetKeyMap = new Map<Decimal,CustomTargetingKey__c>();
        for(CustomTargetingKey__c key : [select id,idDfp__c from CustomTargetingKey__c]){
            customTargetKeyMap.put(key.idDfp__c,key);
        }
        
        if(dfpLi.targeting.customTargeting.children != null){
            for(DfpLineItemService.CustomCriteriaNode sets : dfpLi.targeting.customTargeting.children){
                SalesforceCustomTargeting sct = new SalesforceCustomTargeting();
                sct.CustomCriteriaSet.logicalOperator__c = sets.logicalOperator;
                if(sets.children != null){
                    for(DfpLineItemService.CustomCriteriaNode node : sets.children){
                        Custom_Criteria__c cc = new Custom_Criteria__c();
                        cc.operator__c = node.operator;
                        cc.Custom_Targeting_Key__c = customTargetKeyMap.get(node.keyId).id;
                        cc.valueIds__c = '';
                        for(long v : node.valueIds){
                            cc.valueIds__c += v+','; 
                        }
                        cc.valueIds__c += ',';
                        cc.valueIds__c = cc.valueIds__c.replace(',,','');
                        sct.CustomCriteria.add(cc);
                    }
                }
                salesforceLineItem.customTargeting.add(sct);
            }
        }

        Map<Decimal,Label__c> labelsMap = new Map<Decimal,Label__c>();
        for(Label__c l : [select id,idDfp__c from Label__c ]){
            labelsMap.put(l.idDfp__c,l);
        }

        if(dfpLi.appliedLabels != null){
            for(DfpLineItemService.AppliedLabel al : dfpLi.appliedLabels){
                AppliedLabel__c appL = new AppliedLabel__c(Label__c=labelsMap.get(al.labelId).id);
                salesforceLineItem.appliedLabels.add(appL);
            }
        }
        
        TechnologyTargeting__c tt = new TechnologyTargeting__c();
        if(dfpLi.targeting.technologyTargeting.bandwidthGroupTargeting != null){
            tt.Type__c = 'Bandwidth_Group';
            tt.Values__c = '';
            tt.valueIds__c = '';
            tt.isTargeted__c = dfpLi.targeting.technologyTargeting.bandwidthGroupTargeting.isTargeted;
            for(DfpLineItemService.Technology tec : dfpLi.targeting.technologyTargeting.bandwidthGroupTargeting.bandwidthGroups){
                tt.Values__c += tec.name; 
                tt.valueIds__c += tec.id;
            }
            salesforceLineItem.technologyTargeting.add(tt);
        }
        
        if(dfpLi.targeting.technologyTargeting.browserTargeting != null){
            tt = new TechnologyTargeting__c();
            tt.Type__c = 'Browser';
            tt.Values__c = '';
            tt.valueIds__c = '';
            tt.isTargeted__c = dfpLi.targeting.technologyTargeting.browserTargeting.isTargeted;
            for(DfpLineItemService.Technology tec : dfpLi.targeting.technologyTargeting.browserTargeting.browsers){
                tt.Values__c += tec.name; 
                tt.valueIds__c += tec.id;
            }
            salesforceLineItem.technologyTargeting.add(tt);
        }
        
        if(dfpLi.targeting.technologyTargeting.browserLanguageTargeting != null){
            tt = new TechnologyTargeting__c();
            tt.Type__c = 'Browser_Language';
            tt.Values__c = '';
            tt.valueIds__c = '';
            tt.isTargeted__c = dfpLi.targeting.technologyTargeting.browserLanguageTargeting.isTargeted;
            for(DfpLineItemService.Technology tec : dfpLi.targeting.technologyTargeting.browserLanguageTargeting.browserLanguages){
                tt.Values__c += tec.name; 
                tt.valueIds__c += tec.id;
            }        
            salesforceLineItem.technologyTargeting.add(tt);
        }
        
        if(dfpLi.targeting.technologyTargeting.operatingSystemTargeting != null){
            tt = new TechnologyTargeting__c();
            tt.Type__c = 'Operating_System';
            tt.Values__c = '';
            tt.valueIds__c = '';
            tt.isTargeted__c = dfpLi.targeting.technologyTargeting.operatingSystemTargeting.isTargeted;
            for(DfpLineItemService.Technology tec : dfpLi.targeting.technologyTargeting.operatingSystemTargeting.operatingSystems){
                tt.Values__c += tec.name; 
                tt.valueIds__c += tec.id;
            }
            salesforceLineItem.technologyTargeting.add(tt);
        }
        
        if(dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting != null){
            tt = new TechnologyTargeting__c();
            tt.Type__c = 'Operating_System_Version';
            tt.Values__c = '';
            tt.valueIds__c = '';
            tt.isTargeted__c = true;
            if(dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting.targetedOperatingSystemVersions != null){
                for(DfpLineItemService.Technology tec : dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting.targetedOperatingSystemVersions){
                    tt.Values__c += tec.name; 
                    tt.valueIds__c += tec.id;
                }
                // //TODO per noi adesso sono tutti inclusi o tutti esclusi, rifare il componente come dfp. poi verrà così
                //salesforceLineItem.technologyTargeting.add(tt);
                //tt = new TechnologyTargeting__c();
                /tt.Type__c = 'Operating_System_Version';
                //tt.Values__c = '';
                //tt.valueIds__c = '';
                // 
            }
            
            tt.isTargeted__c = false;    
            if(dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting.excludedOperatingSystemVersions != null){
                for(DfpLineItemService.Technology tec : dfpLi.targeting.technologyTargeting.operatingSystemVersionTargeting.excludedOperatingSystemVersions){
                    tt.Values__c += tec.name; 
                    tt.valueIds__c += tec.id;
                }
                salesforceLineItem.technologyTargeting.add(tt);
            }
            salesforceLineItem.technologyTargeting.add(tt);
        }
        
        return salesforceLineItem;
    }    
    */
    
    /*
        update priority for dfplineitem.
        for not override technology,geo and custom targeting, it requires set xsi:type
        instead use XXX_type (see function above: setTechnologyType,setGeoType,setCustomCriteriaType)    
    */
    public static void fillDfpLineItem(
        DfpLineItemService.LineItem li,
        String newpriority,
        Inventory_Target__c[] newInventoryTarget, 
        PlacementTargeting__c[] newPlacementTargeting, 
        AppliedLabel__c[] newLabels
    ){    
        if(newPriority != null) {
            Integer p = Integer.valueOf(newPriority);
            li.priority = p;
        }

        Boolean hasInventoryTarget = newInventoryTarget != null && !newInventoryTarget.isEmpty();
        Boolean hasPlacementTarget = newPlacementTargeting != null && !newPlacementTargeting.isEmpty();

        if(hasInventoryTarget) {
            li.targeting.inventoryTargeting.targetedAdUnits = new List<DfpLineItemService.AdUnitTargeting>();
            li.targeting.inventoryTargeting.excludedAdUnits = new List<DfpLineItemService.AdUnitTargeting>();
            for(Inventory_Target__c it : newInventoryTarget){
                DfpLineItemService.AdUnitTargeting adUnitTargeting = new DfpLineItemService.AdUnitTargeting();
                adUnitTargeting.adUnitId  = it.adUnitIdDfp__c;
                adUnitTargeting.includeDescendants  = it.includeDescendants__c;
                if(it.InventoryTargetingType__c == 'targeted'){
                    li.targeting.inventoryTargeting.targetedAdUnits.add(adUnitTargeting);
                }else{
                    li.targeting.inventoryTargeting.excludedAdUnits.add(adUnitTargeting);
                }
            }
        }

        if(hasPlacementTarget || hasInventoryTarget) {
            li.targeting.inventoryTargeting.targetedPlacementIds = new Long[]{};
        }

        if(hasPlacementTarget) {            
            for(PlacementTargeting__c pt : newPlacementTargeting){
                li.targeting.inventoryTargeting.targetedPlacementIds.add( (long) pt.placementId__c );
            }            
        }

        if(newLabels != null) {
            li.appliedLabels = new DfpLineItemService.AppliedLabel[]{};            
            for(AppliedLabel__c l : newLabels){
                 if(l.Label__r.type__c != 'AD_UNIT_FREQUENCY_CAP'){
                DfpLineItemService.AppliedLabel al = new DfpLineItemService.AppliedLabel();
                al.labelId = (long) l.idDfp__c;
                al.isNegated = false; //TODO, verificare
                li.appliedLabels.add(al);
                 }
            }            
        }
    }
    
    public static void prepareDfpLineItemForUpdate(DfpLineItemService.LineItem li) {
        if(li.targeting.technologyTargeting.bandwidthGroupTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.bandwidthGroupTargeting.bandwidthGroups);
        }
        if(li.targeting.technologyTargeting.BrowserTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.browserTargeting.browsers );
        }
        if(li.targeting.technologyTargeting.browserLanguageTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.browserLanguageTargeting.browserLanguages );
        }
        if(li.targeting.technologyTargeting.deviceCapabilityTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.deviceCapabilityTargeting.targetedDeviceCapabilities );
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.deviceCapabilityTargeting.excludedDeviceCapabilities );
        }
        if(li.targeting.technologyTargeting.deviceCategoryTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.deviceCategoryTargeting.targetedDeviceCategories );
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.deviceCategoryTargeting.excludedDeviceCategories );
        }
        if(li.targeting.technologyTargeting.deviceManufacturerTargeting!= null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.deviceManufacturerTargeting.deviceManufacturers );
        }
        if(li.targeting.technologyTargeting.mobileCarrierTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.mobileCarrierTargeting.mobileCarriers );
        }
        if(li.targeting.technologyTargeting.mobileDeviceTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.mobileDeviceTargeting.targetedMobileDevices);
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.mobileDeviceTargeting.excludedMobileDevices);
        }
        if(li.targeting.technologyTargeting.mobileDeviceSubmodelTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.mobileDeviceSubmodelTargeting.targetedMobileDeviceSubmodels );
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.mobileDeviceSubmodelTargeting.excludedMobileDeviceSubmodels );                    
        }
        if(li.targeting.technologyTargeting.operatingSystemTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.operatingSystemTargeting.operatingSystems );
        }
        if(li.targeting.technologyTargeting.operatingSystemVersionTargeting != null){
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.operatingSystemVersionTargeting.targetedOperatingSystemVersions );
            UtilityLineItemIntegration.setTechnologyType(li.targeting.technologyTargeting.operatingSystemVersionTargeting.excludedOperatingSystemVersions );
        }   
        
        if(li.targeting.geoTargeting != null){
            UtilityLineItemIntegration.setGeoType(li.targeting.geoTargeting.targetedLocations);
            UtilityLineItemIntegration.setGeoType(li.targeting.geoTargeting.excludedLocations);
        }
        
        if(li.targeting.customTargeting != null){
            UtilityLineItemIntegration.setCustomCriteriaType(li.targeting.customTargeting);
        }   
    }

    public static testMethod void testUtilityLineItemIntegration(){
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        lineitem__c li = new lineitem__c(
            opportunity__c=o.id,
            Start_Date__c=date.today(),
            Start_Hour__c='0',
            Start_Minute__c='0',
            End_Date__c=date.today(),
            End_Hour__c='0',
            End_Minute__c='0',
            prezzo_net_net__c = 0
        );
        
        
        insert li;
        
        UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
        UtilityLineItemIntegration.getLineItemsByOppId(o.id);
        
        DfpLineItemService.LineItem dfpLi = new DfpLineItemService.LineItem();
        
        UtilityLineItemIntegration.syncDfpToSfdcLineItem(li,dfpLi);
        UtilityLineItemIntegration.syncSfdcToDfpLineItem(li,dfpLi,0);
        
        /*
        try{
            UtilityLineItemIntegration.syncDfpToSfdcLineItem(dfpLi,li);
        }catch(Exception e){}
        */     
        
    }

}