public class ControllerReportOppoWithRa {

    public date datainizio {get;set;}
    public date datafine {get;set;}
    
    public list<OpportunityWithRaClass> oppList {get;set;}
    
    public list<string> mesi {get;set;}

    public class OpportunityWithRaClass{
        public Opportunity opp {get;set;}
        public Map<string,decimal> raMap{get;set;}
        public OpportunityWithRaClass(Opportunity o){
            opp = o;
            raMap = new Map<string,double>{
                'Gennaio' => 0,
                'Febbraio' => 0,
                'Marzo' => 0,
                'Aprile' => 0,
                'Maggio' => 0,
                'Giugno' => 0,
                'Luglio' => 0,
                'Agosto' => 0,
                'Settembre' => 0,
                'Ottobre' => 0,
                'Novembre' => 0,
                'Dicembre' => 0
            };
        }
    }
    
    public ControllerReportOppoWithRa(){
        mesi = new list<string>{'Gennaio','Febbraio','Marzo','Aprile','Maggio','Giugno','Luglio','Agosto','Settembre','Ottobre','Novembre','Dicembre'};
        getRa();
    }
    
    public void getRa(){
        string ll = ApexPAges.currentPage().getParameters().get('limit');
        integer l = 1000;
        if(ll != null){
            l = Integer.valueOf(ll);
        }
        oppList = new list<OpportunityWithRaClass>();
        list<AggregateResult> raList = [select line_item__r.opportunity__c opp,mese__c mese,sum(valore__c) sum
                                               from revenue_application__c 
                                               where line_item__r.opportunity__r.isWon = true
                                               and anno_numero__c =: date.today().year()
                                               group by line_item__r.opportunity__c,mese__c
                                               Limit : l
                                              ];
        

        Map<id,list<AggregateResult>> aggregateMap = new Map<id,list<AggregateResult>>();
        set<id> oppsId = new set<id>();                                              

        for(AggregateResult ar : raList){
            id oppId = (id)ar.get('opp');
            if(! aggregateMap.keySet().contains(oppId)){
                oppsID.add(oppId);
                aggregateMap.put(oppId,new list<AggregateResult>());
            }
            aggregateMap.get(oppId).add(ar);
        }
        for(Opportunity o :[select id,name,account.name,account.settore__c,venditore__r.name,
                                                                     Agenzia_di_riferimento__r.name
                                                              from opportunity
                                                              where id in : oppsId
                                                              order by venditore__c
                                                            ]){
            OpportunityWithRaClass ora = new OpportunityWithRaClass(o);
            for(AggregateResult ar : aggregateMap.get(o.id)){
                ora.raMap.put((string) ar.get('mese'),(decimal) ar.get('sum'));
            }
            oppList.add(ora);
        }
    }

    public static testMethod void testControllerReportOppoWithRa(){
        ControllerReportOppoWithRa o = new ControllerReportOppoWithRa();
        o.getRa();        
    }


}