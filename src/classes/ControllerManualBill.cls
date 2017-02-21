/**
 *  Date:   2013/01/21
 *  Description:    Controller for manualTicket Visualforce Page
 *  Author: Ivano Cortese
 */
public class ControllerManualBill {
	private Quote q;
	private Ticket_Fatturazione__c tkt;
	
	public Opportunity opty {get;set;}	
	public boolean canSave {get;set;}
	ApexPages.StandardController stdController;	
	
	public ControllerManualBill(ApexPages.StandardController stdController){
		this.stdController = stdController;
		opty = [SELECT Id,Name,SyncedQuoteId,Anagrafica_di_Fatturazione__r.Check_amministrativo__c,Escludi_da_fatt_auto__c,Check_amministrativo__c,
                    (SELECT Id, Metodo_di_pagamento__c, Termini_di_pagamento__c, Descrizione_Termini_Pagamento__c, Indirizzo_Spedizione_Alternativo__c, Modalita_di_spedizione__c, Codice_IVA__c, Lingua_template_fattura__c, Email_aggiuntive__c, Descrizione_IVA__c,Indirizzo_Spedizione_Alternativo__r.Ragione_sociale__c,
                    Indirizzo_Spedizione_Alternativo__r.Via__c, Indirizzo_Spedizione_Alternativo__r.Citta__c, Indirizzo_Spedizione_Alternativo__r.Provincia__r.Sigla__c, Indirizzo_Spedizione_Alternativo__r.Cap__c, Indirizzo_Spedizione_Alternativo__r.Stato__c, Indirizzo_Spedizione_Alternativo__r.Email_di_Spedizione__c,
                    Opportunity.Anagrafica_di_Fatturazione__r.BillingStreet, Opportunity.Anagrafica_di_Fatturazione__r.BillingPostalCode, Opportunity.Anagrafica_di_Fatturazione__r.BillingCity, Opportunity.Anagrafica_di_Fatturazione__r.BillingState, Opportunity.Anagrafica_di_Fatturazione__r.BillingCountry, Opportunity.Anagrafica_di_Fatturazione__r.RecordType.DeveloperName, /*Opportunity.Anagrafica_di_Fatturazione__r.Customer_Posting_Group__c,*/
                    Opportunity.Anagrafica_di_Fatturazione__r.Ragione_sociale_fattura__c, Opportunity.Anagrafica_di_Fatturazione__r.Partita_IVA__c, Opportunity.Anagrafica_di_Fatturazione__r.Codice_fiscale__c, Opportunity.Anagrafica_di_Fatturazione__r.Email_principale__c, Opportunity.Anagrafica_di_Fatturazione__r.Codice_fatturazione_completo__c, Opportunity.Note_fattura__c, Opportunity.Anagrafica_di_Fatturazione__r.DescrizioneAliquotaIVA__c,
                    Opportunity.Owner.Area_BL__c,Opportunity.Name, Opportunity.Commissione_Agenzia__c
                    FROM Quotes)
                FROM Opportunity
	            WHERE Id = :ApexPages.currentPage().getParameters().get('optyId')];
		
		if(!opty.Check_amministrativo__c)
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'È necessario eseguire il check amministrativo per la seguente campagna prima di poter procedere con la fatturazione manuale.'));
		else
			if(!opty.Escludi_da_fatt_auto__c)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'È necessario escludere la seguente campagna dalla fatturazione automatica prima di poter procedere con la fatturazione manuale.'));
			else{
				if(opty.Quotes.size() == 1){
					q = opty.Quotes.get(0);
				}else if(opty.SyncedQuoteId != null){
					q = (new map<id,quote>(opty.quotes)).get(opty.SyncedQuoteId);
				}
				tkt = (Ticket_Fatturazione__c)stdController.getRecord();
				//tkt.Anno_riferimento__c = String.valueOf(Date.today().year());
				canSave = true;
			}		
	}
	
	public PageReference saveTkt(){
		try{
			tkt = ScheduledTicketCreation.createTicket(tkt.Mese_riferimento__c, tkt.Anno_riferimento__c, q);
			tkt.Stato__c = 'Draft';
			tkt.Ticket_manuale__c = true;
			insert tkt;
		}catch(Exception e){
			
		}			
		return new ApexPages.StandardController(tkt).view();	
	}
	
	public PageReference back(){
		PageReference p = new PageReference('/'+opty.Id);
		p.setRedirect(true);
		return p;
	}
}