public class OpportunityTriggerHandler{
    private static GenericObject mylogger= new GenericObject(new OpportunityTriggerHandler());
    /*
        Data una lista di opportunità, ritorna una mappa con id opportunità -> lista degli utenti correlati:
        - owner opportunità
        - owner brand
        - owner centro media
        - utenti dell'agenzia territoriale
    */
    public static map<id,set<id>> getUsersRelatedToOpportunities(list<opportunity> opportunities){
        map<id,set<id>> userMap = new map<id,set<id>>(); //id opp -> list user id
        map<String,set<id>> agenzie = new map<string,set<id>>(); //nome gruppo agenzia -> set opp id
 
        for(Opportunity o : opportunities) {
            userMap.put(o.id,new set<id>());

            userMap.get(o.id).add(o.OwnerId); //Owner opportunità
            
            if(!String.isBlank(o.OwnerAccountId__c)){
                userMap.get(o.id).add(o.OwnerAccountId__c); //Owner diretta                    
            }
                    
            if(!String.isBlank(o.OwnerCentroMediaId__c)){
                userMap.get(o.id).add(o.OwnerCentroMediaId__c); //Owner centro media                
            }
            
            if(!String.isBlank(o.Agenzia_di_riferimento__c)) {
                if(agenzie.get(o.Nome_gruppo_agenzia__c) == null){
                    agenzie.put(o.Nome_gruppo_agenzia__c, new set<id>());
                }
                agenzie.get(o.Nome_gruppo_agenzia__c).add(o.id); //DelevoperName dell'agenzia (gruppo) associata
            }


        } 
        
        //Add agency users who are associated with opportunity
        for(Group g : [SELECT DeveloperName, (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName IN : agenzie.keySet()]) {
            for(GroupMember gm : g.GroupMembers) {
                //Check if Id is a User Id
                if(gm.UserOrGroupId.getSobjectType().getDescribe().getName().equals('User')) {   
                    for(id oppid : agenzie.get(g.developername)){
                        userMap.get(oppId).add(gm.UserOrGroupId);
                    }
                    mylogger.logDebug('Aggiunto utente gruppo agenzia: ' +  gm.UserOrGroupId);       
                }
            } 
        }

        return userMap;
    }

    public static void notifyUsersRelated(map<id,opportunity> newMap,map<id,opportunity> oldMap){

        set<id> newOpp = new set<id>();
        set<id> changedOpp = new set<id>();
        set<id> approvedOpp = new set<id>();

        list<opportunity> opps = new list<opportunity>();

        if(Trigger.isInsert){
            newOpp.addAll(newMap.keySet());
            opps.addAll(newMap.values());
        }
        if(Trigger.isUpdate){
            for(opportunity o : newMap.values()){
                if(o.StageName != oldMap.get(o.id).StageName){
                    changedOpp.add(o.id);
                    opps.add(o);
                }else if(o.Approvata_commercialmente__c && ! oldMap.get(o.id).Approvata_commercialmente__c){
                    approvedOpp.add(o.id);
                    opps.add(o);
                }
            }
        }

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        map<id,set<id>> oppUsersMap = getUsersRelatedToOpportunities(opps);

        set<id> users = new set<id>();
        for(id i : oppUsersMap.keySet()){
            users.addAll(oppUsersMap.get(i));
        } 
        map<id,user> usersMap = new map<id,user>([SELECT Id, Name, Email FROM User WHERE Id IN : users or id =: USerInfo.getUserId() ]);

        mylogger.logDebug('oppUsersMap = '+ oppUsersMap); 
        mylogger.logDebug('usersMap = '+ usersMap);

        for(id oppid : oppUsersMap.keySet()){
            Messaging.SingleEmailMessage e = new Messaging.SingleEmailMessage();
            List<String> emails = new list<string>();
            for(id i : oppUsersMap.get(oppid)){
                emails.add(usersMap.get(i).email);
            }
            e.setToAddresses(emails);
            
            //Per Debug
            //e.setToAddresses(new List<String>{'massimiliano.colombi@italiaonline.it'});
            //e.setCCAddresses(new List<String>{'raffaello.lacontana@telnext.com'});

            if(newOpp.contains(oppid)){
                String body = '';
                body += 'Una nuova opportunità è stata creata.<br/><br/>';
                body += 'identificativo: '+newMap.get(oppid).identificativo_campagna__c + '<br/>';
                body += 'creata da: '+ usersMap.get(newMap.get(oppid).CreatedById).Name + '<br/>';
                body += 'data creazione: '+newMap.get(oppid).CreatedDate.format();              
                e.setSubject('Opportunità creata: '+newMap.get(oppid).identificativo_campagna__c );
                e.setHtmlBody(body);
            }
            if(changedOpp.contains(oppid) && !newMap.get(oppid).isWon){
                String body = '';
                body += 'Lo stato di un\'opportunità è cambiato da ' +oldMap.get(oppid).StageName + ' a ' +newMap.get(oppid).StageName + '.<br/><br/>';
                body += 'identificativo: '+newMap.get(oppid).identificativo_campagna__c + '<br/>';
                body += 'modificata da: '+usersMap.get(newMap.get(oppid).LastModifiedById).Name + '<br/>';
                body += 'data modifica: '+newMap.get(oppid).LastModifiedDate.format();
                e.setSubject('Cambio stato Opportunità: '+newMap.get(oppid).identificativo_campagna__c );
                e.setHtmlBody(body);
            }
            if(changedOpp.contains(oppid) && newMap.get(oppid).isWon){
                String body = '';
                body += 'Un\'opportunità è stata Chiusa/Vinta.<br/><br/>';
                body += 'identificativo: '+newMap.get(oppid).identificativo_campagna__c + '<br/>';
                body += 'modificata da: '+usersMap.get(newMap.get(oppid).LastModifiedById).Name + '<br/>';
                body += 'data modifica: '+newMap.get(oppid).LastModifiedDate.format();
                e.setSubject('Opportunità Chiusa/Vinta: '+newMap.get(oppid).identificativo_campagna__c );
                e.setHtmlBody(body);
            }
            if(approvedOpp.contains(oppid)){
                String body = '';
                body += 'Un\'opportunità è stata approvata commercialmente.<br/><br/>';
                body += 'identificativo: '+newMap.get(oppid).identificativo_campagna__c + '<br/>';
                body += 'modificata da: '+usersMap.get(newMap.get(oppid).LastModifiedById).Name + '<br/>';
                body += 'data modifica: '+newMap.get(oppid).LastModifiedDate.format();
                e.setSubject('Opportunità approvata commercialmente: '+newMap.get(oppid).identificativo_campagna__c );
                e.setHtmlBody(body);
            }
            emailMessages.add(e);
        }
        
        //Send emails
        if(emailMessages.size() > 0){
            Messaging.sendEmail(emailMessages);
        }
    }

    /**
     *  Inizializza l'opportunità andando a copiare dall'account corrispondente l'agenzia di riferimento
     *  e la percentuale agenzia su brand
     */
    public static void copyDataFromAccount(Opportunity[] triggerNew) {
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity o : triggerNew){
            accountIds.add(o.AccountId);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT
            Id,
            agenzia_territoriale__c,
            Percentuale_commisioning_agenzia__c
            FROM Account
            WHERE Id IN :accountIds
        ]);
        
        for(Opportunity o : triggerNew){
//            if(o.AccountId != null && o.Agenzia_di_riferimento__c == null) {
              if(o.AccountId != null) {
                o.Agenzia_di_riferimento__c = accountsMap.get(o.AccountId).agenzia_territoriale__c;
                o.Percentuale_agenzia_su_brand__c = accountsMap.get(o.AccountId).Percentuale_commisioning_agenzia__c;
            }            
        }               
    }

    /**
     *  Popola la lookup dell'owner e copia l'id dell'agenzia di riferimento e del centro media in un campi dedicati    
     */ 
    public static void doFieldUpdates(Opportunity[] opps) {
        
        for(Opportunity o : opps) {
            o.venditore__c = o.ownerid;
            o.Agenzia_di_riferimento_txt__c = o.agenzia_di_riferimento__c;
            o.Centro_Media_txt__c = o.Centro_Media__c;
            if(o.DataPrimaChiusaVinta__c == null){
                o.OwnerBrandHistory__c=o.OwnerAccountId__c;
                o.OwnerCMHistory__c=o.OwnerCentroMediaId__c;
                o.AgenziaTerritorialeHistory__c=o.Agenzia_di_riferimento__c;
                o.TipoMandatoAgenziaHistory__c=o.TipoMandatoAgenzia__c;
                o.BrandHistory__c=o.Account.Id;
                o.TipoVenditoreBrandHistory__c = o.TipoVenditoreBrand__c;
                o.TipoVenditoreCMHistory__c = o.TipoVenditoreCM__c;   
                o.CentroMediaHistory__c = o.Centro_Media__c;
            }
        }
    }

    public static void doFieldUpdatesOnChanged(Opportunity[] newOpps,Map<Id,Opportunity> oldMap){
        for(Opportunity o : newOpps){
            if(o.NrLineitemsApprovazioneOverbookRichiesta__c > oldMap.get(o.Id).NrLineitemsApprovazioneOverbookRichiesta__c){
                o.OverbookApprovato__c = false;
            }
        }
    }
    
    /**
     *  Rollup su stato opportunità. Se tutti i lineitem banner sono reserved allora metto l'opp in stato reserved.
     *  Calcola anche il rollup sul numero di revenue fatturate
     */
    public static void rollupLineItemFields(Opportunity[] opps) {
        Map<Id, String> reservationStatusMap = new Map<Id, String>();
        
        //Azzera i valori dei campi su cui fare il rollup
        for(Opportunity opp : opps) {
            opp.NumeroRevenueFatturate__c = 0;
            opp.Impression_OAS__c = 0;
            opp.NrLineitemsApprovazioneOverbookRichiesta__c = 0;
        }
        
        // select data__c from dataChiusuraRicavo__c  
        
        List <LineItem__c> lineitem_list;

        if(Test.isRunningTest()) {
            lineitem_list =[SELECT Id, reservationstatus__c,ProductFamily__c,opportunity__c,end_date__c,status__c,NumeroRevenueFatturate__c,
                Delivery_Model__c,
                Integrato_con_OAS_formula__c,                  
                Quantita__c,
                ApprovazioneOverbookRichiesta__c
            FROM LineItem__c 
            WHERE opportunity__c IN :opps limit 1
        ];
        }else{
            lineitem_list=[SELECT
                Id,
                reservationstatus__c,
                ProductFamily__c,
                opportunity__c,
                end_date__c,
                status__c,
                NumeroRevenueFatturate__c,
                Delivery_Model__c,
                Integrato_con_OAS_formula__c,                  
                Quantita__c,
                ApprovazioneOverbookRichiesta__c
            FROM LineItem__c 
            WHERE opportunity__c IN :opps
        ];
        }
        for(LineItem__c li :lineitem_list ){
            if(li.ProductFamily__c == 'Banner'){
                reservationStatusMap.put(
                    li.opportunity__c,
                    reservationStatusMap.get(li.opportunity__c) == 'UNRESERVED' ? 'UNRESERVED' : li.reservationStatus__c
                );                
            }
            
            Opportunity o = (Opportunity) trigger.newMap.get(li.Opportunity__c);
            
            o.NumeroRevenueFatturate__c += li.NumeroRevenueFatturate__c != null ? li.NumeroRevenueFatturate__c : 0;

            o.NrLineitemsApprovazioneOverbookRichiesta__c += li.ApprovazioneOverbookRichiesta__c ? 1 : 0;
            
            //Rollup delle quantità sull'opportunità
            if(li.Delivery_Model__c == 'CPM' && li.Integrato_con_OAS_formula__c == 'true') {
                o.Impression_OAS__c += li.Quantita__c != null ? li.Quantita__c : 0;
            }
        }

        // ricalcolo delle approvazioni sull'overbooking
        for(Opportunity opp : opps) {
            opp.AllowOverbook__c = opp.NrLineitemsApprovazioneOverbookRichiesta__c == 0;
        }
        
    
        for(Id i : reservationStatusMap.keySet()) {
            trigger.newMap.get(i).put('reservationStatus__c', reservationStatusMap.get(i));
        }  

    }
    
    /*
        Non è possibile cacellare Li già lavorati su OAS con data di inizio nel passato
    */
    public static void checkDeletedLi(Opportunity[] opps) {
        map<id,opportunity> oppsMap = new map<id,opportunity>([select id,(select name_dfp__c,start_date__c,start_hour__c,start_minute__c,stato_lavorazione_oas__c,id_oas__c from line_items__r) from opportunity where id in : opps]);
        for(Opportunity o : opps){
            try{
                LineItemTriggerHandler.checkDeletedLi(oppsMap.get(o.id).line_items__r);
            }catch(LineItemTriggerHandler.LineItemHandlerException e){
                o.addError(e.getMessage());
            }       
        }
    }
    
    /**
     *  Elimino manualmente i lineitem, per scatenare i trigger di eliminazione a cascata degli oggetti
     *  collegati al LineItem. In caso contrario, essendo opportunità e lineitems in master-detail, i trigger
     *  sui lineitem non vengono scatenati
     */
    public static void deleteLi(Opportunity[] opps) {
        delete [SELECT Id FROM Pacchetto_Combo_Opportunity__c WHERE Opportunity__c IN :opps];
        
        delete [SELECT
            Id
            FROM LineItem__c
            WHERE Opportunity__c IN :opps
        ];
    }
     
    /**
     *  Elimino i teamtargeted associati all'opp (no master detail)
     */
    public static void deleteTeamTargeted(Opportunity[] opps) {
        delete [SELECT
            Id
            FROM TeamTargeted__c
            WHERE Opportunity__c IN :opps
        ];          
    }
    
    //se cambio commisioning agenzia ad un'opportunità, nel trigger del lineitem controllo questo set, tengo il net net e ricalcolo lo sconto
    public static set<id> oppCommissioneChanged = new set<id>(); 
    
    public static void updateLineItemsIfNeeded(Opportunity[] opps) {
        Set<Id> oppChanged = new Set<Id>();
        Set<Id> oppClosedWon = new Set<Id>();
        Set<Id> oppApprovedOverbook = new Set<Id>();

        for(Opportunity o : opps){
            if(o.Commissione_Agenzia__c != trigger.oldMap.get(o.id).get('Commissione_Agenzia__c')){
                oppChanged.add(o.id);
                oppCommissioneChanged.add(o.id);
            }
            if(o.iswon && !((Opportunity)trigger.oldmap.get(o.id)).isWon) {
                oppClosedWon.add(o.id);
            }

            if(o.OverbookApprovato__c && !((Opportunity)trigger.oldmap.get(o.id)).OverbookApprovato__c) {
                oppApprovedOverbook.add(o.Id);
            }
        }
        
        if(!oppChanged.isEmpty() || !oppClosedWon.isEmpty() || !oppApprovedOverbook.isEmpty()) {
            LineItem__c[] liToUpdate = [SELECT
                                            Id,
                                            opportunity__c,
                                            Stato_lavorazione_OAS__c,
                                            ad_server__c,
                                            oas_modificato_dopo_riapertura__c,
                                            QuantitaApprovazioneOverbook__c,
                                            Quantita__c,
                                            BacinoRiservato__c,
                                            OverbookApprovato__c,
                                            ApprovazioneOverbookRichiesta__c,
                                            CheckUtilizzoSOV__c
                                        FROM LineItem__c 
                                        WHERE (Opportunity__c IN : oppClosedWon) // AND ad_server__c = 'OAS', prima solo OAS per resettare lo stato, adesso tutti per scatenare val rule su LI
                                            OR Opportunity__c in : oppChanged
                                            OR Opportunity__c in : oppApprovedOverbook
                                        ];
            for(LineItem__c li : liToUpdate) {
                if( oppClosedWon.contains(li.opportunity__c)){
                    if(li.CheckUtilizzoSOV__c){
                        li.BacinoRiservato__c = true; // ogni volta che la opp viene chiusa vinta il bacino viene considerato come riservato    
                    }
                    if(li.ad_server__c == 'OAS' &&
                    (li.oas_modificato_dopo_riapertura__c == 1 || li.Stato_lavorazione_OAS__c == null || li.Stato_lavorazione_OAS__c == 'Da Caricare Pianificazione')
                    ){
                        if(li.oas_modificato_dopo_riapertura__c == 1 && (li.Stato_lavorazione_OAS__c <> null && li.Stato_lavorazione_OAS__c <> 'Da Caricare Pianificazione')){
                            li.Stato_lavorazione_OAS__c = 'Da Rilavorare';
                        }else{
                            li.Stato_lavorazione_OAS__c = 'Da Caricare Pianificazione';
                        }    
                    } 
                }

                if( oppApprovedOverbook.contains(li.opportunity__c) ){
                    li.QuantitaApprovazioneOverbook__c = li.Quantita__c;
                    if(li.ApprovazioneOverbookRichiesta__c && !li.OverbookApprovato__c){ // tutte i line item che necessitavano di approvazione vengono flaggati come approvati
                        li.OverbookApprovato__c = true;
                    }
                }
            }
            Boolean oldSkip = LineItemTriggerHandler.skipValidationTotali;          
            try {
                LineItemTriggerHandler.skipValidationTotali = true;
                update liToUpdate;
                update [select id from Pacchetto_Combo_Opportunity__c where opportunity__c in : oppChanged];
            } catch(DMLException e) {
                mylogger.logDebug(trigger.new);
                if(trigger.new.size() == 1) {
                    mylogger.logDebug(e);
                    trigger.new[0].addError(e.getDmlMessage(0));                
                } else throw e;
            } finally {
                LineItemTriggerHandler.skipValidationTotali = oldSkip;
            }                                  
        }   
    }
    
    public static void updateRevenues(Opportunity[] opps) {
        if(!RevenueApplicationTriggerHandler.skipUpdateRevenues) {
            set<id> oppsChanged = new set<id>();
            for(Opportunity o : opps){
                //per aggiornare venditore obiettivo e campi storico revenue
                if(o.ownerid != ((Opportunity)Trigger.oldMAp.get(o.id)).ownerid || (o.isWon && !((Opportunity)Trigger.oldMAp.get(o.id)).iswon) ){
                    oppsChanged.add(o.id);
                }
            }
            try{
                LineItemTriggerHandler.skipUpdateLineItem = true;
                RevenueApplicationTriggerHandler.updateRevenuesStorico = true;
                update [SELECT Id FROM Revenue_application__c where Line_Item__r.opportunity__c in : oppsChanged ];
            } catch(exception e){
                //Se da errore qui voglio mandare una mail ma non bloccare
                UtilExceptionIntegration.sendEmail('Exception in trigger afterUpdateOpportunity',e+'');
            }
        }               
    }   
    
    public static void updateRicavi(Opportunity[] opps) {
        if(!RicavoTriggerHandler.skipUpdateRicavi) {
            set<id> oppsChanged = new set<id>();
            for(Opportunity o : opps){
                //per aggiornare venditore obiettivo e campi storico ricavi
                if(o.ownerid != ((Opportunity)Trigger.oldMAp.get(o.id)).ownerid || (o.isWon && !((Opportunity)Trigger.oldMAp.get(o.id)).iswon) ){
                    oppsChanged.add(o.id);
                }
            }
            try{
                LineItemTriggerHandler.skipUpdateLineItem = true;
                RicavoTriggerHandler.updateRicavoStorico = true;
                update [SELECT Id FROM Ricavo__c where Line_Item__r.opportunity__c in : oppsChanged ];
            } catch(exception e){
                //Se da errore qui voglio mandare una mail ma non bloccare
                UtilExceptionIntegration.sendEmail('Exception in trigger afterUpdateOpportunity',e+'');
            }
        }               
    }

 
    public static void sendCPLEmails(){
      //  String CurrentClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));

if(!Test.isRunningTest()) {

        List <Integer> i= new List <Integer>();
        Set<Id> oppIds;
        if(Trigger.isDelete){
            oppIds = trigger.oldmap.keySet();
        }else{
            oppIds = trigger.newMap.keySet();
        }
        ///controllo aggiunto per evitare l'invio email alle 6 del mattino quando lo scheduler aggiorna tutte le opportunità con i dati da dfp
        List <LineItem__c> lineitem_listAll =[SELECT Id, Ad_Server__c, Opportunity__c FROM LineItem__c   Where Opportunity__c IN : oppIds ];
        Boolean isAdwords=false;
        for (LineItem__c l:lineitem_listAll){
            if(l.Ad_Server__c == 'ADWORDS'){
                isAdwords=true;
            }

        }
        if(!isAdwords){
            return;
        }


        List <LineItem__c> lineitem_list =[SELECT Id, Ad_Server__c, Opportunity__c, Start_Date__c, Start_Hour__c, Start_Minute__c, End_Date__c, End_Hour__c, End_Minute__c, Quantita__c, Note_commerciali__c, Goal_delivery__c FROM LineItem__c   Where Opportunity__c IN : oppIds and Ad_Server__c ='ADWORDS'];

        mylogger.logDebug('sendCPLEmails ci sono nr line item '+lineitem_list.size()+ ' licode ');
        if (lineitem_list.size()>0){

           EmailTemplate tempModifica = UtilNotificheOAS.oasTemplates.get('Notifica_lavorazione_OAS');
           EmailTemplate tempEliminazione = UtilNotificheOAS.oasTemplates.get('Notifica_eliminazione_OAS');
           Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};     
           Id TargetObjectId;
            String[] ccEmails = new String[]{};

            try{
            
            Contact c = UtilNotificheOAS.adwordsContact;
            TargetObjectId = c.id;
            if(c.Email_in_cc__c != null) {
                    ccEmails = c.Email_in_cc__c.split(',');
                }
            }catch(exception e){
                    TargetObjectId = [SELECT Id FROM User WHERE email = 'libero@telnext.com'].Id;
            }


        mylogger.logDebug('sendCPLEmails Trigger.isUpdate'+Trigger.isUpdate+'Trigger.isAfter'+Trigger.isAfter);

         if(Trigger.isUpdate && lineitem_list.size()>0){
                Set<Id> newOASOptyIDs = new Set<Id>();
                for(LineItem__c li :lineitem_list){
                    newOASOptyIDs.add(li.Opportunity__c);
                }
                
                for(SObject oObj : Trigger.new){
                    Opportunity o = (Opportunity) oObj;
                    Messaging.SingleEmailMessage mail ;
                //   Id ownerid= [Select OwnerId From Opportunity where id =:oObj.id].get(0).OwnerId;
                   String [] ownerEmail=new String[]{[Select Email from User where id = :o.OwnerId].Email};
                   mylogger.logDebug('ownerEmail '+ownerEmail);
                    //If Opportunity become WON send an email by using prepareEmail method with email template inside    
                    /////   StageName  Chiusa Vinta – in modifica      
                    //o.IsWon && !(   (Opportunity)Trigger.oldMap.get(o.Id)).IsWon && newOASOptyIDs.contains(o.Id)       )         
                    // se l'ooportunità 
                    Opportunity oldOpp= (Opportunity) Trigger.oldMap.get(o.Id);
                    if( o.IsWon && !(oldOpp.StageName == 'Chiusa Vinta – in modifica' ))
                    {
                        mail =UtilNotificheOAS.getMessage(tempModifica.id,TargetObjectId,o.id);
                        ccEmails.add(ownerEmail[0]);
                        mail.setCcAddresses(ccEmails);
                        emails.add(mail);
                        mylogger.logDebug('opportunità nuova '+o.id);
                    }else if(o.IsWon && newOASOptyIDs.contains(o.Id) && UtilNotificheOAS.isChagend((Opportunity)Trigger.oldMap.get(o.Id),o)){
                        //Prepare a different message to highlight changes
                        mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(TargetObjectId);
                        mail.setSubject('Opportunità modificata: '+o.Name);
                        ccEmails.add(ownerEmail[0]);
                        mail.setCcAddresses(ccEmails);
                        mail.setHtmlBody(UtilNotificheOAS.getBodyModificaOpp((Opportunity)Trigger.oldMap.get(o.Id),o));
                        mylogger.logDebug('sendCPLEmails Trigger.isUpdate opportunità modificata '+o.id);
                       emails.add(mail);

                    }
                    
                }
            }

            if(Trigger.isDelete){
                UtilSkipTrigger.fromTriggerDeleteOpportunity = true;
                Set<Id> oldOASOptyIDs = new Set<Id>();
                for(LineItem__c li :((List<LineItem__c>)[SELECT Id, Ad_Server__c,stato_lavorazione_oas__c,Opportunity__c FROM LineItem__c WHERE Opportunity__c IN : Trigger.oldmap.keyset()])){
                    if(li.Ad_Server__c == 'ADWORDS' && li.stato_lavorazione_oas__c != '' && li.stato_lavorazione_oas__c != null)
                        oldOASOptyIDs.add(li.Opportunity__c);
                }
                
                for(SObject oObj : Trigger.old){
                    Opportunity o = (Opportunity) oObj;
                    if(oldOASOptyIDs.contains(o.Id)){
                        String [] ownerEmail=new String[]{[Select Email from User where id = :o.OwnerId].Email};
                        Messaging.SingleEmailMessage mail = UtilNotificheOAS.getMessage(tempEliminazione.id,TargetObjectId,o.id);
                        mylogger.logDebug('opportunità cancellata '+o.id);
                        ccEmails.add(ownerEmail[0]);
                        mail.setCcAddresses(ccEmails);
                        emails.add(mail);
                    }
                }
            }

            mylogger.logDebug('invio le email');
            
             UtilNotificheOAS.sendEmails(emails);


        }


}

}

    public static void sendOASEmails() {
        /*
        riga 299
        fare un nuovo tipo server 
         global static stepResponse chiudiEVinciStep2(String arg){
  299:         UtilSkipTrigger.skipCheckNotificheOAS = true;
        */

        if(!UtilSkipTrigger.skipCheckNotificheOAS){
            Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
        
            Id TargetObjectId;
            String[] ccEmails = new String[]{};
    
            try{
                Contact c = UtilNotificheOAS.oasContact;
                TargetObjectId = c.id;
                if(c.Email_in_cc__c != null) {
                    ccEmails = c.Email_in_cc__c.split(',');
                }               
            }catch(exception e){
                TargetObjectId = [SELECT Id FROM User WHERE email = 'libero@telnext.com'].Id;
            }
            
            EmailTemplate tempModifica = UtilNotificheOAS.oasTemplates.get('Notifica_lavorazione_OAS');
            EmailTemplate tempEliminazione = UtilNotificheOAS.oasTemplates.get('Notifica_eliminazione_OAS');        
            
            
            if(Trigger.isUpdate){
                Set<Id> newOASOptyIDs = new Set<Id>();
                for(LineItem__c li :((List<LineItem__c>)[SELECT Id, Ad_Server__c, Opportunity__c, Start_Date__c, Start_Hour__c, Start_Minute__c, End_Date__c, End_Hour__c, End_Minute__c, Quantita__c, Note_commerciali__c, Goal_delivery__c FROM LineItem__c WHERE Ad_Server__c = 'OAS' AND Opportunity__c IN : Trigger.newmap.keyset()])){
                    newOASOptyIDs.add(li.Opportunity__c);
                }
                
                for(SObject oObj : Trigger.new){
                    Opportunity o = (Opportunity) oObj;
                    //If Opportunity become WON send an email by using prepareEmail method with email template inside                   
                    if((o.IsWon && !((Opportunity)Trigger.oldMap.get(o.Id)).IsWon && newOASOptyIDs.contains(o.Id))){
                        emails.add(UtilNotificheOAS.getMessage(tempModifica.id,TargetObjectId,o.id));
                    }else if(o.IsWon && newOASOptyIDs.contains(o.Id) && UtilNotificheOAS.isChagend((Opportunity)Trigger.oldMap.get(o.Id),o)){
                        //Prepare a different message to highlight changes
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(TargetObjectId);
                        mail.setSubject('Opportunità modificata: '+o.Name);
                        mail.setHtmlBody(UtilNotificheOAS.getBodyModificaOpp((Opportunity)Trigger.oldMap.get(o.Id),o));
                        emails.add(mail);
                    }
                }
            }
            
            if(Trigger.isDelete){
                UtilSkipTrigger.fromTriggerDeleteOpportunity = true;
                Set<Id> oldOASOptyIDs = new Set<Id>();
                for(LineItem__c li :((List<LineItem__c>)[SELECT Id, Ad_Server__c,stato_lavorazione_oas__c,Opportunity__c FROM LineItem__c WHERE Opportunity__c IN : Trigger.oldmap.keyset()])){
                    if(li.Ad_Server__c == 'OAS' && li.stato_lavorazione_oas__c != '' && li.stato_lavorazione_oas__c != null)
                        oldOASOptyIDs.add(li.Opportunity__c);
                }
                
                for(SObject oObj : Trigger.old){
                    Opportunity o = (Opportunity) oObj;
                    if(oldOASOptyIDs.contains(o.Id)){
                        Messaging.SingleEmailMessage mail = UtilNotificheOAS.getMessage(tempEliminazione.id,TargetObjectId,o.id);
                        emails.add(mail);
                    }
                }
            }
            
            UtilNotificheOAS.sendEmails(emails,ccEmails);
            
            //se riutilizzo il trigger.old dopo l'invio mail i dati ci sono ancora se no manda mail senza dati!!!
            if(Trigger.isDelete){
                for(SObject o : Trigger.old){
                    mylogger.logDebug('oo'+o.id);
                }
            }
        }       
    }   
    
    /*
        After insert, after update do all'owner centro media il permesso di modificare l'opportunità e le revenues
    */
    public static void manageSharing(Opportunity[] triggerNew, Map<Id, Opportunity> triggerOldMap, Map<Id,Id> forcedOldCentroMediaOwnerMap) {
        manageSharing(triggerNew, triggerOldMap, forcedOldCentroMediaOwnerMap, false);
    }
    
    public static void manageSharing(Opportunity[] triggerNew, Map<Id, Opportunity> triggerOldMap, Map<Id,Id> forcedOldCentroMediaOwnerMap, Boolean forceUpdate) {
        /*
            Devo dare diritti di edit a opportunità e revenues a:
            1. Owner opportunità
            2. Owner account
            3. Owner centro media
            4. Opportunity team members
        */
                                                        
        Opportunity[] opps = new Opportunity[]{};
        Set<Id> oppsWithOwnerChanged = new Set<Id>();
        Set<Id> oppsWithAccountChanged = new Set<Id>();
        Set<Id> oldUserIds = new Set<Id>();

        //Genero una mappa con i vecchi owner dei centri media dell'opportunità
        Map<Id, Id> oldOwnerCentroMediaIdMap = new Map<Id, Id>();
        if(forcedOldCentroMediaOwnerMap != null) {
            oldOwnerCentroMediaIdMap = forcedOldCentroMediaOwnerMap;
        } else if(triggerOldMap != null) {
            for(Opportunity o : triggerNew) {
                oldOwnerCentroMediaIdMap.put(o.Id, triggerOldMap.get(o.Id).OwnerCentroMediaId__c);
                if(o.OwnerId != triggerOldMap.get(o.Id).OwnerId) oppsWithOwnerChanged.add(o.Id);
                if(o.AccountId != triggerOldMap.get(o.Id).AccountId) oppsWithAccountChanged.add(o.Id);
            }
        }
        
        //Determino se sono cambiati degli owner dei centri media e popolo i relativi set
        for(SObject so : triggerNew) {
            Opportunity o = (opportunity) so;
            Id oldOwnerCM = oldOwnerCentroMediaIdMap.get(o.Id);
            Id ownerCM = (Id) o.OwnerCentroMediaId__c;
            
            Boolean isOwnerCentroMediaChanged = oldOwnerCM != ownerCM || forceUpdate;
            mylogger.logDebug('ISOWNERCENTROMEDIACHANGED!!! ' + isOwnerCentroMediaChanged);
            
            if(isOwnerCentroMediaChanged) {
                opps.add(o);
                if(oldOwnerCM != null) oldUserIds.add(oldOwnerCM);
            }
        }

        //Se sono cambiati degli owner dei centri media cancello il vecchio owner centro media dallo sharing e aggiungo quello nuovo, e propago le modifiche
        //alle revenues sottostanti
        if(!opps.isEmpty()) {    
            Map<Id, Revenue_application__c> raMap = new Map<Id, Revenue_application__c>([SELECT
                Id,
                Line_Item__r.Opportunity__c
                FROM 
                Revenue_application__c
                WHERE Line_Item__r.Opportunity__c IN :opps
            ]);
    
            OpportunityShare[] oppShareToDelete = new OpportunityShare[]{};
            for(OpportunityShare os : [SELECT Id, OpportunityId, UserOrGroupId FROM OpportunityShare WHERE UserOrGroupId IN :oldUserIds AND OpportunityId IN :oldOwnerCentroMediaIdMap.keySet()]) {         
                if(oldOwnerCentroMediaIdMap.get(os.OpportunityId) == os.UserOrGroupId) oppShareToDelete.add(os);
            }
            
            OpportunityShare[] oppShare = new OpportunityShare[]{};
            for(Opportunity o : opps) {
                if(o.OwnerCentroMediaId__c != null) {
                    oppShare.add(
                        new OpportunityShare(
                            UserOrGroupId = o.OwnerCentroMediaId__c,
                            OpportunityId = o.id, 
                            OpportunityAccessLevel = 'Edit'
                        )
                    );
                }
                //RowCause = 'Team', 
            }        
    
            //Aggiorno lo sharing sull'opportunità
            Database.delete(oppShareToDelete, false);
            Database.insert(oppShare, false);                                        
            //updateRevenueSharing(raMap, opps);
        }
        
        mylogger.logDebug('OPPSWITHOWNERCHANGED!!! ' + oppsWithOwnerChanged);
        
        //Se è cambiato l'owner dell'opportunità propago la ownership alle revenues sottostanti
        /*
        if(!oppsWithOwnerChanged.isEmpty()) {
            Revenue_application__c[] revenueToChangeOwner = [SELECT
                Id,
                OwnerId,
                Line_Item__r.Opportunity__r.OwnerId
                FROM Revenue_application__c
                WHERE Line_Item__r.Opportunity__c IN :oppsWithOwnerChanged
            ];
            for(Revenue_application__c ra : revenueToChangeOwner) {
                ra.OwnerId = ra.Line_Item__r.Opportunity__r.OwnerId;    
            }
            Boolean skipLi = LineItemTriggerHandler.skipUpdateLineItem;
            LineItemTriggerHandler.skipUpdateLineItem = true;
            try {
                update revenueToChangeOwner;
            } finally {
                LineItemTriggerHandler.skipUpdateLineItem = skipLi;
            }
        }
        */
        
        //Se è cambiato il brand o l'owner dell'opportunità aggiorno le revenue in maniera asincrona
        //(Do il tempo al sistema di sistemare i permessi sull'opp prima di propagarli sulle revenues)
        if(!oppsWithAccountChanged.isEmpty() || !oppsWithOwnerChanged.isEmpty()) {
            Set<Id> oppsToUpdate = new Set<Id>();
            oppsToUpdate.addAll(oppsWithAccountChanged);
            oppsToUpdate.addAll(oppsWithOwnerChanged);
            //updateRevenueSharingAsync(oppsToUpdate);    
        }
    }
    
    /*
    @future
    public static void updateRevenueSharingAsync(Set<Id> oppIds) {
        Map<Id, Revenue_application__c> raMap = new Map<Id, Revenue_application__c>();
        Opportunity[] opps = new Opportunity[]{};
        for(Revenue_application__c ra : [SELECT
            Id,
            Line_Item__r.Opportunity__c
            FROM Revenue_application__c
            WHERE Line_Item__r.Opportunity__c IN :oppIds
        ]) {
            raMap.put(ra.Id, ra);
            opps.add(new Opportunity(Id = ra.Line_Item__r.Opportunity__c));
        }
        OpportunityTriggerHandler.updateRevenueSharing(raMap, opps);            
    }
    */
    
    /*
    public static void updateRevenueSharing(Map<Id, Revenue_application__c> raMap, Opportunity[] opps) {
        //Aggiorno lo sharing sulle revenues
        
        Database.delete([SELECT Id FROM Revenue_application__Share WHERE ParentId IN :raMap.keySet()], false);
        Map<Id, OpportunityShare[]> oppShareMap = new Map<Id, OpportunityShare[]>();
        Map<Id, GroupMember[]> gmMap = new Map<Id, GroupMember[]>();
        Set<Id> groupIds = new Set<Id>();
        for(OpportunityShare os : [SELECT OpportunityId, UserOrGroupId, OpportunityAccessLevel FROM OpportunityShare WHERE OpportunityId IN :opps]) {
            if(oppShareMap.get(os.OpportunityId) == null) oppShareMap.put(os.OpportunityId, new OpportunityShare[]{});          
            oppShareMap.get(os.OpportunityId).add(os);
            if(os.UserOrGroupId.getSObjectType() == Group.SOBjectType) {
                groupIds.add(os.UserOrGroupId);
                gmMap.put(os.UserOrGroupId, new GroupMember[]{});
            }
        }
        for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE Group.Type = 'SharingRuleGroup' AND GroupId IN :gmMap.keySet()]) {
            gmMap.get(gm.GroupId).add(gm);
        }
        mylogger.logDebug('OPPSHAREMAP!!! ' + oppShareMap);
        Revenue_application__Share[] raShare = new Revenue_application__Share[]{};
        for(Revenue_application__c ra : raMap.values()) {
            for(OpportunityShare os : oppShareMap.get(ra.Line_Item__r.Opportunity__c)) {
                if(gmMap.get(os.UserOrGroupId) != null && !gmMap.get(os.UserOrGroupId).isEmpty()) {
                    for(GroupMember gm : gmMap.get(os.UserOrGroupId)) {
                        raShare.add(new Revenue_application__Share(
                            ParentId = ra.Id,
                            UserOrGroupId = gm.UserOrGroupId,
                            AccessLevel = os.OpportunityAccessLevel  == 'All' ? 'Edit' : os.OpportunityAccessLevel
                        ));                     
                    }                   
                } else {
                    raShare.add(new Revenue_application__Share(
                        ParentId = ra.Id,
                        UserOrGroupId = os.UserOrGroupId,
                        AccessLevel = os.OpportunityAccessLevel  == 'All' ? 'Edit' : os.OpportunityAccessLevel
                    ));
                }
            }               
        }
        mylogger.logDebug(Database.insert(raShare, false));                              
        
    }   
    */     
}