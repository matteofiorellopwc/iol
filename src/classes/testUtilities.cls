@isTest
public class testUtilities{

    public static testMethod void testUtilityAdUnit(){
        UtilityAdUnit uau = new UtilityAdUnit();
        uau.syncAllAdunit();
    }

    public static testMethod void testUtilityCustomTargeting(){
        UtilityCustomTargeting uct = new UtilityCustomTargeting();
        uct.syncAllCustomTargeting();
    }
    
    public static testMethod void testUtilityLabel(){
        UtilityLabel ul = new UtilityLabel();
        ul.syncAllLabel();
    }    
    
    public static testMethod void testUtilityPlacement(){
        UtilityPlacement up = new UtilityPlacement();
        up.syncAllPlacement();
    }    
    
    public static testMethod void testUtilityTeam(){
        UtilityTeam ut = new UtilityTeam();
        ut.syncAllTeam();
    }
    
   
    
    public static testMethod void testUtilityDataValue(){
        Date d = date.newinstance(2012, 1, 1);
        DateTime dt = datetime.newInstance(2010, 1, 1, 0, 0, 0);
        UtilityDataValue.getLineItemTimeOfDay('0','0');
        UtilityDataValue.getLineItemDateTime(d,0,0,0);
        UtilityDataValue.getLineItemDateTime(dt);
        UtilityDataValue.getLineItemDateTime(2010, 1, 1, 0, 0, 0);
        UtilityDataValue.getLineItemMoney(1000);
        UtilityDataValue.getInventoryDateTime(d,0,0,0);
        UtilityDataValue.getInventoryDateTime(dt);
        UtilityDataValue.getInventoryDateTime(2010, 1, 1, 0, 0, 0);
        UtilityDataValue.getForecastTimeOfDay('0','0');
        UtilityDataValue.getForecastMoney(1000);
        UtilityDataValue.getForecastDateTime(d,0,0,0);
        UtilityDataValue.getForecastDateTime(dt);
        UtilityDataValue.getForecastDateTime(2010, 1, 1, 0, 0, 0);
        UtilityDataValue.getReportDateTime(d,0,0,0);
        UtilityDataValue.getReportDateTime(dt);
        UtilityDataValue.getReportDateTime(2010, 1, 1, 0, 0, 0);
        UtilityDataValue.getReportDate(2010, 1, 1);
    }


    public static testMethod void testBatch() {
        Test.startTest();
        Database.executeBatch(new BatchableUpdateDfpDataModel(1), 1);
        Test.stopTest();
    }


}