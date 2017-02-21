@IsTest
public class UtilityAdUnitInventoryTest {

	@IsTest
	public static void testGetAdUnitLineItem() {
		UtilityAdUnitInventory u = new UtilityAdUnitInventory();
		u.allAdUnitMap = new Map<id,AdUnit__c>{
								'a00000000000001' => getAdUnit('a00000000000001',null,false,'','ACTIVE','1'),
								'a00000000000002' => getAdUnit('a00000000000002','a00000000000001',false,'300x250','ACTIVE','2'),
								'a00000000000003' => getAdUnit('a00000000000003','a00000000000001',false,'300x250','ACTIVE','3'),
								'a00000000000004' => getAdUnit('a00000000000004','a00000000000002',false,'300x250','ACTIVE','4'),
								'a00000000000005' => getAdUnit('a00000000000005','a00000000000002',false,'300x250','ACTIVE','5'),
								'a00000000000006' => getAdUnit('a00000000000006','a00000000000005',false,'300x250','ACTIVE','6'),
								'a00000000000007' => getAdUnit('a00000000000007','a00000000000006',true,'300x250','ACTIVE','7')
							};
		u.dfpAdUnitMap = new Map<String,AdUnit__c>{
								'1' => u.allAdUnitMap.get('a00000000000001')	
							};
		u.adUnitTree = new Map<id,list<id>>{
								'a00000000000001' => new list<id>{'a00000000000002','a00000000000003'},
								'a00000000000002' => new list<id>{'a00000000000004','a00000000000005'},
								'a00000000000003' => new list<id>(),
								'a00000000000004' => new list<id>(),
								'a00000000000005' => new list<id>{'a00000000000006'},
								'a00000000000006' => new list<id>{'a00000000000007'},
								'a00000000000007' => new list<id>()
							};

		set<id> adunits = u.getAdUnitLineItem(new List<Inventory_Target__c>{
													getInventoryTarget('a07000000000001','a00000000000001','targeted')
											  },'300x250');
		
		list<id> adunitActual = new list<id>();
		adunitActual.addAll(adunits);
		adunitActual.sort();

		list<id> adunitsExpected = new list<id>{'a00000000000002','a00000000000003','a00000000000004','a00000000000005','a00000000000006'};
		System.assertEquals(adunitsExpected,adunitActual);

		adunits = u.getAdUnitLineItem(new List<PlacementTargeting__c>{
												new PlacementTargeting__c(
													Placement__r = new Placement__c(
														targetedAdUnitIds__c = '1'
													)
												)
										  },'300x250');
		 
		adunitActual = new list<id>();
		adunitActual.addAll(adunits);
		adunitActual.sort();

		System.assertEquals(adunitsExpected,adunitActual);


		adunits = u.getAdUnitLineItem(new List<Inventory_Target__c>{
												getInventoryTarget('a07000000000001','a00000000000002','targeted'),
												getInventoryTarget('a07000000000002','a00000000000005','exclued')
										  },'300x250');
		 
		adunitActual = new list<id>();
		adunitActual.addAll(adunits);
		adunitActual.sort();

		adunitsExpected = new list<id>{'a00000000000002','a00000000000004'};
		System.assertEquals(adunitsExpected,adunitActual);

	}

	@IsTest
	public static void getAdUnitLineItemOas(){
		utilityTest.insertDfpOasOpp();
		lineitem__c li = [select id from lineitem__c where ad_Server__c = 'OAS'];
		AdUnit__c adu = new AdUnit__c(name='test',pageoas__c='testexclude');
        insert adu;
        Inventory_target__c it = new Inventory_target__c(ad_unit__c=adu.id,lineitem__c=li.id, InventoryTargetingType__c ='targeted');
        insert it;
        
        li = [select Ad_Server__c,
					 (Select Ad_Unit__c,InventoryTargetingType__c,ad_unit__r.pageOas__c from Inventory_Target__r),
					 (Select SectionOas__r.Pages__c,SectionOas__c from SectionsOasTargeted__r)
			  from LineItem__c
			  where Id =: li.id
			 ];
        set<id> adunits = UtilityAdUnitInventory.getAdUnitLineItemOas(li);
	}

	private static AdUnit__c getAdunit(Id id,Id ParentAdUnit,Boolean explicitlyTargeted,String Sizes,String Status,String idDfp){
		return new AdUnit__c(
				Id = id,
				ParentAdUnit__c = ParentAdUnit,
				explicitlyTargeted__c = explicitlyTargeted,
				Sizes__c = Sizes,
				Status__c = Status,
				idDfp__c=idDfp
			);
	}

	private static Inventory_Target__c getInventoryTarget(Id id,Id Ad_Unit,String InventoryTargetingType){
		return new Inventory_Target__c(
				Id=id,
				Ad_Unit__c = Ad_Unit,
				InventoryTargetingType__c = InventoryTargetingType
			);
	}

	@IsTest
	public static void testGetEstimatePercentageAdUnit(){
		utilityTest.insertDfpOasOpp();
		lineitem__c li = [select opportunity__r.accountid,id,(select ad_unit__c from inventory_target__r) from lineitem__c where ad_Server__c = 'DFP'];
		

		set<id> adunit = new set<id>{li.inventory_target__r[0].ad_unit__c};

		asset a = new asset(Name='test',
							Impressions__c=1000,
							AdUnit__c= li.inventory_target__r[0].ad_unit__c,
							AccountId=li.opportunity__r.accountid,
							month__c=('0'+date.today().addmonths(-1).month()).right(2),
							adUnitView__c = 'FLAT',
							year__c=date.today().addmonths(-1).year()+'');
		insert a;
		date dataPrimoMese = date.today().addmonths(-1).toStartOfmonth();
		Map<id,decimal> estimatePercentage = UtilityAdUnitInventory.getEstimateImpressionAdUnit(adunit,dataPrimoMese);

		System.assertEquals(estimatePercentage.get(li.inventory_target__r[0].ad_unit__c),1000);
	}

	@IsTest
	public static void testGetDeliveredPercantageAdUnit(){
		utilityTest.insertDfpOasOpp();
		lineitem__c li = [select opportunity__r.accountid,product__c,id,(select ad_unit__c from inventory_target__r) from lineitem__c where ad_Server__c = 'DFP'];
		
		Id adunit1 = li.inventory_target__r[0].ad_unit__c;
		
		AdUnit__c adu2 = new AdUnit__c(name='test');
		insert adu2;

		Id adunit2 = adu2.id;

		asset a = new asset(Name='test',
							Impressions__c=1000,
							AdUnit__c=adunit1,
							line_item__c = li.id,
							product2Id=li.product__c,
							AccountId=li.opportunity__r.accountid,
							adUnitView__c = 'FLAT',
							day__c=date.today());
		insert a;
		a = a.clone();
		a.Adunit__c = adunit2;
		insert a;

		date dataPrimoMeseGiornaliero = date.today().toStartOfMonth();
		Map<id,decimal> estimatePercentage = UtilityAdUnitInventory.getDeliveredImpressionAdUnit(li.id,dataPrimoMeseGiornaliero);

		System.assertEquals(estimatePercentage.get(adunit1),1000);
		System.assertEquals(estimatePercentage.get(adunit2),1000);
	}
}