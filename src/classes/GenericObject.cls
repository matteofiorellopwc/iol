public virtual class GenericObject {
	private String type ;
	private System.LoggingLevel loglvl=System.LoggingLevel.DEBUG;

	public GenericObject(Object o ) {
		type=String.valueOf(o).substringBefore(':');
	}

	public void setLvl(System.LoggingLevel l){
		loglvl=l;

	}

	public void logDebug(Object msg ){
		String m=type+' : '+(String)String.valueOf(msg);
		system.debug(loglvl,m);
	}

}