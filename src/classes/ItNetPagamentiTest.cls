@isTest
public class ItNetPagamentiTest {       
    
    @isTest
    static void testCreaPagamenti() {
        Account a = UtilTestApritisito.insertClienteTest('Temp');
        
        PagamentoAria__c result = ItNetPagamenti.creaPagamento(new Map<String,String>{
            'accountId' => a.Id,
            'importo' => '100',
            'cod' => '0',
            'desc' => 'desc',
            'order_no' => '1',
            'proc_payment_id' => 'ppId',
            'transaction_id' => 'tId',
            'type_payment' => 'Paypal',
            'invoice_no' => '1',
            'type_credit_card' => 'Visa'             
        });
        
        System.assertEquals(100, result.Importo__c);
        System.assertEquals(1, result.NumeroSuccessi__c);
        
        TransazioneAria__c t = [SELECT INVOICE_NO__c, TYPE_CREDIT_CARD__c FROM TransazioneAria__c WHERE PagamentoAria__c = :result.Id LIMIT 1];
        System.assertEquals(t.INVOICE_NO__c, '1');
        System.assertEquals(t.TYPE_CREDIT_CARD__c, 'Visa');       
    }
    
    @isTest
    public static void testGeneraPagamenti() {
        Test.startTest();
        
        //Creo un listino con 10 prodotti full, condizione di fatturazione anticipata e 1 elemento contrattuale a prodotto
        Product2[] pL = UtilTestApritisito.insertProdottiItNet(10);
        Listino__c l = UtilTestApritisito.insertListino();
        RigaListino__c[] rlL = UtilTestApritisito.insertRigheListino(l, pL);
        CondizioneDiFatturazione__c cdf = UtilTestApritisito.insertCondizioneDiFatturazione();
        RigaListinoElementoContrattuale__c[] ecL = UtilTestApritisito.insertElementiContrattuali(rlL, cdf);

        //Creo un codiceIVA attivo e lo applico ai prodotti
        CodiceIVA__c ci = UtilTestApritisito.insertCodiceIva('21', 21);
        Storico_IVA__c[] siL = UtilTestApritisito.insertStoriciIva(ci, pL);     

        //Creo un account con un contratto/sottocontratto contenente i 10 prodotti appena creati
        Account a = UtilTestApritisito.insertClienteTest(null);
        Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
        
        //All'inserimento dei prodottisottocontratto un trigger dovrebbe collegarli automaticamente alle righe listino
        //e dovrebbe inserire le righe sottocontratto clonandole dagli elementi contrattuali. Mi aspetto data di prossimo
        //billing = oggi in quanto le condizioni di fatturazione sono "pagamento anticipato"
        ProdottoSottoContratto__c[] pscL = UtilTestApritisito.insertProdottiSottoContratto(sc, pL);
        
        //Controllo il corretto funzionamento del trigger
        System.assertEquals(10, ([SELECT Id FROM RigaSottoContratto__c]).size());       
        
        //Genero gli importi. Essendo la condizione di fatturazione anticipata, mi aspetto che venga creato un importo per
        //ogni riga sotto contratto, con data di fatturazione = oggi
        ItNetPagamenti.generaImportiRigheSottoContratto(Date.today());
        
        //Controllo
        System.assertEquals(10, ([SELECT Id FROM ImportoRigaSottoContratto__c]).size());
        
        //Controllo alcuni campi
        ImportoRigaSottoContratto__c irsc = [SELECT Id, Aliquota_iva__c, Codice_IVA__c, Start_date__c, End_date__c FROM ImportoRigaSottoContratto__c LIMIT 1];
        System.assertEquals(irsc.Codice_IVA__c, '21');
        //System.assertEquals(irsc.Start_date__c, Date.today().addDays(-10));
        
        
        //Genero i pagamenti
        PagamentoAria__c[] res = ItNetPagamenti.generaPagamenti(Date.today());
        System.assertEquals(1, res.size());
        //L'importo totale dovrebbe essere uguale a 100*12(il periodo degli elementi contrattuali è 1 anno e l'importo è 100)
        //incrementato dell'aliquota (21%) per 10 (ci sono 10 prodotti nel sottocontratto) 
        System.assertEquals(10 * 100 * 12 * 1.21, res[0].Importo__c);       
        
        //Testo il batch di invio pagamenti
        Database.executeBatch(new BatchableInviaPagamenti(res), 1);
        
        Test.stopTest();
    }
}