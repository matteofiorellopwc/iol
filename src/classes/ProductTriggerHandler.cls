public class ProductTriggerHandler {

    public static boolean skipProductTrigger = false;

    public static void addPriceBookEntry(Product2[] prods) {
        try{
            Pricebook2 pbStandard = [SELECT
                Id FROM Pricebook2
                WHERE isStandard = true
                AND isActive = true
            ];
            
            Set<Id> prodWithPbe = new Set<Id>();
            for(PricebookEntry pbe : [SELECT
                Id,
                product2id 
                FROM PricebookEntry 
                WHERE priceBook2Id = :pbStandard.id
                AND product2Id IN :prods
            ]){
                prodWithPbe.add(pbe.product2id);
            }
            
            PricebookEntry[] pbeToInsert = new PricebookEntry[]{};
            for(Product2 p : prods){
                if(!prodWithPbe.contains(p.id)){
                    priceBookEntry pbe = new priceBookEntry();
                    pbe.product2id = p.id;
                    pbe.priceBook2id = pbStandard.id;
                    pbe.isActive = true;
                    pbe.UnitPrice = 0;                
                    pbeToInsert.add(pbe);
                }
            }
            
            insert pbeToInsert;         
        }catch(Exception e) {
            //Questo catch serve per gestire i test
            system.debug(e.getMessage());
        }       
    }
    
    public static void doFieldUpdates(Product2[] prods) {
        for(Product2 p : prods){
            p.ore_singole_text__c = p.ore_singole__c; //MULTISELECT TO TEXT
        }       
    }
    
    /**
     *  This method creates the impressions stimate records related to the input prods, if they don't exist.
     */  
    public static void createImpressionStimateObj(Product2[] prods, Map<Id,Product2> oldProds, Boolean isInsert) {
        
        Map<Id, Set<Id>> existingImpressionMap = deleteNotNeededImpressionsStimate(prods, oldProds, isInsert);
        
        Set<Id> productIds = new Set<Id>();
        Set<String> canaliPrimari = new Set<String>();      
        Map<Id,Set<String>> canaliAdUnitMap = new Map<Id,Set<String>>(); //id adunit -> set canali primari
        
        Map<Id, Set<String>> prodMultisizesMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> adUnitMultisizeMap = new Map<Id, Set<String>>();


        for(Product2 p : prods) {
            if(p.Delivery_Model__c == 'CPD' && p.CalcolaCPDconImprStimate__c) {
                productIds.add(p.Id);
                if(p.CanalePrimario__c != null && p.CanalePrimario__c != '') {
                    canaliPrimari.add(p.CanalePrimario__c);
                } 
                if(p.Size__c == 'Multisize') {
                    String[] pSizes = p.Multisize__c.split(';');
                    Set<String> pSizesSet = new Set<String>();
                    pSizesSet.addAll(pSizes);
                    prodMultisizesMap.put(p.Id, pSizesSet);
                }
            }           
        }
        
        if(productIds.isEmpty()){
            return;
        }
                
        Map<Id,AdUnit__c> availableAdUnits = new Map<Id,AdUnit__c>();

        for(AdUnit__c a : [SELECT Id, SublevelSizes__c, CanalePrimario__c FROM AdUnit__c WHERE showAdUnitFormula__c = TRUE AND CanalePrimario__c <> NULL AND SublevelSizes__c <> NULL]) {
            for(String cp : a.CanalePrimario__c.split(';')) {
                if(canaliPrimari.contains(cp)) {
                    availableAdUnits.put(a.id,a);                   
                }
            }
            String[] pSizes = a.sublevelSizes__c.split(';');
            Set<String> pSizesSet = new Set<String>();
            pSizesSet.addAll(pSizes);
            adUnitMultisizeMap.put(a.Id, pSizesSet);

            canaliAdUnitMap.put(a.id,new set<String>());
            if(! String.isBlank(a.CanalePrimario__c)){
                canaliAdUnitMap.get(a.id).addAll(a.CanalePrimario__c.split(';'));
            }
        }       

        Map<String, Set<Id>> sizeMap = new Map<String, Set<Id>>();
        for(Product2 p : prods) {
            if(productIds.contains(p.id)){
                for(AdUnit__c a : availableAdUnits.values()) {
                    if(adUnitMultisizeMap.get(a.Id) != null && prodMultisizesMap.get(p.Id) != null  && adUnitMultisizeMap.get(a.Id).containsAll(prodMultisizesMap.get(p.Id))) {
                        String[] pSizes = new String[]{};
                        pSizes.addAll(prodMultisizesMap.get(p.Id));
                        pSizes.sort();                  
                        String key = String.join(pSizes, ';');
                        
                        if(!sizeMap.containsKey(key)) sizeMap.put(key, new Set<Id>());
                        sizeMap.get(key).add(a.Id);
                    }               
                }
            }
        }
        
        for(AdUnit__c au : availableAdUnits.values()) {         
            String[] sizes = au.sublevelSizes__c.split(';');
            for(String size : sizes) {
                if(!sizeMap.containsKey(size)) sizeMap.put(size, new Set<Id>());
                sizeMap.get(size).add(au.Id);
            }               
        } 
                
        Impressions_Stimate__c[] isList = new Impressions_Stimate__c[]{};
        for(Product2 p : prods) {
            if(productIds.contains(p.id)){
                String key = null;
                if(p.Size__c != 'Multisize' && sizeMap.containsKey(p.Size__c)) {
                    key = p.Size__c; 
                } else if(p.Size__c == 'Multisize') {
                    String[] pSizes = new String[]{};
                    pSizes.addAll(prodMultisizesMap.get(p.Id));
                    pSizes.sort();                  
                    key = String.join(pSizes, ';');                                                             
                }
    
                if(key == null || !sizeMap.containsKey(key)) continue;
                
                for(Id auId : sizeMap.get(key)) {
                    if( 
                        canaliAdUnitMap.get(auId).contains(p.CanalePrimario__c) && 
                        (existingImpressionMap.get(p.Id) == null || !existingImpressionMap.get(p.Id).contains(auId))
                    ) {
                        isList.add(new Impressions_Stimate__c(Product__c = p.Id, AdUnit__c = auId, Feriali__c = 0, Festive__c = 0));
                    }
                }
            }
        }
        insert isList;                  
    }
                
    /**
     *  This method checks if product properties don't match anymore with the existing adunit properties (size, canaleprimario) and deletes
     *  the records of impressions_stimate__c that are not needed anymore.
     *  Returns: a map productId=>Set<ImpressionsStimateId> of the impressions stimate that are still related to the product and should not be overridden
     */
    private static Map<Id, Set<Id>> deleteNotNeededImpressionsStimate(Product2[] prods, Map<Id,Product2> oldProds, Boolean isInsert) {
        //Map<Id, Id> changedSizesMap = new Map<Id, Id>();
        Set<Id> changedSomething = new Set<Id>();
        
        for(Product2 p : prods) {
            if(!isInsert && oldProds != null                                                    && 
               (oldProds.get(p.Id).Delivery_Model__c == 'CPD' && p.Delivery_Model__c != 'CPD'   ||
               oldProds.get(p.Id).CalcolaCPDconImprStimate__c != p.CalcolaCPDconImprStimate__c  ||             
               oldProds.get(p.Id).CanalePrimario__c != p.CanalePrimario__c                      ||
               oldProds.get(p.Id).Size__c != p.Size__c                                          ||
               oldProds.get(p.Id).multisize__c != p.multisize__c))
            {
                changedSomething.add(p.Id);    
            }                                   
        }

        if(!changedSomething.isEmpty()) {
            delete [SELECT Id FROM Impressions_Stimate__c WHERE Product__c IN :changedSomething];
        }   
        
        Map<Id, Set<Id>> existingImpressionMap = new Map<Id, Set<Id>>();
        Map<Id, Impressions_Stimate__c> isToDelete = new Map<Id, Impressions_Stimate__c>();
        for(Impressions_Stimate__c is : [SELECT Id, Product__c, Product__r.CanalePrimario__c, AdUnit__c, AdUnit__r.CanalePrimario__c, AdUnit__r.sublevelSizes__c, Product__r.Size__c, Product__r.multisize__c FROM Impressions_Stimate__c WHERE Product__c IN :prods]) {
            Boolean mustDeleteIs = is.AdUnit__r.sublevelSizes__c == null || is.AdUnit__r.sublevelSizes__c == '' || is.AdUnit__r.CanalePrimario__c == null || is.AdUnit__r.CanalePrimario__c == ''; 

            if(mustDeleteIs) {
                isToDelete.put(is.Id, is);
                continue;
            }
                                    
            Set<String> adunitSizes = new Set<String>();
            adunitSizes.addAll(is.AdUnit__r.sublevelSizes__c.replace(' ', '').split(';'));
            if(is.Product__r.Size__c == 'Multisize') {
                Set<String> sizes = new Set<String>();
                sizes.addAll(is.Product__r.multisize__c.split(';'));
                mustDeleteIs = !adUnitSizes.containsAll(sizes); 
            } else {            
                mustDeleteIs = !adunitSizes.contains(is.Product__r.Size__c.replace(' ', ''));
            }
            
            if(mustDeleteIs) {
                isToDelete.put(is.Id, is);
                continue;
            }
            
            Set<String> adunitCanaliPrimari = new Set<String>();
            adunitCanaliPrimari.addAll(is.AdUnit__r.CanalePrimario__c.split(';'));
            mustDeleteIs = !adunitCanaliPrimari.contains(is.Product__r.CanalePrimario__c);
             
            if(mustDeleteIs) {
                isToDelete.put(is.Id, is);
                continue;
            }   
            
            if(!existingImpressionMap.containsKey(is.Product__c)) existingImpressionMap.put(is.Product__c, new Set<Id>());
            existingImpressionMap.get(is.Product__c).add(is.AdUnit__c);
        }

        Database.delete(isToDelete.values(), false);    
        return existingImpressionMap;       
    }
    
    public static void resetCPD(Product2[] prods, Map<Id, Product2> oldProds) {
        Set<Id> prodsToReset = new Set<Id>();
        if(oldProds == null) return;
        for(Product2 p : prods) {
            Boolean isCPDTypeChanged = p.Delivery_Model__c == 'CPD' && p.CalcolaCPDconImprStimate__c && !oldProds.get(p.Id).CalcolaCPDconImprStimate__c;
            if(isCPDTypeChanged) prodsToReset.add(p.Id);            
        }   
        if(!prodsToReset.isEmpty()) {
            delete [SELECT Id FROM Inventory_Target__c WHERE Product__c IN :prodsToReset];
            delete [SELECT Id FROM DayPartTargeting__c WHERE Product__c IN :prodsToReset];
        }
    }
    
    public static void preventModify(Product2[] prods, Map<Id, Product2> oldProds) {
        Set<Id> modifiedProducts = new Set<Id>();
        Map<Id, Product2> pMap = new Map<Id, Product2>(prods);
        for(Product2 p : prods) {
            Boolean isChanged = (
                p.Delivery_model__c != oldProds.get(p.Id).Delivery_model__c // ||
                //p.Portale__c != oldProds.get(p.Id).Portale__c             ||
                //p.Size__c != oldProds.get(p.Id).Size__c                     ||
                //p.multisize__c != oldProds.get(p.Id).multisize__c         ||
                //p.Target_platform__c != oldProds.get(p.Id).target_platform__c 
            );
            if(isChanged) modifiedProducts.add(p.Id);
        }
        
        if(!modifiedProducts.isEmpty()) {
            for(Product2 p : [SELECT
                Id,
                Name,
                (SELECT Id FROM line_items__r Limit 1)
                FROM Product2
                WHERE Id IN :prods
            ]) {
                if(!p.Line_items__r.isEmpty()) {
                    pMap.get(p.Id).addError('Delivery model, size e target platform non si possono modificare se il prodotto ha line item associati');
                }
            }
        }               
    }    
    
    public static void deleteProductChilds(Product2[] prods) {
        //Per evitare query inutili alla cancellazione degli oggettini
        LineItemTriggerHandler.skipUpdateLineItem = true;
    
        Product2[] deletedProduct = [SELECT
            Id,
            Name,
            (SELECT Id FROM Day_Part_Targeting__r),
            (SELECT Id FROM Frequency_Caps__r),
            (SELECT Id FROM Inventory_Target__r),
            (SELECT Id FROM Technology_Targeting__r),
            (SELECT Id FROM Custom_Criteria_Set__r),
            (SELECT Id FROM Optionals__r),
            (SELECT Id FROM PlacementTargeting__r),
            (SELECT Id FROM TeamsTargeted__r),
            (SELECT Id FROM line_items__r),
            (SELECT Id FROM AppliedLabel__r),
            (SELECT Id FROM Prodotti_Pacchetti_Combo__r),
            (SELECT Id FROM SectionsOasTargeted__r),
            (SELECT Id FROM CookieSearchTermsOASTargeted__r),
            (SELECT Id FROM Impressions_Stimate__r),
            (SELECT Id FROM Geography__r)
            FROM Product2
            WHERE Id IN :prods
        ];
            
        FrequencyCap__c[] fCaps = new FrequencyCap__c[]{};
        DayPartTargeting__c[] dayPart = new DayPartTargeting__c[]{};
        Inventory_Target__c[] inventory = new Inventory_Target__c[]{};
        TechnologyTargeting__c[] techno = new TechnologyTargeting__c[]{};
        CustomCriteriaSet__c[] criteriaSet = new CustomCriteriaSet__c[]{};
        Optional__c[] optionals = new Optional__c[]{};
        PlacementTargeting__c[] placements = new PlacementTargeting__c[]{};
        TeamTargeted__c[] teams = new TeamTargeted__c[]{};
        AppliedLabel__c[] als = new AppliedLabel__c[]{};
        CookieSearchOasTargeted__c[] csots = new CookieSearchOasTargeted__c[]{};
        SectionOasTargeted__c[] sots = new SectionOasTargeted__c[]{};
        Impressions_Stimate__c[] iss = new Impressions_Stimate__c[]{};
        Geography__c[] geos = new Geography__c[]{};
                                                            
        for(Product2 p : deletedProduct) {
            if(!p.line_items__r.isEmpty()){
                Trigger.oldMap.get(p.id).addError('Non si possono cancellare prodotti con line item associati.');
            }
            if(!p.Prodotti_Pacchetti_Combo__r.isEmpty()){
                Trigger.oldMap.get(p.id).addError('Non si possono cancellare prodotti associati ad un pacchetto.');
            }
            
            fCaps.addAll(p.Frequency_Caps__r);
            dayPart.addAll(p.Day_Part_Targeting__r);
            inventory.addAll(p.Inventory_Target__r);
            techno.addAll(p.Technology_Targeting__r);
            criteriaSet.addAll(p.Custom_Criteria_Set__r);
            optionals.addAll(p.Optionals__r);
            placements.addAll(p.PlacementTargeting__r);
            teams.addAll(p.TeamsTargeted__r);
            als.addAll(p.appliedLabel__r);
            csots.addAll(p.CookieSearchTermsOASTargeted__r);
            sots.addAll(p.SectionsOasTargeted__r);
            iss.addAll(p.Impressions_Stimate__r);
            geos.addAll(p.Geography__r);
        }
        
        delete fCaps;
        delete dayPart;
        delete inventory;
        delete techno;
        delete criteriaSet;
        delete optionals;
        delete placements;    
        delete teams;   
        delete als;
        delete csots;
        delete sots;
        delete iss;
    }
}