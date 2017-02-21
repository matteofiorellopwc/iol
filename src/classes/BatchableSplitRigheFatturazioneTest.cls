@isTest
private class BatchableSplitRigheFatturazioneTest {

	static void printLimits(String s){
		System.debug(s + ' --> ' + Limits.getQueries());
	}

	@isTest static void testSplitRigheFatturazioneErogato() {
		Date dataPrimoMesePrec = date.today().addMonths(-1).toStartOfMonth();
		LineItem__c li = initOppLineItem(dataPrimoMesePrec);
		Test.startTest(); //to avoid problems in soql limits
		Riga_Fatturazione__c rf = initTicket(li,dataPrimoMesePrec);
		li = initAdUnit(li);

		asset[] aa = new asset[]{ getAsset(li),getAsset(li) };
		aa[0].Impressions__c = 1000000;
		aa[0].AdUnit__c = li.inventory_target__r[0].Ad_Unit__c;
		aa[0].Day__c = dataPrimoMesePrec;

		aa[1].Impressions__c = 2000000;
		aa[1].AdUnit__c = li.inventory_target__r[1].Ad_Unit__c;
		aa[1].Day__c = dataPrimoMesePrec;		

		insert aa;

		Database.executeBatch(new BatchableSplitRigheFatturazione(new Riga_Fatturazione__c[]{ rf }),1);
		Test.stopTest();
		Spaccato_Riga_Fatturazione__c[] spList = [select Spaccato_prezzo_unitario__c from Spaccato_Riga_Fatturazione__c order by Brand__c];
		system.debug(spList);
		Decimal sp0 = (li.Totale__c/3).setScale(2,ROUNDINGMODE.HALF_UP);
		Decimal sp1 = (li.Totale__c*2/3).setScale(2,ROUNDINGMODE.HALF_UP);
		System.assertEquals(sp0,spList[0].Spaccato_prezzo_unitario__c);
		System.assertEquals(sp1,spList[1].Spaccato_prezzo_unitario__c);
	}

	@isTest static void testSplitRigheFatturazioneErogatoMeseRevenuePrecedente() {
		Date dataPrimoMesePrec = date.today().addMonths(-1).toStartOfMonth();
		LineItem__c li = initOppLineItem(dataPrimoMesePrec);
		Test.startTest(); //to avoid problems in soql limits
		Riga_Fatturazione__c rf = initTicket(li,dataPrimoMesePrec);
		li = initAdUnit(li);

		dataPrimoMesePrec = dataPrimoMesePrec.addMonths(-1);
		asset[] aa = new asset[]{ getAsset(li),getAsset(li),getAsset(li) };
		aa[0].Impressions__c = 1000000;
		aa[0].AdUnit__c = li.inventory_target__r[0].Ad_Unit__c;
		aa[0].month__c=('0'+dataPrimoMesePrec.month()).right(2); 
		aa[0].year__c=dataPrimoMesePrec.year()+'';

		aa[1].Impressions__c = 1000000;
		aa[1].AdUnit__c = li.inventory_target__r[1].Ad_Unit__c;
		aa[1].month__c=('0'+dataPrimoMesePrec.month()).right(2); 
		aa[1].year__c=dataPrimoMesePrec.year()+'';

		aa[2].Impressions__c = 1000000;
		aa[2].AdUnit__c = li.inventory_target__r[2].Ad_Unit__c;
		aa[2].month__c=('0'+dataPrimoMesePrec.month()).right(2); 
		aa[2].year__c=dataPrimoMesePrec.year()+'';

		insert aa;

		Database.executeBatch(new BatchableSplitRigheFatturazione(new Riga_Fatturazione__c[]{ rf }),1);
		Test.stopTest();
		Spaccato_Riga_Fatturazione__c[] spList = [select Spaccato_prezzo_unitario__c from Spaccato_Riga_Fatturazione__c order by Spaccato_prezzo_unitario__c];
		system.debug(spList);
		Decimal sp = (li.Totale__c/3).setScale(2,ROUNDINGMODE.HALF_UP);
		System.assertEquals(sp,spList[0].Spaccato_prezzo_unitario__c);
		System.assertEquals(sp,spList[1].Spaccato_prezzo_unitario__c);
		System.assertNotEquals(sp,spList[2].Spaccato_prezzo_unitario__c); //28.33 vs 28.34
		System.assertEquals(li.Totale__c,spList[0].Spaccato_prezzo_unitario__c+spList[1].Spaccato_prezzo_unitario__c+spList[2].Spaccato_prezzo_unitario__c);
	}
	
	@isTest static void testSplitRigheFatturazioneStimatoMeseRevenue() {
		Date dataPrimoMesePrec = date.today().addMonths(-1).toStartOfMonth();
		LineItem__c li = initOppLineItem(dataPrimoMesePrec);
		Test.startTest(); //to avoid problems in soql limits
		Riga_Fatturazione__c rf = initTicket(li,dataPrimoMesePrec);
		li = initAdUnit(li);

		asset[] aa = new asset[]{ getAsset(li),getAsset(li) };
		aa[0].Impressions__c = 2000000;
		aa[0].AdUnit__c = li.inventory_target__r[0].Ad_Unit__c;
		aa[0].month__c=('0'+dataPrimoMesePrec.month()).right(2); 
		aa[0].year__c=dataPrimoMesePrec.year()+'';

		aa[1].Impressions__c = 3000000;
		aa[1].AdUnit__c = li.inventory_target__r[1].Ad_Unit__c;
		aa[1].month__c=('0'+dataPrimoMesePrec.month()).right(2);
		aa[1].year__c=dataPrimoMesePrec.year()+'';

		insert aa;

		Database.executeBatch(new BatchableSplitRigheFatturazione(new Riga_Fatturazione__c[]{ rf }),1);
		Test.stopTest();
		Spaccato_Riga_Fatturazione__c[] spList = [select Spaccato_prezzo_unitario__c from Spaccato_Riga_Fatturazione__c order by Brand__c];
		system.debug(spList);
		Decimal sp0 = (li.Totale__c*2/5).setScale(2,ROUNDINGMODE.HALF_UP);
		Decimal sp1 = (li.Totale__c*3/5).setScale(2,ROUNDINGMODE.HALF_UP);
		System.assertEquals(sp0,spList[0].Spaccato_prezzo_unitario__c);
		System.assertEquals(sp1,spList[1].Spaccato_prezzo_unitario__c);
	}		

	@isTest static void testSplitRigheFatturazioneSenzaErogato() {
		Date dataPrimoMesePrec = date.today().addMonths(-1).toStartOfMonth();
		LineItem__c li = initOppLineItem(dataPrimoMesePrec);
		Test.startTest(); //to avoid problems in soql limits
		Riga_Fatturazione__c rf = initTicket(li,dataPrimoMesePrec);
		li = initAdUnit(li);

		Database.executeBatch(new BatchableSplitRigheFatturazione(new Riga_Fatturazione__c[]{ rf }),1);
		Test.stopTest();
		Spaccato_Riga_Fatturazione__c[] spList = [select Spaccato_prezzo_unitario__c from Spaccato_Riga_Fatturazione__c order by Spaccato_prezzo_unitario__c];
		system.debug(spList);
		Decimal sp = (li.Totale__c/3).setScale(2,ROUNDINGMODE.HALF_UP);

		System.assertEquals(sp,spList[0].Spaccato_prezzo_unitario__c);
		System.assertEquals(sp,spList[1].Spaccato_prezzo_unitario__c);
		System.assertNotEquals(sp,spList[2].Spaccato_prezzo_unitario__c);
		System.assertEquals(li.Totale__c,spList[0].Spaccato_prezzo_unitario__c+spList[1].Spaccato_prezzo_unitario__c+spList[2].Spaccato_prezzo_unitario__c);
	}	

	private static lineitem__c initOppLineItem(Date liDate){
		Opportunity o = utilityTest.insertDfpOasOpp();
		lineitem__c li = [select Quantita__c,Start_date__c,End_date__c,Opportunity__c
						  from lineitem__c 
						  where ad_Server__c = 'DFP'];
		li.Quantita__c = 1000000;
		li.Start_Date__c = liDate;
		li.End_Date__c = liDate;
		LineItemTriggerHandler.skipValidationAdServer = true;
		update li;

		li = [select id,Quantita__c,Totale__c,opportunity__r.accountid,product__c,
					(select ad_unit__c from inventory_target__r),
					(select id from revenue_applications__r)
				from lineitem__c 
			  	where ad_Server__c = 'DFP'
			 ];	
		return li;
	}

	private static Riga_Fatturazione__c initTicket(LineItem__c li,Date d){
		Ticket_Fatturazione__c tf = new Ticket_Fatturazione__c(Opportunity__c=li.Opportunity__c);
		tf.Anno_riferimento__c = d.year()+'';
		tf.Mese_riferimento__c = UtilityDataValue.getMonthFromDate(d);
		insert tf;

		Riga_Fatturazione__c rf = new Riga_Fatturazione__c(Ticket_Fatturazione__c=tf.id,line_item__c=li.id,Prezzo_unitario__c=li.Totale__c);
		insert rf;

		Revenue_application__c ra = new Revenue_application__c(
			line_item__c=li.id,
			mese__c = UtilityDataValue.getMonthFromDate(d),
			anno__c = d.year()+'',
			Riga_Fatturazione__c = rf.id,
			Ticket_Fatturazione__c = tf.id,
			valore__c = li.Totale__c
		);

		insert ra;

		return rf;
	}

	private static LineItem__c initAdUnit(LineItem__c li){
		AdUnit__c adu = new AdUnit__c(
								Id = li.inventory_target__r[0].ad_unit__c,
								Area_editoriale__c = 'test',
								Brand__c = 'test',
								Delivery_Channel__c = 'test',
								Sizes__c = '300x250',
								Status__c = 'ACTIVE'
							);
		update adu;
		AdUnit__c adu2 = new AdUnit__c(
								Name='test2',
								Area_editoriale__c = 'test2',
								Brand__c = 'test2',
								Delivery_Channel__c = 'test2',
								Sizes__c = '300x250',
								Status__c = 'ACTIVE'
							);
		AdUnit__c adu3 = new AdUnit__c(
								Name='test3',
								Area_editoriale__c = 'test3',
								Brand__c = 'test3',
								Delivery_Channel__c = 'test3',
								Sizes__c = '300x250',
								Status__c = 'ACTIVE'
							);
		insert (new list<adunit__c>{adu2,adu3});	
		inventory_target__c iv2 = new Inventory_target__c(
								LineItem__c = li.id,
								Ad_Unit__c = adu2.id,
								InventoryTargetingType__c='targeted'
							);
		inventory_target__c iv3 = new Inventory_target__c(
								LineItem__c = li.id,
								Ad_Unit__c = adu3.id,
								InventoryTargetingType__c='targeted'
							);		
		insert new list<Inventory_target__c>{iv2,iv3};

		return  [select id,Quantita__c,Totale__c,opportunity__r.accountid,product__c,
					(select ad_unit__c from inventory_target__r  order by ad_unit__r.Brand__c),
					(select id from revenue_applications__r)
				from lineitem__c 
			  	where ad_Server__c = 'DFP'
		];	
	}

	private static Asset getAsset(LineItem__c li){
		return new Asset(
					Name='test',
					line_item__c = li.id,
					product2Id=li.product__c,
					AccountId=li.opportunity__r.accountid,
					adUnitView__c = 'FLAT'
				);
	}
}