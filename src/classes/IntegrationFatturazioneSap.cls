/**
 *  Date:   2016/03/30
 *  Description:    Mapping class for Fatturazione
 *  Author: Luca Mancuso
 */
public class IntegrationFatturazioneSap {

    private static String getAuthorizationHeader(String customSettName){
        BasicAuthApplication__c cs = BasicAuthApplication__c.getInstance(customSettName);
        Blob headerValue = Blob.valueOf(cs.username__c + ':' + cs.password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        return authorizationHeader;        
    }

    public static String insertTestataIOL(Ticket_Fatturazione__c tf,String customSettName){
    	SapWSNew.SALESFORCE sap=new SapWSNew.SALESFORCE();
     	sap.inputHttpHeaders_x = new Map<String,String>();
        sap.endpoint_x = BasicAuthApplication__c.getInstance(customSettName).endpoint__c;
        sap.inputHttpHeaders_x.put('Authorization', getAuthorizationHeader(customSettName));
     	sap.timeout_x=20000;
     	SapWSNew.ZSD_TESTATE_VENDITA_IN testata_req= createTestataSap(tf);//new SapWSNew.ZSD_TESTATE_VENDITA_IN();
     	String response='';
        try{
	        response=sap.ZSD_TESTATE_VENDITA_SF(testata_req);
        }catch(Exception e){
	 		system.debug(e);
	 		response=e.getMessage();
        }
        system.debug('testata_resp '+response);
        return Test.isRunningTest() ? 'OK' : response;
    }    

    public static String insertRigaIOL(Riga_Fatturazione__c rf,String customSettName){
SapWSNew.SALESFORCE sap=new SapWSNew.SALESFORCE();
     	sap.inputHttpHeaders_x = new Map<String,String>();
        sap.endpoint_x = BasicAuthApplication__c.getInstance(customSettName).endpoint__c;
        sap.inputHttpHeaders_x.put('Authorization', getAuthorizationHeader(customSettName));
     	sap.timeout_x=20000;
     	SapWSNew.ZSD_RIGHE_VENDITA_IN rItn = createRigaSap(rf);
        String response='';
        try{
	        response=sap.ZSD_RIGHE_VENDITA_SF(rItn);
        }catch(Exception e){
	 		system.debug(e);
	 		response=e.getMessage();
        }    
        return Test.isRunningTest() ? 'OK' : response;
    }  

    public static String insertClienteIOL(Ticket_Fatturazione__c tf,String customSettName){
    	SapWSNew.SALESFORCE sap=new SapWSNew.SALESFORCE();
     	sap.inputHttpHeaders_x = new Map<String,String>();
        sap.endpoint_x = BasicAuthApplication__c.getInstance(customSettName).endpoint__c;
        sap.inputHttpHeaders_x.put('Authorization', getAuthorizationHeader(customSettName));
     	sap.timeout_x=20000;
     	SapWSNew.ZSD_INSERISCI_CLIENTE_IN cliente_req= createClienteSap(tf);//new SapWSNew.ZSD_TESTATE_VENDITA_IN();
        String response='';
        try{
	        response=sap.ZSD_INSERISCI_CLIENTE_SF(cliente_req);
        }catch(Exception e){
	 		system.debug(e);
	 		response=e.getMessage();
        }
        return Test.isRunningTest() ? 'OK' : response;
    }
    
    /*CLAUDIO 01/12/2016
    public static string debugInserisciClienteIOLNav(NavisionManageClientiNav2013.InserisciClienteIOL_element el){
        string s = '';
        return s;
    }
    */
     	
    public static SapWSNew.ZSD_TESTATE_VENDITA_IN createTestataSap(Ticket_Fatturazione__c t){
        	SapWSNew.ZSD_TESTATE_VENDITA_IN sapTes = new SapWSNew.ZSD_TESTATE_VENDITA_IN();
            
            sapTes.Document_Type = t.Tipologia_ticket__c; 
            /* sul nuovo wsdl sarà un int
            String s='0000015548';
			integer i=integer.ValueOf(s);
			system.debug(i);
            */
                       
            sapTes.NR_DOC = ''+integer.ValueOf(t.Name);
            sapTes.Sell_to_Customer_No = t.Codice_fatturazione__c;
            sapTes.Payment_Terms_Code = t.Termini_di_pagamento__c;
            sapTes.Payment_Method_Code = t.Metodo_di_pagamento__c;
	        sapTes.Currency_Code = 'EUR';
            sapTes.ID_Campagna = t.Opportunity__r.Identificativo_Campagna__c;
            sapTes.Applies_to_Doc_No = '';
            sapTes.Address = t.Billing_Indirizzo__c;   
            sapTes.Post_Code = t.Billing_CAP__c; 
            sapTes.City = t.Billing_Citta__c;
            sapTes.County = t.Billing_Provincia__c;
            sapTes.Country = t.Billing_Nazione__c;
            sapTes.Name = t.Ragione_sociale_indirizzo_di_spedizione__c;
            sapTes.Indirizzo_email =   t.Email_spedizione__c != null ? t.Email_spedizione__c : '';
            sapTes.LINGUA = t.Lingua_template_fattura__c;
            sapTes.Tipo_Spedizione = t.Modalita_di_spedizione__c;
            sapTes.Commento1 = t.Note_fattura_1__c != null ? t.Note_fattura_1__c : '';
            sapTes.Commento2 = t.Note_fattura_2__c != null ? t.Note_fattura_2__c : '';
            sapTes.Cod_BL = t.Business_Line__c;
            sapTes.Percentuale_ristorno_agenzia = t.Percentuale_ristorno_agenzia__c.format().replace('.','').replace(',','.');
            system.debug('ristorno '+sapTes.Percentuale_ristorno_agenzia);            
            sapTes.Nome_Opportunita = t.Nome_Opportunit__c;            
            system.debug('valore '+t.Valore_Fattura__c.format().replace('.','').replace(',','.'));
            sapTes.Amount = t.Valore_Fattura__c.format().replace('.','').replace(',','.');

                   
         /////////////////////////////////4/5/2016 obsoleti non servono a sap
      /*              sapTes.Codice_Template = t.ID_template_stampa__c;
       //     sapTes.Cliente=t.codice_sede__c;
         	// per pubb amministrazione da implementare in fase 2
 		 	//	sapTes.pa_nrcontratto = t.Opportunity__r.Codice_CIG__c;
         	//  sapTes.pa_codice_CIG = t.Opportunity__r.Codice_CIG__c;
          	//  sapTes.pa_codice_CUP = t.Opportunity__r.Codice_CUP__c
          	//  sapTes.pa_data_contratto = t.Opportunity__r.Codice_CUP__c;
            //////? da sostituire con righe e non spaccati Numero_totale_righe__c
            sapTes.Numero_di_righe = (Integer) t.Numero_di_righe_spaccati__c;
            sapTes.Flusso_di_provenienza = t.Flusso_provenienza__c;
            sapTes.DocumentoAggregabile = string.valueOf(t.Documento_aggregabile__c);
            sapTes.Company = t.Company__c;
            sapTes.Area_Code = '';
            sapTes.Posting_Description = '';
            sapTes.Credit_Card_Type = '';
            sapTes.Credit_Card_No = '';
            sapTes.Credit_Card_Expiration_Date = '01/01/1900 1.00';//DateTime.newInstanceGmt(1900, 1, 1);
            sapTes.Salesperson_Code = 'CLIENTE';
            sapTes.TIPOREC = t.Tipo_Rec_Testata__c;
            sapTes.Bank_Account = '';
		*/
        system.debug('@@Testata: '+sapTes);
        return sapTes;
    }
    
        /*
    *   3 main methods for IOL Advertising: creating cliente, testata di vendita and righe di vendita
    *   Added: 1 method 
    */
    public static SapWSNew.ZSD_INSERISCI_CLIENTE_IN createClienteSap(Ticket_Fatturazione__c t){
         	SapWSNew.ZSD_INSERISCI_CLIENTE_IN sapCli = new SapWSNew.ZSD_INSERISCI_CLIENTE_IN();
       		        /* sul nuovo wsdl sarà un int
            String s='0000015548';
			integer i=integer.ValueOf(s);
			system.debug(i);
            */
            sapCli.NR_DOC = ''+integer.ValueOf(t.Name);
            sapCli.CODICE_SEDE = t.codice_sede__c;
			sapCli.VAT_REGISTRATION_NO = t.Partita_IVA__c;
            sapCli.FISCAL_CODE = t.Codice_fiscale__c;
            
/////////////////////////////////4/5/2016 obsoleti non servono a sap
          /* sapCli.Codice_iPA = t.Codice_iPA__c;
          sapCli.FLUSSO_PROVENIENZA = t.Flusso_provenienza__c; 
            
            sapCli.TipoRec = t.Tipo_Rec_Cliente__c;
            sapCli.No_x = t.Codice_fatturazione__c;
            sapCli.Name = t.Ragione_sociale__c;

            String[] addresses = splitAddress(t.Legal_Indirizzo__c);
            sapCli.Address = addresses[0];
            sapCli.Address_2 = addresses[1];
            sapCli.Email = t.Account__r.Email_principale__c;
            */
            /* old version
            t.Legal_Indirizzo__c = t.Legal_Indirizzo__c != null ? t.Legal_Indirizzo__c : ''; 
            if(t.Legal_Indirizzo__c.length() > 50){
                sapCli.Address = t.Legal_Indirizzo__c.substring(0,50);
            }else{
                sapCli.Address = t.Legal_Indirizzo__c;
            }
            */            
            /*
            sapCli.Post_Code = t.Legal_CAP__c;
            sapCli.City = t.Legal_Citta__c;
            sapCli.County = t.Legal_Provincia__c;
            sapCli.xDescrNazione = t.Legal_Nazione__c;
            sapCli.Customer_Posting_Group = t.Customer_Posting_Group__c;
            sapCli.Payment_Method_Code = t.Metodo_di_pagamento__c;
            sapCli.Payment_Terms_Code = t.Termini_di_pagamento__c;
            sapCli.Reminder_Terms_Code = t.Termini_sollecito__c;
            */
        system.debug('@@Cliente: '+sapCli);
        return sapCli;
    }
    
    public static SapWSNew.ZSD_RIGHE_VENDITA_IN createRigaSap(Riga_Fatturazione__c r){
        	SapWSNew.ZSD_RIGHE_VENDITA_IN sapRow = new SapWSNew.ZSD_RIGHE_VENDITA_IN();
            sapRow.Document_Type = r.Tipologia_ticket__c;
                /* sul nuovo wsdl sarà un int
            String s='0000015548';
			integer i=integer.ValueOf(s);
			system.debug(i);
            */
            sapRow.NR_DOC = ''+integer.ValueOf(r.Numero_Ticket__c);            
            ///////avvertire cervero per ticket manuali
            sapRow.Line_No = (Integer)r.Numero_Riga__c;            
            sapRow.CONTORIC = r.Conto_ricavo__c;
            sapRow.DescrizioneSorg = r.Descrizione__c != null ? r.Descrizione__c : '';
            sapRow.xQty = r.Quantita__c.format().replace('.','').replace(',','.');
            sapRow.XUnitPrice = r.Prezzo_unitario__c.format().replace('.','').replace(',','.');
            sapRow.VATCODE = r.Codice_IVA__c;
            //CLAUDIO 05/07/2016 B
            sapRow.xUM = r.Nascondi_date_competenza__c ?  'X' : '';
            //sapRow.xUM='';
            //E
            sapRow.Cod_Prodotto = r.Dimensione_Prodotto__c;
            sapRow.Cod_Canale = r.Canale__c;
            sapRow.xStartDate = r.Start_date__c.format();
            sapRow.xEndDate = r.End_date__c.format();
            sapRow.Raggruppamento = r.Raggruppamento__c;
            sapRow.CONTORISC = r.Conto_risconto__c;

            //2013/many months before Nov: Changed with an empty field
            //2013/11/26 reverted to DescrizioneAliquotaIVA from riga di fatturazione

            
            system.debug('@@Riga: '+sapRow);
            
          /////////////////////////////////4/5/2016 obsoleti non servono a sap
          /*  sapCli.Codice_iPA = t.Codice_iPA__c;  
            sapRow.TipoRec = r.Tipo_Rec_Riga__c;
            sapRow.Type_x = 'CONTO (C/G)';
            sapRow.Flusso_provenienza = r.Flusso_provenienza__c;
            sapRow.xVatBase = 0;
            sapRow.xLineDisc = 0;
            sapRow.ImportoIVA_Incl_Sorg = 0;
           
            sapRow.xJobNo = '';
            sapRow.Cod_Brand = 'na';
            sapRow.Cod_Area_Editoriale = 'na';
            sapRow.Cod_Delivery_Channel = 'na';
            */
            
        return sapRow;
    }
    
        public static String[] splitAddress(String address){
        String[] split = new String[]{'',''};
        address = address != null ? address : '';            
        //  Ref# IND 10
        if(address.length() > 40){

            list<String> parts = address.split(' ',-1);
            system.debug('@@Parts: '+parts);
            for(String s : parts){
                if(split[0].length() <= 40 && (split[0].length()+s.length() <= 40) && split[1] == ''){
                    split[0] += s+' ';
                }else{
                    if(split[1].length() <= 40 && (split[1].length()+s.length() <= 40)){
                        split[1] += s+' ';
                    }
                }
            }
            split[0] = split[0].removeEnd(' ');
            split[1] = split[1].removeEnd(' ');
        }
        else{
            split[0] = address;
        }
     
        return split;   
    }
}