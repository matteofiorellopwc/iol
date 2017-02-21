public class UtilityDataValue {

// LineItemService
    public static DfpLineItemService.TimeOfDay getLineItemTimeOfDay(String h,String m){
        DfpLineItemService.TimeOfDay tod = new DfpLineItemService.TimeOfDay();
        tod.hour = Integer.valueOf(h);
        tod.minute = m;
        return tod;
    }
    
    public static DfpLineItemService.DateTime_x getLineItemDateTime(Date d,integer hour, integer minute,integer second){
        return getLineItemDateTime(d.year(),d.month(), d.day(), hour, minute, second);
    }    
    
    public static DfpLineItemService.DateTime_x getLineItemDateTime(Date d,string hour, string minute,string second){
        return getLineItemDateTime(d.year(),d.month(), d.day(), Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second));
    }      

    public static DfpLineItemService.DateTime_x getLineItemDateTime(DateTime dt){
        return getLineItemDateTime(dt.year(),dt.month(), dt.day(), dt.hour(), dt.minute(),dt.second());
    }

    public static DfpLineItemService.DateTime_x getLineItemDateTime(integer year,integer month, integer day, integer hour, integer minute,integer second){
        DfpLineItemService.Date_x d = new DfpLineItemService.Date_x();
        d.year = year;
        d.month = month;
        d.day = day;
        DfpLineItemService.DateTime_x dt = new DfpLineItemService.DateTime_x();
        dt.date_x = d;
        dt.hour = hour;
        dt.minute = minute;
        dt.second = second;
        dt.timezoneID = 'Europe/Rome';
        return dt;    
    }        

    public static DfpLineItemService.Money getLineItemMoney(long amount){
        DfpLineItemService.Money money = new DfpLineItemService.Money();
        money.microAmount = amount;
        money.currencyCode = 'EUR';
        return money;
    }
    
// InventoryService    

    public static DfpInventoryService.DateTime_x getInventoryDateTime(Date d,integer hour, integer minute,integer second){
        return getInventoryDateTime(d.year(),d.month(), d.day(), hour, minute, second);
    }
    
    public static DfpInventoryService.DateTime_x getInventoryDateTime(Date d,string hour, string minute,string second){
        return getInventoryDateTime(d.year(),d.month(), d.day(), Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second));
    }    

    public static DfpInventoryService.DateTime_x getInventoryDateTime(DateTime dt){
        return getInventoryDateTime(dt.year(),dt.month(), dt.day(), dt.hour(), dt.minute(),dt.second());
    }

    public static DfpInventoryService.DateTime_x getInventoryDateTime(integer year,integer month, integer day, integer hour, integer minute,integer second){
        DfpInventoryService.Date_x d = new DfpInventoryService.Date_x();
        d.year = year;
        d.month = month;
        d.day = day;
        DfpInventoryService.DateTime_x dt = new DfpInventoryService.DateTime_x();
        dt.date_x = d;
        dt.hour = hour;
        dt.minute = minute;
        dt.second = second;
        return dt;    
    }    
    
// ForecastService

    public static DfpForecastService.TimeOfDay getForecastTimeOfDay(String h,String m){
        DfpForecastService.TimeOfDay tod = new DfpForecastService.TimeOfDay();
        tod.hour = Integer.valueOf(h);
        tod.minute = m;
        return tod;
    }
    
    public static DfpForecastService.Money getForecastMoney(long amount){
        DfpForecastService.Money money = new DfpForecastService.Money();
        money.microAmount = amount;
        money.currencyCode = 'EUR';
        return money;
    }
    
    public static DfpForecastService.DateTime_x getForecastDateTime(Date d,integer hour, integer minute,integer second){
        return getForecastDateTime(d.year(),d.month(), d.day(), hour, minute, second);
    }      
    
    public static DfpForecastService.DateTime_x getForecastDateTime(Date d,string hour, string minute,string second){
        return getForecastDateTime(d.year(),d.month(), d.day(), Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second));
    }       
    
    public static DfpForecastService.DateTime_x getForecastDateTime(DateTime dt){
        return getForecastDateTime(dt.year(),dt.month(), dt.day(), dt.hour(), dt.minute(),dt.second());
    }
    
    public static DfpForecastService.DateTime_x getForecastDateTime(integer year,integer month, integer day, integer hour, integer minute,integer second){
        DfpForecastService.Date_x d = new DfpForecastService.Date_x();
        d.year = year;
        d.month = month;
        d.day = day;
        DfpForecastService.DateTime_x dt = new DfpForecastService.DateTime_x();
        dt.date_x = d;
        dt.hour = hour;
        dt.minute = minute;
        dt.second = second;
        return dt;    
    }

// Report Service

    public static DfpReportService.DateTime_x getReportDateTime(Date d,integer hour, integer minute,integer second){
        return getReportDateTime(d.year(),d.month(), d.day(), hour, minute, second);
    }      
    
    public static DfpReportService.DateTime_x getReportDateTime(Date d,string hour, string minute,string second){
        return getReportDateTime(d.year(),d.month(), d.day(), Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second));
    }       
    
    public static DfpReportService.DateTime_x getReportDateTime(DateTime dt){
        return getReportDateTime(dt.year(),dt.month(), dt.day(), dt.hour(), dt.minute(),dt.second());
    }
    
    public static DfpReportService.DateTime_x getReportDateTime(integer year,integer month, integer day, integer hour, integer minute,integer second){
        DfpReportService.Date_x d = new DfpReportService.Date_x();
        d.year = year;
        d.month = month;
        d.day = day;
        DfpReportService.DateTime_x dt = new DfpReportService.DateTime_x();
        dt.date_x = d;
        dt.hour = hour;
        dt.minute = minute;
        dt.second = second;
        return dt;    
    } 
    
    public static DfpReportService.Date_x getReportDate(integer year,integer month, integer day){
        DfpReportService.Date_x d = new DfpReportService.Date_x();
        d.year = year;
        d.month = month;
        d.day = day;
        return d;
    }
    
    //Return the Italian month by given a date
    public static String getMonthFromDate(Date d){
        String m;
        
        if(d.month() == 1)
            m = 'Gennaio';
        if(d.month() == 2)
            m = 'Febbraio';
        if(d.month() == 3)
            m = 'Marzo';
        if(d.month() == 4)
            m = 'Aprile';
        if(d.month() == 5)
            m = 'Maggio';
        if(d.month() == 6)
            m = 'Giugno';
        if(d.month() == 7)
            m = 'Luglio';
        if(d.month() == 8)
            m = 'Agosto';
        if(d.month() == 9)
            m = 'Settembre';
        if(d.month() == 10)
            m = 'Ottobre';
        if(d.month() == 11)
            m = 'Novembre';
        if(d.month() == 12)
            m = 'Dicembre';
        
        return m;
    }

    public static DateTime getSalesforceDateTime(DfpLineItemService.DateTime_x dt){
        return DateTime.newInstance(dt.date_x.year,dt.date_x.month,dt.date_x.day,dt.hour,dt.minute,dt.second);
    }
}