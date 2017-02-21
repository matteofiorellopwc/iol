@isTest
public class testingClass{
/*
    public static testMethod void testDfpCompanyService(){
        
        DfpCompanyService companyService = new DfpCompanyService();
        DfpCompanyService.CommonError ce = new DfpCompanyService.CommonError();
        DfpCompanyService.InternalApiError iae = new DfpCompanyService.InternalApiError();        
        DfpCompanyService.CustomCriteriaNode ccn = new DfpCompanyService.CustomCriteriaNode(); 
        DfpCompanyService.Authentication a = new DfpCompanyService.Authentication(); 
        DfpCompanyService.CompanyServiceInterfacePort csip = new DfpCompanyService.CompanyServiceInterfacePort(); 
        DfpCompanyService.BooleanValue BooleanValue = new DfpCompanyService.BooleanValue(); 
        DfpCompanyService.AppliedLabel AppliedLabel = new DfpCompanyService.AppliedLabel(); 
        DfpCompanyService.updateCompanyResponse_element updateCompanyResponse_element = new DfpCompanyService.updateCompanyResponse_element(); 
        DfpCompanyService.UniqueError UniqueError  = new DfpCompanyService.UniqueError(); 
        DfpCompanyService.RequiredError RequiredError = new DfpCompanyService.RequiredError(); 
        DfpCompanyService.CustomCriteriaLeaf CustomCriteriaLeaf = new DfpCompanyService.CustomCriteriaLeaf(); 
        DfpCompanyService.AuthenticationError AuthenticationError = new DfpCompanyService.AuthenticationError(); 
        DfpCompanyService.PermissionError PermissionError = new DfpCompanyService.PermissionError(); 
        DfpCompanyService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpCompanyService.PublisherQueryLanguageSyntaxError(); 
        DfpCompanyService.getCompany_element getCompany_element = new DfpCompanyService.getCompany_element(); 
        DfpCompanyService.String_ValueMapEntry String_ValueMapEntry = new DfpCompanyService.String_ValueMapEntry(); 
        DfpCompanyService.Size Size = new DfpCompanyService.Size(); 
        DfpCompanyService.Value Value = new DfpCompanyService.Value(); 
        DfpCompanyService.getCompaniesByStatementResponse_element getCompaniesByStatementResponse_element = new DfpCompanyService.getCompaniesByStatementResponse_element(); 
        DfpCompanyService.OAuth OAuth = new DfpCompanyService.OAuth(); 
        DfpCompanyService.createCompany_element createCompany_element = new DfpCompanyService.createCompany_element(); 
        DfpCompanyService.CompanyPage CompanyPage = new DfpCompanyService.CompanyPage(); 
        DfpCompanyService.CustomCriteria CustomCriteria = new DfpCompanyService.CustomCriteria(); 
        DfpCompanyService.updateCompaniesResponse_element updateCompaniesResponse_element = new DfpCompanyService.updateCompaniesResponse_element(); 
        DfpCompanyService.TypeError TypeError = new DfpCompanyService.TypeError(); 
        DfpCompanyService.NumberValue NumberValue = new DfpCompanyService.NumberValue();  
        DfpCompanyService.AdUnitSize AdUnitSize = new DfpCompanyService.AdUnitSize();
        DfpCompanyService.SoapResponseHeader SoapResponseHeader = new DfpCompanyService.SoapResponseHeader();        
        DfpCompanyService.CustomCriteriaSet CustomCriteriaSet = new DfpCompanyService.CustomCriteriaSet(); 
        DfpCompanyService.NotNullError NotNullError = new DfpCompanyService.NotNullError(); 
        DfpCompanyService.createCompanyResponse_element createCompanyResponse_element = new DfpCompanyService.createCompanyResponse_element(); 
        DfpCompanyService.updateCompanies_element updateCompanies_element = new DfpCompanyService.updateCompanies_element(); 
        DfpCompanyService.DateTimeValue DateTimeValue = new DfpCompanyService.DateTimeValue(); 
        DfpCompanyService.CompanyCreditStatusError CompanyCreditStatusError = new DfpCompanyService.CompanyCreditStatusError(); 
        DfpCompanyService.Statement Statement = new DfpCompanyService.Statement(); 
        DfpCompanyService.getCompaniesByStatement_element getCompaniesByStatement_element = new DfpCompanyService.getCompaniesByStatement_element(); 
        DfpCompanyService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpCompanyService.PublisherQueryLanguageContextError(); 
        DfpCompanyService.ApiError ApiError = new DfpCompanyService.ApiError(); 
        DfpCompanyService.Date_x Date_x = new DfpCompanyService.Date_x(); 
        DfpCompanyService.SoapRequestHeader SoapRequestHeader = new DfpCompanyService.SoapRequestHeader(); 
        DfpCompanyService.createCompaniesResponse_element createCompaniesResponse_element = new DfpCompanyService.createCompaniesResponse_element(); 
        DfpCompanyService.getCompanyResponse_element getCompanyResponse_element = new DfpCompanyService.getCompanyResponse_element(); 
        DfpCompanyService.ApiException ApiException = new DfpCompanyService.ApiException(); 
        DfpCompanyService.Company Company = new DfpCompanyService.Company(); 
        DfpCompanyService.QuotaError QuotaError = new DfpCompanyService.QuotaError(); 
        DfpCompanyService.ApplicationException ApplicationException = new DfpCompanyService.ApplicationException(); 
        DfpCompanyService.ApiVersionError ApiVersionError = new DfpCompanyService.ApiVersionError(); 
        DfpCompanyService.ParseError ParseError = new DfpCompanyService.ParseError(); 
        DfpCompanyService.LabelEntityAssociationError LabelEntityAssociationError = new DfpCompanyService.LabelEntityAssociationError(); 
        DfpCompanyService.ServerError ServerError = new DfpCompanyService.ServerError(); 
        DfpCompanyService.DateTime_x DateTime_x = new DfpCompanyService.DateTime_x(); 
        DfpCompanyService.StatementError StatementError = new DfpCompanyService.StatementError(); 
        DfpCompanyService.ClientLogin ClientLogin = new DfpCompanyService.ClientLogin(); 
        DfpCompanyService.CreativePlaceholder CreativePlaceholder = new DfpCompanyService.CreativePlaceholder(); 
        DfpCompanyService.TextValue TextValue = new DfpCompanyService.TextValue(); 
        
        try{
            csip.updateCompany(new DfpCompanyService.Company());
        }catch(Exception e){}
        
        try{
            csip.getCompany(10);
        }catch(exception e){}
        
        try{
            csip.getCompaniesByStatement(new DfpCompanyService.Statement());
        }catch(exception e){}        
        
        try{
            csip.createCompanies(new list<DfpCompanyService.Company>());
        }catch(exception e){}
        
        try{
            csip.updateCompanies(new list<DfpCompanyService.Company>());
        }catch(exception e){}
        
        try{
            csip.createCompany(new DfpCompanyService.Company());
        }catch(exception e){}                        
        
    }
    
    public static testMethod void testDfpForecastService(){
        DfpForecastService forcecastService = new DfpForecastService();
        DfpForecastService.CommonError CommonError = new DfpForecastService.CommonError();
        DfpForecastService.InternalApiError InternalApiError = new DfpForecastService.InternalApiError();
        DfpForecastService.LineItemSummary LineItemSummary = new DfpForecastService.LineItemSummary();
        DfpForecastService.BandwidthGroup BandwidthGroup = new DfpForecastService.BandwidthGroup();
        DfpForecastService.OrderError OrderError = new DfpForecastService.OrderError();
        DfpForecastService.UserDomainTargeting UserDomainTargeting = new DfpForecastService.UserDomainTargeting();
        DfpForecastService.InventoryTargetingError InventoryTargetingError = new DfpForecastService.InventoryTargetingError();
        DfpForecastService.DayPartTargeting DayPartTargeting = new DfpForecastService.DayPartTargeting();
        DfpForecastService.getForecastResponse_element getForecastResponse_element = new DfpForecastService.getForecastResponse_element();
        DfpForecastService.RequiredError RequiredError = new DfpForecastService.RequiredError();                                                                        
        DfpForecastService.CustomCriteriaLeaf CustomCriteriaLeaf = new DfpForecastService.CustomCriteriaLeaf();
        DfpForecastService.AuthenticationError AuthenticationError = new DfpForecastService.AuthenticationError();
        DfpForecastService.RegionLocation RegionLocation = new DfpForecastService.RegionLocation();
        DfpForecastService.PermissionError PermissionError = new DfpForecastService.PermissionError();
        DfpForecastService.DeviceManufacturerTargeting DeviceManufacturerTargeting = new DfpForecastService.DeviceManufacturerTargeting();
        DfpForecastService.AdUnitAfcSizeError AdUnitAfcSizeError = new DfpForecastService.AdUnitAfcSizeError();
        DfpForecastService.LineItemOperationError LineItemOperationError = new DfpForecastService.LineItemOperationError();
        DfpForecastService.InventoryTargeting InventoryTargeting = new DfpForecastService.InventoryTargeting();
        DfpForecastService.MobileDeviceSubmodelTargeting MobileDeviceSubmodelTargeting = new DfpForecastService.MobileDeviceSubmodelTargeting();
        DfpForecastService.ForecastServiceInterfacePort ForecastServiceInterfacePort = new DfpForecastService.ForecastServiceInterfacePort();
        DfpForecastService.OperatingSystemTargeting OperatingSystemTargeting = new DfpForecastService.OperatingSystemTargeting();
        DfpForecastService.MobileDevice MobileDevice = new DfpForecastService.MobileDevice();
        DfpForecastService.InventoryUnitError InventoryUnitError = new DfpForecastService.InventoryUnitError();
        DfpForecastService.BandwidthGroupTargeting BandwidthGroupTargeting = new DfpForecastService.BandwidthGroupTargeting();
        DfpForecastService.CustomCriteria CustomCriteria = new DfpForecastService.CustomCriteria();
        DfpForecastService.AdUnitCodeError AdUnitCodeError = new DfpForecastService.AdUnitCodeError();
        DfpForecastService.GeoTargeting GeoTargeting = new DfpForecastService.GeoTargeting();
        DfpForecastService.TimeOfDay TimeOfDay = new DfpForecastService.TimeOfDay();
        DfpForecastService.AdUnitSize AdUnitSize = new DfpForecastService.AdUnitSize();
        DfpForecastService.SoapResponseHeader SoapResponseHeader = new DfpForecastService.SoapResponseHeader();
        DfpForecastService.CustomCriteriaSet CustomCriteriaSet = new DfpForecastService.CustomCriteriaSet();
        DfpForecastService.RegExError RegExError = new DfpForecastService.RegExError();
        DfpForecastService.NotNullError NotNullError = new DfpForecastService.NotNullError();
        DfpForecastService.BrowserLanguageTargeting BrowserLanguageTargeting = new DfpForecastService.BrowserLanguageTargeting();
        DfpForecastService.getForecastByIdResponse_element getForecastByIdResponse_element = new DfpForecastService.getForecastByIdResponse_element();
        DfpForecastService.AdUnitTargeting AdUnitTargeting = new DfpForecastService.AdUnitTargeting();
        DfpForecastService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpForecastService.PublisherQueryLanguageContextError();
        DfpForecastService.Date_x Date_x = new DfpForecastService.Date_x();
        DfpForecastService.SoapRequestHeader SoapRequestHeader = new DfpForecastService.SoapRequestHeader();
        DfpForecastService.NullError NullError = new DfpForecastService.NullError();                    
        DfpForecastService.OperatingSystemVersionTargeting OperatingSystemVersionTargeting = new DfpForecastService.OperatingSystemVersionTargeting();
        DfpForecastService.ApiExceptionError ApiExceptionError = new DfpForecastService.ApiExceptionError();
        DfpForecastService.ForecastError ForecastError = new DfpForecastService.ForecastError();
        DfpForecastService.MobileCarrierTargeting MobileCarrierTargeting = new DfpForecastService.MobileCarrierTargeting();
        DfpForecastService.ApplicationException ApplicationException = new DfpForecastService.ApplicationException();                    
        DfpForecastService.Money Money = new DfpForecastService.Money();
        DfpForecastService.ApiVersionError ApiVersionError = new DfpForecastService.ApiVersionError();
        DfpForecastService.ContentTargeting ContentTargeting = new DfpForecastService.ContentTargeting();
        DfpForecastService.ServerError ServerError = new DfpForecastService.ServerError();
        DfpForecastService.DateTime_x DateTime_x = new DfpForecastService.DateTime_x();                    
        DfpForecastService.DeviceManufacturer DeviceManufacturer = new DfpForecastService.DeviceManufacturer();
        DfpForecastService.BrowserLanguage BrowserLanguage = new DfpForecastService.BrowserLanguage();
        DfpForecastService.MobileDeviceSubmodel MobileDeviceSubmodel = new DfpForecastService.MobileDeviceSubmodel();
        DfpForecastService.TechnologyTargeting TechnologyTargeting = new DfpForecastService.TechnologyTargeting();
        DfpForecastService.CustomCriteriaNode CustomCriteriaNode = new DfpForecastService.CustomCriteriaNode();                    
        DfpForecastService.Authentication Authentication = new DfpForecastService.Authentication();
        DfpForecastService.CountryLocation CountryLocation = new DfpForecastService.CountryLocation();
        DfpForecastService.AppliedLabel AppliedLabel = new DfpForecastService.AppliedLabel();
        DfpForecastService.UniqueError UniqueError = new DfpForecastService.UniqueError();
        DfpForecastService.DeliveryData DeliveryData = new DfpForecastService.DeliveryData();                                                    
        DfpForecastService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpForecastService.PublisherQueryLanguageSyntaxError();
        DfpForecastService.OperatingSystem OperatingSystem = new DfpForecastService.OperatingSystem();
        DfpForecastService.Size Size = new DfpForecastService.Size();
        DfpForecastService.OAuth OAuth = new DfpForecastService.OAuth();
        DfpForecastService.TypeError TypeError = new DfpForecastService.TypeError();                                                    
        DfpForecastService.VideoPositionTargeting VideoPositionTargeting = new DfpForecastService.VideoPositionTargeting();
        DfpForecastService.CityLocation CityLocation = new DfpForecastService.CityLocation();
        DfpForecastService.RequiredNumberError RequiredNumberError = new DfpForecastService.RequiredNumberError();
        DfpForecastService.ReservationDetailsError ReservationDetailsError = new DfpForecastService.ReservationDetailsError();
        DfpForecastService.Technology Technology = new DfpForecastService.Technology();                                                    
        DfpForecastService.ApiError ApiError = new DfpForecastService.ApiError();
        DfpForecastService.Targeting Targeting = new DfpForecastService.Targeting();
        DfpForecastService.BrowserTargeting BrowserTargeting = new DfpForecastService.BrowserTargeting();
        DfpForecastService.getForecastById_element getForecastById_element = new DfpForecastService.getForecastById_element();
        DfpForecastService.Browser Browser = new DfpForecastService.Browser();                                                                            
        DfpForecastService.Forecast Forecast = new DfpForecastService.Forecast();
        DfpForecastService.QuotaError QuotaError = new DfpForecastService.QuotaError();
        DfpForecastService.MobileDeviceTargeting MobileDeviceTargeting = new DfpForecastService.MobileDeviceTargeting();
        DfpForecastService.RangeError RangeError = new DfpForecastService.RangeError();  
        DfpForecastService.ParseError ParseError = new DfpForecastService.ParseError();
        DfpForecastService.Location Location = new DfpForecastService.Location();
        DfpForecastService.FrequencyCap FrequencyCap = new DfpForecastService.FrequencyCap();
        DfpForecastService.StatementError StatementError = new DfpForecastService.StatementError();  
        DfpForecastService.DeliveryIndicator DeliveryIndicator = new DfpForecastService.DeliveryIndicator();
        DfpForecastService.MetroLocation MetroLocation = new DfpForecastService.MetroLocation();
        DfpForecastService.CreativePlaceholder CreativePlaceholder = new DfpForecastService.CreativePlaceholder();
        DfpForecastService.ClientLogin ClientLogin = new DfpForecastService.ClientLogin();  
        DfpForecastService.RequiredCollectionError RequiredCollectionError = new DfpForecastService.RequiredCollectionError();
        DfpForecastService.CustomTargetingError CustomTargetingError = new DfpForecastService.CustomTargetingError();
        DfpForecastService.LineItemFlightDateError LineItemFlightDateError = new DfpForecastService.LineItemFlightDateError();
        DfpForecastService.MobileCarrier MobileCarrier = new DfpForecastService.MobileCarrier();  
        DfpForecastService.Stats Stats = new DfpForecastService.Stats();
        DfpForecastService.DayPart DayPart = new DfpForecastService.DayPart();
        DfpForecastService.PostalCodeLocation PostalCodeLocation = new DfpForecastService.PostalCodeLocation();  
        DfpForecastService.OperatingSystemVersion OperatingSystemVersion = new DfpForecastService.OperatingSystemVersion();
        DfpForecastService.LineItem LineItem = new DfpForecastService.LineItem();
                                                                 
        try{
            ForecastServiceInterfacePort.getForecast(new DfpForecastService.LineItem());
        }catch(Exception e){}
        try{
            ForecastServiceInterfacePort.getForecastById(10);
        }catch(Exception e){}        
    }    

    public static testMethod void testDfpInventoryService(){
        DfpInventoryService inventoryService = new DfpInventoryService();
        
        DfpInventoryService.createAdUnitsResponse_element createAdUnitsResponse_element = new DfpInventoryService.createAdUnitsResponse_element();
        DfpInventoryService.CommonError CommonError = new DfpInventoryService.CommonError();
        DfpInventoryService.updateAdUnit_element updateAdUnit_element = new DfpInventoryService.updateAdUnit_element();
        DfpInventoryService.AdUnitAction AdUnitAction = new DfpInventoryService.AdUnitAction();
        DfpInventoryService.InternalApiError InternalApiError = new DfpInventoryService.InternalApiError();
        DfpInventoryService.Authentication Authentication = new DfpInventoryService.Authentication();
        DfpInventoryService.getAdUnit_element getAdUnit_element = new DfpInventoryService.getAdUnit_element();
        DfpInventoryService.StringLengthError StringLengthError = new DfpInventoryService.StringLengthError();                                                        
        DfpInventoryService.ActivateAdUnits ActivateAdUnits = new DfpInventoryService.ActivateAdUnits();
        DfpInventoryService.performAdUnitAction_element performAdUnitAction_element = new DfpInventoryService.performAdUnitAction_element();
        DfpInventoryService.BooleanValue BooleanValue = new DfpInventoryService.BooleanValue();
        DfpInventoryService.UniqueError UniqueError = new DfpInventoryService.UniqueError();
        DfpInventoryService.getAdUnitSizes_element getAdUnitSizes_element = new DfpInventoryService.getAdUnitSizes_element();
        DfpInventoryService.RequiredError RequiredError = new DfpInventoryService.RequiredError();
        DfpInventoryService.LabelFrequencyCap LabelFrequencyCap = new DfpInventoryService.LabelFrequencyCap();
        DfpInventoryService.AuthenticationError AuthenticationError = new DfpInventoryService.AuthenticationError();                                                        
        DfpInventoryService.PermissionError PermissionError = new DfpInventoryService.PermissionError();
        DfpInventoryService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError= new DfpInventoryService.PublisherQueryLanguageSyntaxError();
        DfpInventoryService.InventoryUnitPartnerAssociationError InventoryUnitPartnerAssociationError = new DfpInventoryService.InventoryUnitPartnerAssociationError();
        DfpInventoryService.InvalidColorError InvalidColorError = new DfpInventoryService.InvalidColorError();
        DfpInventoryService.Size Size = new DfpInventoryService.Size();
        DfpInventoryService.String_ValueMapEntry String_ValueMapEntry = new DfpInventoryService.String_ValueMapEntry();
        DfpInventoryService.AdUnitAfcSizeError AdUnitAfcSizeError = new DfpInventoryService.AdUnitAfcSizeError();
        DfpInventoryService.Value Value = new DfpInventoryService.Value();                                                        
        DfpInventoryService.DeactivateAdUnits DeactivateAdUnits = new DfpInventoryService.DeactivateAdUnits();
        DfpInventoryService.updateAdUnits_element updateAdUnits_element = new DfpInventoryService.updateAdUnits_element();
        DfpInventoryService.OAuth OAuth = new DfpInventoryService.OAuth();
        DfpInventoryService.AdSenseSettingsInheritedProperty AdSenseSettingsInheritedProperty = new DfpInventoryService.AdSenseSettingsInheritedProperty();
        DfpInventoryService.AdUnit AdUnit = new DfpInventoryService.AdUnit();
        DfpInventoryService.InventoryUnitError InventoryUnitError = new DfpInventoryService.InventoryUnitError();
        DfpInventoryService.AdUnitHierarchyError AdUnitHierarchyError = new DfpInventoryService.AdUnitHierarchyError();
        DfpInventoryService.AdUnitCodeError AdUnitCodeError = new DfpInventoryService.AdUnitCodeError();                                                        
        DfpInventoryService.TypeError TypeError = new DfpInventoryService.TypeError();
        DfpInventoryService.NumberValue NumberValue = new DfpInventoryService.NumberValue();
        DfpInventoryService.getAdUnitsByStatement_element getAdUnitsByStatement_element = new DfpInventoryService.getAdUnitsByStatement_element();
        DfpInventoryService.AdUnitSize AdUnitSize = new DfpInventoryService.AdUnitSize();
        DfpInventoryService.SoapResponseHeader SoapResponseHeader = new DfpInventoryService.SoapResponseHeader();
        DfpInventoryService.getAdUnitSizesResponse_element getAdUnitSizesResponse_element = new DfpInventoryService.getAdUnitSizesResponse_element();
        DfpInventoryService.performAdUnitActionResponse_element performAdUnitActionResponse_element = new DfpInventoryService.performAdUnitActionResponse_element();
        DfpInventoryService.RegExError RegExError = new DfpInventoryService.RegExError();                                                        
        DfpInventoryService.updateAdUnitsResponse_element updateAdUnitsResponse_element = new DfpInventoryService.updateAdUnitsResponse_element();
        DfpInventoryService.createAdUnitResponse_element createAdUnitResponse_element = new DfpInventoryService.createAdUnitResponse_element();
        DfpInventoryService.NotNullError NotNullError = new DfpInventoryService.NotNullError();
        DfpInventoryService.AssignAdUnitsToPlacement AssignAdUnitsToPlacement = new DfpInventoryService.AssignAdUnitsToPlacement();
        DfpInventoryService.ArchiveAdUnits ArchiveAdUnits = new DfpInventoryService.ArchiveAdUnits();
        DfpInventoryService.Size_StringMapEntry Size_StringMapEntry = new DfpInventoryService.Size_StringMapEntry();
        DfpInventoryService.DateTimeValue DateTimeValue = new DfpInventoryService.DateTimeValue();
        DfpInventoryService.Statement Statement = new DfpInventoryService.Statement();                                                        
        DfpInventoryService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpInventoryService.PublisherQueryLanguageContextError();
        DfpInventoryService.ApiError ApiError = new DfpInventoryService.ApiError();
        DfpInventoryService.Date_x Date_x = new DfpInventoryService.Date_x();
        DfpInventoryService.SoapRequestHeader SoapRequestHeader = new DfpInventoryService.SoapRequestHeader();
        DfpInventoryService.NullError NullError = new DfpInventoryService.NullError();
        DfpInventoryService.ApiExceptionError ApiExceptionError = new DfpInventoryService.ApiExceptionError();
        DfpInventoryService.InventoryUnitSizesError InventoryUnitSizesError = new DfpInventoryService.InventoryUnitSizesError();
        DfpInventoryService.InventoryServiceInterfacePort InventoryServiceInterfacePort = new DfpInventoryService.InventoryServiceInterfacePort();                                                        
        DfpInventoryService.QuotaError QuotaError = new DfpInventoryService.QuotaError();
        DfpInventoryService.ApplicationExceptionError ApplicationExceptionError = new DfpInventoryService.ApplicationExceptionError();
        DfpInventoryService.AdUnitPage AdUnitPage = new DfpInventoryService.AdUnitPage();
        DfpInventoryService.AdSenseSettings AdSenseSettings = new DfpInventoryService.AdSenseSettings();                                                        
        DfpInventoryService.createAdUnits_element createAdUnits_element = new DfpInventoryService.createAdUnits_element();
        DfpInventoryService.ParseError ParseError = new DfpInventoryService.ParseError();
        DfpInventoryService.ApiVersionError ApiVersionError = new DfpInventoryService.ApiVersionError();
        DfpInventoryService.ServerError ServerError = new DfpInventoryService.ServerError();
        DfpInventoryService.updateAdUnitResponse_element updateAdUnitResponse_element = new DfpInventoryService.updateAdUnitResponse_element();
        DfpInventoryService.FrequencyCapError FrequencyCapError = new DfpInventoryService.FrequencyCapError();
        DfpInventoryService.FrequencyCap FrequencyCap = new DfpInventoryService.FrequencyCap();
        DfpInventoryService.getAdUnitsByStatementResponse_element getAdUnitsByStatementResponse_element = new DfpInventoryService.getAdUnitsByStatementResponse_element();                                                        
        DfpInventoryService.DateTime_x DateTime_x = new DfpInventoryService.DateTime_x();
        DfpInventoryService.StatementError StatementError = new DfpInventoryService.StatementError();
        DfpInventoryService.ClientLogin ClientLogin = new DfpInventoryService.ClientLogin();
        DfpInventoryService.TextValue TextValue = new DfpInventoryService.TextValue();
        DfpInventoryService.UpdateResult UpdateResult = new DfpInventoryService.UpdateResult();
        DfpInventoryService.getAdUnitResponse_element getAdUnitResponse_element = new DfpInventoryService.getAdUnitResponse_element();
        DfpInventoryService.createAdUnit_element createAdUnit_element = new DfpInventoryService.createAdUnit_element();
    
        
        try{
            InventoryServiceInterfacePort.performAdUnitAction(new DfpInventoryService.AdUnitAction(),new DfpInventoryService.Statement());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.updateAdUnits(new list<DfpInventoryService.AdUnit>());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.updateAdUnit(new DfpInventoryService.AdUnit());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.getAdUnitsByStatement(new DfpInventoryService.Statement());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.getAdUnitSizes();
        }catch(Exception e){}                                
        try{
            InventoryServiceInterfacePort.getAdUnit('adUnitId');
        }catch(Exception e){}                                
        try{
            InventoryServiceInterfacePort.createAdUnits(new list<DfpInventoryService.AdUnit>());
        }catch(Exception e){}                                
        try{
            InventoryServiceInterfacePort.createAdUnit(new DfpInventoryService.AdUnit());
        }catch(Exception e){}                                                        
    
    }    
    
    
    public static testMethod void testDfpLineItemService(){
        DfpLineItemService lineitemService = new DfpLineItemService();
        
        DfpLineItemService.CommonError CommonError = new DfpLineItemService.CommonError();
        DfpLineItemService.TechnologyTargetingError TechnologyTargetingError = new DfpLineItemService.TechnologyTargetingError();
        DfpLineItemService.ReserveLineItems ReserveLineItems = new DfpLineItemService.ReserveLineItems();
        DfpLineItemService.InternalApiError InternalApiError = new DfpLineItemService.InternalApiError();
        //DfpLineItemService.LineItemSummary LineItemSummary = new DfpLineItemService.LineItemSummary();
        DfpLineItemService.BandwidthGroup BandwidthGroup = new DfpLineItemService.BandwidthGroup();
        DfpLineItemService.OrderError OrderError = new DfpLineItemService.OrderError();
        DfpLineItemService.DateTimeRangeTargetingError DateTimeRangeTargetingError = new DfpLineItemService.DateTimeRangeTargetingError();
        DfpLineItemService.createLineItem_element createLineItem_element = new DfpLineItemService.createLineItem_element();
        DfpLineItemService.UserDomainTargeting UserDomainTargeting = new DfpLineItemService.UserDomainTargeting();
        DfpLineItemService.InventoryTargetingError InventoryTargetingError = new DfpLineItemService.InventoryTargetingError();
        DfpLineItemService.DayPartTargeting DayPartTargeting = new DfpLineItemService.DayPartTargeting();
        DfpLineItemService.BooleanValue BooleanValue = new DfpLineItemService.BooleanValue();
        DfpLineItemService.RequiredError RequiredError = new DfpLineItemService.RequiredError();
        DfpLineItemService.CustomCriteriaLeaf CustomCriteriaLeaf = new DfpLineItemService.CustomCriteriaLeaf();
        DfpLineItemService.AuthenticationError AuthenticationError = new DfpLineItemService.AuthenticationError();
        DfpLineItemService.PermissionError PermissionError = new DfpLineItemService.PermissionError();
        DfpLineItemService.RegionLocation RegionLocation = new DfpLineItemService.RegionLocation();
        DfpLineItemService.DeviceManufacturerTargeting DeviceManufacturerTargeting = new DfpLineItemService.DeviceManufacturerTargeting();
        DfpLineItemService.updateLineItemsResponse_element updateLineItemsResponse_element = new DfpLineItemService.updateLineItemsResponse_element();
        DfpLineItemService.InventoryTargeting InventoryTargeting = new DfpLineItemService.InventoryTargeting();
        DfpLineItemService.LineItemOperationError LineItemOperationError = new DfpLineItemService.LineItemOperationError();
        DfpLineItemService.MobileDeviceSubmodelTargeting MobileDeviceSubmodelTargeting = new DfpLineItemService.MobileDeviceSubmodelTargeting();
        DfpLineItemService.ReleaseLineItems ReleaseLineItems = new DfpLineItemService.ReleaseLineItems();
        DfpLineItemService.OperatingSystemTargeting OperatingSystemTargeting = new DfpLineItemService.OperatingSystemTargeting();
        DfpLineItemService.MobileDevice MobileDevice = new DfpLineItemService.MobileDevice();
        DfpLineItemService.BandwidthGroupTargeting BandwidthGroupTargeting = new DfpLineItemService.BandwidthGroupTargeting();
        DfpLineItemService.CustomCriteria CustomCriteria = new DfpLineItemService.CustomCriteria();
        DfpLineItemService.NumberValue NumberValue = new DfpLineItemService.NumberValue();
        DfpLineItemService.GeoTargeting GeoTargeting = new DfpLineItemService.GeoTargeting();
        DfpLineItemService.TimeOfDay TimeOfDay = new DfpLineItemService.TimeOfDay();
        DfpLineItemService.AdUnitSize AdUnitSize = new DfpLineItemService.AdUnitSize();                        
        DfpLineItemService.SoapResponseHeader SoapResponseHeader = new DfpLineItemService.SoapResponseHeader();
        DfpLineItemService.CustomCriteriaSet CustomCriteriaSet = new DfpLineItemService.CustomCriteriaSet();
        DfpLineItemService.NotNullError NotNullError = new DfpLineItemService.NotNullError();
        DfpLineItemService.getLineItem_element getLineItem_element = new DfpLineItemService.getLineItem_element();
        DfpLineItemService.createLineItemResponse_element createLineItemResponse_element = new DfpLineItemService.createLineItemResponse_element();
        DfpLineItemService.BrowserLanguageTargeting BrowserLanguageTargeting = new DfpLineItemService.BrowserLanguageTargeting();
        DfpLineItemService.DateTimeValue DateTimeValue = new DfpLineItemService.DateTimeValue();
        DfpLineItemService.CompanyCreditStatusError CompanyCreditStatusError = new DfpLineItemService.CompanyCreditStatusError();
        DfpLineItemService.AdUnitTargeting AdUnitTargeting = new DfpLineItemService.AdUnitTargeting();
        DfpLineItemService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpLineItemService.PublisherQueryLanguageContextError();
        DfpLineItemService.Date_x Date_x = new DfpLineItemService.Date_x();
        DfpLineItemService.SoapRequestHeader SoapRequestHeader = new DfpLineItemService.SoapRequestHeader();
        DfpLineItemService.performLineItemAction_element performLineItemAction_element = new DfpLineItemService.performLineItemAction_element();
        DfpLineItemService.ResumeAndOverbookLineItems ResumeAndOverbookLineItems = new DfpLineItemService.ResumeAndOverbookLineItems();
        DfpLineItemService.NullError NullError = new DfpLineItemService.NullError();
        DfpLineItemService.ApiException ApiException = new DfpLineItemService.ApiException();
        DfpLineItemService.OperatingSystemVersionTargeting OperatingSystemVersionTargeting = new DfpLineItemService.OperatingSystemVersionTargeting();
        DfpLineItemService.ForecastError ForecastError = new DfpLineItemService.ForecastError();
        DfpLineItemService.LineItemPage LineItemPage = new DfpLineItemService.LineItemPage();
        DfpLineItemService.MobileCarrierTargeting MobileCarrierTargeting = new DfpLineItemService.MobileCarrierTargeting();
        DfpLineItemService.ApplicationException ApplicationException = new DfpLineItemService.ApplicationException();
        DfpLineItemService.GenericTargetingError GenericTargetingError = new DfpLineItemService.GenericTargetingError();
        DfpLineItemService.ApiVersionError ApiVersionError = new DfpLineItemService.ApiVersionError();
        DfpLineItemService.Money Money = new DfpLineItemService.Money();
        DfpLineItemService.createLineItemsResponse_element createLineItemsResponse_element = new DfpLineItemService.createLineItemsResponse_element();
        DfpLineItemService.ContentTargeting ContentTargeting = new DfpLineItemService.ContentTargeting();
        DfpLineItemService.ServerError ServerError = new DfpLineItemService.ServerError();
        DfpLineItemService.DateTime_x DateTime_x = new DfpLineItemService.DateTime_x();
        DfpLineItemService.FrequencyCapError FrequencyCapError = new DfpLineItemService.FrequencyCapError();
        DfpLineItemService.UnarchiveLineItems UnarchiveLineItems = new DfpLineItemService.UnarchiveLineItems();
        DfpLineItemService.LineItemError LineItemError = new DfpLineItemService.LineItemError();
        DfpLineItemService.performLineItemActionResponse_element performLineItemActionResponse_element = new DfpLineItemService.performLineItemActionResponse_element();
        DfpLineItemService.DeviceManufacturer DeviceManufacturer = new DfpLineItemService.DeviceManufacturer();
        DfpLineItemService.BrowserLanguage BrowserLanguage = new DfpLineItemService.BrowserLanguage();
        DfpLineItemService.MobileDeviceSubmodel MobileDeviceSubmodel = new DfpLineItemService.MobileDeviceSubmodel();
        DfpLineItemService.TechnologyTargeting TechnologyTargeting = new DfpLineItemService.TechnologyTargeting();
        DfpLineItemService.createLineItems_element createLineItems_element = new DfpLineItemService.createLineItems_element();
        DfpLineItemService.updateLineItem_element updateLineItem_element = new DfpLineItemService.updateLineItem_element();
        DfpLineItemService.CustomCriteriaNode CustomCriteriaNode = new DfpLineItemService.CustomCriteriaNode();
        DfpLineItemService.Authentication Authentication = new DfpLineItemService.Authentication();
        DfpLineItemService.StringLengthError StringLengthError = new DfpLineItemService.StringLengthError();
        DfpLineItemService.CountryLocation CountryLocation = new DfpLineItemService.CountryLocation();
        DfpLineItemService.UserDomainTargetingError UserDomainTargetingError = new DfpLineItemService.UserDomainTargetingError();
        DfpLineItemService.AppliedLabel AppliedLabel = new DfpLineItemService.AppliedLabel();
        DfpLineItemService.ActivateLineItems ActivateLineItems = new DfpLineItemService.ActivateLineItems();
        DfpLineItemService.UniqueError UniqueError = new DfpLineItemService.UniqueError();
        DfpLineItemService.ResumeLineItems ResumeLineItems = new DfpLineItemService.ResumeLineItems();
        DfpLineItemService.getLineItemsByStatementResponse_element getLineItemsByStatementResponse_element = new DfpLineItemService.getLineItemsByStatementResponse_element();  
        DfpLineItemService.DeliveryData DeliveryData = new DfpLineItemService.DeliveryData();
        DfpLineItemService.ClickTrackingLineItemError ClickTrackingLineItemError = new DfpLineItemService.ClickTrackingLineItemError();
        DfpLineItemService.OperatingSystem OperatingSystem = new DfpLineItemService.OperatingSystem();
        DfpLineItemService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpLineItemService.PublisherQueryLanguageSyntaxError();
        DfpLineItemService.String_ValueMapEntry String_ValueMapEntry = new DfpLineItemService.String_ValueMapEntry();
        DfpLineItemService.Size Size = new DfpLineItemService.Size();
        DfpLineItemService.Value Value = new DfpLineItemService.Value();
        DfpLineItemService.OAuth OAuth = new DfpLineItemService.OAuth();
        DfpLineItemService.LineItemCreativeAssociationError LineItemCreativeAssociationError = new DfpLineItemService.LineItemCreativeAssociationError();
        DfpLineItemService.InvalidUrlError InvalidUrlError = new DfpLineItemService.InvalidUrlError();
        DfpLineItemService.VideoPositionTargeting VideoPositionTargeting = new DfpLineItemService.VideoPositionTargeting();
        DfpLineItemService.TypeError TypeError = new DfpLineItemService.TypeError();
        DfpLineItemService.CityLocation CityLocation = new DfpLineItemService.CityLocation();
        DfpLineItemService.RequiredNumberError RequiredNumberError = new DfpLineItemService.RequiredNumberError();
        DfpLineItemService.ReservationDetailsError ReservationDetailsError = new DfpLineItemService.ReservationDetailsError();
        DfpLineItemService.LineItemAction LineItemAction = new DfpLineItemService.LineItemAction();
        DfpLineItemService.ReserveAndOverbookLineItems ReserveAndOverbookLineItems = new DfpLineItemService.ReserveAndOverbookLineItems();
        DfpLineItemService.Technology Technology = new DfpLineItemService.Technology();
        DfpLineItemService.Statement Statement = new DfpLineItemService.Statement();
        DfpLineItemService.ApiError ApiError = new DfpLineItemService.ApiError();
        DfpLineItemService.Targeting Targeting = new DfpLineItemService.Targeting();
        DfpLineItemService.BrowserTargeting BrowserTargeting = new DfpLineItemService.BrowserTargeting();
        DfpLineItemService.Browser Browser = new DfpLineItemService.Browser();
        DfpLineItemService.LineItemServiceInterfacePort LineItemServiceInterfacePort = new DfpLineItemService.LineItemServiceInterfacePort();
        DfpLineItemService.DayPartTargetingError DayPartTargetingError = new DfpLineItemService.DayPartTargetingError();
        DfpLineItemService.QuotaError QuotaError = new DfpLineItemService.QuotaError();
        DfpLineItemService.GeoTargetingError GeoTargetingError = new DfpLineItemService.GeoTargetingError();
        DfpLineItemService.MobileDeviceTargeting MobileDeviceTargeting = new DfpLineItemService.MobileDeviceTargeting();
        DfpLineItemService.getLineItemsByStatement_element getLineItemsByStatement_element = new DfpLineItemService.getLineItemsByStatement_element();
        DfpLineItemService.RangeError RangeError = new DfpLineItemService.RangeError();
        DfpLineItemService.ParseError ParseError = new DfpLineItemService.ParseError();
        DfpLineItemService.PauseLineItems PauseLineItems = new DfpLineItemService.PauseLineItems();
        DfpLineItemService.LabelEntityAssociationError LabelEntityAssociationError = new DfpLineItemService.LabelEntityAssociationError();
        DfpLineItemService.Location Location = new DfpLineItemService.Location();
        DfpLineItemService.FrequencyCap FrequencyCap = new DfpLineItemService.FrequencyCap();
        DfpLineItemService.DeliveryIndicator DeliveryIndicator = new DfpLineItemService.DeliveryIndicator();
        DfpLineItemService.StatementError StatementError = new DfpLineItemService.StatementError();
        DfpLineItemService.MetroLocation MetroLocation = new DfpLineItemService.MetroLocation();
        DfpLineItemService.ClientLogin ClientLogin = new DfpLineItemService.ClientLogin();
        DfpLineItemService.ArchiveLineItems ArchiveLineItems = new DfpLineItemService.ArchiveLineItems();
        DfpLineItemService.CreativePlaceholder CreativePlaceholder = new DfpLineItemService.CreativePlaceholder();
        DfpLineItemService.RequiredCollectionError RequiredCollectionError = new DfpLineItemService.RequiredCollectionError();
        DfpLineItemService.DeleteLineItems DeleteLineItems = new DfpLineItemService.DeleteLineItems();
        DfpLineItemService.updateLineItemResponse_element updateLineItemResponse_element = new DfpLineItemService.updateLineItemResponse_element();
        DfpLineItemService.CustomTargetingError CustomTargetingError = new DfpLineItemService.CustomTargetingError();
        DfpLineItemService.TextValue TextValue = new DfpLineItemService.TextValue();
        DfpLineItemService.LineItemFlightDateError LineItemFlightDateError = new DfpLineItemService.LineItemFlightDateError();
        DfpLineItemService.MobileCarrier MobileCarrier = new DfpLineItemService.MobileCarrier();
        DfpLineItemService.updateLineItems_element updateLineItems_element = new DfpLineItemService.updateLineItems_element();
        DfpLineItemService.getLineItemResponse_element getLineItemResponse_element = new DfpLineItemService.getLineItemResponse_element();
        DfpLineItemService.DayPart DayPart = new DfpLineItemService.DayPart();
        DfpLineItemService.Stats Stats = new DfpLineItemService.Stats();
        DfpLineItemService.UpdateResult UpdateResult = new DfpLineItemService.UpdateResult();
        DfpLineItemService.PostalCodeLocation PostalCodeLocation = new DfpLineItemService.PostalCodeLocation();
        DfpLineItemService.OperatingSystemVersion OperatingSystemVersion = new DfpLineItemService.OperatingSystemVersion();
        DfpLineItemService.LineItem LineItem = new DfpLineItemService.LineItem();
                                                                                             
        try{
            LineItemServiceInterfacePort.getLineItem(10);
        }catch(Exception e){}                                                        
        try{
            LineItemServiceInterfacePort.updateLineItems(new list<DfpLineItemService.LineItem>());
        }catch(Exception e){}                                                        
        try{
            LineItemServiceInterfacePort.createLineItems(new list<DfpLineItemService.LineItem>());
        }catch(Exception e){}                                                        
        try{
            LineItemServiceInterfacePort.getLineItemsByStatement(new DfpLineItemService.Statement());
        }catch(Exception e){}                                                        
        try{
            LineItemServiceInterfacePort.createLineItem(new DfpLineItemService.LineItem());
        }catch(Exception e){}                                                        
        try{
            LineItemServiceInterfacePort.performLineItemAction(new DfpLineItemService.LineItemAction(),new DfpLineItemService.Statement());
        }catch(Exception e){}                                                        
        try{
            LineItemServiceInterfacePort.updateLineItem(new DfpLineItemService.LineItem());
        }catch(Exception e){}                                                                                                        
    
    }

    public static testMethod void testDfpOrderService(){
        DfpOrderService orderService = new DfpOrderService();
        
        DfpOrderService.CommonError CommonError = new DfpOrderService.CommonError();
        DfpOrderService.ApproveOrdersWithoutReservationChanges ApproveOrdersWithoutReservationChanges = new DfpOrderService.ApproveOrdersWithoutReservationChanges();
        DfpOrderService.InternalApiError InternalApiError = new DfpOrderService.InternalApiError();
        DfpOrderService.updateOrder_element updateOrder_element = new DfpOrderService.updateOrder_element();
        DfpOrderService.ApproveOrders ApproveOrders = new DfpOrderService.ApproveOrders();
        DfpOrderService.OrderError OrderError = new DfpOrderService.OrderError();
        DfpOrderService.Authentication Authentication = new DfpOrderService.Authentication();
        DfpOrderService.SubmitOrdersForApprovalAndOverbook SubmitOrdersForApprovalAndOverbook = new DfpOrderService.SubmitOrdersForApprovalAndOverbook();
        DfpOrderService.StringLengthError StringLengthError = new DfpOrderService.StringLengthError();
        DfpOrderService.createOrderResponse_element createOrderResponse_element = new DfpOrderService.createOrderResponse_element();
        DfpOrderService.BooleanValue BooleanValue = new DfpOrderService.BooleanValue();
        DfpOrderService.AppliedLabel AppliedLabel = new DfpOrderService.AppliedLabel();        
        DfpOrderService.UniqueError UniqueError = new DfpOrderService.UniqueError();
        DfpOrderService.RequiredError RequiredError = new DfpOrderService.RequiredError();
        DfpOrderService.PauseOrders PauseOrders = new DfpOrderService.PauseOrders();
        DfpOrderService.OrderPage OrderPage = new DfpOrderService.OrderPage();
        DfpOrderService.AuthenticationError AuthenticationError = new DfpOrderService.AuthenticationError();
        DfpOrderService.PermissionError PermissionError = new DfpOrderService.PermissionError();
        DfpOrderService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpOrderService.PublisherQueryLanguageSyntaxError();
        DfpOrderService.DisapproveOrders DisapproveOrders = new DfpOrderService.DisapproveOrders();
        DfpOrderService.String_ValueMapEntry String_ValueMapEntry = new DfpOrderService.String_ValueMapEntry();
        DfpOrderService.createOrdersResponse_element createOrdersResponse_element = new DfpOrderService.createOrdersResponse_element();
        DfpOrderService.Value Value = new DfpOrderService.Value();
        DfpOrderService.OAuth OAuth = new DfpOrderService.OAuth();                                                                                        
        DfpOrderService.ArchiveOrders ArchiveOrders = new DfpOrderService.ArchiveOrders();
        DfpOrderService.TypeError TypeError = new DfpOrderService.TypeError();
        DfpOrderService.updateOrderResponse_element updateOrderResponse_element = new DfpOrderService.updateOrderResponse_element();
        DfpOrderService.getOrdersByStatement_element getOrdersByStatement_element = new DfpOrderService.getOrdersByStatement_element();                                                                                        
        DfpOrderService.NumberValue NumberValue = new DfpOrderService.NumberValue();
        DfpOrderService.SoapResponseHeader SoapResponseHeader = new DfpOrderService.SoapResponseHeader();
        DfpOrderService.updateOrdersResponse_element updateOrdersResponse_element = new DfpOrderService.updateOrdersResponse_element();
        DfpOrderService.updateOrders_element updateOrders_element = new DfpOrderService.updateOrders_element();                                                                                        
        DfpOrderService.SubmitOrdersForApprovalWithoutReservationChanges SubmitOrdersForApprovalWithoutReservationChanges = new DfpOrderService.SubmitOrdersForApprovalWithoutReservationChanges();
        DfpOrderService.NotNullError NotNullError = new DfpOrderService.NotNullError();
        DfpOrderService.SubmitOrdersForApproval SubmitOrdersForApproval = new DfpOrderService.SubmitOrdersForApproval();
        DfpOrderService.ResumeAndOverbookOrders ResumeAndOverbookOrders = new DfpOrderService.ResumeAndOverbookOrders();                                                                                        
        DfpOrderService.DateTimeValue DateTimeValue = new DfpOrderService.DateTimeValue();
        DfpOrderService.Statement Statement = new DfpOrderService.Statement();
        DfpOrderService.CompanyCreditStatusError CompanyCreditStatusError = new DfpOrderService.CompanyCreditStatusError();
        DfpOrderService.createOrders_element createOrders_element = new DfpOrderService.createOrders_element();                                                                                                                        
        DfpOrderService.Order Order = new DfpOrderService.Order();
        DfpOrderService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpOrderService.PublisherQueryLanguageContextError();
        DfpOrderService.ApiError ApiError = new DfpOrderService.ApiError();                                                                                                                        
        DfpOrderService.DisapproveOrdersWithoutReservationChanges DisapproveOrdersWithoutReservationChanges = new DfpOrderService.DisapproveOrdersWithoutReservationChanges();
        DfpOrderService.Date_x Date_x = new DfpOrderService.Date_x();
        DfpOrderService.SoapRequestHeader SoapRequestHeader = new DfpOrderService.SoapRequestHeader();                                                                                                                        
        DfpOrderService.OrderServiceInterfacePort OrderServiceInterfacePort = new DfpOrderService.OrderServiceInterfacePort();
        DfpOrderService.ApproveAndOverbookOrders ApproveAndOverbookOrders = new DfpOrderService.ApproveAndOverbookOrders();
        DfpOrderService.ApiException ApiException = new DfpOrderService.ApiException();                                                                                                                        
        DfpOrderService.performOrderActionResponse_element performOrderActionResponse_element = new DfpOrderService.performOrderActionResponse_element();
        DfpOrderService.ResumeOrders ResumeOrders = new DfpOrderService.ResumeOrders();
        DfpOrderService.ForecastError ForecastError = new DfpOrderService.ForecastError();                                                                                                                        
        DfpOrderService.QuotaError QuotaError = new DfpOrderService.QuotaError();
        DfpOrderService.OrderActionError OrderActionError = new DfpOrderService.OrderActionError();
        DfpOrderService.ApplicationException ApplicationException = new DfpOrderService.ApplicationException();                                                                                                                        
        DfpOrderService.RangeError RangeError = new DfpOrderService.RangeError();
        DfpOrderService.ParseError ParseError = new DfpOrderService.ParseError();
        DfpOrderService.Money Money = new DfpOrderService.Money();                                                                                                                        
        DfpOrderService.ApiVersionError ApiVersionError = new DfpOrderService.ApiVersionError();
        DfpOrderService.RetractOrdersWithoutReservationChanges RetractOrdersWithoutReservationChanges = new DfpOrderService.RetractOrdersWithoutReservationChanges();
        DfpOrderService.LabelEntityAssociationError LabelEntityAssociationError = new DfpOrderService.LabelEntityAssociationError();                                                                                                                        
        DfpOrderService.ServerError ServerError = new DfpOrderService.ServerError();
        DfpOrderService.OrderAction OrderAction = new DfpOrderService.OrderAction();
        DfpOrderService.createOrder_element createOrder_element = new DfpOrderService.createOrder_element();                                                                                                                        
        DfpOrderService.UnarchiveOrders UnarchiveOrders = new DfpOrderService.UnarchiveOrders();
        DfpOrderService.DateTime_x DateTime_x = new DfpOrderService.DateTime_x();
        DfpOrderService.StatementError StatementError = new DfpOrderService.StatementError();       
        DfpOrderService.ClientLogin ClientLogin = new DfpOrderService.ClientLogin();
        DfpOrderService.RequiredCollectionError RequiredCollectionError = new DfpOrderService.RequiredCollectionError();  
        DfpOrderService.TextValue TextValue = new DfpOrderService.TextValue();
        DfpOrderService.getOrder_element getOrder_element = new DfpOrderService.getOrder_element();  
        DfpOrderService.InvalidEmailError InvalidEmailError = new DfpOrderService.InvalidEmailError();
        DfpOrderService.getOrderResponse_element getOrderResponse_element = new DfpOrderService.getOrderResponse_element();  
        DfpOrderService.RetractOrders RetractOrders = new DfpOrderService.RetractOrders();
        DfpOrderService.UpdateResult UpdateResult = new DfpOrderService.UpdateResult();        
        DfpOrderService.getOrdersByStatementResponse_element getOrdersByStatementResponse_element = new DfpOrderService.getOrdersByStatementResponse_element();  
        DfpOrderService.performOrderAction_element performOrderAction_element = new DfpOrderService.performOrderAction_element();
        DfpOrderService.DeleteOrders DeleteOrders = new DfpOrderService.DeleteOrders();                                                                                                                                                           
        
        try{
            OrderServiceInterfacePort.createOrders(new list<DfpOrderService.Order>());
        }catch(Exception e){}                                                        
        try{
            OrderServiceInterfacePort.updateOrders(new list<DfpOrderService.Order>());
        }catch(Exception e){}
        try{
            OrderServiceInterfacePort.updateOrder(new DfpOrderService.Order());
        }catch(Exception e){}
        try{
            OrderServiceInterfacePort.performOrderAction(new DfpOrderService.OrderAction(),new DfpOrderService.Statement());
        }catch(Exception e){}
        try{
            OrderServiceInterfacePort.getOrdersByStatement(new DfpOrderService.Statement());
        }catch(Exception e){}
        try{
            OrderServiceInterfacePort.getOrder(10);
        }catch(Exception e){}
        try{
            OrderServiceInterfacePort.createOrder(new DfpOrderService.Order());
        }catch(Exception e){}
    
    }    
*/
}