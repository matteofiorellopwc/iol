/**
 *  Date:   2016/04/26
 *  Description:    
 *  Author: Luca Mancuso
 */
global class ScheduledUpdateTicketFromSap implements Schedulable{
                
    global void execute(SchedulableContext sc) {
        executeAsync();
    }
    
    @future(callout=true)
    public static void executeAsync(){
        //Savepoint sp = Database.setSavepoint();   //You have uncommitted work pending, per ora c'è solo un update quindi si può togliere
        try{
            updateInfoNav(null);
        }catch(exception e){
            //Database.rollback(sp);
            UtilExceptionIntegration.sendEmailToCustomEmailLog('Errore durante l\'aggiornamento dei dati di ritorno da Navision',e+'','TelnextLog');
        }
    }
    
    public static void updateInfoNav(list<Id> tktIDs){
        map<String, Ticket_Fatturazione__c> iolTktMap = new map<String, Ticket_Fatturazione__c>();
        //map<String, Ticket_Fatturazione__c> itnetTktMap = new map<String, Ticket_Fatturazione__c>();
        
        Ticket_Fatturazione__c[] tktToUpdate = new Ticket_Fatturazione__c[]{};
        
        list<Ticket_Fatturazione__c> iolTickets = new list<Ticket_Fatturazione__c>();
        //list<Ticket_Fatturazione__c> itnetTickets = new list<Ticket_Fatturazione__c>();
        
        if(tktIDs == null){
            iolTickets = [SELECT Id, Name,  Ragione_sociale__c ,Tipo_Rec_Testata__c,  Tipologia_ticket__c, Email_spedizione__c, Lingua_template_fattura__c, Modalita_di_spedizione__c, Tipo_Cliente__c,
                            Descrizione_Termini_Pagamento__c, Opportunity__r.Identificativo_Campagna__c, Stato__c,
                            Numero_Fattura__c,Data_emissione_fattura__c,Importo_Totale__c,Link_Documento__c,Pagata__c
                            FROM Ticket_Fatturazione__c
                            WHERE (Stato__c = 'Inviato' OR Stato__c = 'Fatturato')
                            AND Tipo_cliente__c = 'Anagrafica di Fatturazione'
                            AND (Numero_Fattura__c = null OR Numero_Fattura__c = '')
                            ];

        }   
        else{
            iolTickets = [SELECT Id, Name,  Ragione_sociale__c ,Tipo_Rec_Testata__c,  Tipologia_ticket__c, Email_spedizione__c, Lingua_template_fattura__c, Modalita_di_spedizione__c, Tipo_Cliente__c,
                            Descrizione_Termini_Pagamento__c, Opportunity__r.Identificativo_Campagna__c, Stato__c,
                            Numero_Fattura__c,Data_emissione_fattura__c,Importo_Totale__c,Link_Documento__c,Pagata__c
                            FROM Ticket_Fatturazione__c
                            WHERE Id IN : tktIDs
                            AND Tipo_cliente__c = 'Anagrafica di Fatturazione'];
        }
            system.debug('ScheduledUpdateTicketFromSap richiedo ticket nr'+iolTickets.size());
        if(!iolTickets.IsEmpty()){
            BasicAuthApplication__c cs = BasicAuthApplication__c.getInstance('Ticketing_Advertising');
            Blob headerValue = Blob.valueOf(cs.username__c + ':' + cs.password__c);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            SapWSNew.SALESFORCE sap=new SapWSNew.SALESFORCE();
     		sap.inputHttpHeaders_x = new Map<String,String>();
        	sap.endpoint_x = cs.endpoint__c;
       		sap.inputHttpHeaders_x.put('Authorization', authorizationHeader);
		   	sap.timeout_x=20000;
            SapWsNew.ZSD_CHECK_TICKET_IN listaTicket= new SapWsNew.ZSD_CHECK_TICKET_IN();
            List <SapWsNew.ZSD_CHECK_TICKET> ticketToCheck= new  List <SapWsNew.ZSD_CHECK_TICKET> ();
            
            for(Ticket_Fatturazione__c t : iolTickets){
    			SapWsNew.ZSD_CHECK_TICKET currCheck= new SapWsNew.ZSD_CHECK_TICKET();
    			currCheck.NR_DOC=''+Integer.valueOf(t.Name);
    			system.debug('nrDc'+currCheck.NR_DOC);
    			ticketToCheck.add(currCheck);
    			iolTktMap.put(''+Integer.valueOf(t.Name), t);
			}
            listaTicket.item= ticketToCheck;
            
            
            SapWsNew.ZSD_CHECK_TICKET_SFResponse_element res =sap.ZSD_CHECK_TICKET_SF(listaTicket);
            system.debug('res.CHECKTICKETSIOLRESULT'+res.CHECKTICKETSIOLRESULT);
            List <SapWsNew.ZSD_CHECK_TICKET> listaResp=res.LISTATICKET_OUT.item;
            Ticket_Fatturazione__c tmp;
             system.debug(' listaResp size '+listaResp.size());
             for (SapWsNew.ZSD_CHECK_TICKET tSap:listaResp){
             	Boolean isChanged = false;
             	system.debug('tSap.NR_DOC '+tSap.NR_DOC);
             	tmp = iolTktMap.get(tSap.NR_DOC);
			    system.debug('@@TktSF: '+tmp);
				system.debug('tSap.NRPROTOCOLLO '+tSap.NRPROTOCOLLO);
        		system.debug('tSap.DATAREGISTRAZIONE '+tSap.DATAREGISTRAZIONE);
        		system.debug('tSap.IMPONIBILE '+tSap.IMPONIBILE);
        		system.debug('tSap.PAGATA '+tSap.PAGATA);
        		system.debug('tSap.LINKDOCUMENTO '+tSap.LINKDOCUMENTO);	
        		try{
	        		if(tmp <> null && String.isNotBlank(tSap.NRPROTOCOLLO)){
	                       if(tmp.Numero_Fattura__c <> tSap.NRPROTOCOLLO){
	                            tmp.Numero_Fattura__c=tSap.NRPROTOCOLLO;
	                            isChanged = true;                            
	                            tmp.Stato__c = 'Fatturato';
	        			}
	        			 date mydate = date.valueOf(tSap.DATAREGISTRAZIONE);
                        
                        if(tmp.Data_emissione_fattura__c <> mydate){
                            tmp.Data_emissione_fattura__c =  mydate;
                            isChanged = true;
                        }
                        if(tmp.Importo_Totale__c <> Decimal.valueOf(tSap.Imponibile)){
                            tmp.Importo_Totale__c = Decimal.valueOf(tSap.Imponibile);
                            isChanged = true;
                        }
                        if(tmp.Link_Documento__c <> tSap.LinkDocumento){
                            tmp.Link_Documento__c = tSap.LinkDocumento;
                            isChanged = true;
                        }
                        if(tSap.Pagata != null){
                            if(tmp.Pagata__c <> Boolean.valueOf(tSap.Pagata)){
                                tmp.Pagata__c = Boolean.valueOf(tSap.Pagata);
                                isChanged = true;
                            }
                            if(Boolean.valueOf(tSap.Pagata)){
                                tmp.Stato__c = 'Pagato';
                            }
                        }else{
                            tmp.Pagata__c = false;
                        }

                    }
               

                    if(isChanged){
                        tktToUpdate.add(tmp);
                    }	
	        		
        		
        		}catch(Exception e ){
        			system.debug(e);
        		}
        		
        		
        		
             }
             /*
			for (SapWsNew.ZSD_CHECK_TICKET tSap:listaResp){
				system.debug('tSap.NR_DOC '+tSap.NR_DOC);
				
			    tmp = iolTktMap.get(tSap.NR_DOC);
			    system.debug('@@TktSF: '+tmp);
				system.debug('tSap.NRPROTOCOLLO '+tSap.NRPROTOCOLLO);
        		system.debug('tSap.DATAREGISTRAZIONE '+tSap.DATAREGISTRAZIONE);
        		system.debug('tSap.IMPONIBILE '+tSap.IMPONIBILE);
        		system.debug('tSap.PAGATA '+tSap.PAGATA);
        		system.debug('tSap.LINKDOCUMENTO '+tSap.LINKDOCUMENTO);	
            	Boolean isChanged = false;
                if(tmp <> null){
                    if(String.isNotBlank(tSap.NR_DOC)){
                        if(tmp.Numero_Fattura__c <> tSap.NR_DOC){
                            tmp.Numero_Fattura__c = tSap.NR_DOC;
                            isChanged = true;                            
                            tmp.Stato__c = 'Fatturato';                            
                        }
                        date mydate = date.valueOf(tSap.DATAREGISTRAZIONE);
                        
                        if(tmp.Data_emissione_fattura__c <> mydate){
                            tmp.Data_emissione_fattura__c =  mydate;
                            isChanged = true;
                        }
                        if(tmp.Importo_Totale__c <> Decimal.valueOf(tSap.Imponibile)){
                            tmp.Importo_Totale__c = Decimal.valueOf(tSap.Imponibile);
                            isChanged = true;
                        }
                        if(tmp.Link_Documento__c <> tSap.LinkDocumento){
                            tmp.Link_Documento__c = tSap.LinkDocumento;
                            isChanged = true;
                        }
                        if(tSap.Pagata != null){
                            if(tmp.Pagata__c <> Boolean.valueOf(tSap.Pagata)){
                                tmp.Pagata__c = Boolean.valueOf(tSap.Pagata);
                                isChanged = true;
                            }
                            if(Boolean.valueOf(tSap.Pagata)){
                                tmp.Stato__c = 'Pagato';
                            }
                        }else{
                            tmp.Pagata__c = false;
                        }

                    }
               

                    if(isChanged){
                        tktToUpdate.add(tmp);
                    }
                }
            }*/
        }
         
        UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger = true;
        update tktToUpdate;
    }    
}