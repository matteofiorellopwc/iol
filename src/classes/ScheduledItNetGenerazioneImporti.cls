global class ScheduledItNetGenerazioneImporti implements System.Schedulable {
		
	global void execute(System.SchedulableContext SC) {
		faiTutto(Date.Today());										
	}
	
	public void faiTutto(Date dataDiRiferimento) {
		System.SavePoint sp = Database.setSavePoint();
		try {
			ItNetPagamenti.generaImportiRigheSottoContratto(dataDiRiferimento);
			ItNetPagamenti.generaPagamenti(dataDiRiferimento);
			Database.executeBatch(new BatchableInviaPagamenti(), 10);
		} catch(Exception e) {
			Database.rollback(sp);
			String errorMsg = UtilExceptionIntegration.getExceptionMessage(e);
			UtilExceptionIntegration.sendEmailToCustomEmailLog('Error in ScheduledItNetGenerazioneImporti',errorMsg,'ApritiSitoLog');			
		}
	}
}