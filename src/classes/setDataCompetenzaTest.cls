@isTest
private class setDataCompetenzaTest {

    @isTest 
    static void myUnitTest() {
        Product2[] pL = UtilTestApritisito.insertProdottiItNet(10);
        Listino__c l = UtilTestApritisito.insertListino();
        RigaListino__c[] rlL = UtilTestApritisito.insertRigheListino(l, pL);
        CondizioneDiFatturazione__c cdf = UtilTestApritisito.insertCondizioneDiFatturazione();
        RigaListinoElementoContrattuale__c[] ecL = UtilTestApritisito.insertElementiContrattuali(rlL, cdf);
        CodiceIVA__c ci = UtilTestApritisito.insertCodiceIva('21', 21);
        Storico_IVA__c[] siL = UtilTestApritisito.insertStoriciIva(ci, pL);     
        Account a = UtilTestApritisito.insertClienteTest(null);
        Contratto__c c = UtilTestApritisito.insertContrattoTest(a);
        SottoContratto__c sc = UtilTestApritisito.insertSottoContratto(c);
        ProdottoSottoContratto__c[] pscL = UtilTestApritisito.insertProdottiSottoContratto(sc, pL);
        
        //Crea la condizione di fatturazione Annuale Anticipata
        CondizioneDiFatturazione__c cdfAnnualeAnticipata = new CondizioneDiFatturazione__c(
            Name = 'Annuale anticipata',
            Numero_unita_periodo__c = 1,
            Unita_di_misura_periodo__c = 'Anno',
            Tipo__c = 'Anticipata'
        );
        insert cdfAnnualeAnticipata;
        
        //Crea la condizione di fatturazione Mensile Posticipata
        CondizioneDiFatturazione__c cdfMensilePosticipata = new CondizioneDiFatturazione__c(
            Name = 'Mensile posticipata',
            Numero_unita_periodo__c = 1,
            Unita_di_misura_periodo__c = 'Mese',
            Tipo__c = 'Posticipata'
        );
        insert cdfMensilePosticipata;
        
        //Crea la condizione di fatturazione Una Tantum
        CondizioneDiFatturazione__c cdfUnaTantum = new CondizioneDiFatturazione__c(
            Name = 'Una Tantum',
            Numero_unita_periodo__c = 1,
            Unita_di_misura_periodo__c = 'Una tantum',
            Tipo__c = 'Anticipata'
        );
        insert cdfUnaTantum;
        
        //Seleziona una riga sotto contratto
        RigaSottoContratto__c rsc = [SELECT Name, Condizione_di_fatturazione__c, Data_prossimo_billing__c,
                                            Ultima_data_non_vuota__c
                                     FROM RigaSottoContratto__c LIMIT 1];        
        //Controlla con condizione Annuale anticipata        
        rsc.Condizione_di_fatturazione__c = cdfAnnualeAnticipata.Id;
        update rsc;
        ImportoRigaSottoContratto__c irscAnnualeAnticipata = new ImportoRigaSottoContratto__c(
                RigaSottoContratto__c = rsc.Id,
                Aliquota_iva__c = 20,
                Importo_netto_iva__c = 100
        );
        insert irscAnnualeAnticipata;
        ImportoRigaSottoContratto__c irscAA = [SELECT DataBilling__c, Start_date__c, End_date__c FROM ImportoRigaSottoContratto__c WHERE Id =: irscAnnualeAnticipata.Id];
        System.assertEquals(irscAA.End_date__c, irscAA.DataBilling__c.addMonths(12).addDays(-1));
        System.assertEquals(irscAA.Start_date__c, irscAA.DataBilling__c);
        
        //Controlla con condizione Mensile posticipata        
        rsc.Condizione_di_fatturazione__c = cdfMensilePosticipata.Id;
        update rsc;
        ImportoRigaSottoContratto__c irscMensilePosticipata = new ImportoRigaSottoContratto__c(
                RigaSottoContratto__c = rsc.Id,
                Aliquota_iva__c = 20,
                Importo_netto_iva__c = 100
        );
        
        rsc = [SELECT Name, Condizione_di_fatturazione__c, Data_prossimo_billing__c,Condizione_di_fatturazione__r.Numero_mesi__c,
                                            Ultima_data_non_vuota__c
                                     FROM RigaSottoContratto__c LIMIT 1];
        system.debug(rsc.Condizione_di_fatturazione__r.Numero_mesi__c);
        system.debug(rsc.Ultima_data_non_vuota__c);
        
        /*
        insert irscMensilePosticipata;
        ImportoRigaSottoContratto__c irscMP = [SELECT DataBilling__c, Start_date__c, End_date__c FROM ImportoRigaSottoContratto__c WHERE Id =: irscMensilePosticipata.Id];
        System.assertEquals(irscMP.Start_date__c, irscMP.DataBilling__c.addMonths(-1).addDays(1));
        System.assertEquals(irscMP.End_date__c, irscMP.DataBilling__c);
        */
        
        //Controlla con condizione Una Tantum
        rsc.Condizione_di_fatturazione__c = cdfUnaTantum.Id;
        update rsc;
        ImportoRigaSottoContratto__c irscUnaTantum = new ImportoRigaSottoContratto__c(
                RigaSottoContratto__c = rsc.Id,
                Aliquota_iva__c = 20,
                Importo_netto_iva__c = 100
        );
        insert irscUnaTantum;
        ImportoRigaSottoContratto__c irscUnaTantumUT = [SELECT DataBilling__c, Start_date__c, End_date__c FROM ImportoRigaSottoContratto__c WHERE Id =: irscUnaTantum.Id];
        System.assertEquals(irscUnaTantumUT.End_date__c, irscUnaTantumUT.DataBilling__c);
        System.assertEquals(irscUnaTantumUT.End_date__c, irscUnaTantumUT.DataBilling__c);
        
    }
}