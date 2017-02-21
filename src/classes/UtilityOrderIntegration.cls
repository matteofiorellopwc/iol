public class UtilityOrderIntegration {
    public static void approveOrders(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();    
        performeOrderAction(ids,'ApproveOrders',dfp);
    }

    public static void deleteOrders(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();    
        performeOrderAction(ids,'DeleteOrders',dfp);
    } 
    
    public static void approveOrders(List<decimal> ids,dfpintegration dfp){
        performeOrderAction(ids,'ApproveOrders',dfp);
    }
    
    public static void archiveOrders(List<decimal> ids){
        Dfpintegration dfp = new Dfpintegration(); 
        performeOrderAction(ids,'ArchiveOrders',dfp);
    }

    public static void archiveOrders(List<decimal> ids,Dfpintegration dfp){
        performeOrderAction(ids,'ArchiveOrders',dfp);
    }
    
    public static void pauseOrders(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();    
        performeOrderAction(ids,'PauseOrders',dfp);
    }

    public static void pauseOrders(List<decimal> ids,dfpintegration dfp){
        performeOrderAction(ids,'PauseOrders',dfp);
    }
    
    public static void performeOrderAction(List<decimal> ids,string orderAction){
        dfpintegration dfp = new dfpintegration();    
        performeOrderAction(ids,orderAction,dfp);
    }
    
    public static void performeOrderAction(List<decimal> ids,string orderAction,dfpintegration dfp){
        try{
            DfpOrderService.Statement orderFilterStatement = new DfpOrderService.Statement();
            orderFilterStatement.query = 'WHERE id in ('+ListToString(ids)+') LIMIT 1000 OFFSET 0';
            DfpOrderService.orderAction action = new DfpOrderService.orderAction();
            action.type = orderAction;
            dfp.orderservice.performOrderAction(action,orderFilterStatement);
        }catch(Exception e){
            throw new IntegrationException(e.getMessage());
        }
    }
    
    public static DfpOrderService.OrderPage getOrdersByIds(List<decimal> ids){
        dfpintegration dfp = new dfpintegration();   
        return getOrdersByIds(ids,dfp);
    }
    
    public static DfpOrderService.OrderPage getOrdersByIds(List<decimal> ids,dfpintegration dfp){
        try{
            DfpOrderService.Statement orderFilterStatement = new DfpOrderService.Statement();
            orderFilterStatement.query = 'WHERE id in ('+ListToString(ids)+') LIMIT 1000 OFFSET 0';
            return dfp.orderservice.getOrdersByStatement(orderFilterStatement);
        }catch(Exception e){
            throw new IntegrationException(e.getMessage());
        }
        return null;
    }
    
    public static string ListToString(List<decimal> ids){
        string s = '';
        for(decimal d : ids){
            s += d+',';
        }
        s += ',';
        s = s.replace(',,','');
        return s;
    }    
    
    public static void syncDfpToSfdcOrders(list<Opportunity> opps){
        dfpIntegration dfp = new dfpIntegration();
        syncDfpToSfdcOrders(opps,dfp);
    }
    public static void syncDfpToSfdcOrders(list<Opportunity> opps,dfpIntegration dfp){
        Map<decimal,Opportunity> oppsMap = new Map<decimal,Opportunity>();
        for(Opportunity o : opps){
            oppsMap.put(o.id_dfp__c,o);
        }
        
        list<decimal> orderList = new list<decimal>();
        orderList.addAll(oppsMap.keySet());
        DfpOrderService.OrderPage orderPage = UtilityOrderIntegration.getOrdersByIds(orderList,dfp);
        if(orderPage.totalResultSetSize > 0){
            for(DfpOrderService.Order o : orderPage.results){
                Opportunity opp = oppsMap.get(o.id);
                if(opp != null){
                    UtilityOrderIntegration.syncDfpToSfdcOrder(opp,o);
                }
            }
        }
    }
    
    public static void syncDfpToSfdcOrder(Opportunity sfdc,DfpOrderService.Order dfp){
        sfdc.status__c = dfp.status;
    }    
    
    public class IntegrationException extends Exception{}

}