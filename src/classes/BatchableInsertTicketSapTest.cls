/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BatchableInsertTicketSapTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
    }

    public static ticket_fatturazione__c insertTicket(){
        Account a = new Account(
        recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Anagrafica di Fatturazione').getRecordTypeId(),
            name='test');
        insert a;        
        ticket_fatturazione__c tf = new ticket_fatturazione__c(Account__c=a.id);
        insert tf;
        Riga_Fatturazione__c rf = new Riga_Fatturazione__c(Ticket_Fatturazione__c=tf.id);
        insert rf;
        rf = new Riga_Fatturazione__c(Ticket_Fatturazione__c=tf.id);
        insert rf;
        Spaccato_Riga_Fatturazione__c srf = new Spaccato_Riga_Fatturazione__c(Riga_Fatturazione__c=rf.id);
        insert srf;
        
        return tf;
    }

    public static testMethod void testBatchableInsertTicketSap(){
        BasicAuthApplication__c cs = new BasicAuthApplication__c(name='Ticketing_Advertising',username__c='test',password__c='test',endpoint__c='test');
        insert cs;
        cs = new BasicAuthApplication__c(name='Ticketing_Apritisito',username__c='test',password__c='test',endpoint__c='test');
        insert cs; 
    
        ticket_fatturazione__c tf1 = insertTicket();
        ticket_fatturazione__c tf2 = insertTicket();
        tf2.Account__c = null;
        update tf2;
        ticket_fatturazione__c tf3 = insertTicket();
        tf3.Account__c = UtilTestApritisito.insertClienteTest('').id;
        update tf3;
        
        Test.startTest();        
        Database.ExecuteBatch(new BatchableInsertTicketSap(new list<id>{tf1.id,tf2.id,tf3.id}));
        Test.stopTest();        
    }
}