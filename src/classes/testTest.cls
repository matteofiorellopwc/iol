@isTest
public class testTest{

    public static testMethod void test(){
        Account a = new Account(Name = 'xxx');
        insert a;
        System.assertEquals('xxx', [SELECT Name FROM Account WHERE Id = :a.Id].Name);
        
        Savepoint sp = Database.setSavepoint();
        
        a.name = 'test';
        update a;
        System.assertEquals('test', [SELECT Name FROM Account WHERE Id = :a.Id].Name);
        
        Database.rollback(sp);
        
        System.assertEquals('xxx', [SELECT Name FROM Account WHERE Id = :a.Id].Name);
        System.assertEquals('test',a.name);
    }

}