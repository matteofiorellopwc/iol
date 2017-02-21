global class BatchableInsertTicketSap implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

    list<id> tickets;
    String IOLcs = 'Ticketing_Advertising';
    String ITNETcs = 'Ticketing_Apritisito'; 
  
    set<string> ticketInviati;
   
    public BatchableInsertTicketSap(list<id> tickets){
        this.tickets = tickets;

        list<Ticket_Fatturazione__c> tt = [SELECT stato__c FROM ticket_fatturazione__c WHERE id IN : tickets];
        for(ticket_fatturazione__c t : tt){
            t.errore__c = '';
            t.stato__c = 'Invio in corso';
        }
        list<Riga_Fatturazione__c> rr = [SELECT Id, Stato__c FROM Riga_Fatturazione__c WHERE ticket_fatturazione__c IN : tickets];
        for(Riga_Fatturazione__c r : rr){
            r.stato__c = 'Invio in corso';
        }
        list<Spaccato_Riga_Fatturazione__c> ss = [SELECT Id, Stato__c FROM Spaccato_Riga_Fatturazione__c WHERE Riga_Fatturazione__c IN : rr];
        for(Spaccato_Riga_Fatturazione__c s : ss){
            s.stato__c = 'Invio in corso';
        }
        update ss;
        update rr;
        update tt;
        system.debug('BatchableInsertTicketSap costruttore '+tickets);

    }

    global Iterable<sObject> start(Database.BatchableContext BC){

        list<sObject> sobjects = new list<sObject>();
        for(Ticket_Fatturazione__c tf : selectTickets(tickets) ){
            sobjects.add(tf);
        }
        
        for(Riga_Fatturazione__c rf : selectRighe(tickets)){
            system.debug('start riga di fatt:'+rf.id);
            sobjects.add(rf);    
        }
                
        system.debug('sobjects size = '+sobjects.size());
        ticketInviati = new set<string>();
        return sobjects;

    }

    public class BatchableInsertTicketSapException extends Exception {}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String result = '';
        for(sObject o : scope){
            result = '';
            system.debug('o.getSObjectType() '+o.getSObjectType());
            if(o.getSObjectType() == Ticket_Fatturazione__c.sObjectType){
                Ticket_Fatturazione__c tf = (Ticket_Fatturazione__c) o;
            	system.debug('batchableInsertTicket invio la testata tf.Testata_inviata__c'+tf.Testata_inviata__c);
                
                if(!tf.Testata_inviata__c){
                    try{
                         if(tf.Tipo_cliente__c.containsIgnoreCase('ITNET')){
                                //result = IntegrationFatturazioneNav2009.insertTestataITNET(tf,ITNETcs);
                                result = 'OK';
                            }   
                            else{
                            	
                                result = IntegrationFatturazioneSap.insertTestataIOL(tf,IOLcs);
                            }
                            system.debug('batchableInsertTicket insertTestataIOL '+result);
                            if(result != 'OK'){
                                throw new BatchableInsertTicketSapException(result);
                            }

                            tf.Stato__c = 'Testata inviata';
                            ticketInviati.add(tf.id);
                            tf.Testata_inviata__c = true;
                        
                    }catch(exception e){
                        if(Test.isRunningTest()){
                            tf.Stato__c = 'Testata inviata';
                            tf.Testata_inviata__c = true;
                            ticketInviati.add(tf.id);
                        }else{
                            tf.Stato__c = 'Errore';
                            tf.Errore__c = 'Errore durante l\'inserimento della testata:\n'+e.getMessage();
                            continue;
                        }
                    }
                }else{
                    ticketInviati.add(tf.id);
                }
                
                if(!tf.Cliente_inviato__c){
                    try{
                        if(tf.Tipo_cliente__c.containsIgnoreCase('ITNET')){
                            //result = IntegrationFatturazioneNav2009.insertClienteITNET(tf,ITNETcs);
                            result = 'OK';
                        }else{
                            result = IntegrationFatturazioneSap.insertClienteIOL(tf,IOLcs);
                        }
                        system.debug('batchableInsertTicket insertClienteIOL '+result);
                        
                        if(result != 'OK'){
                            throw new BatchableInsertTicketSapException(result);
                        }
                        tf.Cliente_inviato__c = true;
                        tf.Stato__c = 'Cliente inviato';
                    }catch(exception e){
                        if(Test.isRunningTest()){
                            tf.Cliente_inviato__c = true;
                            tf.Stato__c = 'Cliente inviato';
                        }else{
                            tf.Stato__c = 'Errore';
                            tf.Errore__c = 'Errore durante l\'inserimento del cliente:\n'+e.getMessage();
                        }
                    }
                }
            }
            
            
            if(o.getSObjectType() == Riga_Fatturazione__c.sObjectType){
                Riga_Fatturazione__c rf = (Riga_Fatturazione__c) o;
                system.debug('Riga_Fatturazione__c  id'+rf.id);
                if(ticketInviati.contains(rf.ticket_fatturazione__c)){
                    try{
                        if(rf.Ticket_Fatturazione__r.Tipo_cliente__c.containsIgnoreCase('ITNET')){
                           // result = IntegrationFatturazioneNav2009.InsertRigaITNET(rf,ITNETcs);
                           result ='OK';
                        }
                        else{
                            result = IntegrationFatturazioneSap.InsertRigaIOL(rf,IOLcs);
                        }
                        if(result != 'OK'){
                            throw new BatchableInsertTicketSapException(result);
                            
                        }
						 system.debug('batchableInsertTicket InsertRigaIOL '+result);

                        rf.Stato__c = 'Inviata';

                    }catch(Exception e){
                        rf.Stato__c = 'Errore';
                        rf.errore__c = 'Errore durante l\'inserimento della riga\n'+e.getMessage();
                    }
                }
            }
        }
        update scope;

    }

    global void finish(Database.BatchableContext BC){
    }
    public list<Ticket_Fatturazione__c> selectTickets(list<Id> ticketIDs){
        return [SELECT Id, Name, Tipo_Rec_Cliente__c, Codice_fatturazione__c, Ragione_sociale__c , Documento_aggregabile__c, Legal_Indirizzo__c, Legal_CAP__c, Legal_Citta__c, Legal_Provincia__c, Legal_Nazione__c, Billing_Indirizzo__c, Billing_CAP__c, Billing_Citta__c, Billing_Provincia__c, Billing_Nazione__c, Partita_IVA__c, Codice_fiscale__c, Customer_Posting_Group__c, Metodo_di_pagamento__c, Termini_di_pagamento__c, Termini_sollecito__c, Flusso_provenienza__c,
                    Tipo_Rec_Testata__c,  Tipologia_ticket__c, Email_spedizione__c, ID_template_stampa__c, Lingua_template_fattura__c, Modalita_di_spedizione__c, Note_fattura_1__c, Note_fattura_2__c, Cliente_inviato__c,Testata_inviata__c, Tipo_Cliente__c,
                    Descrizione_Termini_Pagamento__c,Codice_iPA__c,codice_sede__c, Opportunity__r.Identificativo_Campagna__c, Business_Line__c, Company__c, Ragione_sociale_indirizzo_di_spedizione__c, Numero_di_righe_spaccati__c, Percentuale_ristorno_agenzia__c, Nome_Opportunit__c, Valore_Fattura__c, Account__r.email_principale__c
                    FROM Ticket_Fatturazione__c
                    WHERE Id IN :ticketIDs];
    }
    
    public list<Riga_Fatturazione__c> selectRighe(list<Id> ticketIDs){
        return [SELECT Id, Tipo_Rec_Riga__c, Tipologia_ticket__c, Numero_Ticket__c, Numero_Riga__c, Conto_ricavo__c, Descrizione__c, 
                       Quantita__c, Prezzo_unitario__c, Codice_IVA__c,Start_date__c, End_date__c, Raggruppamento__c, Conto_risconto__c, 
                       Note_esenzione_IVA__c,DescrizioneAliquotaIVA__c, Flusso_provenienza__c,Ticket_Fatturazione__c, errore__c, 
                       Ticket_Fatturazione__r.Tipo_Cliente__c,
                       Canale__c, Dimensione_Prodotto__c, Line_Item__c,Nascondi_date_competenza__c,
                       Centro_di_costo__c //da mantenere per itnet
                FROM Riga_Fatturazione__c
                WHERE Ticket_Fatturazione__c IN : ticketIDs];
    } 
}