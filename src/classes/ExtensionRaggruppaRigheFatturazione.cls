public with sharing class ExtensionRaggruppaRigheFatturazione {
    
    public Riga_Fatturazione__c[] rows {get;set;}
    public Riga_Fatturazione__c rowGroup {get;set;}
    ApexPages.StandardSetController controller;

    Id ticket;
    
    public ExtensionRaggruppaRigheFatturazione(ApexPages.StandardSetController controller) {
        this.controller = controller;
        rows = (Riga_Fatturazione__c[]) controller.getSelected();

        if(!rows.isEmpty()){
            ticket = rows[0].Ticket_fatturazione__c;
        }

        Set<Decimal> numbersSet = new Set<Decimal>();
        Decimal maxIndex = 1;

        for(Riga_Fatturazione__c r : [Select Numero_Riga__c from Riga_Fatturazione__c where Ticket_Fatturazione__c =: ticket and id not in : rows]){
            numbersSet.add(r.Numero_Riga__c);
            if(r.Numero_Riga__c > maxIndex){
                maxIndex = r.Numero_Riga__c;
            }
        }

        decimal minIndex;
        for(integer i=1;i<maxIndex+2;i++){
            if(!numbersSet.contains(i)){
                minIndex = i;
                break;
            }
        }

        rowGroup = new Riga_fatturazione__c(Numero_Riga__c=minIndex);
    }

    public PageReference customSave(){
        for(Riga_Fatturazione__c r : rows){
            r.Descrizione__c = rowGroup.Descrizione__c;
            r.Start_date__c = rowGroup.Start_date__c;
            r.End_date__c = rowGroup.End_date__c;
            //CLAUDIO 05/07/2016 B
            // Numero_Riga is not used to aggregate rows anymore. 'Raggruppamento' is used instead.
            //r.Numero_Riga__c = rowGroup.Numero_Riga__c;
            r.Nascondi_date_competenza__c = rowGroup.Nascondi_date_competenza__c;
            r.Raggruppamento__c = string.valueof(rowGroup.Numero_Riga__c);
            //E
        }
        update rows;
        return new PageReference('/'+ticket);
    }
    

/*    
    public void sort(){
        Riga_Fatturazione__c[] sortedRows = new Riga_Fatturazione__c[]{};
        Decimal[] numbers = new decimal[]{};
        map<decimal,Riga_Fatturazione__c[]> rowsMap = new map<decimal,Riga_Fatturazione__c[]>();
        for(Riga_Fatturazione__c r : rows){
            if(r.Numero_Riga__c != null){
                if(rowsMap.get(r.Numero_Riga__c) == null ){
                    rowsMap.put(r.Numero_Riga__c,new Riga_Fatturazione__c[]{});
                    numbers.add(r.Numero_Riga__c);                    
                }
                rowsMap.get(r.Numero_Riga__c).add(r);

            }else{
                sortedRows.add(r);
            }
        }
        numbers.sort();
        for(decimal i : numbers){
            for(Riga_Fatturazione__c r : rowsMap.get(i)){
                sortedRows.add(r);
            }
        }
        
        rows = sortedRows;
    }
*/    
}