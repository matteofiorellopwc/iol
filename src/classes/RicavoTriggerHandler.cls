public with sharing class RicavoTriggerHandler {
    public static Boolean updateRicavoStorico = false; //aggiorna storico ricavi solo se opportunity è diventata chiusa vinta
    public static Boolean skipUpdateRicavi = false;

    /**
     *  Aggiorna i campi inerenti allo storico sulle revenue application in input
     *  
     */     
    public static void updateFieldsStorico(Ricavo__c[] ricavi) {
        Set<Id> liSet = new Set<Id>();
        for(Ricavo__c ricavo : ricavi) {
            liSet.add(ricavo.Line_Item__c);
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

        for(Ricavo__c ricavo : ricavi) {
            try{
                ricavo.LiStartDateStorico__c = lineItemMap.get(ricavo.Line_Item__c).Start_Date__c;
                ricavo.LiEndDate__c = lineItemMap.get(ricavo.Line_Item__c).End_Date__c;
                ricavo.LiSconto__c = lineItemMap.get(ricavo.Line_Item__c).sconto__c;
                ricavo.LiScontoTotale__c = lineItemMap.get(ricavo.Line_Item__c).Sconto_totale__c;
                ricavo.LiPrezzoNetNet__c = lineItemMap.get(ricavo.Line_Item__c).Prezzo_net_net__c;
                ricavo.LiTotale__c = lineItemMap.get(ricavo.Line_Item__c).Totale__c;
                ricavo.RiValore__c = ricavo.Valore__c;
                ricavo.RiPercentuale_applicata__c = ricavo.Percentuale_applicata__c;
                ricavo.RiAnno__c = ricavo.Anno__c;
                ricavo.RiMese__c = ricavo.Mese__c;
                ricavo.RiDataPrimoMeseStorico__c = ricavo.Data_primo_mese__c;
                ricavo.RiTipoAccountDirettaStorico__c = ricavo.Tipo_Account_Diretta__c;
                ricavo.RiCapoGruppoCentroMediaStorico__c = ricavo.Capo_Gruppo_Centro_Media__c;
                ricavo.OpVenditoreBrandPortafoglioStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.OwnerAccount__c;
                ricavo.LiSottoClasseStorico__c = lineItemMap.get(ricavo.Line_Item__c).Sotto_Classe__c;
                ricavo.OpCentroMediaStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.Centro_Media__r.Name;
                ricavo.OpVenditoreBrandStoricoStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.OwnerBrandHistory__r.Name;
                ricavo.OpVenditoreCMStoricoStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.OwnerCMHistory__r.Name;
                ricavo.OpAgenziaDiRiferimentoStoricoStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.AgenziaTerritorialeHistory__r.Name;
                ricavo.OpAgenziaRiferimentoPortafoglioStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.Agenzia_Brand__c;
                ricavo.LiQuantitStorico__c = lineItemMap.get(ricavo.Line_Item__c).Quantita__c;
                ricavo.LiClasseProdottoStorico__c = lineItemMap.get(ricavo.Line_Item__c).Classe_prodotto__c;
                ricavo.OpVenditoreCMPortafoglioStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.OwnerCentroMedia__c;
                ricavo.OpTipoOpportunityStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.Tipo_Opportunity__c;
                ricavo.OpCanaleDiVenditaStorico__c = lineItemMap.get(ricavo.Line_Item__c).Opportunity__r.Canale_di_vendita__c;
            }catch(Exception e){
                System.debug('Eccezione rilevata: '+e.getMessage());
            }
        }
    }
    
    public static void checkIfRicaviSuMesiAperti(Ricavo__c[] ricavi, Ricavo__c[] vecchiRicavi, Map<Id,Ricavo__c> vecchiRicaviMap, Boolean isInsertion, Boolean isUpdate, Boolean isDeletion){
        Date dataChiusuraRicavoLocal = RicavoTriggerHandler.getDataChiusuraRicavo(true);
        Date dataChiusuraRicavoNazionale = RicavoTriggerHandler.getDataChiusuraRicavo(false);
        if(!UtilSkipTrigger.skipCheckIfRicaviSuMesiAperti){
        	if(isInsertion || isUpdate){
	            for(Ricavo__c ricavo : ricavi){
	                Date dataChiusuraRicavo = ricavo.Local__c ? dataChiusuraRicavoLocal : dataChiusuraRicavoNazionale;
	                if(ricavo.Data_primo_mese__c <= dataChiusuraRicavo){
	                    if(isInsertion){
	                        ricavo.Valore__c.addError('Non si possono inserire ricavi di mesi chiusi');
	                    }else if(isUpdate && 
	                        (vecchiRicaviMap.get(ricavo.Id).Anno__c != ricavo.Anno__c ||
	                        vecchiRicaviMap.get(ricavo.Id).Mese__c != ricavo.Mese__c ||
	                        vecchiRicaviMap.get(ricavo.Id).Valore__c != ricavo.Valore__c
	                        )){
	                        ricavo.Valore__c.addError('Non si possono modificare ricavi di mesi chiusi');
	                    } 
	                }
	            }
	        }else if(isDeletion){
	            for(Ricavo__c ricavo : vecchiRicavi){
	                Date dataChiusuraRicavo = ricavo.Local__c ? dataChiusuraRicavoLocal : dataChiusuraRicavoNazionale;
	                if(ricavo.Data_primo_mese__c <= dataChiusuraRicavo){
	                    ricavo.Valore__c.addError('Non si possono eliminare ricavi di mesi chiusi');
	                }
	            }
	        }
        }
    }

    public static Date getDataChiusuraRicavo(Boolean isLocalUser){
        return DataChiusuraRicavo__c.getValues(isLocalUser ? 'local' : 'nazionale').data__c;
    }
}