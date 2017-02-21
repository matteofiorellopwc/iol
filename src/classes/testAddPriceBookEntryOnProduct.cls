public class testAddPriceBookEntryOnProduct{

    @isTest(seeAllData=true)
    public static void insertNewProduct(){
        list<product2> pList = new list<product2>();
    
        Product2 p = new Product2(name = 'test prod');
        insert p;
        
        pList.add(p);
        
        ProductTriggerHandler.addPriceBookEntry(pList);
        list<priceBookEntry> pbes = [select id from priceBookEntry where priceBook2.isStandard = true and product2id =: p.id];
        system.assertEquals(1,pbes.size());
        
        p = new Product2(name = 'test prod 2');
        pList.add(p);
        
        upsert pList;
    }
    
    //test catching exception in trigger
    public static testMethod void insertNewProductNoStandardPB(){
        Product2 p = new Product2(name = 'test prod');
        insert p;    
    }
}