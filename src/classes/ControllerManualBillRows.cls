/**
 *  Date:   2013/01/23
 *  Description:    Controller for manualRow Visualforce Page
 *  Author: Ivano Cortese
 */
public class ControllerManualBillRows {
    private Id tktID;
    private Opportunity opty;
    private Quote q;
    
    public Ticket_Fatturazione__c tkt {get;set;}
    public List<tableItem> table {get;set;}

    
    public ControllerManualBillRows(){
        tktID = ApexPages.currentPage().getParameters().get('Id');
        tkt = [SELECT Id, Opportunity__c, Ticket_manuale__c,Legal_Nazione__c,Anno_riferimento__c,Data_primo_mese__c
               FROM Ticket_Fatturazione__c WHERE Id = :tktID];
        if(tkt.Ticket_manuale__c){
            opty = [SELECT Id, SyncedQuoteId, Check_amministrativo__c, Escludi_da_fatt_auto__c,
                        (SELECT Descrizione_IVA__c,Codice_IVA__c
                        FROM Quotes)
                    FROM Opportunity
                    WHERE Id = :tkt.Opportunity__c];
                    
            if(opty.Quotes.size() == 1){
                q = opty.Quotes.get(0);
            }else if(opty.SyncedQuoteId != null){
                q = (new map<id,quote>(opty.quotes)).get(opty.SyncedQuoteId);
            }
            
            table = new List<tableItem>();
            //Set<Id> ProdPkgIDs = new Set<Id>();
            for(LineItem__c li :((List<LineItem__c>)[select Id, Opportunity__c, Start_Date__c, End_Date__c, Delivery_Model__c, Product__c, Prezzo_net_net__c, Quantita__c, Formato_formula__c, Pacchetto_Combo_Opportunity__c,
                                                        Pacchetto_Combo_Opportunity__r.Nome_pacchetto__c, Pacchetto_Combo_Opportunity__r.Data_inizio__c, Pacchetto_Combo_Opportunity__r.Data_fine__c, Conto_Ricavo__c, Conto_Risconto__c,
                                                        Product__r.Name, Product__r.Centro_di_costo__c, Product__r.Canale_Prodotto__c, Opportunity__r.Account.Canale_Cliente__c, Opportunity__r.Name, Opportunity__r.Identificativo_Campagna__c, Opportunity__r.Anagrafica_di_Fatturazione__r.Note_esenzione_IVA__c,
                                                        Opportunity__r.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c, Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Dimensione_Prodotto__c, Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Centro_di_costo__c, Pacchetto_Combo_Opportunity__r.PacchettoCombo__c,
                                                        Opportunity__r.Account.Name, Opportunity__r.Centro_Media__c, Opportunity__r.Agenzia_di_riferimento__c, Opportunity__r.Owner.Tipo__c, Opportunity__r.Owner.Area_BL__c,Product__r.Dimensione_Prodotto__c,
                                                        Name_Dfp__c,Pacchetto_Combo_Opportunity__r.Name,Opportunity__r.Account.Cliente_Gruppo__c,Local__c,DimensioneCanale__c,
                                                        (select valore__c from Revenue_applications__r where data_primo_mese__c =: tkt.data_primo_mese__c)
                                                        FROM LineItem__c
                                                        WHERE Opportunity__c = :tkt.Opportunity__c])){
                /* aggregazione per pacchetto
                if(!ProdPkgIDs.contains(li.Product__c) && !ProdPkgIDs.contains(li.Pacchetto_Combo_Opportunity__c)){
                    tableItem item = new tableItem();
                    item.li = li;
                    item.row = rowMapping(item.row, li,q);
                    item.row.Line_Item__c = li.id;
                    table.add(item);
                    if(li.Pacchetto_Combo_Opportunity__c != null){
                        ProdPkgIDs.add(li.Pacchetto_Combo_Opportunity__c);
                    }else{
                        ProdPkgIDs.add(li.Product__c);
                    }
                }
                */
                /* nessuna aggr*/
                tableItem item = new tableItem();
                item.li = li;
                item.row = rowMapping(item.row, li,q);

                table.add(item);
                /**/
            }
            //system.debug('@@Set: '+ProdPkgIDs);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Non è possibile creare nuove righe su ticket automatici.'));
        }
        
    }

    public AsyncApexJob  aaj {get;set;}

    public void runBatchableSplitRigheFatturazione(Riga_Fatturazione__c[] rows) {
        id sfdcJobID = Database.executeBatch(new BatchableSplitRigheFatturazione(rows),1);
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: sfdcJobID ];     
    }
    
    public void getJobStatus(){
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: aaj.id];
    }    
    
    private Riga_Fatturazione__c rowMapping(Riga_Fatturazione__c r, LineItem__c li,Quote q){
        r.Ticket_Fatturazione__c = tktID;
        
        //r.Stato__c = 'Draft';
        /* aggregazione per pacchetto
        system.debug('@@Pacchetto Opty: '+li.Pacchetto_Combo_Opportunity__c);
        if(li.Pacchetto_Combo_Opportunity__c != null){
            r.Descrizione__c = li.Pacchetto_Combo_Opportunity__r.Nome_pacchetto__c;
            //Ref #NMC 30: Centro di costo dismissed
            //r.Centro_di_costo__c = li.Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Centro_di_costo__c;
            r.Dimensione_Prodotto__c = li.Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Dimensione_Prodotto__c;
        }else{
            r.Descrizione__c = li.Opportunity__r.Name.replace(li.Opportunity__r.Identificativo_Campagna__c+' -','')+' '+li.Formato_formula__c+' '+(li.Delivery_model__c == 'CPD' ? '' :li.Quantita__c+'');
            //Ref #NMC 30: Centro di costo dismissed
            //r.Centro_di_costo__c = li.Product__r.Centro_di_costo__c;
            r.Dimensione_Prodotto__c = li.Product__r.Dimensione_Prodotto__c;
        }
        */
        /*nessuna aggregazione*/
        if(li.Pacchetto_Combo_Opportunity__c == null){
            r.Descrizione__c = li.Opportunity__r.Name.replace(li.Opportunity__r.Identificativo_Campagna__c+' -','')+' '+(String.isBlank(li.Formato_formula__c) ? '' : li.Formato_formula__c)+' '+(li.Delivery_model__c == 'CPD' ? '' :li.Quantita__c+'');                               
        }else{
            r.Descrizione__C = li.Pacchetto_Combo_Opportunity__r.Nome_pacchetto__c;
        }

        r.Line_Item__c = li.Id;
        r.PacchettoOpportunity__c = li.Pacchetto_Combo_Opportunity__c;

        //Ref #NMC 30: Centro di costo dismissed
        //r.Centro_di_costo__c = li.Product__r.Centro_di_costo__c;
        r.Dimensione_Prodotto__c = li.Product__r.id;
        /**/

		//CLAUDIO 05/07/2016 B
        //DEPRECATED! Raggruppamento is now used to aggregate ticket's rows (ExyensionRaggruppaRigheFatturazione.cls)
        //r.Raggruppamento__c = li.Opportunity__r.Identificativo_Campagna__c;
		r.Raggruppamento__c = '';
		//E

        //DEPRECATED! Note esenzione IVA not used any more.
        //r.Note_esenzione_IVA__c = li.Opportunity__r.Anagrafica_di_Fatturazione__r.Note_esenzione_IVA__c;
        //Changed! Descrizione Aliquota IVA will be moved on Note in fattura on Ticket di Fatturazione
        //r.DescrizioneAliquotaIVA__c = li.Opportunity__r.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c;
        
        /*
        **  Rif. Req PAG IVA 20
        */
        r.DescrizioneAliquotaIVA__c = q.Descrizione_IVA__c;
        r.Codice_IVA__c = q.Codice_IVA__c;
        r.Canale__c = UtilityTicketing.getCanale(li);

        /*
        **  Conto Ricavo e Conto Risconto
        */
        ////////String prodName
        r.Conto_ricavo__c = UtilityTicketing.getContoRicavo(li,tkt.Legal_Nazione__c,Decimal.valueOf(tkt.Anno_riferimento__c),li.Product__r.Name);
        r.Conto_risconto__c = li.Conto_risconto__c;

        r.Quantita__c = 1;

        if(li.revenue_applications__r.size() == 1){
            r.Prezzo_unitario__c = li.revenue_applications__r[0].valore__c;
        }
        
        Date firstDayOfMonth = tkt.Data_primo_mese__c;
        Date lastDayOfMonth = tkt.Data_primo_mese__c.addMonths(1).addDays(-1);

        if(li.Start_Date__c > firstDayOfMonth && li.Start_Date__c <= lastDayOfMonth ){
            r.Start_date__c = li.Start_date__c;
        }else{
            r.Start_date__c = firstDayOfMonth;
        }

        if(li.End_Date__c < lastDayOfMonth && li.End_date__c >= firstDayOfMonth){
            r.End_date__c = li.End_date__C;
        }else{
            r.End_date__c = lastDayOfMonth;
        }

        return r;
    }
    
    public void saveRows(){
        PageReference p = new PageReference('/'+tktID);
        p.setRedirect(true);
        List<Riga_Fatturazione__c> rowsToInsert = new List<Riga_Fatturazione__c>();
        System.debug('TABLE: '+table);
        for(tableItem i :table){
            if(i.sel){
                if(i.row.Start_date__c == null || i.row.End_date__c == null || i.row.Prezzo_unitario__c == null){
                    if(i.row.Start_date__c == null)
                        i.row.Start_date__c.addError('Inserire un valore');
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'È necessario inserire la start date di competenza.'));
                    if(i.row.End_date__c == null)
                        i.row.End_date__c.addError('Inserire un valore');
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'È necessario inserire la end date di competenza.'));
                    if(i.row.Prezzo_unitario__c == null)
                        i.row.Prezzo_unitario__c.addError('Inserire un valore');
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'È necessario inserire il prezzo di competenza.'));
                    return;
                }   
                //i.row.Numero_Riga__c = rowCounter++;
                rowsToInsert.add(i.row);
            }
        }
        if(!rowsToInsert.isEmpty()){
            AggregateResult maxCount = [SELECT max(Numero_Riga__c) maxCount FROM Riga_Fatturazione__c WHERE Ticket_Fatturazione__c = :tktID];
            Decimal rowCounter = (Decimal) maxCount.get('maxCount');
            rowCounter = rowCounter == null ? 1 : rowCounter+1;
            /*
                per i line item di un pacchetto devo mettere lo stesso numero riga
                e le stesse date (data di inizio = minore delle date di inizio,
                                  data di fine = minore delle date di fine
                                 )
            */
            UtilityTicketing.setNumeroRigaDateOnRigheFatturazione(rowsToInsert,rowCounter.intValue());
            insert rowsToInsert;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selezionare almeno una riga.'));
            return;
        }
        tkt.stato__c = 'In attesa di spaccato righe';
        update tkt;
        runBatchableSplitRigheFatturazione(rowsToInsert);
    }
    
    public PageReference back(){
        PageReference p = new PageReference('/'+tktID);
        p.setRedirect(true);
        return p;
    }
    
    public class tableItem{
        public Boolean sel {get;set;}
        public LineItem__c li {get;set;}
        public Riga_Fatturazione__c row {get;set;}
        
        public tableItem(){
            sel = false;
            li = new LineItem__c();
            row = new Riga_Fatturazione__c();
        }
    }

}