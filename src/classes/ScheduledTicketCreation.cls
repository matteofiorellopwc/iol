/**
 *  Date:   2012/11/22
 *  Description:    Scheduled class for Bill Tickets creation based on Revenue Application
 *  Author: Ivano Cortese
 */
global class ScheduledTicketCreation implements Schedulable{
    global void execute(SchedulableContext sc) {
        Savepoint sp = Database.setSavepoint();   
        try{
            createTickets(Date.today());
        }catch(exception e){
            Database.rollback(sp);
            UtilExceptionIntegration.sendEmailToCustomEmailLog('Errore nella creazione di ticket',e+'','IolLog');
        }
    }
    
    private Date d;
    private Map<Id, Map<Id, LineItem__c>> LineItemsPerOptyID;
    private List<Riga_Fatturazione__c> allRows = new List<Riga_Fatturazione__c>();
    
    public class TicketCreationException extends exception{}
    
    public void createTickets(Date dt){
        d = dt;
        LineItemsPerOptyID = new Map<Id, Map<Id, LineItem__c>>();
        allRows = new List<Riga_Fatturazione__c>();
        
        Map<Id, Map<Id, Revenue_application__c>> revAppsPerOptyID = new Map<Id, Map<Id, Revenue_application__c>>();
        Map<String, TicketClass> tktClassPerOptyID_Month = new Map<String, TicketClass>();
        //Query ALL Revenue Applications without a Ticket bill
        for(Revenue_application__c ra :((list<Revenue_application__c>)[select Id, Line_Item__c, Mese__c, Anno__c, Mese_numero__c, Anno_numero__c, Percentuale_applicata__c, Ticket_Fatturazione__c, Riga_Fatturazione__c, Valore__c,
                                                                        Line_Item__r.Opportunity__r.Id, Line_Item__r.Opportunity__r.Conto_ricavo__c, Line_Item__r.Opportunity__r.Conto_risconto__c,
                                                                        Line_Item__r.end_date__c, Line_Item__r.Product__c, Line_Item__r.Pacchetto_Combo_Opportunity__c, Numero_impression__c,
                                                                        Line_Item__r.Product__r.Family, Line_Item__r.Product__r.Categoria_libero__c, Line_Item__r.Product__r.Dimensione_Prodotto__c,
                                                                        Line_Item__r.Type_DFP__c,ADXPlacementUpdated__c,Line_Item__r.CPCQuantityAutomationUpdated__c,Line_Item__r.Delivery_Model__c,
                                                                        Line_Item__r.Product__r.Vetrina__c,Line_Item__r.Product__r.Local__c,Line_Item__r.Start_Date__c,Line_Item__r.Product__r.Name,Line_Item__r.Product__r.Id
                                                                        from Revenue_application__c
                                                                        where Ticket_Fatturazione__c = null
                                                                        AND Line_Item__r.Opportunity__r.StageName = 'Chiusa vinta'
                                                                        AND Line_Item__r.Opportunity__r.Check_amministrativo__c = true
                                                                        AND Line_Item__r.Opportunity__r.Escludi_da_fatt_auto__c = false
                                                                        AND ((Anno_numero__c = :d.year() AND Mese_numero__c <= :d.month()) OR Anno_numero__c < :d.year())
                                                                        AND Mese_numero__c > 0
                                                                        //AND Percentuale_applicata__c > 0
                                                                        //AND Valore__c > 0
                                                                        AND ( Valore__c > 0 OR Valore__c < 0 )
                                                                        AND Line_Item__r.Opportunity__r.Import_Ext_ID__c = null
                                                                        ])){
            List<Revenue_application__c> vRevApp;
            Map<Id, Revenue_application__c> revAppMap;
            if(!revAppsPerOptyID.containsKey(ra.Line_Item__r.Opportunity__r.Id)){
                revAppMap = new Map<Id, Revenue_application__c>();
            }
            else{
                revAppMap = revAppsPerOptyID.get(ra.Line_Item__r.Opportunity__r.Id);
            }
            revAppMap.put(ra.Id, ra);
            revAppsPerOptyID.put(ra.Line_Item__r.Opportunity__r.Id, revAppMap);
        }
        
        
        system.debug('@@revAppsPerOptyID: '+revAppsPerOptyID);
        

        //Query ALL Line Items from previous App Rev without a bill
        for(LineItem__c li :((list<LineItem__c>)[select Id, Opportunity__c, Start_Date__c, End_Date__c, Delivery_Model__c, Product__c, Prezzo_net_net__c, Quantita__c, Formato_formula__c, Pacchetto_Combo_Opportunity__c,
                                                Pacchetto_Combo_Opportunity__r.Nome_pacchetto__c, Pacchetto_Combo_Opportunity__r.Data_inizio__c, Pacchetto_Combo_Opportunity__r.Data_fine__c, Conto_Ricavo__c, Conto_Risconto__c,
                                                Product__r.Name, Product__r.Centro_di_costo__c, Product__r.Canale_Prodotto__c, Opportunity__r.Account.Canale_Cliente__c, Opportunity__r.Name, Opportunity__r.Identificativo_Campagna__c, Opportunity__r.Anagrafica_di_Fatturazione__r.Note_esenzione_IVA__c,
                                                Opportunity__r.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c, Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Dimensione_Prodotto__c, Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Centro_di_costo__c, Pacchetto_Combo_Opportunity__r.PacchettoCombo__c,
                                                Opportunity__r.Account.Name, Opportunity__r.Account.Cliente_Gruppo__c, Opportunity__r.Centro_Media__c, Opportunity__r.Agenzia_di_riferimento__c, Opportunity__r.Owner.Tipo__c, Opportunity__r.Owner.Area_BL__c,Local__c,
                                                Product__r.Vetrina__c,Product__r.Local__c,DimensioneCanale__c
                                                from LineItem__c
                                                //TODO where Id IN :revAppIDperLIID.keySet()
                                                where Opportunity__c IN :revAppsPerOptyID.keySet()
                                                ORDER BY End_Date__c ASC])){
                Map<Id, LineItem__c> liMap;
                if(!LineItemsPerOptyID.containsKey(li.Opportunity__c))
                    liMap = new Map<Id, LineItem__c>();
                else
                    liMap = LineItemsPerOptyID.get(li.Opportunity__c);
                liMap.put(li.Id, li);
                LineItemsPerOptyID.put(li.Opportunity__c, liMap);
        }
            
            
        //Final ticket and rows list to be inserted
        List<Ticket_Fatturazione__c> ticketToInsert = new List<Ticket_Fatturazione__c>();
        List<ticketClass> ticketClassToInsert = new List<ticketClass>();
        Quote q;
        
        map<Id,string> oppError = new map<Id,string>(); //opportunità con errore da notificare

        Map<Id, Opportunity> mapIdOty = new Map<Id, Opportunity>([SELECT Id,Name,SyncedQuoteId,Anagrafica_di_Fatturazione__r.Check_amministrativo__c,
                                                                        Anagrafica_di_Fatturazione__r.Owner.UserLocal__c,
                                                                        (SELECT Id, Metodo_di_pagamento__c, Termini_di_pagamento__c, Descrizione_Termini_Pagamento__c, Indirizzo_Spedizione_Alternativo__c, Modalita_di_spedizione__c, Codice_IVA__c, Lingua_template_fattura__c, Email_aggiuntive__c, Descrizione_IVA__c,Indirizzo_Spedizione_Alternativo__r.Ragione_sociale__c,
                                                                        Indirizzo_Spedizione_Alternativo__r.Via__c, Indirizzo_Spedizione_Alternativo__r.Citta__c, Indirizzo_Spedizione_Alternativo__r.Provincia__r.Sigla__c, Indirizzo_Spedizione_Alternativo__r.Cap__c, Indirizzo_Spedizione_Alternativo__r.Stato__c, Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c,
                                                                        Opportunity.Anagrafica_di_Fatturazione__r.BillingStreet, Opportunity.Anagrafica_di_Fatturazione__r.BillingPostalCode, Opportunity.Anagrafica_di_Fatturazione__r.BillingCity, Opportunity.Anagrafica_di_Fatturazione__r.BillingState, Opportunity.Anagrafica_di_Fatturazione__r.BillingCountry, Opportunity.Anagrafica_di_Fatturazione__r.RecordType.DeveloperName, /*Opportunity.Anagrafica_di_Fatturazione__r.Customer_Posting_Group__c,*/
                                                                        Opportunity.Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c, Opportunity.Anagrafica_di_Fatturazione__r.Partita_IVA__c, Opportunity.Anagrafica_di_Fatturazione__r.Codice_fiscale__c, Opportunity.Anagrafica_di_Fatturazione__r.Email_principale__c, Opportunity.Anagrafica_di_Fatturazione__r.Codice_fatturazione_completo__c, Opportunity.Note_fattura__c, Opportunity.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c,
                                                                        Opportunity.Owner.Area_BL__c,Opportunity.Name, Opportunity.Commissione_Agenzia__c,Opportunity.Anagrafica_di_Fatturazione__r.Pubblica_Amministrazione__c
                                                                        FROM Quotes)
                                                                    FROM Opportunity
                                                                    WHERE Id IN :revAppsPerOptyID.keySet()
                                                                    AND Anagrafica_di_Fatturazione__c <> null
                                                                    AND Import_Ext_ID__c = null]);

            for(Opportunity o : mapIdOty.values()) {
                system.debug('check opp '+o.id);      
                //if no quote jump to next opty
                if(o.Quotes.size() == 1){
                    system.debug('1 quote');
                    q = o.Quotes.get(0);
                }else if(o.SyncedQuoteId != null){
                    system.debug('synced quote');                
                    q = (new map<id,quote>(o.quotes)).get(o.SyncedQuoteId);
                }else{
                    system.debug('no quote');                
                    oppError.put(o.Id,'Quote assente o non sincronizzata');
                    continue;
                }
                    
                if(o.Anagrafica_di_Fatturazione__r.Check_amministrativo__c == false){
                    system.debug('no check admin'); 
                    oppError.put(o.Id,'Anagrafica di fatturazione senza check amministrativo');
                    continue;
                }
                
                system.debug('revAppsPerOptyID.get(q.OpportunityId).values() = '+revAppsPerOptyID.get(q.OpportunityId).values()); 
                
                //Create a new ticket for every month into the application revenue
                Map<String, Ticket_Fatturazione__c> ticketToInsertPerMonth = new Map<String, Ticket_Fatturazione__c>();
                List<Revenue_application__c> rApps = new List<Revenue_application__c>();
                for(Revenue_application__c ra :revAppsPerOptyID.get(q.OpportunityId).values()){
                    
                    if(!tktClassPerOptyID_Month.containsKey(q.OpportunityId+'_'+ra.Mese_Numero__c+'_'+ra.Anno__c)){
                        Ticket_Fatturazione__c tkt = createTicket(ra.Mese__c, ra.Anno__c, q);
                                                                   
                        ticketClass tktClass = new ticketClass(tkt, ra.Mese_numero__c.intValue(), d, q.Codice_IVA__c, q.Descrizione_IVA__c);
                        tktClassPerOptyID_Month.put(q.OpportunityId+'_'+ra.Mese_Numero__c+'_'+ra.Anno__c, tktClass);
                        
                        List<Revenue_application__c> raList = new List<Revenue_application__c>();
                        raList.add(ra);
                        
                        /* aggregione per pacchetto
                        system.debug('@@Id Pacchetto: '+ra.Line_Item__r.Pacchetto_Combo_Opportunity__c);
                        if(ra.Line_Item__r.Pacchetto_Combo_Opportunity__c != null)
                            tktClass.raListPerPacchettoID.put(ra.Line_Item__r.Pacchetto_Combo_Opportunity__c, raList);
                        else
                            tktClass.raListPerLIID.put(ra.Line_Item__c, raList);                        
                        */
                        /* nessuna aggregazione */
                        tktClass.raListPerLIID.put(ra.Line_Item__c, raList);                        
                        /**/
                    }
                    else{
                        ticketClass tktClass = tktClassPerOptyID_Month.get(q.OpportunityId+'_'+ra.Mese_Numero__c+'_'+ra.Anno__c);
                        List<Revenue_application__c> raList;
                        
                        /* aggregazione per pacchetto
                        if(ra.Line_Item__r.Pacchetto_Combo_Opportunity__c != null){
                            if(tktClass.raListPerPacchettoID.containsKey(ra.Line_Item__r.Pacchetto_Combo_Opportunity__c))
                                raList = tktClass.raListPerPacchettoID.get(ra.Line_Item__r.Pacchetto_Combo_Opportunity__c);
                            else
                                raList = new List<Revenue_application__c>();
                            raList.add(ra);
                            tktClass.raListPerPacchettoID.put(ra.Line_Item__r.Pacchetto_Combo_Opportunity__c, raList);
                        }
                        else{
                            if(tktClass.raListPerLIID.containsKey(ra.Line_Item__c))
                                raList = tktClass.raListPerLIID.get(ra.Line_Item__c);
                            else
                                raList = new List<Revenue_application__c>();
                            raList.add(ra);
                            tktClass.raListPerLIID.put(ra.Line_Item__c, raList);    
                        }
                        */
                        /* nessuna aggregazione */
                        if(tktClass.raListPerLIID.containsKey(ra.Line_Item__c)){
                            raList = tktClass.raListPerLIID.get(ra.Line_Item__c);
                        }else{
                            raList = new List<Revenue_application__c>();
                        }
                        raList.add(ra);
                        tktClass.raListPerLIID.put(ra.Line_Item__c, raList);                            
                        /**/
                    }
                    
                    ticketClass tktC = tktClassPerOptyID_Month.get(q.OpportunityId+'_'+ra.Mese_Numero__c+'_'+ra.Anno__c);

                    //non fatturo il line item non è ancora finito e la revenue è di un mese non ancora concluso
                    Boolean checkDate = (ra.Line_Item__r.end_date__c >= d && d <= lastDayOfMonth((integer)ra.anno_numero__c,(integer)ra.mese_numero__c));

                    //per i prodotti local vetrina posso fatturare appena è partito
                    if(ra.Line_Item__r.Product__r.Vetrina__c && ra.Line_Item__r.Product__r.Local__c){
                        checkDate = ra.Line_Item__r.Start_Date__c >= d;
                    }
                    System.debug('data non valida: '+checkDate);
                    //non fatturo se ho dei cpc senza il flag processato o se ho revenue di adx senza flag processato
                    Boolean checkAdxCpc = false;
                    if(!checkDate){
                        checkAdxCpc = !isRevenueADXCPCProcessed(ra);
                        if(checkAdxCpc){
                            oppError.put(o.Id,'CPC o ADX non processato');
                        }
                    }

                    if(checkDate || checkAdxCpc){
                        tktC.bill = false;
                    }
                }
            }
            //Before insert NEW Tickets, check on valore__c
            for(string key : tktClassPerOptyID_Month.keySet()){
                ticketClass tktClass = tktClassPerOptyID_Month.get(key);
                //AN - Check for negative Ticket
                if (tktClass.bill) {
                    Boolean includeTicket = true;
                    for(Id idLI : tktClass.raListPerLIID.keySet()){
                        Decimal currValue = 0;
                        includeTicket = true;
                        for (Revenue_application__c ra : tktClass.raListPerLIID.get(idLI)) {
                            currValue += ra.Valore__c;
                        }
          //CLAUDIO ARADO 11/01/2017 B 
          //            if (currValue <= 0) { 
          // E            
                        if (currValue < 0) {
                            includeTicket = false;
                            removeBillForNextMonths(key, tktClassPerOptyID_Month);
                            String[] keySplitted = key.split('_');
                            Id idOpty = (Id)keySplitted[0];
                            oppError.put(idOpty,'Line item con valori negativi');
                            continue;
                        }
                    }
                    tktClass.bill = includeTicket;
                }
             }

            //Insert NEW Tickets
            for(string key : tktClassPerOptyID_Month.keySet()){
                ticketClass tktClass = tktClassPerOptyID_Month.get(key);
                //system.debug('@@Ticket: opp '+ tktClass.tkt.Opportunity__c + ' mese '+tktClass.tkt.Mese_riferimento__c +' bill '+tktClass.billDate);
                //if(tktClass.billDate <= d){
                if(tktClass.bill){
                    ticketToInsert.add(tktClass.tkt);
                }else{
                    tktClassPerOptyID_Month.remove(key);
                }
            }

            insert ticketToInsert;
            
            List<Revenue_application__c> raToUpdate = new List<Revenue_application__c>();
            for(ticketClass tktClass : tktClassPerOptyID_Month.values()){
                //Integer rowCounter = 1;

                /* aggregazione per pacchetto
                //Create a new Riga Fatturazione for each Pacchetto
                system.debug('@@Rev Apps per Pacchetto: '+tktClass.raListPerPacchettoID);
                for(Id packId : tktClass.raListPerPacchettoID.keySet()){
                    Riga_Fatturazione__c row = new Riga_Fatturazione__c(
                    Ticket_Fatturazione__c = tktClass.tkt.Id,
                    Codice_IVA__c = tktClass.codiceIVA,
                    Quantita__c = 1,
                    Prezzo_unitario__c = 0,
                    Numero_Riga__c = rowCounter++
                    );
                    allRows.add(row);
                    raToUpdate.addAll(manageRows('Pacchetto', row, tktClass, tktClass.raListPerPacchettoID.get(packId)));
                }
                */
                
                //Create a new Riga Fatturazione for each Line Item
                //2013/12/06 Aggregation per Product removed!
                
                system.debug('@@Rev Apps per LI: '+tktClass.raListPerLIID);
                for(Id Id : tktClass.raListPerLIID.keySet()){
                	/*controllo che la riga abbia un valore e non sia a zero , nel caso , salto la riga
                	
                	*/
                	List<Revenue_application__c> revApps = tktClass.raListPerLIID.get(Id);
                	Boolean isRigaWithValue=false;
                	for(Revenue_application__c ra :revApps){
                		if (ra.Valore__c>0){
                			isRigaWithValue=true;
                		}
                	}
                	if(!isRigaWithValue){
                		continue;
                	}
                    Riga_Fatturazione__c row = new Riga_Fatturazione__c(
                    Ticket_Fatturazione__c = tktClass.tkt.Id,
                    Codice_IVA__c = tktClass.codiceIVA,
                    Quantita__c = 1,
                    Prezzo_unitario__c = 0
                    //Numero_Riga__c = rowCounter++
                    );
                    allRows.add(row);
                   //CLAUDIO 14/11/2016 B
                    row.Stato__c = 'Da inviare';
                    // E
                    
                    raToUpdate.addAll(manageRows(row, tktClass, tktClass.raListPerLIID.get(Id)));
                    system.debug('@@RA To update: '+raToUpdate);
                }
                
            }

            /*
                per i line item di un pacchetto devo mettere lo stesso numero riga 
                e le stesse date (data di inizio = minore delle date di inizio,
                                  data di fine = minore delle date di fine
                                 )
            */
            //CLAUDIO 22/11/2016 non più vero con SAP che -->modificata UtilityTicketing.setNumeroRigaDateOnRigheFatturazione
            UtilityTicketing.setNumeroRigaDateOnRigheFatturazione(allRows,1);
            
            //Insert NEW Rows
            insert allRows;
            system.debug('@@:ALL Rows: '+allRows);
            system.debug('@@:Data d: '+d);
            
            
            /*
                On Line Item trigger, there is a control that can not be 
                unbilled revenues dated earlier to revenues already billed.
                updating all the revenues together, may fail that control.
                //update raToUpdate;
            */
            map<decimal,revenue_application__c[]> revenueMap = new map<decimal,revenue_application__c[]>();
            for(revenue_application__c ra : raToUpdate){
                ra.Riga_Fatturazione__c = ra.Riga_Fatturazione__r.Id;
                system.debug('@@RFid: '+ ra.Riga_Fatturazione__r);
                decimal key = ra.anno_numero__c*100 + ra.mese_numero__c;
                if(revenueMap.get(key) == null){
                    revenueMap.put(key, new revenue_application__c[]{});
                }
                revenueMap.get(key).add(ra);
            }
            list<decimal> orderedKey = new list<decimal>();
            orderedKey.addAll(revenueMap.keySet());
            orderedKey.sort();
            system.debug('orderedKey = '+orderedKey);
            for(decimal k : orderedKey){
                update revenueMap.get(k);
            }

           
        /*
            Notify administration if tickets generation fails
        */
        if(oppError.keySet().size() > 0){

            String body = 'Non è stato possibile generare dei ticket di fatturazione per le seguenti opportunità<br/><br/>';
            body += '<table>';

            String bodyNazionale = '';
            String bodyLocal = '';

            for(Id oppId : oppError.keySet()){
                if(mapIdOty.get(oppId).Anagrafica_di_Fatturazione__r.Owner.UserLocal__c){
                    bodyLocal += '<tr><td style="font-weight:bold;">'+mapIdOty.get(oppId).Name+'</td>'+'<td style="padding-left:5px;">'+oppError.get(oppId)+'</td>';                    
                }else{
                    bodyNazionale += '<tr><td style="font-weight:bold;">'+mapIdOty.get(oppId).Name+'</td>'+'<td style="padding-left:5px">'+oppError.get(oppId)+'</td>';                    
                }
            }


            if(bodyNazionale != ''){
                UtilExceptionIntegration.sendHtmlEmailToCustomEmailLog('Errori nella generazione dei ticket',body+bodyNazionale+'</table>','Amministrazione');                
            }
            if(bodyLocal != ''){
                UtilExceptionIntegration.sendHtmlEmailToCustomEmailLog('Errori nella generazione dei ticket',body+bodyLocal+'</table>','Amministrazione Local');                
            }

        }
        

        //Create Spaccato righe
        //CLAUDIO 14/11/2016 commentata
        //if(!Test.IsRunningTest())
          //  Database.executeBatch(new BatchableSplitRigheFatturazione(allRows),1);
    
    }
        
    /*
    * This function set the bill=false for Opportunity billed after the month and year passed
    * It pooulate also oppWithNegativeRows
    */
    public void removeBillForNextMonths(String inKey, Map<String, TicketClass> tktClassPerOptyID_Month) {
        //Parsing the input key
        String[] inKeySplitted = inKey.split('_');
        Id inIdOpty = (Id)inKeySplitted[0];
        Integer inMonth = Integer.valueOf(inKeySplitted[1]);
        Integer inYear = Integer.valueOf(inKeySplitted[2]);

        for(String key : tktClassPerOptyID_Month.keySet()){
            String[] currKeySplitted = key.split('_');
            Id currIdOpty = (Id)currKeySplitted[0];
            if (currIdOpty == inIdOpty) {
                Integer currMonth = Integer.valueOf(currKeySplitted[1]);
                Integer currYear = Integer.valueOf(currKeySplitted[2]);
                if (currYear > inYear || (currYear == inYear && currMonth > inMonth)) {
                    tktClassPerOptyID_Month.get(key).bill = false;
                }
            }
        }
    }

    public static Date lastDayOfMonth(Integer year, Integer month){
        if(month == 12){
            month = 1;
            year = year +1;
        }
        else
         ++month;
        Date d = date.newInstance(year, month, 1);
        return d.addDays(-1);
    }
    
    
    public List<Revenue_application__c> manageRows(Riga_Fatturazione__c row, ticketClass tktClass, List<Revenue_application__c> revApps){
            List<Revenue_application__c> raToUpdate = new List<Revenue_application__c>();
            
            Set<Id> pacchettiSet = new Set<Id>();
            Integer mese = d.month();
            Integer anno = d.year();
            Integer quantity = 0;
            for(Revenue_application__c ra :revApps){
                //row.Conto_ricavo__c = ra.Line_Item__r.Opportunity__r.Conto_ricavo__c;
                //row.Conto_risconto__c = ra.Line_Item__r.Opportunity__r.Conto_risconto__c;
                row.Prezzo_unitario__c = row.Prezzo_unitario__c + ra.Valore__c;
                system.debug('@@Quantity: '+quantity);
                system.debug('@@#Impression: '+ra.Numero_impression__c);
                system.debug('@@Quantity: '+quantity);
                String prodName=ra.Line_Item__r.Product__r.Name;
                system.debug('@@prod: '+prodName);
                
                    //Temporary line item
                    LineItem__c tmp = LineItemsPerOptyID.get(ra.Line_Item__r.Opportunity__r.Id).get(ra.Line_Item__c);
                    Decimal percApplyed =  (ra.Percentuale_applicata__c == null) ? 0 : ra.Percentuale_applicata__c;
                    quantity = quantity + (percApplyed * tmp.Quantita__c /100).intValue();
                    
                    /*
                    if(s == 'Pacchetto'){
                        if(tmp.Pacchetto_Combo_Opportunity__c != null && !pacchettiSet.contains(tmp.Pacchetto_Combo_Opportunity__c)){
                            row.Descrizione__c = tmp.Pacchetto_Combo_Opportunity__r.Nome_pacchetto__c;
                            pacchettiSet.add(tmp.Pacchetto_Combo_Opportunity__c);
                            //Ref #NMC 30: Centro di costo dismissed
                            //row.Centro_di_costo__c = tmp.Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Centro_di_costo__c;
                            //Ref #NMC 50
                            row.Dimensione_Prodotto__c = tmp.Pacchetto_Combo_Opportunity__r.PacchettoCombo__r.Dimensione_Prodotto__c;
                            row.Pacchetto__c = tmp.Pacchetto_Combo_Opportunity__r.PacchettoCombo__c;
                        }
                    }// else Prodotto
                    else{
                        row.Descrizione__c = tmp.Opportunity__r.Name.replace(tmp.Opportunity__r.Identificativo_Campagna__c+' -','')+' '+tmp.Formato_formula__c+' '+(tmp.Delivery_model__c == 'CPD' ? '' :quantity+'');//tmp.Quantita__c;
                        //Ref #NMC 30: Centro di costo dismissed
                        //row.Centro_di_costo__c = tmp.Product__r.Centro_di_costo__c;
                        //Ref #NMC 50
                        row.Dimensione_Prodotto__c = ra.Line_Item__r.Product__r.Dimensione_Prodotto__c;
                        row.Line_Item__c = tmp.Id;
                    }
                    */



                    /**/
                    if(tmp.Pacchetto_Combo_Opportunity__c == null){
                        row.Descrizione__c = tmp.Opportunity__r.Name.replace(tmp.Opportunity__r.Identificativo_Campagna__c+' -','')+' '+(String.isBlank(tmp.Formato_formula__c) ? '' : tmp.Formato_formula__c)+' '+(tmp.Delivery_model__c == 'CPD' ? '' :quantity+'');//tmp.Quantita__c;                        
                    }else{
                        row.Descrizione__C = tmp.Pacchetto_Combo_Opportunity__r.Nome_pacchetto__c;
                    }

                    //Ref #NMC 30: Centro di costo dismissed
                    //row.Centro_di_costo__c = tmp.Product__r.Centro_di_costo__c;
                    //Ref #NMC 50
                    ////// aggiungere il nuovo campo sap
                    row.Dimensione_Prodotto__c = ra.Line_Item__r.Product__r.Id;
                    row.Line_Item__c = tmp.Id;
                    row.PacchettoOpportunity__c = tmp.Pacchetto_Combo_Opportunity__c;
                    /**/

                    //Gestione date
                    if(tmp.Start_Date__c.month() == ra.Mese_numero__c && tmp.Start_Date__c.year() == ra.Anno_numero__c && (row.Start_date__c == null || row.Start_date__c > tmp.Start_Date__c)){
                        row.Start_date__c = tmp.Start_Date__c;
                    }else{
                        if(tmp.Start_Date__c < date.newInstance(ra.Anno_numero__c.intValue(), ra.Mese_numero__c.intValue(), 1)){
                            row.Start_date__c = date.newInstance(ra.Anno_numero__c.intValue(), ra.Mese_numero__c.intValue(), 1);
                        }
                    }
            
                    if(tmp.End_Date__c.month() == ra.Mese_numero__c && tmp.End_Date__c.year() == ra.Anno_numero__c && tmp.End_Date__c <= d && (row.End_date__c == null || row.End_date__c < tmp.End_Date__c)){
                        row.End_date__c = tmp.End_Date__c;
                    }else{
                        if((tmp.End_Date__c.month() > ra.Mese_numero__c && tmp.End_Date__c.year() == ra.Anno_numero__c) || (tmp.End_Date__c.year() > ra.Anno_numero__c)){
                            row.End_date__c = lastDayOfMonth(ra.Anno_numero__c.intValue(), ra.Mese_numero__c.intValue());
                        }
                    }

                    //per i prodotti vetrina local, la fatturazione è tutta sul primo mese e le date di competenza sono quelle di inizio e di fine
                    if(tmp.Product__r.Vetrina__c && tmp.Product__r.Local__c){
                        row.Start_date__c = tmp.Start_Date__c;
                        row.End_date__c = tmp.End_Date__c;
                    }
                    
					//CLAUDIO 05/07/2016 B
        			//DEPRECATED! Raggruppamento is now used to aggregate ticket's rows (ExyensionRaggruppaRigheFatturazione.cls)
                    //row.Raggruppamento__c = tmp.Opportunity__r.Identificativo_Campagna__c;
                    row.Raggruppamento__c = '';
                    //E
                    
                    //DEPRECATED! Note esenzione IVA not used any more.
                    //row.Note_esenzione_IVA__c = tmp.Opportunity__r.Anagrafica_di_Fatturazione__r.Note_esenzione_IVA__c;
                    //Changed! Descrizione Aliquota IVA will be moved on Note in fattura on Ticket di Fatturazione
                    //row.DescrizioneAliquotaIVA__c = tmp.Opportunity__r.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c;
                    
                    /*
                    **  Rif. Req PAG IVA 20
                    */
                    row.DescrizioneAliquotaIVA__c = tktClass.descAliquotaIVA;
                    row.Canale__c = UtilityTicketing.getCanale(tmp);
                    
                    mese = ra.Mese_numero__c.intValue();
                    anno = ra.Anno_numero__c.intValue();
                    
                    /*
                    **  Conto Ricavo e Conto Risconto
                    */
                    row.Conto_ricavo__c = UtilityTicketing.getContoRicavo(tmp,tktClass.tkt.Legal_Nazione__c,Decimal.valueOf(tktClass.tkt.Anno_riferimento__c),prodName);
                    row.Conto_risconto__c = tmp.Conto_risconto__c;
                    
                //Associate each Revenue Application with its ticket and row
                ra.Ticket_Fatturazione__c = tktClass.tkt.Id;
                ra.Riga_Fatturazione__r = row;
                raToUpdate.add(ra);
            }
            if(row.Start_date__c == null){
                row.Start_date__c = date.newInstance(anno, mese, 1);
            }
            if(row.End_date__c == null){
                row.End_date__c = lastDayOfMonth(anno, mese);
            }
            return raToUpdate;
        }
    
    
    public class ticketClass{
        public Ticket_Fatturazione__c tkt;
        public Map<Id, List<Revenue_application__c>> raListPerLIID = new Map<Id, List<Revenue_application__c>>();
        //public Map<Id, List<Revenue_application__c>> raListPerPacchettoID = new Map<Id, List<Revenue_application__c>>();
        public date billDate;
        public boolean bill;
        public String codiceIVA;
        public String descAliquotaIVA;
        
        public ticketClass(Ticket_Fatturazione__c tkt, Integer month, Date d, String codIva, String descIVA){
            bill = true;
            this.tkt = tkt;
            if(month < d.month() || d.isSameDay(lastDayOfMonth(d.year(), month)))
                billDate = d;
            else
                billDate = d.addDays(1);
            codiceIVA = codIVA;
            descAliquotaIVA = descIVA;
        }
    }
    
    public static Ticket_Fatturazione__c createTicket(String mese, String anno, Quote q){
        Ticket_Fatturazione__c tkt = new Ticket_Fatturazione__c(
            Tipologia_ticket__c = 'Fattura',
            Mese_riferimento__c = mese,
            Anno_riferimento__c = anno,
            Flusso_provenienza__c = 'SFADV',
            Account__c = q.Opportunity.Anagrafica_di_Fatturazione__c,
            Opportunity__c = q.OpportunityId,
            Quote__c = q.Id,
            Codice_fatturazione__c = q.Opportunity.Anagrafica_di_Fatturazione__r.Codice_fatturazione_completo__c,
            Metodo_di_pagamento__c = q.Metodo_di_pagamento__c,
            Termini_di_pagamento__c = q.Termini_di_pagamento__c,
            /*
            **  Rif. Req PAG IVA 10
            **  New field Descrizione Termini di pagamento
            */
            Descrizione_Termini_Pagamento__c = q.Descrizione_Termini_Pagamento__c,
            Legal_Indirizzo__c = q.Opportunity.Anagrafica_di_Fatturazione__r.BillingStreet,
            Legal_Citta__c = q.Opportunity.Anagrafica_di_Fatturazione__r.BillingCity,
            Legal_Provincia__c = q.Opportunity.Anagrafica_di_Fatturazione__r.BillingState,
            Legal_CAP__c = q.Opportunity.Anagrafica_di_Fatturazione__r.BillingPostalCode,
            Legal_Nazione__c = q.Opportunity.Anagrafica_di_Fatturazione__r.BillingCountry,
            Codice_fiscale__c = q.Opportunity.Anagrafica_di_Fatturazione__r.Codice_fiscale__c,
            Ragione_sociale__c = q.Opportunity.Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c,
            Partita_IVA__c = q.Opportunity.Anagrafica_di_Fatturazione__r.Partita_IVA__c,
            //Customer_Posting_Group__c = q.Opportunity.Anagrafica_di_Fatturazione__r.Customer_Posting_Group__c,
            Modalita_di_spedizione__c = q.Modalita_di_spedizione__c,
            Lingua_template_fattura__c = q.Lingua_template_fattura__c,
            // CLAUDIO 14/11/2016 B
            //Stato__c = 'In attesa di spaccato righe',
            Stato__c = 'Draft',
            // CLAUDIO 14/11/2016 E
            //Note in fattura NEW VERSION
            Note_fattura_1__c = q.Opportunity.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c,
            Note_fattura_2__c = q.Opportunity.Note_fattura__c,
            Business_Line__c = UtilityTicketing.getBusinessLine(q),

            Percentuale_ristorno_agenzia__c = q.Opportunity.Commissione_Agenzia__c,
            Nome_Opportunit__c = q.Opportunity.Name
        );
        /* pubblica amministrazione
        if(q.Opportunity.Anagrafica_di_Fatturazione__r.Pubblica_Amministrazione__c){
            tkt.Flusso_provenienza__c = 'SFADVPA';
        }
        */
        /*
        Note in fattura
        if(q.Opportunity.Note_fattura__c != null){ 
            if(q.Opportunity.Note_fattura__c != null && q.Opportunity.Note_fattura__c.length() > 250){
                tkt.Note_fattura_1__c = q.Opportunity.Note_fattura__c.substring(0,250);
                tkt.Note_fattura_2__c = q.Opportunity.Note_fattura__c.substring(250);
            }else{
                tkt.Note_fattura_1__c = q.Opportunity.Note_fattura__c;
                tkt.Note_fattura_2__c = '';
            }
        }*/
        //Indirizzo di spedizione
        if(q.Indirizzo_Spedizione_Alternativo__c != null){
            tkt.Ragione_sociale_indirizzo_di_spedizione__c = q.Indirizzo_Spedizione_Alternativo__r.Ragione_sociale__c;
            tkt.Billing_Indirizzo__c = q.Indirizzo_Spedizione_Alternativo__r.Via__c;
            tkt.Billing_Citta__c = q.Indirizzo_Spedizione_Alternativo__r.Citta__c;
            tkt.Billing_Provincia__c = q.Indirizzo_Spedizione_Alternativo__r.Provincia__r.Sigla__c;
            tkt.Billing_CAP__c = q.Indirizzo_Spedizione_Alternativo__r.Cap__c;
            tkt.Billing_Nazione__c = q.Indirizzo_Spedizione_Alternativo__r.Stato__c;
            tkt.Email_spedizione__c = q.Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c;
        }
        else{
            tkt.Ragione_sociale_indirizzo_di_spedizione__c = tkt.Ragione_sociale__c;
            tkt.Billing_Indirizzo__c = tkt.Legal_Indirizzo__c;
            tkt.Billing_Citta__c = tkt.Legal_Citta__c;
            tkt.Billing_Provincia__c = tkt.Legal_Provincia__c;
            tkt.Billing_CAP__c = tkt.Legal_CAP__c;
            tkt.Billing_Nazione__c = tkt.Legal_Nazione__c;
            tkt.Email_spedizione__c = q.Opportunity.Anagrafica_di_Fatturazione__r.Email_principale__c;
        }
        if(q.Email_aggiuntive__c != null && tkt.Email_spedizione__c != null)
            tkt.Email_spedizione__c = tkt.Email_spedizione__c + ';' + q.Email_aggiuntive__c;
        return tkt;
    }

        /*
    * For evey RA, it checks if the flag ADXPlacementUpdated__c is setted to true
    */
    public static Boolean isRevenueADXCPCProcessed(Revenue_application__c ra) {
        Boolean areProcessed = true;
        if ((!ra.ADXPlacementUpdated__c && ra.Line_Item__r.Type_DFP__c == 'AD_EXCHANGE') || (ra.Line_Item__r.Type_DFP__c == 'PRICE_PRIORITY' && !ra.Line_Item__r.CPCQuantityAutomationUpdated__c && ra.Line_Item__r.Delivery_model__c == 'CPC')  ) {
            areProcessed = false;
        }
        return areProcessed;
    }
}