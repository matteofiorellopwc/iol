/**
 *  Date:   2013/01/09
 *  Description:    Mapping class for Fatturazione
 *  Author: Ivano Cortese
 */
public class IntegrationMappingFatturazione {
    public List<NavisionManageClienti.InserisciClienteLibero_element> listaClienti = new List<NavisionManageClienti.InserisciClienteLibero_element>();
    public List<NavisionManageTestateVendita.InserisciTestateVenditaLibero_element> listaTestateVend = new List<NavisionManageTestateVendita.InserisciTestateVenditaLibero_element>();
    public List<NavisionManageRigheVendita.InserisciRigheVenditaLibero_element> listaRigheVend = new List<NavisionManageRigheVendita.InserisciRigheVenditaLibero_element>();
    
    public List<Ticket_Fatturazione__c> tickets;
    public List<Riga_Fatturazione__c> righe;
    
    
    public List<Ticket_Fatturazione__c> selectTickets(List<Id> ticketIDs){
        tickets = [SELECT Id, Name, Tipo_Rec_Cliente__c, Codice_fatturazione__c, Ragione_sociale__c , Documento_aggregabile__c, Legal_Indirizzo__c, Legal_CAP__c, Legal_Citta__c, Legal_Provincia__c, Legal_Nazione__c, Billing_Indirizzo__c, Billing_CAP__c, Billing_Citta__c, Billing_Provincia__c, Billing_Nazione__c, Partita_IVA__c, Codice_fiscale__c, Customer_Posting_Group__c, Metodo_di_pagamento__c, Termini_di_pagamento__c, Termini_sollecito__c, Flusso_provenienza__c,
                        Tipo_Rec_Testata__c,  Tipologia_ticket__c, Email_spedizione__c, ID_template_stampa__c, Lingua_template_fattura__c, Modalita_di_spedizione__c, Note_fattura_1__c, Note_fattura_2__c, Cliente_inviato__c,Testata_inviata__c, Tipo_Cliente__c
                        FROM Ticket_Fatturazione__c
                        WHERE Id IN :ticketIDs];
        return tickets;
    }
    public List<Riga_Fatturazione__c> selectRighe(List<Id> ticketIDs){
        righe = [SELECT Id, Tipo_Rec_Riga__c, Tipologia_ticket__c, Numero_Ticket__c, Numero_Riga__c, Conto_ricavo__c, Descrizione__c, Quantita__c, Prezzo_unitario__c, Codice_IVA__c, Centro_di_costo__c, Start_date__c, End_date__c, Raggruppamento__c, Conto_risconto__c, Note_esenzione_IVA__c,DescrizioneAliquotaIVA__c, Flusso_provenienza__c,Ticket_Fatturazione__c, errore__c, Ticket_Fatturazione__r.Tipo_Cliente__c
                                                                    FROM Riga_Fatturazione__c
                                                                    WHERE Ticket_Fatturazione__c IN : ticketIDs];
        return righe;
    
    }
    
    /*
    ** Old method, NOT USED!
    **
    public void addNavisionObj(List<Id> ticketIDs){
        selectTickets(ticketIDs);
        for(Ticket_Fatturazione__c t : tickets){
            listaClienti.add(createClienteNav(t));
            listaTestateVend.add(createTestataNav(t));
        }
        selectRighe(ticketIDs);
        for(Riga_Fatturazione__c r : righe){
            listaRigheVend.add(createRigaNav(r));
        }
    }
    */
    
    
    /*
    ** 3 main methods for IOL Advertising: creating cliente, testata di vendita and righe di vendita
    */
    public static NavisionManageClienti.InserisciClienteLibero_element createClienteNav(Ticket_Fatturazione__c t){
        NavisionManageClienti.InserisciClienteLibero_element navCli = new NavisionManageClienti.InserisciClienteLibero_element();
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
    public static string debugInserisciClienteLiberoNav(NavisionManageClienti.InserisciClienteLibero_element el){
        string s = '';
        return s;
    }
    
    public static NavisionManageTestateVendita.InserisciTestateVenditaLibero_element createTestataNav(Ticket_Fatturazione__c t){
        NavisionManageTestateVendita.InserisciTestateVenditaLibero_element navTes = new NavisionManageTestateVendita.InserisciTestateVenditaLibero_element();
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
        system.debug('@@Testata: '+navTes);
        return navTes;
    }
    public static string debugInserisciTestateVenditaLibero(NavisionManageTestateVendita.InserisciTestateVenditaLibero_element el){
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
    
    public static NavisionManageRigheVendita.InserisciRigheVenditaLibero_element createRigaNav(Riga_Fatturazione__c r){
        NavisionManageRigheVendita.InserisciRigheVenditaLibero_element navRow = new NavisionManageRigheVendita.InserisciRigheVenditaLibero_element();
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
            //Changed with an empty field
            //navRow.DescrizioneAliquotaIVA = r.DescrizioneAliquotaIVA__c;
            navRow.DescrizioneAliquotaIVA = '';
            navRow.Flusso_provenienza = r.Flusso_provenienza__c;
            navRow.xVatBase = 0;
            navRow.xLineDisc = 0;
            navRow.ImportoIVA_Incl_Sorg = 0;
            navRow.xUM = '';
            navRow.xJobNo = '';
        return navRow;
    }
    public static string debugInserisciRigheVenditaLiberoNav(NavisionManageRigheVendita.InserisciRigheVenditaLibero_element el){
        string s = '';
        return s;
    }
    
    
    /*
    ** 3 main methods for ITNET Apritisito: creating cliente, testata di vendita and righe di vendita
    */
    public static NavisionManageClienti.InserisciClienteITNET_element createClienteNav_ITNET(Ticket_Fatturazione__c t){
        NavisionManageClienti.InserisciClienteITNET_element navCli = new NavisionManageClienti.InserisciClienteITNET_element();
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
    
    public static NavisionManageTestateVendita.InserisciTestateVenditaITNET_element createTestataNav_ITNET(Ticket_Fatturazione__c t){
        NavisionManageTestateVendita.InserisciTestateVenditaITNET_element navTes = new NavisionManageTestateVendita.InserisciTestateVenditaITNET_element();
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
    
    public static NavisionManageRigheVendita.InserisciRigheVenditaITNET_element createRigaNav_ITNET(Riga_Fatturazione__c r){
        NavisionManageRigheVendita.InserisciRigheVenditaITNET_element navRow = new NavisionManageRigheVendita.InserisciRigheVenditaITNET_element();
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