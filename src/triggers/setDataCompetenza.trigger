trigger setDataCompetenza on ImportoRigaSottoContratto__c (before insert, before update) {
    
    //Insieme di ID delle righe sotto contratto
    Set<Id> rscIds = new Set<Id>();
    for (ImportoRigaSottoContratto__c irsc: Trigger.new) {
        rscIds.add(irsc.RigaSottoContratto__c);
    }
    
    //Mappa delle righe sotto contratto
    Map<Id, RigaSottoContratto__c> rscM = new Map<Id, RigaSottoContratto__c>(
        [SELECT Data_prossimo_billing__c,
                Condizione_di_fatturazione__r.Tipo__c,
                Condizione_di_fatturazione__r.Unita_di_misura_periodo__c,
                Condizione_di_fatturazione__r.Numero_mesi__c
                FROM RigaSottoContratto__c WHERE Id IN :rscIds]
    );
    
    for (ImportoRigaSottoContratto__c irsc: Trigger.new) {
        
        if(Trigger.isInsert){            
            irsc.DataBilling__c = rscM.get(irsc.RigaSottoContratto__c).Data_prossimo_billing__c;    
        }
        
        if(! irsc.Data_competenza_manuale__c ){
 
            Date dataBilling = irsc.DataBilling__c;
            String tipo = rscM.get(irsc.RigaSottoContratto__c).Condizione_di_fatturazione__r.Tipo__c;
            String unitaDiMisura = rscM.get(irsc.RigaSottoContratto__c).Condizione_di_fatturazione__r.Unita_di_misura_periodo__c;
            Decimal numeroMesi = rscM.get(irsc.RigaSottoContratto__c).Condizione_di_fatturazione__r.Numero_mesi__c;
    
            if(unitaDiMisura == 'Una Tantum'){
                irsc.Start_date__c = dataBilling;
                irsc.End_date__c = dataBilling;
            }    
            else if(tipo == 'Anticipata'){         
                Date endDate = dataBilling.addMonths(Math.round(numeroMesi)).addDays(-1);
                irsc.Start_date__c = dataBilling;
                irsc.End_date__c = endDate;                                                             
            }       
            else if(tipo == 'Posticipata'){
                Date startDate = dataBilling.addMonths(Math.round(-numeroMesi)).addDays(1);
                irsc.Start_date__c = startDate;
                irsc.End_date__c = dataBilling;                                                                   
            } 
        }
    }
}