/**
 *  Date:   2013/01/09
 *  Description:    Mapping class for Fatturazione
 *  Author: Ivano Cortese
 */
public class IntegrationFatturazioneNav2009 {

    private static String getAuthorizationHeader(String customSettName){
        BasicAuthApplication__c cs = BasicAuthApplication__c.getInstance(customSettName);
        Blob headerValue = Blob.valueOf(cs.username__c + ':' + cs.password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        return authorizationHeader;
    }

    public static String insertClienteITNET(Ticket_Fatturazione__c tf,String customSettName) {
        NavisionManageClientiNav2009.InserisciClienteITNET_element cItn = createClienteNav_ITNET(tf);
        
        NavisionManageClientiNav2009.ManageClientiSoap ncs = new NavisionManageClientiNav2009.ManageClientiSoap();
        ncs.endpoint_x = BasicAuthApplication__c.getInstance(customSettName).endpoint__c+'ManageClienti.asmx';
        ncs.inputHttpHeaders_x = new Map<String,String>();
        ncs.inputHttpHeaders_x.put('Authorization', getAuthorizationHeader(customSettName));
        ncs.timeout_x = 20000;
        
        system.debug('Endpoint inserisci cliente itnet = '+ncs.endpoint_x);
        return Test.isRunningTest() ? 'OK' : ncs.InserisciClienteITNET(cItn);
    }

    public static String insertTestataITNET(Ticket_Fatturazione__c tf,String customSettName){
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element tItn = createTestataNav_ITNET(tf);
        
        NavisionManageTestateVenditaNav2009.ManageTestateVenditaSoap ncs = new NavisionManageTestateVenditaNav2009.ManageTestateVenditaSoap();
        ncs.endpoint_x = BasicAuthApplication__c.getInstance(customSettName).endpoint__c+'ManageTestateVendita.asmx';
        ncs.inputHttpHeaders_x = new Map<String,String>();
        ncs.inputHttpHeaders_x.put('Authorization', getAuthorizationHeader(customSettName));
        ncs.timeout_x = 20000;
        
        return Test.isRunningTest() ? 'OK' : ncs.InserisciTestateVenditaITNET(tItn);
    }    

    public static String insertRigaITNET(Riga_Fatturazione__c rf,String customSettName){
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element rItn = createRigaNav_ITNET(rf);
        
        NavisionManageRigheVenditaNav2009.ManageRigheVenditeSoap ncs = new NavisionManageRigheVenditaNav2009.ManageRigheVenditeSoap();
        ncs.endpoint_x = BasicAuthApplication__c.getInstance(customSettName).endpoint__c+'ManageRigheVendite.asmx';
        ncs.inputHttpHeaders_x = new Map<String,String>();
        ncs.inputHttpHeaders_x.put('Authorization', getAuthorizationHeader(customSettName));
        ncs.timeout_x = 20000;
        
        return Test.isRunningTest() ? 'OK' : ncs.InserisciRigheVenditaITNET(rItn);
    }    
    
    /*
    ** 3 main methods for IOL Advertising: creating cliente, testata di vendita and righe di vendita
    */
    public static NavisionManageClientiNav2009.InserisciClienteLibero_element createClienteNav(Ticket_Fatturazione__c t){
        NavisionManageClientiNav2009.InserisciClienteLibero_element navCli = new NavisionManageClientiNav2009.InserisciClienteLibero_element();
            //Key = 
            //ID =
            navCli.TipoRec = t.Tipo_Rec_Cliente__c;
            navCli.NrDoc = t.Name;
            navCli.No_x = t.Codice_fatturazione__c;
            navCli.Name = t.Ragione_sociale__c;
            t.Legal_Indirizzo__c = t.Legal_Indirizzo__c != null ? t.Legal_Indirizzo__c : ''; 
            if(t.Legal_Indirizzo__c.length() > 50){
                navCli.Address = t.Legal_Indirizzo__c.substring(0,50);
            }else{
                navCli.Address = t.Legal_Indirizzo__c;
            }
            navCli.Post_Code = t.Legal_CAP__c;
            navCli.City = t.Legal_Citta__c;
            navCli.County = t.Legal_Provincia__c;
            navCli.xDescrNazione = t.Legal_Nazione__c;
            navCli.VAT_Registration_No_x = t.Partita_IVA__c != null ? t.Partita_IVA__c : '';
            navCli.Fiscal_Code = t.Codice_fiscale__c != null ? t.Codice_fiscale__c : '';
            navCli.Customer_Posting_Group = t.Customer_Posting_Group__c;
            navCli.Payment_Method_Code = t.Metodo_di_pagamento__c;
            navCli.Payment_Terms_Code = t.Termini_di_pagamento__c;
            navCli.Reminder_Terms_Code = t.Termini_sollecito__c;
            navCli.Flusso_provenienza = t.Flusso_provenienza__c;
        system.debug('@@Cliente: '+navCli);
        return navCli;
    }
    public static string debugInserisciClienteLiberoNav(NavisionManageClientiNav2009.InserisciClienteLibero_element el){
        string s = '';
        return s;
    }
    
    public static NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element createTestataNav(Ticket_Fatturazione__c t){
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element navTes = new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element();
            navTes.TipoRec = t.Tipo_Rec_Testata__c;
            navTes.Document_Type = t.Tipologia_ticket__c;
            navTes.No = t.Name;
            navTes.Posting_Date = DateTime.newInstanceGmt(1900, 1, 1);
            navTes.Sell_to_Customer_No = t.Codice_fatturazione__c;
            navTes.Payment_Method_Code = t.Metodo_di_pagamento__c;
            navTes.Payment_Terms_Code = t.Termini_di_pagamento__c;
            //  Ref# PAG IVA 10
            navTes.Payment_Terms_Description = t.Descrizione_Termini_Pagamento__c;
            system.debug('@@Desc TermDiPag: '+t.Descrizione_Termini_Pagamento__c);
            //  Ref# OPP FAT 10
            navTes.ID_Campagna = t.Opportunity__r.Identificativo_Campagna__c;
            system.debug('@@Ident Camp: '+t.Opportunity__r.Identificativo_Campagna__c);
            t.Billing_Indirizzo__c = t.Billing_Indirizzo__c != null ? t.Billing_Indirizzo__c : '';            
            //  Ref# IND 10
            if(t.Billing_Indirizzo__c.length() > 40){
              navTes.Address = '';
              navTes.Address_2 = '';
              list<String> parts = t.Billing_Indirizzo__c.split(' ',-1);
              system.debug('@@Parts: '+parts);
              for(String s : parts){
                if(navTes.Address.length() <= 40 && (navTes.Address.length()+s.length() <= 40) && navTes.Address_2 == '')
                  navTes.Address += s+' ';
                else
                  if(navTes.Address_2.length() <= 40 && (navTes.Address_2.length()+s.length() <= 40))
                    navTes.Address_2 += s+' ';
              }
              navTes.Address = navTes.Address.removeEnd(' ');
              navTes.Address_2 = navTes.Address_2.removeEnd(' ');
            }
            else{
              navTes.Address = t.Billing_Indirizzo__c;
                navTes.Address_2 = '';
            }
            system.debug('@@Address1: '+navTes.Address);
            system.debug('@@Address2: '+navTes.Address_2);
            /*
            **  OLD VERSION
            if(t.Billing_Indirizzo__c.length() > 50){
                navTes.Address = t.Billing_Indirizzo__c.substring(0,50);
                navTes.Address_2 = t.Billing_Indirizzo__c.substring(50);
            }else{
                navTes.Address = t.Billing_Indirizzo__c;
                navTes.Address_2 = '';
            }
            */
            navTes.Post_Code = t.Billing_CAP__c;
            navTes.City = t.Billing_Citta__c;
            navTes.County = t.Billing_Provincia__c;
            navTes.Country = t.Billing_Nazione__c;
            navTes.Name = t.Ragione_sociale__c;
            navTes.Indirizzo_email = t.Email_spedizione__c != null ? t.Email_spedizione__c : '';
            navTes.Codice_Template = t.ID_template_stampa__c;
            navTes.Lingua_Template = t.Lingua_template_fattura__c;
            navTes.Tipo_Spedizione = t.Modalita_di_spedizione__c;
            navTes.Flusso_di_provenienza = t.Flusso_provenienza__c;
            navTes.DocumentoAggregabile = t.Documento_aggregabile__c;
            navTes.Bank_Account = '';
            navTes.Salesperson_Code = 'CLIENTE';
            navTes.Currency_Code = 'EUR';
            navTes.Area_Code = '';
            navTes.Posting_Description = '';
            //Ticket Number if Nota credito ELSE empty string
            navTes.Applies_to_Doc_No = '';
            navTes.Credit_Card_Type = '';
            navTes.Credit_Card_No = '';
            navTes.Credit_Card_Expiration_Date = DateTime.newInstanceGmt(1900, 1, 1);
            navTes.Commento1 = t.Note_fattura_1__c != null ? t.Note_fattura_1__c : '';
            navTes.Commento2 = t.Note_fattura_2__c != null ? t.Note_fattura_2__c : '';
        system.debug('@@Testata: '+navTes);
        return navTes;
    }
/*    
    public static string debugInserisciTestateVenditaLibero(NavisionManageTestateVenditaNav2009.InserisciTestateVenditaLibero_element el){
        String s = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><InserisciTestateVenditaLibero xmlns="http://tempuri.org/"><TipoRec>{TipoRec}</TipoRec><Document_Type>{Document_Type}</Document_Type><No>{No}</No><Posting_Date>{Posting_Date}</Posting_Date><Sell_to_Customer_No>{Sell_to_Customer_No}</Sell_to_Customer_No><Bank_Account>{Bank_Account}</Bank_Account><Salesperson_Code>{Salesperson_Code}</Salesperson_Code><Payment_Terms_Code>{Payment_Terms_Code}</Payment_Terms_Code><Payment_Method_Code>{Payment_Method_Code}</Payment_Method_Code><Currency_Code>{Currency_Code}</Currency_Code><Area_Code>{Area_Code}</Area_Code><Applies_to_Doc_No>{Applies_to_Doc_No}</Applies_to_Doc_No><Posting_Description>{Posting_Description}</Posting_Description><Credit_Card_Type>{Credit_Card_Type}</Credit_Card_Type><Credit_Card_No>{Credit_Card_No}</Credit_Card_No><Credit_Card_Expiration_Date>{Credit_Card_Expiration_Date}</Credit_Card_Expiration_Date><Address>{Address}</Address><Address_2>{Address_2}</Address_2><Name>{Name}</Name><Post_Code>{Post_Code}</Post_Code><City>{City}</City><County>{County}</County><Country>{Country}</Country><Indirizzo_email>{Indirizzo_email}</Indirizzo_email><Codice_Template>{Codice_Template}</Codice_Template><Lingua_Template>{Lingua_Template}</Lingua_Template><Tipo_Spedizione>{Tipo_Spedizione}</Tipo_Spedizione><Commento1>{Commento1}</Commento1><Commento2>{Commento2}</Commento2><Flusso_di_provenienza>{Flusso_di_provenienza}</Flusso_di_provenienza><DocumentoAggregabile>{DocumentoAggregabile}</DocumentoAggregabile></InserisciTestateVenditaLibero></soap:Body></soap:Envelope>';
        s = s.replace('{TipoRec}',el.TipoRec+'');
        s = s.replace('{Document_Type}',el.Document_Type+'');
        s = s.replace('{No}',el.No+'');
        s = s.replace('{Posting_Date}',el.Posting_Date+'');
        s = s.replace('{Sell_to_Customer_No}',el.Sell_to_Customer_No+'');
        s = s.replace('{Bank_Account}',el.Bank_Account+'');
        s = s.replace('{Salesperson_Code}',el.Salesperson_Code+'');
        s = s.replace('{Payment_Terms_Code}',el.Payment_Terms_Code+'');
        s = s.replace('{Payment_Method_Code}',el.Payment_Method_Code+'');
        s = s.replace('{Currency_Code}',el.Currency_Code+'');
        s = s.replace('{Applies_to_Doc_No}',el.Applies_to_Doc_No+'');
        s = s.replace('{Area_Code}',el.Area_Code+'');
        s = s.replace('{Posting_Description}',el.Posting_Description+'');
        s = s.replace('{Credit_Card_Type}',el.Credit_Card_Type+'');
        s = s.replace('{Credit_Card_No}',el.Credit_Card_No+'');
        s = s.replace('{Credit_Card_Expiration_Date}',el.Credit_Card_Expiration_Date+'');
        s = s.replace('{Address}',el.Address+'');
        s = s.replace('{Name}',el.Name+'');
        s = s.replace('{Address_2}',el.Address_2+'');
        s = s.replace('{Post_Code}',el.Post_Code+'');
        s = s.replace('{City}',el.City+'');
        s = s.replace('{County}',el.County+'');
        s = s.replace('{Country}',el.Country+'');
        s = s.replace('{Indirizzo_email}',el.Indirizzo_email+'');
        s = s.replace('{Codice_Template}',el.Codice_Template+'');
        s = s.replace('{Lingua_Template}',el.Lingua_Template+'');
        s = s.replace('{Tipo_Spedizione}',el.Tipo_Spedizione+'');
        s = s.replace('{Commento1}',el.Commento1+'');
        s = s.replace('{Commento2}',el.Commento2+'');
        s = s.replace('{Flusso_di_provenienza}',el.Flusso_di_provenienza+'');
        s = s.replace('{DocumentoAggregabile}',el.DocumentoAggregabile+'');
        system.debug(s);
        return s;
    }
*/    
    public static NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element createRigaNav(Riga_Fatturazione__c r){
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element navRow = new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element();
            navRow.TipoRec = r.Tipo_Rec_Riga__c;
            navRow.Document_Type = r.Tipologia_ticket__c;
            navRow.Document_No = r.Numero_Ticket__c;
            navRow.Line_No = (Integer)r.Numero_Riga__c;
            navRow.Type_x = 'CONTO (C/G)';
            navRow.xNo = r.Conto_ricavo__c;
            navRow.DescrizioneSorg = r.Descrizione__c != null ? r.Descrizione__c : '';
            navRow.xQty = r.Quantita__c;
            navRow.XUnitPrice = r.Prezzo_unitario__c;
            navRow.CatART_SER_IVA = r.Codice_IVA__c;
            navRow.xDim1 = r.Centro_di_costo__c;
            navRow.xStartDate = r.Start_date__c;
            navRow.xEndDate = r.End_date__c;
            navRow.Raggruppamento = r.Raggruppamento__c;
            navRow.xNoRisconto = r.Conto_risconto__c;
            /*
            **  2013/many months before Nov: Changed with an empty field
            **  2013/11/26 reverted to DescrizioneAliquotaIVA from riga di fatturazione
            */
            navRow.DescrizioneAliquotaIVA = r.DescrizioneAliquotaIVA__c;
            //navRow.DescrizioneAliquotaIVA = '';
            navRow.Flusso_provenienza = r.Flusso_provenienza__c;
            navRow.xVatBase = 0;
            navRow.xLineDisc = 0;
            navRow.ImportoIVA_Incl_Sorg = 0;
            navRow.xUM = '';
            navRow.xJobNo = '';
        return navRow;
    }
    public static string debugInserisciRigheVenditaLiberoNav(NavisionManageRigheVenditaNav2009.InserisciRigheVenditaLibero_element el){
        string s = '';
        return s;
    }
    
    
    /*
    ** 3 main methods for ITNET Apritisito: creating cliente, testata di vendita and righe di vendita
    */
    public static NavisionManageClientiNav2009.InserisciClienteITNET_element createClienteNav_ITNET(Ticket_Fatturazione__c t){
        NavisionManageClientiNav2009.InserisciClienteITNET_element navCli = new NavisionManageClientiNav2009.InserisciClienteITNET_element();
            navCli.TipoRec = t.Tipo_Rec_Cliente__c;
            navCli.NrDoc = t.Name;
            navCli.No_x = t.Codice_fatturazione__c;
            navCli.Name = t.Ragione_sociale__c;
            t.Legal_Indirizzo__c = t.Legal_Indirizzo__c != null ? t.Legal_Indirizzo__c : ''; 
            if(t.Legal_Indirizzo__c.length() > 50){
                navCli.Address = t.Legal_Indirizzo__c.substring(0,50);
            }else{
                navCli.Address = t.Legal_Indirizzo__c;
            }
            navCli.Post_Code = t.Legal_CAP__c;
            navCli.City = t.Legal_Citta__c;
            navCli.County = t.Legal_Provincia__c;
            navCli.xDescrNazione = t.Legal_Nazione__c;
            navCli.VAT_Registration_No_x = t.Partita_IVA__c != null ? t.Partita_IVA__c : '';
            navCli.Fiscal_Code = t.Codice_fiscale__c != null ? t.Codice_fiscale__c : '';
            navCli.Customer_Posting_Group = t.Customer_Posting_Group__c;
            navCli.Payment_Method_Code = t.Metodo_di_pagamento__c;
            navCli.Payment_Terms_Code = t.Termini_di_pagamento__c;
            navCli.Reminder_Terms_Code = t.Termini_sollecito__c;
            navCli.Flusso_provenienza = t.Flusso_provenienza__c;
        return navCli;
    }
    
    public static NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element createTestataNav_ITNET(Ticket_Fatturazione__c t){
        NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element navTes = new NavisionManageTestateVenditaNav2009.InserisciTestateVenditaITNET_element();
            navTes.TipoRec = t.Tipo_Rec_Testata__c;
            navTes.Document_Type = t.Tipologia_ticket__c;
            navTes.No = t.Name;
            navTes.Posting_Date = DateTime.newInstanceGmt(1900, 1, 1);
            navTes.Sell_to_Customer_No = t.Codice_fatturazione__c;
            navTes.Payment_Method_Code = t.Metodo_di_pagamento__c;
            navTes.Payment_Terms_Code = t.Termini_di_pagamento__c;
            t.Billing_Indirizzo__c = t.Billing_Indirizzo__c != null ? t.Billing_Indirizzo__c : ''; 
            if(t.Billing_Indirizzo__c.length() > 50){
                navTes.Address = t.Billing_Indirizzo__c.substring(0,50);
                navTes.Address_2 = t.Billing_Indirizzo__c.substring(50);
            }else{
                navTes.Address = t.Billing_Indirizzo__c;
                navTes.Address_2 = '';
            }
            navTes.Post_Code = t.Billing_CAP__c;
            navTes.City = t.Billing_Citta__c;
            navTes.County = t.Billing_Provincia__c;
            navTes.Country = t.Billing_Nazione__c;
            navTes.Name = t.Ragione_sociale__c;
            navTes.Indirizzo_email = t.Email_spedizione__c != null ? t.Email_spedizione__c : '';
            navTes.Codice_Template = t.ID_template_stampa__c;
            navTes.Lingua_Template = t.Lingua_template_fattura__c;
            navTes.Tipo_Spedizione = t.Modalita_di_spedizione__c;
            navTes.Flusso_di_provenienza = t.Flusso_provenienza__c;
            navTes.DocumentoAggregabile = t.Documento_aggregabile__c;
            navTes.Bank_Account = '';
            navTes.Salesperson_Code = 'CLIENTE';
            navTes.Currency_Code = 'EUR';
            navTes.Area_Code = '';
            navTes.Posting_Description = '';
            //Ticket Number if Nota credito ELSE empty string
            navTes.Applies_to_Doc_No = '';
            navTes.Credit_Card_Type = '';
            navTes.Credit_Card_No = '';
            navTes.Credit_Card_Expiration_Date = DateTime.newInstanceGmt(1900, 1, 1);
            navTes.Commento1 = t.Note_fattura_1__c != null ? t.Note_fattura_1__c : '';
            navTes.Commento2 = t.Note_fattura_2__c != null ? t.Note_fattura_2__c : '';
        return navTes;
    }
    
    public static NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element createRigaNav_ITNET(Riga_Fatturazione__c r){
        NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element navRow = new NavisionManageRigheVenditaNav2009.InserisciRigheVenditaITNET_element();
            navRow.TipoRec = r.Tipo_Rec_Riga__c;
            navRow.Document_Type = r.Tipologia_ticket__c;
            navRow.Document_No = r.Numero_Ticket__c;
            navRow.Line_No = (Integer)r.Numero_Riga__c;
            navRow.Type_x = 'CONTO (C/G)';
            navRow.xNo = r.Conto_ricavo__c;
            navRow.DescrizioneSorg = r.Descrizione__c != null ? r.Descrizione__c : '';
            navRow.xQty = r.Quantita__c;
            navRow.XUnitPrice = r.Prezzo_unitario__c;
            navRow.CatART_SER_IVA = r.Codice_IVA__c;
            navRow.xDim1 = r.Centro_di_costo__c;
            navRow.xStartDate = r.Start_date__c;
            navRow.xEndDate = r.End_date__c;
            navRow.Raggruppamento = r.Raggruppamento__c;
            navRow.xNoRisconto = r.Conto_risconto__c;
            navRow.DescrizioneAliquotaIVA = r.Note_esenzione_IVA__c;
            navRow.Flusso_provenienza = r.Flusso_provenienza__c;
            navRow.xVatBase = 0;
            navRow.xLineDisc = 0;
            navRow.ImportoIVA_Incl_Sorg = 0;
            navRow.xUM = '';
            navRow.xJobNo = '';
        return navRow;
    }
    
}