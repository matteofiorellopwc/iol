trigger LineItem on LineItem__c (
    after delete,
    after insert,
    after update, 
    before delete,
    before insert,
    before update
) { 
    if(!UtilityTrigger.skipTrigger && !LineItemTriggerHandler.skipLineItemTrigger){
        System.debug('Lineitem.trigger!!!');
     System.debug('Lineitem.trigger!!! nr li'+trigger.size);
        System.debug('Trigger.isBefore!!! nr li'+trigger.isBefore);
        System.debug('Trigger.isAfter!!! nr li'+trigger.isAfter);
        System.debug('Trigger.isUpdate!!! nr li'+trigger.isUpdate);

////////////////////////////luca modifiche per il calcolo canale budget
		
		if((!Test.isRunningTest()) && Trigger.isBefore && !Trigger.isDelete) {
		 System.debug('Trigger.isBefore');
		 Map<Id, LineItem__c> liMap = LineItemTriggerHandler.getLineItemMap();
         Map<Id,CustomCriteriaSet__c[]> customMap = LineItemTriggerHandler.getCustomCriteriaMap();
         
         ///Vertical__c 
         
        	 for(LineItem__c li : trigger.new) { 
        	 	system.debug('ciclo for'); 
//      system.debug('li.local__c'+li.local__c+' customMap.size() '+customMap.size()+' li.Delivery_Model__c '+ li.Delivery_Model__c+' liMap.size()>0 '+liMap.size());
	                if(li.local__c){
			 			li.canale_Budget__c='Local';
					}else if (customMap.size()>0){
						li.canale_Budget__c='Audience';
					}else if (li.Delivery_Model__c == 'CPC'){
						li.canale_Budget__c='CPC';
					}else if (li.Vertical__c != null){
						String currVert=li.Vertical__c;
						if(currVert.indexOfIgnoreCase('hp')!=-1){
							li.canale_Budget__c='HP';
						}else{
				        	li.canale_Budget__c='7portals';
						}						
					}
					else if (li.Canale_primario__c == 'RON'){
						 system.debug(li.Canale_primario__c);
						 li.canale_Budget__c='RON';
					}else if (li.Canale_primario__c == 'MAIL'){
						 system.debug(li.Canale_primario__c);
						 li.canale_Budget__c='MAIL';
					}else if (li.Canale_primario__c == 'HP'){
						 system.debug(li.Canale_primario__c);
						 li.canale_Budget__c='HP';
					}else if (liMap.size()>0){
						system.debug('liMap.size() '+liMap.size());
				       for(inventory_target__c iv : liMap.get(li.id).inventory_target__r){
				            if(iv.InventoryTargetingType__c == 'targeted'){
	      			    			li.canale_Budget__c='7portals';
				            }
				            system.debug(iv.path__c);			            
				        }
	                }else if (li.Prodotto__c.indexOfIgnoreCase('dem')!=-1){
	                	li.canale_Budget__c='DEM';
	                }else if (li.Prodotto__c.indexOfIgnoreCase('SMS')!=-1){
	                	li.canale_Budget__c='SMS';
	                }
	                system.debug('fine ciclo');
	                   system.debug('li.canale_Budget__c '+li.canale_Budget__c);				
					}

        	 }
		
/////////////////////////////////





        if(Trigger.isBefore) {      
            if(Trigger.isDelete) {
                LineItemTriggerHandler.checkDeletedLi(trigger.old);     
                 
                for(LineItem__c li : trigger.old) {
                    //Calcolo la mappa delle opportunità
                    LineItemTriggerHandler.oppToUpdate.put(li.Opportunity__c, new Opportunity(Id = li.Opportunity__c));             
                }
                LineItemTriggerHandler.deleteLineItemChilds();          
            } else {
                Map<Id, LineItem__c> lineItemMap = LineItemTriggerHandler.getLineItemMap();
                Map<Id,CustomCriteriaSet__c[]> ccMap = LineItemTriggerHandler.getCustomCriteriaMap();
                for(LineItem__c li : trigger.new) {             
                    //Calcolo la mappa delle opportunità
                    LineItemTriggerHandler.oppToUpdate.put(li.Opportunity__c, new Opportunity(Id = li.Opportunity__c));
                    
                    if(Trigger.isUpdate) {
                        LineItemTriggerHandler.rollupOptionals(li, lineItemMap);
                        LineItemTriggerHandler.joinInventoryTarget(li, lineItemMap);
                        LineItemTriggerHandler.joinCustomCriteria(li,ccMap);
                    }
                    LineItemTriggerHandler.updateFieldsFromFormula(li);  
                    
                    System.debug('UPDATE CALC IN TRIGGER!!! ' + li);
                    UtilLineItem.updatecalc(li,'',null);
                                    
                    if(Trigger.isUpdate) {
                        if(UtilNotificheOAS.isChagendLineItem(trigger.oldMap.get(li.Id),li) && li.ad_server__c == 'OAS') {
                            li.Ultima_modifica_campi_OAS__c = System.now();
                            if(li.opportunityWon__c == 1){
                                if(li.Stato_lavorazione_OAS__c == '' || li.Stato_lavorazione_OAS__c == 'Da Caricare Pianificazione'){
                                    li.Stato_lavorazione_OAS__c = 'Da Caricare Pianificazione';
                                }else{
                                    li.Stato_lavorazione_OAS__c = 'Da Rilavorare';
                                }
                            }
                        }

                        if(LineItemTriggerHandler.hasToUpdateAsset(li, trigger.oldMap.get(li.Id))) {
                            LineItemTriggerHandler.lineItemWithAssetToUpdate.add(li.Id);
                        } 
                                            
                        LineItemTriggerHandler.raToUpdate.addAll(
                            LineItemTriggerHandler.rollupRevenues(li, lineItemMap)
                        );
                        
                        LineItemTriggerHandler.checkRicavi(li, lineItemMap);

                    }
                    
                    if(Trigger.isInsert) {
                        //Calcolo le mappe per la gestione del team targeted                                
                        LineItemTriggerHandler.prodsId.add(li.product__c);
                        LineItemTriggerHandler.oppTeamsTargeted.put(li.opportunity__c, new Set<Id>());
                        LineItemTriggerHandler.prodTeamsTargeted.put(li.Product__c, new Set<Id>());
                        
                        //Gestione OAS
                        if(li.ad_server__c == 'OAS'){
                            if(li.opportunityWon__c == 1) li.Stato_lavorazione_OAS__c = 'Da Caricare Pianificazione';
                            li.Ultima_modifica_campi_OAS__c = System.now();
                        }                                                                                                       
                    }

                    // se il line item ha un bacino di impression disponibili, e non lo supera del 120%, viene automaticamente approvato
                    if(li.CheckUtilizzoSOV__c){ 
                        li.AllowOverbook__c = !li.ApprovazioneOverbookRichiesta__c;
                    }
                }
            }       
        }
        
        if(Trigger.isAfter) {
            LineItemTriggerHandler.skipUpdateLineItem = true;
            if(Trigger.isDelete) {      
                
            } else if(Trigger.isInsert) {
                LineItemTriggerHandler.insertTeamTargeted(trigger.new);
            } else if(Trigger.isUpdate) {
                //Aggiorno i valori obiettivo sulle revenue TODO FARE TEST PER VERIFICARE CHE NON SERVE PIÙ
                //update LineItemTriggerHandler.raToUpdate;
                //Controllo somma totali, somma revenue
                LineItemTriggerHandler.validateTotali(trigger.new);
                
                //Validazioni su date, campi modificabili per evitare errori durante la sincronizzazione con gli ad server
                LineItemTriggerHandler.validationLineItems();
                
                //Aggiorno gli asset
                List<Asset> aL = [SELECT
                    Id
                    FROM Asset
                    WHERE Line_item__c IN :LineItemTriggerHandler.lineItemWithAssetToUpdate
                    AND Tipo__c = 'Erogato DFP Mensile'
                ];
                update aL;      
            }
            
            //Forzo la partenza dei trigger sull'opportunità
            update LineItemTriggerHandler.oppToUpdate.values();
        }               
        
        //Se necessario, invio le notifiche OAS
        LineItemTriggerHandler.sendOASEmails();      
    }                                                                       
}