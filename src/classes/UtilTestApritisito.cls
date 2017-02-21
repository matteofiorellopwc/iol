@isTest
public class UtilTestApritisito{

    public static Account insertClienteTest(String stato){
        Account a = new Account(
            Tipo_anagrafica__c = 'Fisica',
            Codice_fiscale__c = 'TRMHDS21C32C234K',
            Nome_persona_fisica__c = 'Nome',
            Cognome_persona_fisica__c = 'Cognome',
            Stato__c = stato != null ? stato : 'Attivo',
            Phone = '0343212121',
            Email_principale__c = 'test@test.com',
            Chiave_per_legame_accesso_esterni__c = 'key',
            RecordTypeId = UtilItNet.itNetAccountRecordTypeId,
            BillingPostalCode = '1234',
            BillingStreet = 'test',
            BillingCity = 'test',
            BillingState = 'test',
            BillingCountry = 'test',
            luogo_di_nascita__c = 'test',
            Lingua_Documenti__c = 'ITA',
            Account_Accesso__c = '12345'
        );
        insert a;
        return a;
    }

    public static CodiceIva__c insertCodiceIva(String name, Decimal aliquota) {
        CodiceIva__c ci = new CodiceIVA__c(
            Name = name,
            Aliquota__c = aliquota
        );
        insert ci;
        return ci;
    }

    public static Storico_IVA__c[] insertStoriciIva(CodiceIva__c ci, Product2[] pL) {
        Storico_IVA__c[] res = new Storico_IVA__c[]{};
        
        for(Product2 p : pL) {
            res.add(new Storico_IVA__c(
                Codice_IVA__c = ci.Name,
                Data_inizio_validita__c = Date.today().addDays(-10),
                Product__c = p.Id   
            )); 
        }   
        insert res;
        return res;
    }
    
    public static Product2[] insertProdottiItNet(Integer numProdotti){
        return insertProdottiItNet(numProdotti, null);
    }
    
    public static Product2[] insertProdottiItNet(Integer numProdotti, Map<String, Object> additionalProperties){
        Product2[] res = new Product2[]{};
        for(Integer i = 0; i < numProdotti; i++) {
            Product2 p = new Product2(
                recordTypeId = UtilItNet.itNetProductRecordTypeId,
                Name = 'Apritisito Test ' + numProdotti,
                IsActive = true,                
                NumeroMassimoTentativi__c = 3
            );
            if(additionalProperties != null) {
                for(String prop : additionalProperties.keySet()) {
                    p.put(prop, additionalProperties.get(prop));
                }
            }
            res.add(p);
        }
        insert res;
        return res;
    }

    public static Listino__c insertListino(){
        Listino__c l = new Listino__c(
            Canale_di_vendita__c = 'Ecommerce',
            Data_inizio_validita__c = date.today().addDays(-1),
            Metodo_di_pagamento__c = 'BON',
            Termini_di_pagamento__c = '60DF'
        );
        insert l;
        return l;
    }
        
    public static RigaListino__c[] insertRigheListino(Listino__c l, Product2[] prodotti) {
        RigaListino__c[] res = new RigaListino__c[]{};
        for(Product2 p : prodotti) {
            res.add(new RigaListino__c(
                Data_inizio_validita__c = Date.today().addDays(-10),
                Data_fine_validita__c = Date.today().addDays(10),
                Listino__c = l.Id,
                Product__c = p.Id,
                Numero_unita_di_misura_periodo__c = 1,
                Unita_di_misura_periodo__c = 'Anno'         
            )); 
        }
        insert res;
        return res;
    }

    public static RigaListinoElementoContrattuale__c[] insertElementiContrattuali(RigaListino__c[] rlL, CondizioneDiFatturazione__c cdf) {
        RigaListinoElementoContrattuale__c[] res = new RigaListinoElementoContrattuale__c[]{};
        for(RigaListino__c rl : rlL) {
            res.add(new RigaListinoElementoContrattuale__c(
                Elemento_Contrattuale__c = 'Canone Servizio',
                Periodico__c = 'Si',
                Prezzo_esente_IVA__c = 100,
                Numero_unita_di_misura_periodo__c = 1,
                Riga_Listino__c = rl.Id,
                Condizione_Di_Fatturazione__c = cdf.Id
            ));
        }
        insert res;
        return res;
    }
    
    public static CondizioneDiFatturazione__c insertCondizioneDiFatturazione() {
        CondizioneDiFatturazione__c c = new CondizioneDiFatturazione__c(
            Numero_unita_periodo__c = 12,
            Unita_di_misura_periodo__c = 'Anno',
            Tipo__c = 'Anticipata'
        );  
        insert c;
        return c;
    }
    
    public static Contratto__c insertContrattoTest(Account a){
        Contratto__c c = new Contratto__c(
            Cliente__c = a.id,
            Data_Attivazione__c = date.today(),
            Chiave_Univoca_Aria__c = 'test',
            Descrizione__c = 'test',
            Canale_di_vendita__c = 'Ecommerce'
        );
        insert c;        
        return c;
    }
    
    public static SottoContratto__c insertSottoContratto(Contratto__c c){
        SottoContratto__c sc = new SottoContratto__c(
            Contratto__c = c.id
        );
        insert sc;
        return sc;
    }
    
    public static ProdottoSottoContratto__c[] insertProdottiSottoContratto(SottoContratto__c sc,Product2[] pL){       
        ProdottoSottoContratto__c[] res = new ProdottoSottoContratto__c[]{};
        for(Product2 p : pL) {
            res.add(new ProdottoSottoContratto__c(
                SottoContratto__c = sc.id,
                Prodotto__c = p.id,
                Descrizione__c = 'test',
                Quantita__c = 1,
                Data_decorrenza__c = date.today(),
                Data_chiusura__c = date.today().addDays(3)
            ));
        }
        insert res;
        return res;
    }
    
}