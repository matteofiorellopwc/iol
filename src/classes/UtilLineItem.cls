public class UtilLineItem{
        
    public static void updatecalc(LineItem__c li,String fieldEdited,ControllerOptionalLineItem ControllerOptionalLineItem){
        UtilLineItem.updatecalc(li,fieldEdited,ControllerOptionalLineItem,null,null);
    }

    public static void updatecalc(LineItem__c li,String fieldEdited,ControllerOptionalLineItem ControllerOptionalLineItem, decimal maxTotale){
        UtilLineItem.updatecalc(li,fieldEdited,ControllerOptionalLineItem,null,maxTotale);
    }
    
    /*
        li.commissione_agenzia__c è l'unico campo formula facendo così posso usare questo metodo sia da trigger sia da controller senza aver inserito lineitem 
    */
    public static void updatecalc(LineItem__c li,String fieldEdited,ControllerOptionalLineItem ControllerOptionalLineItem,decimal commissioneAgenzia, decimal maxTotale){
    	
	        if(commissioneAgenzia == null){
	            commissioneAgenzia = li.commissione_agenzia__c;
	        }
	        if(commissioneAgenzia == null){
	            commissioneAgenzia = 0;
	        }
	        
	    
	        string sconto_netnet = 'sconto';
	        if(li.Ultima_modifica_prezzo__c == 'netnetprice'){
	            sconto_netnet = 'netnetprice';
	        }
	        if(li.Ultima_modifica_prezzo__c == 'sconto'){
	            sconto_netnet = 'sconto';
	        }
	        if(li.Ultima_modifica_prezzo__c == 'totale'){
	            sconto_netnet = 'totale';
	        }
	        if(fieldEdited == 'sconto' || fieldEdited == 'netnetprice' || fieldEdited == 'totale'){
	            sconto_netnet = fieldEdited;
	        }
	        
	    
	    
	        if(li.Start_Date__c == null || li.End_Date__c == null){
	            if(li.delivery_model__c !='CPC'){
	                li.Start_Date__c = date.today()+6;
	                li.End_Date__c = date.today()+7;
	            }  else {
	                Date firstDayOfMonth = date.today().toStartOfMonth();
	                Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month())-1);
	                li.Start_Date__c = date.today()+6;
	                li.End_Date__c = lastDayOfMonth;
	            }
	        }
	       
	         
	         if(li.start_date__c > li.end_date__c){
	            if(fieldEdited == 'enddate'){
	                li.start_date__c = li.end_date__c;
	            }else{
	                li.end_date__c = li.start_date__c;
	            }
	        }      
	        
	        boolean setGoal = (li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'NETWORK' || li.type_dfp__c == 'HOUSE') && li.delivery_model__c == 'CPD' && li.goal__c != null;
	        //per CPM e CPC metto direttamente il totale
	        
	        system.debug('li.Delivery_Model__c = '+li.Delivery_Model__c);
	
	        if(li.Totale__c == null){
	            li.Totale__c = 0;
	        }
	        if(li.quantita__c == null){
	                li.quantita__c = 0;
	        }
	        if(li.sconto__c == null){
	           li.sconto__c = 0; 
	        }
	        if(li.prezzo_net_net__c == null){
	           li.prezzo_net_net__c = 0; 
	        }        
	        system.debug('li.prezzo_net_net__c  = '+li.prezzo_net_net__c);
	        if(li.Prezzo_listino__c == null){
	           li.Prezzo_listino__c = 0;
	        }
	        if(fieldEdited != ''){
	            li.Ultima_modifica_prezzo__c = fieldEdited;
	        }
	        
	        if(li.Prezzo_listino__c == null){
	            li.Prezzo_listino__c = li.Prezzo_listino_prodotto__c;
	        }
	        
	        if(li.Impressions_unitarie_stimate__c == null){
	            li.Impressions_unitarie_stimate__c = 0;
	        }
	        
	        // System.debug('somma optionals: ' + li.Somma_optionals__c + ' ' + ControllerOptionalLineItem.calcSumOptionals() );
	        
	        if(ControllerOptionalLineItem != null){
	            li.Somma_optionals__c = ControllerOptionalLineItem.calcSumOptionals();
	        }else if(li.Somma_optionals__c == null){
	            li.Somma_optionals__c = 0;
	        }
	        
	        li.Prezzo_listino_optionals__c = li.Somma_optionals__c + li.Prezzo_listino__c;
	        system.debug('li.Prezzo_listino_optionals__c '+li.Prezzo_listino_optionals__c);
	        li.discount_type__c = 'PERCENTAGE';                    
	        
	        //if(fieldEdited == 'goal'){ 
	            li.goal_delivery__c = li.goal__c;
	        //}
	          
	       //li.Ultima_modifica_prezzo__c != 'totale' &&  -> adesso si può sempre modificare anche il totale  
	       if(
	          !((li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'NETWORK' || li.type_dfp__c == 'HOUSE') && li.delivery_model__c <> 'CPD') &&
	          !(li.type_dfp__c == 'ADSENSE' || li.type_dfp__c == 'AD_EXCHANGE') &&
	          !(li.ProductFamily__c == 'Search' || li.ProductFamily__c == 'Placeholder')
	       ){
	        
	            if(li.Delivery_Model__c == 'CPD'){
	                li.quantita__c = li.Start_Date__c.daysBetween(li.End_Date__c) + 1;
	                
	                if(li.CalcolaCPDconImpStimate__c){
	                    System.debug('TIPO TARIFFA!!! ' + li.tipoTariffa__c);
	
	                    if (li.TipoTariffa__c == 'Feriale') {   
	                        li.Impressions_unitarie_stimate__c = li.ImpressionsStimateFeriali__c == null ? 0 : li.ImpressionsStimateFeriali__c;
	
	                    }else if (li.TipoTariffa__c == 'Festiva') {
	                        li.Impressions_unitarie_stimate__c = li.ImpressionsStimateFestive__c == null ? 0 : li.ImpressionsStimateFestive__c;
	                    }else{
	                        li.Impressions_unitarie_stimate__c = 0;
	                    }
	                }
	                li.Impressions_stimate__c = li.quantita__c * li.Impressions_unitarie_stimate__c;
	                
	                if(li.fascia_oraria__c == '0 - 12' ){
	                    li.Impressions_stimate__c *= li.Fattore_correttivo_fascia_0_12__c != null ? li.Fattore_correttivo_fascia_0_12__c : 1;
	                }else if(li.fascia_oraria__c == '12 - 16'){
	                    li.Impressions_stimate__c *= li.Fattore_correttivo_fascia_12_16__c != null ? li.Fattore_correttivo_fascia_12_16__c : 1;
	                }else if(li.fascia_oraria__c == '16 - 24'){
	                    li.Impressions_stimate__c *= li.Fattore_correttivo_fascia_16_24__c  != null ? li.Fattore_correttivo_fascia_16_24__c : 1;
	                }else if(li.fascia_oraria__c == '0 - 16'){
	                    li.Impressions_stimate__c *= li.Fattore_correttivo_fascia_0_16__c  != null ? li.Fattore_correttivo_fascia_0_16__c : 1;
	                    system.debug('updatecalc fattore correttivo Fattore_correttivo_fascia_0_16__c '+li.Fattore_correttivo_fascia_0_16__c);
	                }else if(li.fascia_oraria__c == '12 - 24'){
	                    decimal fattore = 1;
	                    if(li.Fattore_correttivo_fascia_12_16__c != null && li.Fattore_correttivo_fascia_16_24__c != null){
	                        fattore = li.Fattore_correttivo_fascia_12_16__c+li.Fattore_correttivo_fascia_16_24__c;
	                    }
	                    li.Impressions_stimate__c *= fattore;
	                }
	                //se fascia == '0 - 24' non applico il fattore correttivo
	
	                if(setGoal){
	                    li.Impressions_stimate__c = li.Impressions_stimate__c*li.goal__c/100;
	                }
	            }
	            
	            /*AN-20140414*/
	            Integer multiplierTotal = 1;
	            if (li.Duration__c == 'DAILY' && li.Type_DFP__c == 'PRICE_PRIORITY') {
	                multiplierTotal = li.Start_Date__c.daysBetween(li.End_Date__c) + 1;
	                if(li.quantita_totale_DAILYCPC__c != null){
	                    li.Quantita__c = (li.Quantita_totale_DAILYCPC__c / multiplierTotal).setScale(0, RoundingMode.FLOOR);
	                }
	            }
	            /* if ((li.Duration__c == 'LIFETIME' || li.Duration__c == 'NONE')  && li.Type_DFP__c == 'PRICE_PRIORITY') {
	                if(li.quantita_totale_DAILYCPC__c != null){
	                    li.Quantita__c = li.Quantita_totale_DAILYCPC__c;
	                }
	            } */
	
	            if(sconto_netnet == 'totale'){
	                if(li.Quantita__c <= 0){
	                    li.quantita__c.addError('Inserire una quantità > 0');
	                    return;
	                }
	                //calcolo net net
	                if( (li.Delivery_Model__c == 'CPC') || (li.delivery_model__c == 'CPD' && !li.CalcolaCPDconImpStimate__c)){
	/*AN-20140414*/     li.prezzo_net_net__c = (li.totale__c / li.quantita__c) / multiplierTotal;
	                    if(setGoal){
	                        li.prezzo_net_net__c = li.prezzo_net_net__c / (li.goal__c/100);
	                    }
	                }else if(li.delivery_model__c == 'CPD' && li.CalcolaCPDconImpStimate__c){
	                    li.prezzo_net_net__c = li.totale__c / (li.Impressions_stimate__c/1000);
	                }else if(li.Delivery_Model__c == 'CPM'){
	                    if(li.Type_DFP__c != 'SPONSORSHIP'){
	                    	li.prezzo_net_net__c = li.totale__c / (li.quantita__c/1000);
	                    	system.debug('@@@@@asd ' + li.prezzo_net_net__c);
	                	} else {
	                		system.debug('@@@@@ ' + li.prezzo_net_net__c);
	                	} //se è un CPM SPONSORSHIP il campo Prezzo
	                }
	            }
	            
	            /*
	                Se ho cambiato la commissione sull'opportunità, tengo il net net e ricalcolo lo sconto
	            */
	            if(sconto_netnet == 'totale' || sconto_netnet == 'netnetprice' || OpportunityTriggerHandler.oppCommissioneChanged.contains(li.opportunity__c)){
	                li.prezzo_net__c = li.prezzo_net_net__c / (1-commissioneAgenzia/100);
	                if(li.Prezzo_listino_optionals__c != 0){
	                    li.sconto__c = (1 - li.prezzo_net__c / li.Prezzo_listino_optionals__c)*100;
	                }else{
	                    li.sconto__c = 0;
	                }
	            }
	            
	            if(sconto_netnet == 'sconto' && !OpportunityTriggerHandler.oppCommissioneChanged.contains(li.opportunity__c)){
	                li.prezzo_net__c = li.Prezzo_listino_optionals__c * (1-li.sconto__c/100);
	/*AN-20140414*/ li.prezzo_net_net__c = li.prezzo_net__c * (1-commissioneAgenzia/100);// * multiplierTotal;
					system.debug('@@@1');
	            }
	            
	            
	            li.sconto__c = li.sconto__c.setScale(2,ROUNDINGMODE.HALF_UP);
	            li.prezzo_net_net__c = li.prezzo_net_net__c.setScale(4,ROUNDINGMODE.HALF_UP);
	            
	            li.Quantita_calcolata__c = li.quantita__c;        
	
	            
	            /*AN-20140414*/
	            li.totale__c = sconto_netnet == 'totale' ? li.totale__c : li.quantita__c * li.prezzo_net_net__c * multiplierTotal;
	            if(li.Delivery_Model__c != 'CPD' && li.Delivery_Model__c != 'CPC'){
	                li.totale__c /= sconto_netnet == 'totale' ? 1 : 1000;
	                li.Quantita_calcolata__c /= 1000;
	            }
	
	            /*
	                Nel nuovo catalogo il prezzo sui prodotti CPD è per mille impressions.
	                Il totale sarà quindi calcolato come fosse un CPM usando le impressions stimate 
	            */
	            system.debug('li.CalcolaCPDconImpStimate__c = '+li.CalcolaCPDconImpStimate__c);            
	            if(li.Delivery_Model__c == 'CPD' && li.CalcolaCPDconImpStimate__c){
	                li.Totale__c = sconto_netnet == 'totale' ? li.totale__c : (li.Impressions_stimate__c * li.Prezzo_net_net__c) / 1000;
	                li.Quantita_calcolata__c = li.Impressions_stimate__c / 1000;
	            }else if(setGoal){
	                li.totale__c = sconto_netnet == 'totale' ? li.totale__c : li.totale__c*li.goal__c/100;
	                li.Quantita_calcolata__c = li.Quantita_calcolata__c*li.goal__c/100;
	            }
	            
	        }else if(!(li.Delivery_Model__c == 'CPM'&&li.Type_DFP__c == 'SPONSORSHIP')){
	            li.quantita__c = 1;
	            li.Quantita_calcolata__c = 1;
	            li.Prezzo_listino_optionals__c = 0;
	            li.sconto__c = 0;
	            li.prezzo_net__c = li.totale__c;
	            li.prezzo_net_net__c = li.totale__c; //se è CPM e SPONSORSHIP non voglio un ricalcolo sul prezzo	
	            
	        }else if((li.Delivery_Model__c == 'CPM'&&li.Type_DFP__c == 'SPONSORSHIP')){
	        	li.quantita__c = 1;
	            li.Quantita_calcolata__c = 1;
	            li.Prezzo_listino_optionals__c = li.prezzo_net_net__c;
	            li.sconto__c = 0;
	            li.prezzo_net__c = li.prezzo_net_net__c;	
	        }
	        li.totale__c = li.totale__c.setScale(2,ROUNDINGMODE.HALF_UP);
	        system.debug('li.totale__c = '+li.totale__c);
	        li.Ultima_modifica_prezzo__c = sconto_netnet;
	        
	        System.debug('Attenzione: il massimo ripianificabile '+maxTotale);
	        if(maxTotale != null && li.totale__c > maxTotale){
	          System.debug('Stampo errore massimo ripianificabile '+maxTotale);
	          li.totale__c.addError('Attenzione: Il massimo valore ripianificabile è € '+maxTotale);
	        }
    	
    }
    
    public static void updatePacchettoOpportunity(Pacchetto_Combo_Opportunity__c pco,List<lineitem__c> lis){
        pco.totale__c = 0;
        pco.Quantita_totale__c = 0;
        if(pco.sconto__c == null){
            pco.sconto__c = 0;
        }
        date inizio=null,fine=null;
        for(lineitem__c li : lis){
            if(li.start_date__c != null && (inizio==null || li.start_date__c < inizio)){
                inizio = li.start_date__c;
            }
            if(li.end_date__c != null && (fine==null || li.end_date__c > fine)){
                fine = li.end_date__c;
            }
            
            pco.totale__c += li.totale__c;
            if(li.delivery_model__c == 'CPD'){
                pco.Quantita_totale__c += li.impressions_stimate__c != null ? li.impressions_stimate__c : 0;
            }else{
                pco.Quantita_totale__c += li.quantita__c != null ? li.quantita__c : li.quantita__c;
            }
        }
        pco.data_inizio__c = inizio;
        pco.data_fine__c = fine;
    }
}