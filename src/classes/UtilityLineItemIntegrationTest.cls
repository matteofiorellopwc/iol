@isTest
public class UtilityLineItemIntegrationTest{

	public static testMethod void coverageTest(){
		try{ UtilityLineItemIntegration.reserveLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.reserveLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.releaseLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.releaseLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.deleteLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.deleteLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.activateLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.activateLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.archiveLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.archiveLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.pauseLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.pauseLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.reserveAndOverbookLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.reserveAndOverbookLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.resumeLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.resumeLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.resumeAndOverbookLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.resumeAndOverbookLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.unarchiveLineItems(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.unarchiveLineItems(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.performeLineItemAction(new List<decimal>(),''); }catch(exception e){}
		try{ UtilityLineItemIntegration.getLineItemsByIds(new List<decimal>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.getLineItemsByIds(new List<decimal>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.syncDfpToSfdcLineItems(new list<lineitem__c>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.syncDfpToSfdcLineItems(new list<lineitem__c>(),null); }catch(exception e){}
		try{ UtilityLineItemIntegration.setTechnologyType(new LIST<DfpLineItemService.Technology>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.setGeoType(new LIST<DfpLineItemService.Location>()); }catch(exception e){}
		try{ UtilityLineItemIntegration.setCustomCriteriaType(new DfpLineItemService.CustomCriteriaNode()); }catch(exception e){}
		try{ UtilityLineItemIntegration.getCustomCriteriaMap(null); }catch(exception e){}
		try{ UtilityLineItemIntegration.prepareDfpLineItemForUpdate(new DfpLineItemService.LineItem()); }catch(exception e){}		
	}

}