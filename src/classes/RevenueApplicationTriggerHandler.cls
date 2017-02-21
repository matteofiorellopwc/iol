public class RevenueApplicationTriggerHandler { 
    public static Boolean skipUpdateRevenues = false;
    public static Boolean updateRevenuesStorico = false; //aggiorna storico revenue solo se opportunity è diventata chiusa vinta
    
    /**
     *  previene la cancellazione delle revenue già fatturate
     *  @Returns lista delle revenue senza errori
     */
    public static Revenue_application__c[] preventDeleteIfFatturate(Revenue_application__c[] values) {
        Revenue_application__c[] res = new Revenue_application__c[]{};
        for(Revenue_application__c ra : values) {
            if(ra.Ticket_Fatturazione__c != null) {
                ra.addError('Non si possono eliminare revenue application già fatturate');
            } else res.add(ra); 
        }
        return res;
    }
    
    /**
     *  Forza un update dei lineitem associati alle revenues in input, ma solo se skipUpdateLineItem = false
     */
    public static void updateLineItems(Revenue_application__c[] values) {
        if(!LineItemTriggerHandler.skipUpdateLineItem) {
            Map<Id, LineItem__c> lineItemsMap = new Map<Id, LineItem__c>();                   
            for(Revenue_application__c ra : values) {
                if(ra.Line_Item__c != null) {
                    lineItemsMap.put(ra.line_item__c, new LineItem__c(Id = ra.line_item__c));
                }
            }
            update lineItemsMap.values();        
        }           
    }

    /**
     *  Aggiorna i campi inerenti agli obiettivi sulla revenue application in input
     *  Necessario in quanto sono terminate le formule
     */ 
    public static void updateFieldsObiettivo(Revenue_application__c ra, Map<Id, Account> accountMap, Map<Id, User> userMap, Map<Id, LineItem__c> lineItemMap) {     
        if(ra.Tipo_obiettivo__c == 'Forecast Classe Prodotto') ra.classe_prodotto_obiettivo_trig__c = ra.Forecast_Classe_Prodotto_obiettivo__c;
        else {
            Map<String, String> classeMapping = new Map<String, String>{
                'Banner' => 'Premium CPM',
                'Dem' => 'Premium CPM',
                'CPC' => 'Perf.s & Portal Deal',
                'Partnership' => 'Perf.s & Portal Deal',
                'Network' => 'Perf.s & Portal Deal',
                'Simply' => 'Perf.s & Portal Deal',
                'Wind' => 'Wind',
                'Search' => 'Search',
                'Mobile' => 'Mobile',
                'Captive' => 'Captive',
                'Timspot' => 'Timspot'
            };
            ra.classe_prodotto_obiettivo_trig__c = classeMapping.get(ra.sotto_classe_obiettivo__c);
            if(ra.classe_prodotto_obiettivo_trig__c == null) ra.classe_prodotto_obiettivo_trig__c = '';                     
        }               
        
        if(ra.Line_Item__c != null && lineItemMap.get(ra.Line_Item__c).Opportunity__r.Venditore__c != null) {       
            ra.Venditore_trig__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.Venditore__r.FirstName + ' ' + ra.Line_Item__r.Opportunity__r.Venditore__r.LastName;
            ra.Canale_venditore_trig__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.Venditore__r.Canale__c;
        }

        if(ra.Venditore_obiettivo__c != null) {
            ra.Venditore_obiettivo_trig__c = userMap.get(ra.Venditore_obiettivo__c).FirstName + ' ' + userMap.get(ra.Venditore_obiettivo__c).LastName;
            ra.Venditore_obiettivo_canale_trig__c = userMap.get(ra.Venditore_obiettivo__c).Canale__c;
        }
        
        if(ra.Centro_Media_obiettivo__c != null) {         
            ra.Centro_media_obiettivo_trig__c = accountMap.get(ra.Centro_media_obiettivo__c).Name;
        }
        
        if(ra.Cliente_obiettivo__c != null) {
            ra.Cliente_obiettivo_trig__c = accountMap.get(ra.Cliente_obiettivo__c).Name;
        }
        
        if(ra.Agenzia_territoriale_obiettivo__c != null) {                                        
            ra.Agenzia_territoriale_obiettivo_trig__c = accountMap.get(ra.Agenzia_territoriale_obiettivo__c).Name;
        }               
    }

    /**
     *  Aggiorna i campi inerenti agli obiettivi sulle revenue application in input
     *  Necessario in quanto sono terminate le formule
     */     
    public static void updateFieldsObiettivo(Revenue_application__c[] revenues) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> liSet = new Set<Id>();
        for(Revenue_application__c ra : revenues) {
            if(ra.Centro_Media_obiettivo__c != null) accountIds.add(ra.Centro_media_obiettivo__c);
            if(ra.Cliente_obiettivo__c != null) accountIds.add(ra.Cliente_obiettivo__c);
            if(ra.Agenzia_territoriale_obiettivo__c != null) accountIds.add(ra.Agenzia_territoriale_obiettivo__c);
            if(ra.Venditore_obiettivo__c != null) userIds.add(ra.Venditore_obiettivo__c);
            if(ra.Line_Item__c != null) liSet.add(ra.Line_Item__c);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT
            Name
            FROM Account
            WHERE Id IN :accountIds
        ]);
        
        Map<Id, User> userMap = new Map<Id, User>([SELECT
            FirstName,
            LastName,
            Canale__c
            FROM User
            WHERE Id IN :userIds
        ]);
        
        Map<Id, LineItem__c> lineItemMap = new Map<Id, LineItem__c>([SELECT
            Opportunity__r.Venditore__c,
            Opportunity__r.Venditore__r.FirstName,
            Opportunity__r.Venditore__r.LastName,
            Opportunity__r.Venditore__r.Canale__c
            FROM LineItem__c
            WHERE Id IN :liSet
        ]);
                    
        for(Revenue_application__c ra : revenues) {
            updateFieldsObiettivo(ra, accountMap, userMap, lineItemMap);                                
        }       
    }

    /**
     *  Aggiorna i campi inerenti allo storico sulle revenue application in input
     *  
     */     
    public static void updateFieldsStorico(Revenue_application__c[] revenues) {
        Set<Id> liSet = new Set<Id>();
        for(Revenue_application__c ra : revenues) {
            if(ra.Line_Item__c != null) liSet.add(ra.Line_Item__c);
        }
        
        Map<Id, LineItem__c> lineItemMap = new Map<Id, LineItem__c>([SELECT
            Start_Date__c,
            End_Date__c,
            sconto__c,
            Sconto_totale__c,
            Prezzo_net_net__c,
            Totale__c,
            Opportunity__r.OwnerAccount__c,
            Sotto_Classe__c,
            Opportunity__r.Centro_Media__r.Name,
            Opportunity__r.OwnerBrandHistory__r.Name,
            Opportunity__r.OwnerCMHistory__r.Name,
            Opportunity__r.AgenziaTerritorialeHistory__r.Name,
            Opportunity__r.Agenzia_Brand__c,
            Quantita__c,
            Classe_prodotto__c,
            Opportunity__r.OwnerCentroMedia__c,
            Opportunity__r.Tipo_Opportunity__c,
            Opportunity__r.Canale_di_vendita__c
            FROM LineItem__c
            WHERE Id IN :liSet
        ]);
                    
        for(Revenue_application__c ra : revenues) {
            if(ra.Line_Item__c != null) {   
                try{
                    ra.LiStartDateStorico__c = lineItemMap.get(ra.Line_Item__c).Start_Date__c;
                    ra.LiEndDate__c = lineItemMap.get(ra.Line_Item__c).End_Date__c;
                    ra.LiSconto__c = lineItemMap.get(ra.Line_Item__c).sconto__c;
                    ra.LiScontoTotale__c = lineItemMap.get(ra.Line_Item__c).Sconto_totale__c;
                    ra.LiPrezzoNetNet__c = lineItemMap.get(ra.Line_Item__c).Prezzo_net_net__c;
                    ra.LiTotale__c = lineItemMap.get(ra.Line_Item__c).Totale__c;
                    ra.RaValore__c = ra.Valore__c;
                    ra.RaPercentuale_applicata__c = ra.Percentuale_applicata__c;
                    ra.RaAnno__c = ra.Anno__c;
                    ra.RaMese__c = ra.Mese__c;
                    ra.RaDataPrimoMeseStorico__c = ra.Data_primo_mese__c;
                    ra.RaTipoAccountDirettaStorico__c = ra.Tipo_Account_Diretta__c;
                    ra.RaCapoGruppoCentroMediaStorico__c = ra.Capo_Gruppo_Centro_Media__c;
                    ra.OpVenditoreBrandPortafoglioStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.OwnerAccount__c;
                    ra.LiSottoClasseStorico__c = lineItemMap.get(ra.Line_Item__c).Sotto_Classe__c;
                    ra.OpCentroMediaStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.Centro_Media__r.Name;
                    ra.OpVenditoreBrandStoricoStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.OwnerBrandHistory__r.Name;
                    ra.OpVenditoreCMStoricoStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.OwnerCMHistory__r.Name;
                    ra.OpAgenziaDiRiferimentoStoricoStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.AgenziaTerritorialeHistory__r.Name;
                    ra.OpAgenziaRiferimentoPortafoglioStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.Agenzia_Brand__c;
                    ra.LiQuantitStorico__c = lineItemMap.get(ra.Line_Item__c).Quantita__c;
                    ra.LiClasseProdottoStorico__c = lineItemMap.get(ra.Line_Item__c).Classe_prodotto__c;
                    ra.OpVenditoreCMPortafoglioStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.OwnerCentroMedia__c;
                    ra.OpTipoOpportunityStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.Tipo_Opportunity__c;
                    ra.OpCanaleDiVenditaStorico__c = lineItemMap.get(ra.Line_Item__c).Opportunity__r.Canale_di_vendita__c;
                }catch(Exception e){
                    System.debug('Eccezione rilevata: '+e.getMessage());
                }
            }                                
        }       
    }


    /**
     *  Copia tutte le impostazioni di sharing dell'opportunità e le applica alle revenue collegate
     *  Serve per emulare un "controlled by parent" sulle revenue, che non sono master detail
     */
    /* 
    public static void copySharingFromOpportunity(Revenue_application__c[] triggerNew) {
        Map<Id, Revenue_application__c> raMap = new Map<Id, Revenue_application__c>();
        Opportunity[] opps = new Opportunity[]{};
        for(Revenue_application__c ra : [SELECT
            Id,
            Line_Item__r.Opportunity__c
            FROM Revenue_application__c
            WHERE Id IN :triggerNew
            AND Line_Item__r.Opportunity__c <> NULL
        ]) {
            raMap.put(ra.Id, ra);
            opps.add(new Opportunity(Id = ra.Line_Item__r.Opportunity__c));
        }
        OpportunityTriggerHandler.updateRevenueSharing(raMap, opps);        
    } 
    */  
    
    /*
        Se inserisco una revenue o se cambio mese e anno di una esistente devo aggiornare gli asset mensili
        Se le rimuovo semplicemente si sbiancherà il campo revenue sull'asset
    */
    public static void updateAssets(){
        set<id> liToUpdateAsset = new set<id>();
        for(Revenue_Application__c ra : (Revenue_application__c[])Trigger.new){
            if( Trigger.isInsert || 
                Trigger.oldMap.get(ra.id).get('Mese__c') != Trigger.newMap.get(ra.id).get('Mese__c') ||
                Trigger.oldMap.get(ra.id).get('Anno__c') != Trigger.newMap.get(ra.id).get('Anno__c')    
            ){
                liToUpdateAsset.add(ra.line_item__c); 
            }
        }

        if(liToUpdateAsset.size() > 0){
            List<Asset> assets = [select id from asset where line_item__c in : liToUpdateAsset limit 1001];
            if(assets.size()>1000){
                database.executeBatch(new BatchableUpdateAssets(liToUpdateAsset),1000);        
            }else{
                update assets;
            }
        }
        
    }
}