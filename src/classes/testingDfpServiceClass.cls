@isTest
public class testingDfpServiceClass{

    public static testMethod void testDfpCompanyService(){
        
        DfpCompanyService companyService = new DfpCompanyService();
        DfpCompanyService.CommonError ce = new DfpCompanyService.CommonError();
        DfpCompanyService.InternalApiError iae = new DfpCompanyService.InternalApiError();        
     //   DfpCompanyService.Authentication a = new DfpCompanyService.Authentication(); 
        DfpCompanyService.CompanyServiceInterfacePort csip = new DfpCompanyService.CompanyServiceInterfacePort(); 
        DfpCompanyService.BooleanValue BooleanValue = new DfpCompanyService.BooleanValue(); 
        DfpCompanyService.AppliedLabel AppliedLabel = new DfpCompanyService.AppliedLabel(); 
        DfpCompanyService.UniqueError UniqueError  = new DfpCompanyService.UniqueError(); 
        DfpCompanyService.RequiredError RequiredError = new DfpCompanyService.RequiredError(); 
        DfpCompanyService.AuthenticationError AuthenticationError = new DfpCompanyService.AuthenticationError(); 
        DfpCompanyService.PermissionError PermissionError = new DfpCompanyService.PermissionError(); 
        DfpCompanyService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpCompanyService.PublisherQueryLanguageSyntaxError(); 
        DfpCompanyService.Value Value = new DfpCompanyService.Value(); 
        DfpCompanyService.getCompaniesByStatementResponse_element getCompaniesByStatementResponse_element = new DfpCompanyService.getCompaniesByStatementResponse_element(); 
        //DfpCompanyService.OAuth OAuth = new DfpCompanyService.OAuth();
        DfpCompanyService.CompanyPage CompanyPage = new DfpCompanyService.CompanyPage(); 
        DfpCompanyService.updateCompaniesResponse_element updateCompaniesResponse_element = new DfpCompanyService.updateCompaniesResponse_element(); 
        DfpCompanyService.TypeError TypeError = new DfpCompanyService.TypeError(); 
        DfpCompanyService.NumberValue NumberValue = new DfpCompanyService.NumberValue();  
        DfpCompanyService.SoapResponseHeader SoapResponseHeader = new DfpCompanyService.SoapResponseHeader();        
        DfpCompanyService.NotNullError NotNullError = new DfpCompanyService.NotNullError(); 
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
        DfpCompanyService.TextValue TextValue = new DfpCompanyService.TextValue(); 
        DfpCompanyService.TeamError TeamError = new DfpCompanyService.TeamError();
        DfpCompanyService.SetValue SetValue = new DfpCompanyService.SetValue();
        DfpCompanyService.StringLengthError StringLengthError = new DfpCompanyService.StringLengthError();
        DfpCompanyService.CompanyError CompanyError = new DfpCompanyService.CompanyError();
        DfpCompanyService.FeatureError FeatureError = new DfpCompanyService.FeatureError();
        DfpCompanyService.DateValue DateValue = new DfpCompanyService.DateValue();
        DfpCompanyService.String_ValueMapEntry String_ValueMapEntry = new DfpCompanyService.String_ValueMapEntry();
        DfpCompanyService.InvalidEmailError InvalidEmailError = new DfpCompanyService.InvalidEmailError();
        
                
        try{
            csip.getCompaniesByStatement(new DfpCompanyService.Statement());
        }catch(exception e){}        
        
        try{
            csip.createCompanies(new list<DfpCompanyService.Company>());
        }catch(exception e){}
        
        try{
            csip.updateCompanies(new list<DfpCompanyService.Company>());
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
        //DfpForecastService.getForecastResponse_element getForecastResponse_element = new DfpForecastService.getForecastResponse_element();
        DfpForecastService.RequiredError RequiredError = new DfpForecastService.RequiredError();                                                                        
        DfpForecastService.CustomCriteriaLeaf CustomCriteriaLeaf = new DfpForecastService.CustomCriteriaLeaf();
        DfpForecastService.AuthenticationError AuthenticationError = new DfpForecastService.AuthenticationError();
        DfpForecastService.PermissionError PermissionError = new DfpForecastService.PermissionError();
        DfpForecastService.DeviceManufacturerTargeting DeviceManufacturerTargeting = new DfpForecastService.DeviceManufacturerTargeting();
//        DfpForecastService.AdUnitAfcSizeError AdUnitAfcSizeError = new DfpForecastService.AdUnitAfcSizeError();
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
        DfpForecastService.SoapResponseHeader SoapResponseHeader = new DfpForecastService.SoapResponseHeader();
        DfpForecastService.CustomCriteriaSet CustomCriteriaSet = new DfpForecastService.CustomCriteriaSet();
        DfpForecastService.RegExError RegExError = new DfpForecastService.RegExError();
        DfpForecastService.NotNullError NotNullError = new DfpForecastService.NotNullError();
        DfpForecastService.BrowserLanguageTargeting BrowserLanguageTargeting = new DfpForecastService.BrowserLanguageTargeting();
        //DfpForecastService.getForecastByIdResponse_element getForecastByIdResponse_element = new DfpForecastService.getForecastByIdResponse_element();
        DfpForecastService.AdUnitTargeting AdUnitTargeting = new DfpForecastService.AdUnitTargeting();
        DfpForecastService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpForecastService.PublisherQueryLanguageContextError();
        DfpForecastService.Date_x Date_x = new DfpForecastService.Date_x();
        DfpForecastService.SoapRequestHeader SoapRequestHeader = new DfpForecastService.SoapRequestHeader();
        DfpForecastService.NullError NullError = new DfpForecastService.NullError();                    
        DfpForecastService.OperatingSystemVersionTargeting OperatingSystemVersionTargeting = new DfpForecastService.OperatingSystemVersionTargeting();
        DfpForecastService.ApiException ApiException = new DfpForecastService.ApiException();
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
        //DfpForecastService.Authentication Authentication = new DfpForecastService.Authentication();
        DfpForecastService.AppliedLabel AppliedLabel = new DfpForecastService.AppliedLabel();
        DfpForecastService.UniqueError UniqueError = new DfpForecastService.UniqueError();
        DfpForecastService.DeliveryData DeliveryData = new DfpForecastService.DeliveryData();                                                    
        DfpForecastService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpForecastService.PublisherQueryLanguageSyntaxError();
        DfpForecastService.OperatingSystem OperatingSystem = new DfpForecastService.OperatingSystem();
        DfpForecastService.Size Size = new DfpForecastService.Size();
        //DfpForecastService.OAuth OAuth = new DfpForecastService.OAuth();
        DfpForecastService.TypeError TypeError = new DfpForecastService.TypeError();                                                    
        DfpForecastService.VideoPositionTargeting VideoPositionTargeting = new DfpForecastService.VideoPositionTargeting();
        DfpForecastService.RequiredNumberError RequiredNumberError = new DfpForecastService.RequiredNumberError();
        DfpForecastService.ReservationDetailsError ReservationDetailsError = new DfpForecastService.ReservationDetailsError();
        DfpForecastService.Technology Technology = new DfpForecastService.Technology();                                                    
        DfpForecastService.ApiError ApiError = new DfpForecastService.ApiError();
        DfpForecastService.Targeting Targeting = new DfpForecastService.Targeting();
        DfpForecastService.BrowserTargeting BrowserTargeting = new DfpForecastService.BrowserTargeting();
        //DfpForecastService.getForecastById_element getForecastById_element = new DfpForecastService.getForecastById_element();
        DfpForecastService.Browser Browser = new DfpForecastService.Browser();                                                                            
        //DfpForecastService.Forecast Forecast = new DfpForecastService.Forecast();
        DfpForecastService.QuotaError QuotaError = new DfpForecastService.QuotaError();
        DfpForecastService.MobileDeviceTargeting MobileDeviceTargeting = new DfpForecastService.MobileDeviceTargeting();
        DfpForecastService.RangeError RangeError = new DfpForecastService.RangeError();  
        DfpForecastService.ParseError ParseError = new DfpForecastService.ParseError();
        DfpForecastService.Location Location = new DfpForecastService.Location();
        DfpForecastService.FrequencyCap FrequencyCap = new DfpForecastService.FrequencyCap();
        DfpForecastService.StatementError StatementError = new DfpForecastService.StatementError();  
        DfpForecastService.DeliveryIndicator DeliveryIndicator = new DfpForecastService.DeliveryIndicator();
        DfpForecastService.CreativePlaceholder CreativePlaceholder = new DfpForecastService.CreativePlaceholder();
        DfpForecastService.RequiredCollectionError RequiredCollectionError = new DfpForecastService.RequiredCollectionError();
        DfpForecastService.CustomTargetingError CustomTargetingError = new DfpForecastService.CustomTargetingError();
        DfpForecastService.LineItemFlightDateError LineItemFlightDateError = new DfpForecastService.LineItemFlightDateError();
        DfpForecastService.MobileCarrier MobileCarrier = new DfpForecastService.MobileCarrier();  
        DfpForecastService.Stats Stats = new DfpForecastService.Stats();
        DfpForecastService.DayPart DayPart = new DfpForecastService.DayPart();
        DfpForecastService.OperatingSystemVersion OperatingSystemVersion = new DfpForecastService.OperatingSystemVersion();
        DfpForecastService.LineItem LineItem = new DfpForecastService.LineItem();
        DfpForecastService.VideoPositionTarget VideoPositionTarget = new DfpForecastService.VideoPositionTarget();
        DfpForecastService.BaseCustomFieldValue BaseCustomFieldValue = new DfpForecastService.BaseCustomFieldValue();
        DfpForecastService.CustomFieldValue CustomFieldValue = new DfpForecastService.CustomFieldValue();
        DfpForecastService.VideoPosition VideoPosition = new DfpForecastService.VideoPosition();
        DfpForecastService.AudienceSegmentCriteria AudienceSegmentCriteria = new DfpForecastService.AudienceSegmentCriteria();
        DfpForecastService.EntityLimitReachedError EntityLimitReachedError = new DfpForecastService.EntityLimitReachedError();
        DfpForecastService.TeamError TeamError = new DfpForecastService.TeamError();
        DfpForecastService.DeviceCategoryTargeting DeviceCategoryTargeting = new DfpForecastService.DeviceCategoryTargeting();
        DfpForecastService.DeviceCapabilityTargeting DeviceCapabilityTargeting = new DfpForecastService.DeviceCapabilityTargeting();
        DfpForecastService.DeviceCategory DeviceCategory = new DfpForecastService.DeviceCategory();
        DfpForecastService.AudienceExtensionError AudienceExtensionError = new DfpForecastService.AudienceExtensionError();
        DfpForecastService.DropDownCustomFieldValue DropDownCustomFieldValue = new DfpForecastService.DropDownCustomFieldValue();
        DfpForecastService.RequiredSizeError RequiredSizeError = new DfpForecastService.RequiredSizeError();
        DfpForecastService.CustomFieldValueError CustomFieldValueError = new DfpForecastService.CustomFieldValueError();                                                
        DfpForecastService.DeviceCapability DeviceCapability  = new DfpForecastService.DeviceCapability();
        DfpForecastService.TechnologyTargetingError TechnologyTargetingError = new DfpForecastService.TechnologyTargetingError();                           
        DfpForecastService.DateTimeRangeTargetingError DateTimeRangeTargetingError = new DfpForecastService.DateTimeRangeTargetingError();                           
        DfpForecastService.SetValue SetValue = new DfpForecastService.SetValue();                           
        DfpForecastService.BooleanValue BooleanValue = new DfpForecastService.BooleanValue();                           
        DfpForecastService.FeatureError FeatureError = new DfpForecastService.FeatureError();                           
        DfpForecastService.NumberValue NumberValue = new DfpForecastService.NumberValue();                           
        DfpForecastService.DateTimeValue DateTimeValue = new DfpForecastService.DateTimeValue();                           
        DfpForecastService.CompanyCreditStatusError CompanyCreditStatusError = new DfpForecastService.CompanyCreditStatusError();                           
        DfpForecastService.GenericTargetingError GenericTargetingError = new DfpForecastService.GenericTargetingError();                           
        DfpForecastService.ContentMetadataTargetingError ContentMetadataTargetingError = new DfpForecastService.ContentMetadataTargetingError();                           
        DfpForecastService.FrequencyCapError FrequencyCapError = new DfpForecastService.FrequencyCapError();                           
        DfpForecastService.LineItemError LineItemError = new DfpForecastService.LineItemError();                           
        DfpForecastService.CreativeError CreativeError = new DfpForecastService.CreativeError();                           
        DfpForecastService.StringLengthError StringLengthError = new DfpForecastService.StringLengthError();                           
        DfpForecastService.UserDomainTargetingError UserDomainTargetingError = new DfpForecastService.UserDomainTargetingError();                           
        DfpForecastService.ClickTrackingLineItemError ClickTrackingLineItemError = new DfpForecastService.ClickTrackingLineItemError();                           
        DfpForecastService.Value Value = new DfpForecastService.Value();                           
        DfpForecastService.LineItemCreativeAssociationError LineItemCreativeAssociationError = new DfpForecastService.LineItemCreativeAssociationError();                           
        DfpForecastService.ContentMetadataKeyHierarchyTargeting ContentMetadataKeyHierarchyTargeting = new DfpForecastService.ContentMetadataKeyHierarchyTargeting();                           
        DfpForecastService.InvalidUrlError InvalidUrlError = new DfpForecastService.InvalidUrlError();                           
        DfpForecastService.VideoPositionWithinPod VideoPositionWithinPod = new DfpForecastService.VideoPositionWithinPod();                           
        DfpForecastService.DayPartTargetingError DayPartTargetingError = new DfpForecastService.DayPartTargetingError();                           
        DfpForecastService.GeoTargetingError GeoTargetingError = new DfpForecastService.GeoTargetingError();                           
        DfpForecastService.DateValue DateValue = new DfpForecastService.DateValue();                           
        DfpForecastService.LabelEntityAssociationError LabelEntityAssociationError = new DfpForecastService.LabelEntityAssociationError();                           
        DfpForecastService.ContendingLineItem ContendingLineItem = new DfpForecastService.ContendingLineItem();                           
        DfpForecastService.TextValue TextValue = new DfpForecastService.TextValue();                           

        try{
         //   ForecastServiceInterfacePort.getForecast(new DfpLineItemService.LineItem());
        }catch(Exception e){}
        try{
         //   ForecastServiceInterfacePort.getForecastById(10);
        }catch(Exception e){}        
    }    

    public static testMethod void testDfpInventoryService(){
        DfpInventoryService inventoryService = new DfpInventoryService();
        
        DfpInventoryService.createAdUnitsResponse_element createAdUnitsResponse_element = new DfpInventoryService.createAdUnitsResponse_element();
        DfpInventoryService.CommonError CommonError = new DfpInventoryService.CommonError();
        DfpInventoryService.AdUnitAction AdUnitAction = new DfpInventoryService.AdUnitAction();
        DfpInventoryService.InternalApiError InternalApiError = new DfpInventoryService.InternalApiError();
        DfpInventoryService.CreativeWrapperError CreativeWrapperError = new DfpInventoryService.CreativeWrapperError();
        DfpInventoryService.AppliedLabel AppliedLabel = new DfpInventoryService.AppliedLabel();
        DfpInventoryService.EntityLimitReachedError EntityLimitReachedError = new DfpInventoryService.EntityLimitReachedError();
        DfpInventoryService.TeamError TeamError = new DfpInventoryService.TeamError();
        DfpInventoryService.getAdUnitSizesByStatementResponse_element getAdUnitSizesByStatementResponse_element = new DfpInventoryService.getAdUnitSizesByStatementResponse_element();
        DfpInventoryService.AdUnitTypeError AdUnitTypeError = new DfpInventoryService.AdUnitTypeError();
        DfpInventoryService.AdUnitParent AdUnitParent = new DfpInventoryService.AdUnitParent();
        DfpInventoryService.RequiredCollectionError RequiredCollectionError = new DfpInventoryService.RequiredCollectionError();
        DfpInventoryService.RemoveAdUnitsFromPlacement RemoveAdUnitsFromPlacement = new DfpInventoryService.RemoveAdUnitsFromPlacement();
        //DfpInventoryService.Authentication Authentication = new DfpInventoryService.Authentication();
        DfpInventoryService.StringLengthError StringLengthError = new DfpInventoryService.StringLengthError();                                                        
        DfpInventoryService.ActivateAdUnits ActivateAdUnits = new DfpInventoryService.ActivateAdUnits();
        DfpInventoryService.performAdUnitAction_element performAdUnitAction_element = new DfpInventoryService.performAdUnitAction_element();
        DfpInventoryService.BooleanValue BooleanValue = new DfpInventoryService.BooleanValue();
        DfpInventoryService.UniqueError UniqueError = new DfpInventoryService.UniqueError();
        DfpInventoryService.RequiredError RequiredError = new DfpInventoryService.RequiredError();
        DfpInventoryService.LabelFrequencyCap LabelFrequencyCap = new DfpInventoryService.LabelFrequencyCap();
        DfpInventoryService.AuthenticationError AuthenticationError = new DfpInventoryService.AuthenticationError();                                                        
        DfpInventoryService.PermissionError PermissionError = new DfpInventoryService.PermissionError();
        DfpInventoryService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError= new DfpInventoryService.PublisherQueryLanguageSyntaxError();
        DfpInventoryService.InventoryUnitPartnerAssociationError InventoryUnitPartnerAssociationError = new DfpInventoryService.InventoryUnitPartnerAssociationError();
        DfpInventoryService.InvalidColorError InvalidColorError = new DfpInventoryService.InvalidColorError();
        DfpInventoryService.Size Size = new DfpInventoryService.Size();
        DfpInventoryService.String_ValueMapEntry String_ValueMapEntry = new DfpInventoryService.String_ValueMapEntry();
//        DfpInventoryService.AdUnitAfcSizeError AdUnitAfcSizeError = new DfpInventoryService.AdUnitAfcSizeError();
        DfpInventoryService.Value Value = new DfpInventoryService.Value();                                                        
        DfpInventoryService.DeactivateAdUnits DeactivateAdUnits = new DfpInventoryService.DeactivateAdUnits();
        DfpInventoryService.updateAdUnits_element updateAdUnits_element = new DfpInventoryService.updateAdUnits_element();
        //DfpInventoryService.OAuth OAuth = new DfpInventoryService.OAuth();
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
        DfpInventoryService.performAdUnitActionResponse_element performAdUnitActionResponse_element = new DfpInventoryService.performAdUnitActionResponse_element();
        DfpInventoryService.RegExError RegExError = new DfpInventoryService.RegExError();                                                        
        DfpInventoryService.updateAdUnitsResponse_element updateAdUnitsResponse_element = new DfpInventoryService.updateAdUnitsResponse_element();
        DfpInventoryService.NotNullError NotNullError = new DfpInventoryService.NotNullError();
        DfpInventoryService.AssignAdUnitsToPlacement AssignAdUnitsToPlacement = new DfpInventoryService.AssignAdUnitsToPlacement();
        DfpInventoryService.ArchiveAdUnits ArchiveAdUnits = new DfpInventoryService.ArchiveAdUnits();
//        DfpInventoryService.Size_StringMapEntry Size_StringMapEntry = new DfpInventoryService.Size_StringMapEntry();
        DfpInventoryService.DateTimeValue DateTimeValue = new DfpInventoryService.DateTimeValue();
        DfpInventoryService.Statement Statement = new DfpInventoryService.Statement();                                                        
        DfpInventoryService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpInventoryService.PublisherQueryLanguageContextError();
        DfpInventoryService.ApiError ApiError = new DfpInventoryService.ApiError();
        DfpInventoryService.Date_x Date_x = new DfpInventoryService.Date_x();
        DfpInventoryService.SoapRequestHeader SoapRequestHeader = new DfpInventoryService.SoapRequestHeader();
        DfpInventoryService.NullError NullError = new DfpInventoryService.NullError();
        DfpInventoryService.ApiException ApiExceptionError = new DfpInventoryService.ApiException();
        DfpInventoryService.InventoryUnitSizesError InventoryUnitSizesError = new DfpInventoryService.InventoryUnitSizesError();
        DfpInventoryService.InventoryServiceInterfacePort InventoryServiceInterfacePort = new DfpInventoryService.InventoryServiceInterfacePort();                                                        
        DfpInventoryService.QuotaError QuotaError = new DfpInventoryService.QuotaError();
        DfpInventoryService.ApplicationException ApplicationExceptionError = new DfpInventoryService.ApplicationException();
        DfpInventoryService.AdUnitPage AdUnitPage = new DfpInventoryService.AdUnitPage();
        DfpInventoryService.AdSenseSettings AdSenseSettings = new DfpInventoryService.AdSenseSettings();                                                        
        DfpInventoryService.createAdUnits_element createAdUnits_element = new DfpInventoryService.createAdUnits_element();
        DfpInventoryService.ParseError ParseError = new DfpInventoryService.ParseError();
        DfpInventoryService.ApiVersionError ApiVersionError = new DfpInventoryService.ApiVersionError();
        DfpInventoryService.ServerError ServerError = new DfpInventoryService.ServerError();
        DfpInventoryService.FrequencyCapError FrequencyCapError = new DfpInventoryService.FrequencyCapError();
        DfpInventoryService.FrequencyCap FrequencyCap = new DfpInventoryService.FrequencyCap();
        DfpInventoryService.getAdUnitsByStatementResponse_element getAdUnitsByStatementResponse_element = new DfpInventoryService.getAdUnitsByStatementResponse_element();                                                        
        DfpInventoryService.DateTime_x DateTime_x = new DfpInventoryService.DateTime_x();
        DfpInventoryService.StatementError StatementError = new DfpInventoryService.StatementError();
        DfpInventoryService.TextValue TextValue = new DfpInventoryService.TextValue();
        DfpInventoryService.UpdateResult UpdateResult = new DfpInventoryService.UpdateResult();
        DfpInventoryService.AdSenseAccountError AdSenseAccountError = new DfpInventoryService.AdSenseAccountError();        
        DfpInventoryService.SetValue SetValue = new DfpInventoryService.SetValue();        
        DfpInventoryService.FeatureError FeatureError = new DfpInventoryService.FeatureError();        
        DfpInventoryService.DateValue DateValue = new DfpInventoryService.DateValue();        
        
        try{
            InventoryServiceInterfacePort.performAdUnitAction(new DfpInventoryService.AdUnitAction(),new DfpInventoryService.Statement());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.updateAdUnits(new list<DfpInventoryService.AdUnit>());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.getAdUnitsByStatement(new DfpInventoryService.Statement());
        }catch(Exception e){}
        try{
            InventoryServiceInterfacePort.getAdUnitSizesByStatement(new DfpInventoryService.Statement());
        }catch(Exception e){}                                
        try{
            InventoryServiceInterfacePort.createAdUnits(new list<DfpInventoryService.AdUnit>());
        }catch(Exception e){}                                
    
    }    
    
    
    public static testMethod void testDfpLineItemService(){
        DfpLineItemService lineitemService = new DfpLineItemService();
        
        DfpLineItemService.CommonError CommonError = new DfpLineItemService.CommonError();
        DfpLineItemService.TechnologyTargetingError TechnologyTargetingError = new DfpLineItemService.TechnologyTargetingError();
        DfpLineItemService.ReserveLineItems ReserveLineItems = new DfpLineItemService.ReserveLineItems();
        DfpLineItemService.InternalApiError InternalApiError = new DfpLineItemService.InternalApiError();
        DfpLineItemService.BandwidthGroup BandwidthGroup = new DfpLineItemService.BandwidthGroup();
        DfpLineItemService.OrderError OrderError = new DfpLineItemService.OrderError();
        DfpLineItemService.DateTimeRangeTargetingError DateTimeRangeTargetingError = new DfpLineItemService.DateTimeRangeTargetingError();
        DfpLineItemService.UserDomainTargeting UserDomainTargeting = new DfpLineItemService.UserDomainTargeting();
        DfpLineItemService.InventoryTargetingError InventoryTargetingError = new DfpLineItemService.InventoryTargetingError();
        DfpLineItemService.DayPartTargeting DayPartTargeting = new DfpLineItemService.DayPartTargeting();
        DfpLineItemService.BooleanValue BooleanValue = new DfpLineItemService.BooleanValue();
        DfpLineItemService.RequiredError RequiredError = new DfpLineItemService.RequiredError();
        DfpLineItemService.CustomCriteriaLeaf CustomCriteriaLeaf = new DfpLineItemService.CustomCriteriaLeaf();
        DfpLineItemService.AuthenticationError AuthenticationError = new DfpLineItemService.AuthenticationError();
        DfpLineItemService.PermissionError PermissionError = new DfpLineItemService.PermissionError();
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
        DfpLineItemService.SoapResponseHeader SoapResponseHeader = new DfpLineItemService.SoapResponseHeader();
        DfpLineItemService.CustomCriteriaSet CustomCriteriaSet = new DfpLineItemService.CustomCriteriaSet();
        DfpLineItemService.NotNullError NotNullError = new DfpLineItemService.NotNullError();
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
        DfpLineItemService.CustomCriteriaNode CustomCriteriaNode = new DfpLineItemService.CustomCriteriaNode();
        //DfpLineItemService.Authentication Authentication = new DfpLineItemService.Authentication();
        DfpLineItemService.StringLengthError StringLengthError = new DfpLineItemService.StringLengthError();
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
        //DfpLineItemService.OAuth OAuth = new DfpLineItemService.OAuth();
        DfpLineItemService.LineItemCreativeAssociationError LineItemCreativeAssociationError = new DfpLineItemService.LineItemCreativeAssociationError();
        DfpLineItemService.InvalidUrlError InvalidUrlError = new DfpLineItemService.InvalidUrlError();
        DfpLineItemService.VideoPositionTargeting VideoPositionTargeting = new DfpLineItemService.VideoPositionTargeting();
        DfpLineItemService.TypeError TypeError = new DfpLineItemService.TypeError();
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
        DfpLineItemService.ArchiveLineItems ArchiveLineItems = new DfpLineItemService.ArchiveLineItems();
        DfpLineItemService.CreativePlaceholder CreativePlaceholder = new DfpLineItemService.CreativePlaceholder();
        DfpLineItemService.RequiredCollectionError RequiredCollectionError = new DfpLineItemService.RequiredCollectionError();
        DfpLineItemService.DeleteLineItems DeleteLineItems = new DfpLineItemService.DeleteLineItems();
        DfpLineItemService.CustomTargetingError CustomTargetingError = new DfpLineItemService.CustomTargetingError();
        DfpLineItemService.TextValue TextValue = new DfpLineItemService.TextValue();
        DfpLineItemService.LineItemFlightDateError LineItemFlightDateError = new DfpLineItemService.LineItemFlightDateError();
        DfpLineItemService.MobileCarrier MobileCarrier = new DfpLineItemService.MobileCarrier();
        DfpLineItemService.updateLineItems_element updateLineItems_element = new DfpLineItemService.updateLineItems_element();
        DfpLineItemService.DayPart DayPart = new DfpLineItemService.DayPart();
        DfpLineItemService.Stats Stats = new DfpLineItemService.Stats();
        DfpLineItemService.UpdateResult UpdateResult = new DfpLineItemService.UpdateResult();
        DfpLineItemService.OperatingSystemVersion OperatingSystemVersion = new DfpLineItemService.OperatingSystemVersion();
        DfpLineItemService.VideoPositionTarget VideoPositionTarget = new DfpLineItemService.VideoPositionTarget();
        //DfpLineItemService.BaseCustomFieldValue BaseCustomFieldValue = new DfpLineItemService.BaseCustomFieldValue();
        DfpLineItemService.CustomFieldValue CustomFieldValue = new DfpLineItemService.CustomFieldValue();
        DfpLineItemService.VideoPosition VideoPosition = new DfpLineItemService.VideoPosition();
        DfpLineItemService.AudienceSegmentCriteria AudienceSegmentCriteria = new DfpLineItemService.AudienceSegmentCriteria();
        DfpLineItemService.EntityLimitReachedError EntityLimitReachedError = new DfpLineItemService.EntityLimitReachedError();
        DfpLineItemService.TeamError TeamError = new DfpLineItemService.TeamError();
        DfpLineItemService.DeviceCategoryTargeting DeviceCategoryTargeting = new DfpLineItemService.DeviceCategoryTargeting();
        DfpLineItemService.DeviceCapabilityTargeting DeviceCapabilityTargeting = new DfpLineItemService.DeviceCapabilityTargeting();
        DfpLineItemService.DeviceCategory DeviceCategory = new DfpLineItemService.DeviceCategory();
        DfpLineItemService.AudienceExtensionError AudienceExtensionError = new DfpLineItemService.AudienceExtensionError();
        DfpLineItemService.DropDownCustomFieldValue DropDownCustomFieldValue = new DfpLineItemService.DropDownCustomFieldValue();
        DfpLineItemService.RequiredSizeError RequiredSizeError = new DfpLineItemService.RequiredSizeError();
        DfpLineItemService.CustomFieldValueError CustomFieldValueError = new DfpLineItemService.CustomFieldValueError();                                                
        DfpLineItemService.DeviceCapability DeviceCapability  = new DfpLineItemService.DeviceCapability();
        DfpLineItemService.SetValue SetValue = new DfpLineItemService.SetValue();        
        DfpLineItemService.FeatureError FeatureError = new DfpLineItemService.FeatureError();        
        DfpLineItemService.ContentMetadataTargetingError ContentMetadataTargetingError = new DfpLineItemService.ContentMetadataTargetingError();        
        DfpLineItemService.CreativeError CreativeError = new DfpLineItemService.CreativeError();        
        DfpLineItemService.ContentMetadataKeyHierarchyTargeting ContentMetadataKeyHierarchyTargeting = new DfpLineItemService.ContentMetadataKeyHierarchyTargeting();        
        DfpLineItemService.VideoPositionWithinPod VideoPositionWithinPod = new DfpLineItemService.VideoPositionWithinPod();        
        DfpLineItemService.DateValue DateValue = new DfpLineItemService.DateValue();

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
            LineItemServiceInterfacePort.performLineItemAction(new DfpLineItemService.LineItemAction(),new DfpLineItemService.Statement());
        }catch(Exception e){}                                                        
    
    }

    public static testMethod void testDfpOrderService(){
        DfpOrderService orderService = new DfpOrderService();
        
        DfpOrderService.CommonError CommonError = new DfpOrderService.CommonError();
        DfpOrderService.ApproveOrdersWithoutReservationChanges ApproveOrdersWithoutReservationChanges = new DfpOrderService.ApproveOrdersWithoutReservationChanges();
        DfpOrderService.InternalApiError InternalApiError = new DfpOrderService.InternalApiError();
        DfpOrderService.ApproveOrders ApproveOrders = new DfpOrderService.ApproveOrders();
        DfpOrderService.OrderError OrderError = new DfpOrderService.OrderError();
        //DfpOrderService.Authentication Authentication = new DfpOrderService.Authentication();
        DfpOrderService.SubmitOrdersForApprovalAndOverbook SubmitOrdersForApprovalAndOverbook = new DfpOrderService.SubmitOrdersForApprovalAndOverbook();
        DfpOrderService.StringLengthError StringLengthError = new DfpOrderService.StringLengthError();
        DfpOrderService.BooleanValue BooleanValue = new DfpOrderService.BooleanValue();
        DfpOrderService.AppliedLabel AppliedLabel = new DfpOrderService.AppliedLabel();        
        DfpOrderService.UniqueError UniqueError = new DfpOrderService.UniqueError();
        DfpOrderService.RequiredError RequiredError = new DfpOrderService.RequiredError();
        DfpOrderService.PauseOrders PauseOrders = new DfpOrderService.PauseOrders();
        DfpOrderService.OrderPage OrderPage = new DfpOrderService.OrderPage();
        //DfpOrderService.AuthenticationError AuthenticationError = new DfpOrderService.AuthenticationError();
        DfpOrderService.PermissionError PermissionError = new DfpOrderService.PermissionError();
        DfpOrderService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpOrderService.PublisherQueryLanguageSyntaxError();
        DfpOrderService.DisapproveOrders DisapproveOrders = new DfpOrderService.DisapproveOrders();
        DfpOrderService.String_ValueMapEntry String_ValueMapEntry = new DfpOrderService.String_ValueMapEntry();
        DfpOrderService.createOrdersResponse_element createOrdersResponse_element = new DfpOrderService.createOrdersResponse_element();
        DfpOrderService.Value Value = new DfpOrderService.Value();
        //DfpOrderService.OAuth OAuth = new DfpOrderService.OAuth();                                                                                        
        DfpOrderService.ArchiveOrders ArchiveOrders = new DfpOrderService.ArchiveOrders();
        DfpOrderService.TypeError TypeError = new DfpOrderService.TypeError();
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
//        DfpOrderService.OrderAction OrderAction = new DfpOrderService.OrderAction();
        DfpOrderService.UnarchiveOrders UnarchiveOrders = new DfpOrderService.UnarchiveOrders();
        DfpOrderService.DateTime_x DateTime_x = new DfpOrderService.DateTime_x();
        DfpOrderService.StatementError StatementError = new DfpOrderService.StatementError();       
        DfpOrderService.RequiredCollectionError RequiredCollectionError = new DfpOrderService.RequiredCollectionError();  
        DfpOrderService.TextValue TextValue = new DfpOrderService.TextValue();
        DfpOrderService.InvalidEmailError InvalidEmailError = new DfpOrderService.InvalidEmailError();
        DfpOrderService.RetractOrders RetractOrders = new DfpOrderService.RetractOrders();
        DfpOrderService.UpdateResult UpdateResult = new DfpOrderService.UpdateResult();        
        DfpOrderService.getOrdersByStatementResponse_element getOrdersByStatementResponse_element = new DfpOrderService.getOrdersByStatementResponse_element();  
        DfpOrderService.performOrderAction_element performOrderAction_element = new DfpOrderService.performOrderAction_element();
        DfpOrderService.DeleteOrders DeleteOrders = new DfpOrderService.DeleteOrders();      
        DfpOrderService.DropDownCustomFieldValue DropDownCustomFieldValue  = new DfpOrderService.DropDownCustomFieldValue();      
        DfpOrderService.BaseCustomFieldValue BaseCustomFieldValue  = new DfpOrderService.BaseCustomFieldValue(); 
        DfpOrderService.CustomFieldValue CustomFieldValue  = new DfpOrderService.CustomFieldValue(); 
        DfpOrderService.TeamError TeamError  = new DfpOrderService.TeamError(); 
        DfpOrderService.CustomFieldValueError CustomFieldValueError  = new DfpOrderService.CustomFieldValueError(); 
        DfpOrderService.InventoryTargetingError InventoryTargetingError  = new DfpOrderService.InventoryTargetingError(); 
        DfpOrderService.TemplateInstantiatedCreativeError TemplateInstantiatedCreativeError = new DfpOrderService.TemplateInstantiatedCreativeError(); 
        DfpOrderService.FeatureError FeatureError = new DfpOrderService.FeatureError(); 
        DfpOrderService.InvalidUrlError InvalidUrlError = new DfpOrderService.InvalidUrlError(); 
        DfpOrderService.RequiredNumberError RequiredNumberError = new DfpOrderService.RequiredNumberError(); 
        DfpOrderService.EntityLimitReachedError EntityLimitReachedError = new DfpOrderService.EntityLimitReachedError(); 
        DfpOrderService.DateValue DateValue = new DfpOrderService.DateValue(); 

        try{
            OrderServiceInterfacePort.createOrders(new list<DfpOrderService.Order>());
        }catch(Exception e){}                                                        
        try{
            OrderServiceInterfacePort.updateOrders(new list<DfpOrderService.Order>());
        }catch(Exception e){}
        try{
     //       OrderServiceInterfacePort.performOrderAction(new DfpOrderService.OrderAction(),new DfpOrderService.Statement());
        }catch(Exception e){}
        try{
            OrderServiceInterfacePort.getOrdersByStatement(new DfpOrderService.Statement());
        }catch(Exception e){}
    
    }    
    
    public static testMethod void testDfpCustomTargetingService(){
        
        DfpCustomTargetingService customTargetingService = new DfpCustomTargetingService();
        DfpCustomTargetingService.CommonError CommonError  = new DfpCustomTargetingService.CommonError();
        DfpCustomTargetingService.DeleteCustomTargetingKeys DeleteCustomTargetingKeys = new DfpCustomTargetingService.DeleteCustomTargetingKeys();        
        DfpCustomTargetingService.CustomTargetingKeyAction CustomTargetingKeyAction = new DfpCustomTargetingService.CustomTargetingKeyAction();        
        DfpCustomTargetingService.InternalApiError InternalApiError   = new DfpCustomTargetingService.InternalApiError();        
        //DfpCustomTargetingService.Authentication Authentication = new DfpCustomTargetingService.Authentication();        
        DfpCustomTargetingService.createCustomTargetingKeys_element createCustomTargetingKeys_element   = new DfpCustomTargetingService.createCustomTargetingKeys_element();        
        DfpCustomTargetingService.performCustomTargetingValueAction_element performCustomTargetingValueAction_element   = new DfpCustomTargetingService.performCustomTargetingValueAction_element();                                                
        DfpCustomTargetingService.BooleanValue BooleanValue   = new DfpCustomTargetingService.BooleanValue();        
        DfpCustomTargetingService.UniqueError UniqueError   = new DfpCustomTargetingService.UniqueError();        
        DfpCustomTargetingService.CustomTargetingKey CustomTargetingKey   = new DfpCustomTargetingService.CustomTargetingKey();        
        DfpCustomTargetingService.RequiredError RequiredError   = new DfpCustomTargetingService.RequiredError();        
        DfpCustomTargetingService.AuthenticationError AuthenticationError   = new DfpCustomTargetingService.AuthenticationError();        
        DfpCustomTargetingService.updateCustomTargetingValuesResponse_element updateCustomTargetingValuesResponse_element   = new DfpCustomTargetingService.updateCustomTargetingValuesResponse_element();  
        DfpCustomTargetingService.PermissionError PermissionError   = new DfpCustomTargetingService.PermissionError();        
        DfpCustomTargetingService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError   = new DfpCustomTargetingService.PublisherQueryLanguageSyntaxError();        
        DfpCustomTargetingService.String_ValueMapEntry String_ValueMapEntry   = new DfpCustomTargetingService.String_ValueMapEntry();        
        DfpCustomTargetingService.Value Value   = new DfpCustomTargetingService.Value();        
        //DfpCustomTargetingService.OAuth OAuth   = new DfpCustomTargetingService.OAuth();        
        DfpCustomTargetingService.CustomTargetingValue CustomTargetingValue   = new DfpCustomTargetingService.CustomTargetingValue();                                                
        DfpCustomTargetingService.getCustomTargetingValuesByStatementResponse_element getCustomTargetingValuesByStatementResponse_element   = new DfpCustomTargetingService.getCustomTargetingValuesByStatementResponse_element();        
        DfpCustomTargetingService.updateCustomTargetingKeys_element updateCustomTargetingKeys_element   = new DfpCustomTargetingService.updateCustomTargetingKeys_element();        
        DfpCustomTargetingService.updateCustomTargetingKeysResponse_element updateCustomTargetingKeysResponse_element   = new DfpCustomTargetingService.updateCustomTargetingKeysResponse_element();        
        DfpCustomTargetingService.TypeError TypeError   = new DfpCustomTargetingService.TypeError();        
        DfpCustomTargetingService.NumberValue NumberValue   = new DfpCustomTargetingService.NumberValue();        
        DfpCustomTargetingService.SoapResponseHeader SoapResponseHeader   = new DfpCustomTargetingService.SoapResponseHeader();
        DfpCustomTargetingService.createCustomTargetingValuesResponse_element createCustomTargetingValuesResponse_element   = new DfpCustomTargetingService.createCustomTargetingValuesResponse_element();        
        DfpCustomTargetingService.NotNullError NotNullError   = new DfpCustomTargetingService.NotNullError();        
        DfpCustomTargetingService.getCustomTargetingKeysByStatementResponse_element getCustomTargetingKeysByStatementResponse_element   = new DfpCustomTargetingService.getCustomTargetingKeysByStatementResponse_element();        
        DfpCustomTargetingService.CustomTargetingKeyPage CustomTargetingKeyPage  = new DfpCustomTargetingService.CustomTargetingKeyPage();        
        DfpCustomTargetingService.DateTimeValue DateTimeValue = new DfpCustomTargetingService.DateTimeValue();        
        DfpCustomTargetingService.Statement Statement  = new DfpCustomTargetingService.Statement();                                                
        DfpCustomTargetingService.performCustomTargetingKeyAction_element performCustomTargetingKeyAction_element  = new DfpCustomTargetingService.performCustomTargetingKeyAction_element();        
        DfpCustomTargetingService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError  = new DfpCustomTargetingService.PublisherQueryLanguageContextError();        
        DfpCustomTargetingService.ApiError ApiError  = new DfpCustomTargetingService.ApiError();        
        DfpCustomTargetingService.Date_x Date_x = new DfpCustomTargetingService.Date_x();        
        DfpCustomTargetingService.SoapRequestHeader SoapRequestHeader  = new DfpCustomTargetingService.SoapRequestHeader();        
        DfpCustomTargetingService.CustomTargetingServiceInterfacePort CustomTargetingServiceInterfacePort   = new DfpCustomTargetingService.CustomTargetingServiceInterfacePort();
        DfpCustomTargetingService.updateCustomTargetingValues_element updateCustomTargetingValues_element   = new DfpCustomTargetingService.updateCustomTargetingValues_element();        
        DfpCustomTargetingService.NullError NullError   = new DfpCustomTargetingService.NullError();        
        DfpCustomTargetingService.ApiException ApiException  = new DfpCustomTargetingService.ApiException();        
        DfpCustomTargetingService.QuotaError  QuotaError = new DfpCustomTargetingService.QuotaError();        
        DfpCustomTargetingService.createCustomTargetingValues_element createCustomTargetingValues_element  = new DfpCustomTargetingService.createCustomTargetingValues_element();        
        DfpCustomTargetingService.ApplicationException ApplicationException  = new DfpCustomTargetingService.ApplicationException();                                                
        DfpCustomTargetingService.getCustomTargetingValuesByStatement_element getCustomTargetingValuesByStatement_element  = new DfpCustomTargetingService.getCustomTargetingValuesByStatement_element();        
        DfpCustomTargetingService.ApiVersionError ApiVersionError  = new DfpCustomTargetingService.ApiVersionError();        
        DfpCustomTargetingService.ParseError ParseError  = new DfpCustomTargetingService.ParseError();        
        DfpCustomTargetingService.ServerError ServerError  = new DfpCustomTargetingService.ServerError();        
        DfpCustomTargetingService.DateTime_x DateTime_x  = new DfpCustomTargetingService.DateTime_x();        
        DfpCustomTargetingService.CustomTargetingValuePage CustomTargetingValuePage  = new DfpCustomTargetingService.CustomTargetingValuePage();
        DfpCustomTargetingService.CustomTargetingValueAction CustomTargetingValueAction  = new DfpCustomTargetingService.CustomTargetingValueAction();        
        DfpCustomTargetingService.createCustomTargetingKeysResponse_element createCustomTargetingKeysResponse_element  = new DfpCustomTargetingService.createCustomTargetingKeysResponse_element();        
        DfpCustomTargetingService.StatementError StatementError   = new DfpCustomTargetingService.StatementError();        
        DfpCustomTargetingService.performCustomTargetingKeyActionResponse_element performCustomTargetingKeyActionResponse_element  = new DfpCustomTargetingService.performCustomTargetingKeyActionResponse_element();        
        DfpCustomTargetingService.getCustomTargetingKeysByStatement_element getCustomTargetingKeysByStatement_element  = new DfpCustomTargetingService.getCustomTargetingKeysByStatement_element();                                                
        DfpCustomTargetingService.CustomTargetingError CustomTargetingError  = new DfpCustomTargetingService.CustomTargetingError();        
        DfpCustomTargetingService.TextValue TextValue  = new DfpCustomTargetingService.TextValue();        
        DfpCustomTargetingService.UpdateResult UpdateResult  = new DfpCustomTargetingService.UpdateResult();        
        DfpCustomTargetingService.performCustomTargetingValueActionResponse_element performCustomTargetingValueActionResponse_element  = new DfpCustomTargetingService.performCustomTargetingValueActionResponse_element();        
        DfpCustomTargetingService.DeleteCustomTargetingValues DeleteCustomTargetingValues  = new DfpCustomTargetingService.DeleteCustomTargetingValues();        
        DfpCustomTargetingService.SetValue SetValue  = new DfpCustomTargetingService.SetValue();               
        DfpCustomTargetingService.FeatureError FeatureError = new DfpCustomTargetingService.FeatureError();               
        DfpCustomTargetingService.DateValue DateValue = new DfpCustomTargetingService.DateValue();               

        try{
            CustomTargetingServiceInterfacePort.updateCustomTargetingValues(new List<DfpCustomTargetingService.CustomTargetingValue>());
        }catch(Exception e){}
        
        try{
            CustomTargetingServiceInterfacePort.getCustomTargetingKeysByStatement(new DfpCustomTargetingService.Statement());
        }catch(Exception e){}
        
        try{
            CustomTargetingServiceInterfacePort.createCustomTargetingKeys(new List<DfpCustomTargetingService.CustomTargetingKey>());
        }catch(Exception e){}
        
        try{
            CustomTargetingServiceInterfacePort.performCustomTargetingValueAction(new DfpCustomTargetingService.CustomTargetingValueAction(),new DfpCustomTargetingService.Statement());
        }catch(Exception e){}                

        try{
            CustomTargetingServiceInterfacePort.updateCustomTargetingKeys(new list<DfpCustomTargetingService.CustomTargetingKey>());
        }catch(Exception e){}
        
        try{
            CustomTargetingServiceInterfacePort.performCustomTargetingKeyAction(new DfpCustomTargetingService.CustomTargetingKeyAction(),new DfpCustomTargetingService.Statement());
        }catch(Exception e){}
        
        try{
            CustomTargetingServiceInterfacePort.getCustomTargetingValuesByStatement(new DfpCustomTargetingService.Statement());
        }catch(Exception e){}
        
        try{
            CustomTargetingServiceInterfacePort.createCustomTargetingValues(new List<DfpCustomTargetingService.CustomTargetingValue>());
        }catch(Exception e){}                        
    
    }    
    
    public static testMethod void testDfpAudienceSegmentService(){
        DfpAudienceSegmentService dfpAudienceSegmentService = new DfpAudienceSegmentService();
        dfpAudienceSegmentService.CommonError CommonError = new DfpAudienceSegmentService.CommonError();
        dfpAudienceSegmentService.getAudienceSegmentsByStatementResponse_element getAudienceSegmentsByStatementResponse_element = new DfpAudienceSegmentService.getAudienceSegmentsByStatementResponse_element();
        dfpAudienceSegmentService.DateTimeValue DateTimeValue = new DfpAudienceSegmentService.DateTimeValue();
        dfpAudienceSegmentService.AudienceSegment AudienceSegment = new DfpAudienceSegmentService.AudienceSegment();
        dfpAudienceSegmentService.InternalApiError InternalApiError = new DfpAudienceSegmentService.InternalApiError();
        dfpAudienceSegmentService.Statement Statement = new DfpAudienceSegmentService.Statement();
        dfpAudienceSegmentService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpAudienceSegmentService.PublisherQueryLanguageContextError();
        dfpAudienceSegmentService.ApiError ApiError = new DfpAudienceSegmentService.ApiError();
        dfpAudienceSegmentService.Date_x Date_x = new DfpAudienceSegmentService.Date_x();
        dfpAudienceSegmentService.SoapRequestHeader SoapRequestHeader = new DfpAudienceSegmentService.SoapRequestHeader();
        //dfpAudienceSegmentService.Authentication Authentication = new DfpAudienceSegmentService.Authentication();
        dfpAudienceSegmentService.BooleanValue BooleanValue = new DfpAudienceSegmentService.BooleanValue();
        dfpAudienceSegmentService.ApiException ApiException = new DfpAudienceSegmentService.ApiException();        
        dfpAudienceSegmentService.RequiredError RequiredError = new DfpAudienceSegmentService.RequiredError();        
        dfpAudienceSegmentService.AuthenticationError AuthenticationError = new DfpAudienceSegmentService.AuthenticationError();        
        dfpAudienceSegmentService.PermissionError PermissionError = new DfpAudienceSegmentService.PermissionError();        
        dfpAudienceSegmentService.QuotaError QuotaError = new DfpAudienceSegmentService.QuotaError();        
        dfpAudienceSegmentService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpAudienceSegmentService.PublisherQueryLanguageSyntaxError();        
        dfpAudienceSegmentService.AudienceSegmentPage AudienceSegmentPage = new DfpAudienceSegmentService.AudienceSegmentPage();        
        dfpAudienceSegmentService.String_ValueMapEntry String_ValueMapEntry = new DfpAudienceSegmentService.String_ValueMapEntry();        
        dfpAudienceSegmentService.ApplicationException ApplicationException = new DfpAudienceSegmentService.ApplicationException();        
        dfpAudienceSegmentService.Value Value = new DfpAudienceSegmentService.Value();        
        dfpAudienceSegmentService.ApiVersionError ApiVersionError = new DfpAudienceSegmentService.ApiVersionError();        
        //dfpAudienceSegmentService.OAuth OAuth = new DfpAudienceSegmentService.OAuth();        
        dfpAudienceSegmentService.ServerError ServerError = new DfpAudienceSegmentService.ServerError();        
        dfpAudienceSegmentService.DateTime_x DateTime_x = new DfpAudienceSegmentService.DateTime_x();        
        dfpAudienceSegmentService.StatementError StatementError = new DfpAudienceSegmentService.StatementError();        
        dfpAudienceSegmentService.NumberValue NumberValue = new DfpAudienceSegmentService.NumberValue();        
        dfpAudienceSegmentService.TextValue TextValue = new DfpAudienceSegmentService.TextValue();        
        dfpAudienceSegmentService.SoapResponseHeader SoapResponseHeader = new DfpAudienceSegmentService.SoapResponseHeader();        
        dfpAudienceSegmentService.getAudienceSegmentsByStatement_element getAudienceSegmentsByStatement_element = new DfpAudienceSegmentService.getAudienceSegmentsByStatement_element();        
        dfpAudienceSegmentService.NotNullError NotNullError = new DfpAudienceSegmentService.NotNullError();        
        dfpAudienceSegmentService.AudienceSegmentServiceInterfacePort AudienceSegmentServiceInterfacePort = new dfpAudienceSegmentService.AudienceSegmentServiceInterfacePort();
        dfpAudienceSegmentService.AudienceSegmentAction AudienceSegmentAction = new dfpAudienceSegmentService.AudienceSegmentAction();
        dfpAudienceSegmentService.FirstPartyAudienceSegment FirstPartyAudienceSegment = new dfpAudienceSegmentService.FirstPartyAudienceSegment();
        //dfpAudienceSegmentService.ThirdPartyAudienceSegment ThirdPartyAudienceSegment = new dfpAudienceSegmentService.ThirdPartyAudienceSegment();
        dfpAudienceSegmentService.DeactivateAudienceSegments DeactivateAudienceSegments = new dfpAudienceSegmentService.DeactivateAudienceSegments();
        dfpAudienceSegmentService.FirstPartyAudienceSegmentRule FirstPartyAudienceSegmentRule = new dfpAudienceSegmentService.FirstPartyAudienceSegmentRule();
        dfpAudienceSegmentService.RejectAudienceSegments RejectAudienceSegments = new dfpAudienceSegmentService.RejectAudienceSegments();
        dfpAudienceSegmentService.CustomCriteriaNode CustomCriteriaNode = new dfpAudienceSegmentService.CustomCriteriaNode();
        dfpAudienceSegmentService.AudienceSegmentDataProvider AudienceSegmentDataProvider = new dfpAudienceSegmentService.AudienceSegmentDataProvider();
        dfpAudienceSegmentService.SetValue SetValue = new dfpAudienceSegmentService.SetValue();
        dfpAudienceSegmentService.PopulateAudienceSegments PopulateAudienceSegments = new dfpAudienceSegmentService.PopulateAudienceSegments();
        dfpAudienceSegmentService.NonRuleBasedFirstPartyAudienceSegment NonRuleBasedFirstPartyAudienceSegment = new dfpAudienceSegmentService.NonRuleBasedFirstPartyAudienceSegment();
        dfpAudienceSegmentService.ApproveAudienceSegments ApproveAudienceSegments = new dfpAudienceSegmentService.ApproveAudienceSegments();
        dfpAudienceSegmentService.CustomCriteriaLeaf CustomCriteriaLeaf = new dfpAudienceSegmentService.CustomCriteriaLeaf();
        dfpAudienceSegmentService.FeatureError FeatureError = new dfpAudienceSegmentService.FeatureError();
        dfpAudienceSegmentService.InventoryTargeting InventoryTargeting = new dfpAudienceSegmentService.InventoryTargeting();
        dfpAudienceSegmentService.updateAudienceSegmentsResponse_element updateAudienceSegmentsResponse_element = new dfpAudienceSegmentService.updateAudienceSegmentsResponse_element();
        dfpAudienceSegmentService.RuleBasedFirstPartyAudienceSegmentSummary RuleBasedFirstPartyAudienceSegmentSummary = new dfpAudienceSegmentService.RuleBasedFirstPartyAudienceSegmentSummary();
        dfpAudienceSegmentService.CustomCriteria CustomCriteria = new dfpAudienceSegmentService.CustomCriteria();
        dfpAudienceSegmentService.CustomCriteriaSet CustomCriteriaSet = new dfpAudienceSegmentService.CustomCriteriaSet();
        dfpAudienceSegmentService.AudienceSegmentCriteria AudienceSegmentCriteria = new dfpAudienceSegmentService.AudienceSegmentCriteria();
        dfpAudienceSegmentService.performAudienceSegmentAction_element performAudienceSegmentAction_element = new dfpAudienceSegmentService.performAudienceSegmentAction_element();
        dfpAudienceSegmentService.createAudienceSegments_element createAudienceSegments_element = new dfpAudienceSegmentService.createAudienceSegments_element();
        dfpAudienceSegmentService.SharedAudienceSegment SharedAudienceSegment = new dfpAudienceSegmentService.SharedAudienceSegment();
        dfpAudienceSegmentService.AdUnitTargeting AdUnitTargeting = new dfpAudienceSegmentService.AdUnitTargeting();
        dfpAudienceSegmentService.performAudienceSegmentActionResponse_element performAudienceSegmentActionResponse_element = new dfpAudienceSegmentService.performAudienceSegmentActionResponse_element();
        dfpAudienceSegmentService.AudienceSegmentError AudienceSegmentError = new dfpAudienceSegmentService.AudienceSegmentError();
        dfpAudienceSegmentService.createAudienceSegmentsResponse_element createAudienceSegmentsResponse_element = new dfpAudienceSegmentService.createAudienceSegmentsResponse_element();
        dfpAudienceSegmentService.RuleBasedFirstPartyAudienceSegment RuleBasedFirstPartyAudienceSegment = new dfpAudienceSegmentService.RuleBasedFirstPartyAudienceSegment();
        dfpAudienceSegmentService.ActivateAudienceSegments ActivateAudienceSegments = new dfpAudienceSegmentService.ActivateAudienceSegments();
        dfpAudienceSegmentService.DateValue DateValue = new dfpAudienceSegmentService.DateValue();
        dfpAudienceSegmentService.Money Money = new dfpAudienceSegmentService.Money();
        dfpAudienceSegmentService.updateAudienceSegments_element updateAudienceSegments_element = new dfpAudienceSegmentService.updateAudienceSegments_element();
        dfpAudienceSegmentService.UpdateResult UpdateResult = new dfpAudienceSegmentService.UpdateResult();

        try {
            AudienceSegmentServiceInterfacePort.getAudienceSegmentsByStatement(new DfpAudienceSegmentService.Statement());
        } catch(Exception e) {}     
        try {
            AudienceSegmentServiceInterfacePort.performAudienceSegmentAction(new DfpAudienceSegmentService.AudienceSegmentAction(),new DfpAudienceSegmentService.Statement());
        } catch(Exception e) {}     
        try {
            AudienceSegmentServiceInterfacePort.createAudienceSegments(new DfpAudienceSegmentService.FirstPartyAudienceSegment[]{});
        } catch(Exception e) {}     
        try {
            AudienceSegmentServiceInterfacePort.createAudienceSegments(new DfpAudienceSegmentService.FirstPartyAudienceSegment[]{});
        } catch(Exception e) {}     
                                                                
    }

    public static testMethod void testDfpPublisherQueryLanguageService(){
        
        DfpPublisherQueryLanguageService publisherQueryLanguageService = new DfpPublisherQueryLanguageService();
        DfpPublisherQueryLanguageService.CommonError CommonError  = new DfpPublisherQueryLanguageService.CommonError();
        DfpPublisherQueryLanguageService.ResultSet ResultSet = new DfpPublisherQueryLanguageService.ResultSet();
        DfpPublisherQueryLanguageService.InternalApiError InternalApiError = new DfpPublisherQueryLanguageService.InternalApiError();
        DfpPublisherQueryLanguageService.OrderError OrderError = new DfpPublisherQueryLanguageService.OrderError();
        //DfpPublisherQueryLanguageService.Authentication Authentication = new DfpPublisherQueryLanguageService.Authentication();
        DfpPublisherQueryLanguageService.InventoryTargetingError InventoryTargetingError = new DfpPublisherQueryLanguageService.InventoryTargetingError();
        DfpPublisherQueryLanguageService.BooleanValue BooleanValue = new DfpPublisherQueryLanguageService.BooleanValue();
        DfpPublisherQueryLanguageService.UniqueError UniqueError = new DfpPublisherQueryLanguageService.UniqueError();
        DfpPublisherQueryLanguageService.RequiredError RequiredError = new DfpPublisherQueryLanguageService.RequiredError();
        DfpPublisherQueryLanguageService.AuthenticationError AuthenticationError = new DfpPublisherQueryLanguageService.AuthenticationError();
        DfpPublisherQueryLanguageService.PermissionError PermissionError = new DfpPublisherQueryLanguageService.PermissionError();  
        DfpPublisherQueryLanguageService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpPublisherQueryLanguageService.PublisherQueryLanguageSyntaxError();
        DfpPublisherQueryLanguageService.String_ValueMapEntry String_ValueMapEntry = new DfpPublisherQueryLanguageService.String_ValueMapEntry();
//        DfpPublisherQueryLanguageService.AdUnitAfcSizeError AdUnitAfcSizeError = new DfpPublisherQueryLanguageService.AdUnitAfcSizeError();
        DfpPublisherQueryLanguageService.LineItemOperationError LineItemOperationError = new DfpPublisherQueryLanguageService.LineItemOperationError();
        DfpPublisherQueryLanguageService.Value Value = new DfpPublisherQueryLanguageService.Value();
        //DfpPublisherQueryLanguageService.OAuth OAuth = new DfpPublisherQueryLanguageService.OAuth();
        DfpPublisherQueryLanguageService.FileError FileError = new DfpPublisherQueryLanguageService.FileError();
        DfpPublisherQueryLanguageService.InvalidUrlError InvalidUrlError = new DfpPublisherQueryLanguageService.InvalidUrlError();
        DfpPublisherQueryLanguageService.InventoryUnitError InventoryUnitError = new DfpPublisherQueryLanguageService.InventoryUnitError();
        DfpPublisherQueryLanguageService.AdUnitHierarchyError AdUnitHierarchyError = new DfpPublisherQueryLanguageService.AdUnitHierarchyError();
        DfpPublisherQueryLanguageService.AdUnitCodeError AdUnitCodeError = new DfpPublisherQueryLanguageService.AdUnitCodeError();
        DfpPublisherQueryLanguageService.TypeError TypeError = new DfpPublisherQueryLanguageService.TypeError();
        DfpPublisherQueryLanguageService.RequiredSizeError RequiredSizeError = new DfpPublisherQueryLanguageService.RequiredSizeError();
        DfpPublisherQueryLanguageService.NumberValue NumberValue = new DfpPublisherQueryLanguageService.NumberValue();
        DfpPublisherQueryLanguageService.RequiredNumberError RequiredNumberError = new DfpPublisherQueryLanguageService.RequiredNumberError();
        DfpPublisherQueryLanguageService.ReservationDetailsError ReservationDetailsError = new DfpPublisherQueryLanguageService.ReservationDetailsError();
        DfpPublisherQueryLanguageService.SoapResponseHeader SoapResponseHeader = new DfpPublisherQueryLanguageService.SoapResponseHeader();
        DfpPublisherQueryLanguageService.Row Row = new DfpPublisherQueryLanguageService.Row();
        DfpPublisherQueryLanguageService.RegExError RegExError = new DfpPublisherQueryLanguageService.RegExError();
        DfpPublisherQueryLanguageService.ColumnType ColumnType = new DfpPublisherQueryLanguageService.ColumnType();
        DfpPublisherQueryLanguageService.select_element select_element = new DfpPublisherQueryLanguageService.select_element();
        DfpPublisherQueryLanguageService.NotNullError NotNullError = new DfpPublisherQueryLanguageService.NotNullError();
        DfpPublisherQueryLanguageService.selectResponse_element selectResponse_element = new DfpPublisherQueryLanguageService.selectResponse_element();
        DfpPublisherQueryLanguageService.DateTimeValue DateTimeValue = new DfpPublisherQueryLanguageService.DateTimeValue();
        DfpPublisherQueryLanguageService.Statement Statement = new DfpPublisherQueryLanguageService.Statement();
        DfpPublisherQueryLanguageService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpPublisherQueryLanguageService.PublisherQueryLanguageContextError();
        DfpPublisherQueryLanguageService.ApiError ApiError = new DfpPublisherQueryLanguageService.ApiError();
        DfpPublisherQueryLanguageService.Date_x Date_x = new DfpPublisherQueryLanguageService.Date_x();
        DfpPublisherQueryLanguageService.SoapRequestHeader SoapRequestHeader = new DfpPublisherQueryLanguageService.SoapRequestHeader();
        DfpPublisherQueryLanguageService.NullError NullError = new DfpPublisherQueryLanguageService.NullError();                
        DfpPublisherQueryLanguageService.ApiException ApiException = new DfpPublisherQueryLanguageService.ApiException();
        DfpPublisherQueryLanguageService.QuotaError QuotaError = new DfpPublisherQueryLanguageService.QuotaError();
        DfpPublisherQueryLanguageService.OrderActionError OrderActionError = new DfpPublisherQueryLanguageService.OrderActionError();                
        DfpPublisherQueryLanguageService.ApplicationException ApplicationException = new DfpPublisherQueryLanguageService.ApplicationException();
        DfpPublisherQueryLanguageService.RangeError RangeError = new DfpPublisherQueryLanguageService.RangeError();
        DfpPublisherQueryLanguageService.ApiVersionError ApiVersionError = new DfpPublisherQueryLanguageService.ApiVersionError();                
        DfpPublisherQueryLanguageService.ParseError ParseError = new DfpPublisherQueryLanguageService.ParseError();
        DfpPublisherQueryLanguageService.ServerError ServerError = new DfpPublisherQueryLanguageService.ServerError();
        DfpPublisherQueryLanguageService.DateTime_x DateTime_x = new DfpPublisherQueryLanguageService.DateTime_x();                
        DfpPublisherQueryLanguageService.StatementError StatementError = new DfpPublisherQueryLanguageService.StatementError();
        DfpPublisherQueryLanguageService.RequiredCollectionError RequiredCollectionError = new DfpPublisherQueryLanguageService.RequiredCollectionError();                                                
        DfpPublisherQueryLanguageService.TextValue TextValue = new DfpPublisherQueryLanguageService.TextValue();
        DfpPublisherQueryLanguageService.LineItemFlightDateError LineItemFlightDateError = new DfpPublisherQueryLanguageService.LineItemFlightDateError();                                                
        DfpPublisherQueryLanguageService.InvalidEmailError InvalidEmailError = new DfpPublisherQueryLanguageService.InvalidEmailError();
        DfpPublisherQueryLanguageService.CreativeError CreativeError = new DfpPublisherQueryLanguageService.CreativeError();                                                
        DfpPublisherQueryLanguageService.PublisherQueryLanguageServiceInterfacePort PublisherQueryLanguageServiceInterfacePort = new DfpPublisherQueryLanguageService.PublisherQueryLanguageServiceInterfacePort();
        DfpPublisherQueryLanguageService.SetValue SetValue = new DfpPublisherQueryLanguageService.SetValue();
        DfpPublisherQueryLanguageService.FeatureError FeatureError = new DfpPublisherQueryLanguageService.FeatureError();
        DfpPublisherQueryLanguageService.ExchangeRateError ExchangeRateError = new DfpPublisherQueryLanguageService.ExchangeRateError();
        DfpPublisherQueryLanguageService.DateValue DateValue = new DfpPublisherQueryLanguageService.DateValue();

        try{
            PublisherQueryLanguageServiceInterfacePort.select_x(new DfpPublisherQueryLanguageService.Statement());
        }catch(Exception e){}
        
    }
    
    public static testMethod void testDfpPlacementService(){
        
        DfpPlacementService PlacementService = new DfpPlacementService();
        DfpPlacementService.CommonError CommonError = new DfpPlacementService.CommonError();
        DfpPlacementService.InternalApiError InternalApiError = new DfpPlacementService.InternalApiError();
       // DfpPlacementService.Authentication Authentication = new DfpPlacementService.Authentication();
        DfpPlacementService.StringLengthError StringLengthError = new DfpPlacementService.StringLengthError();
        DfpPlacementService.updatePlacements_element updatePlacements_element = new DfpPlacementService.updatePlacements_element();
        DfpPlacementService.BooleanValue BooleanValue = new DfpPlacementService.BooleanValue();
        DfpPlacementService.UniqueError UniqueError = new DfpPlacementService.UniqueError();
        DfpPlacementService.updatePlacementsResponse_element updatePlacementsResponse_element = new DfpPlacementService.updatePlacementsResponse_element();
        DfpPlacementService.RequiredError RequiredError = new DfpPlacementService.RequiredError();
        DfpPlacementService.AuthenticationError AuthenticationError = new DfpPlacementService.AuthenticationError();                                                                                
        DfpPlacementService.PermissionError PermissionError = new DfpPlacementService.PermissionError();
        DfpPlacementService.createPlacements_element createPlacements_element = new DfpPlacementService.createPlacements_element();
        DfpPlacementService.performPlacementActionResponse_element performPlacementActionResponse_element = new DfpPlacementService.performPlacementActionResponse_element();
        DfpPlacementService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpPlacementService.PublisherQueryLanguageSyntaxError();
        DfpPlacementService.PlacementServiceInterfacePort PlacementServiceInterfacePort = new DfpPlacementService.PlacementServiceInterfacePort();
        DfpPlacementService.String_ValueMapEntry String_ValueMapEntry = new DfpPlacementService.String_ValueMapEntry();
        DfpPlacementService.Value Value = new DfpPlacementService.Value();
        //DfpPlacementService.OAuth OAuth = new DfpPlacementService.OAuth();
        DfpPlacementService.SiteTargetingInfo SiteTargetingInfo = new DfpPlacementService.SiteTargetingInfo();
        DfpPlacementService.TypeError TypeError = new DfpPlacementService.TypeError();
        DfpPlacementService.NumberValue NumberValue = new DfpPlacementService.NumberValue();
        DfpPlacementService.SoapResponseHeader SoapResponseHeader = new DfpPlacementService.SoapResponseHeader();
        DfpPlacementService.RegExError RegExError = new DfpPlacementService.RegExError();
        DfpPlacementService.NotNullError NotNullError = new DfpPlacementService.NotNullError();
        DfpPlacementService.getPlacementsByStatement_element getPlacementsByStatement_element = new DfpPlacementService.getPlacementsByStatement_element();
        DfpPlacementService.DateTimeValue DateTimeValue = new DfpPlacementService.DateTimeValue();
        DfpPlacementService.Statement Statement = new DfpPlacementService.Statement();
        DfpPlacementService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpPlacementService.PublisherQueryLanguageContextError();
        DfpPlacementService.ApiError ApiError = new DfpPlacementService.ApiError();
        DfpPlacementService.Date_x Date_x = new DfpPlacementService.Date_x();
        DfpPlacementService.SoapRequestHeader SoapRequestHeader = new DfpPlacementService.SoapRequestHeader();
        DfpPlacementService.Placement Placement = new DfpPlacementService.Placement();
        DfpPlacementService.NullError NullError = new DfpPlacementService.NullError();
        DfpPlacementService.ApiException ApiException = new DfpPlacementService.ApiException();
        DfpPlacementService.QuotaError QuotaError = new DfpPlacementService.QuotaError();
        DfpPlacementService.createPlacementsResponse_element createPlacementsResponse_element = new DfpPlacementService.createPlacementsResponse_element();
        DfpPlacementService.ApplicationException ApplicationException = new DfpPlacementService.ApplicationException(); 
        DfpPlacementService.performPlacementAction_element performPlacementAction_element = new DfpPlacementService.performPlacementAction_element();
        DfpPlacementService.RangeError RangeError = new DfpPlacementService.RangeError();
        DfpPlacementService.PlacementAction PlacementAction = new DfpPlacementService.PlacementAction();
        DfpPlacementService.ParseError ParseError = new DfpPlacementService.ParseError();
        DfpPlacementService.ApiVersionError ApiVersionError = new DfpPlacementService.ApiVersionError();
        DfpPlacementService.DeactivatePlacements DeactivatePlacements = new DfpPlacementService.DeactivatePlacements();
        DfpPlacementService.ServerError ServerError = new DfpPlacementService.ServerError();
        DfpPlacementService.DateTime_x DateTime_x = new DfpPlacementService.DateTime_x();
        DfpPlacementService.StatementError StatementError = new DfpPlacementService.StatementError();
        DfpPlacementService.RequiredCollectionError RequiredCollectionError = new DfpPlacementService.RequiredCollectionError();
        DfpPlacementService.TextValue TextValue = new DfpPlacementService.TextValue();
        DfpPlacementService.PlacementPage PlacementPage = new DfpPlacementService.PlacementPage(); 
        DfpPlacementService.UpdateResult UpdateResult = new DfpPlacementService.UpdateResult();
        DfpPlacementService.getPlacementsByStatementResponse_element getPlacementsByStatementResponse_element = new DfpPlacementService.getPlacementsByStatementResponse_element();
        DfpPlacementService.ActivatePlacements ActivatePlacements = new DfpPlacementService.ActivatePlacements();
        DfpPlacementService.ArchivePlacements ArchivePlacements = new DfpPlacementService.ArchivePlacements();
        DfpPlacementService.SetValue SetValue = new DfpPlacementService.SetValue();        
        DfpPlacementService.FeatureError FeatureError = new DfpPlacementService.FeatureError();        
        DfpPlacementService.PlacementError PlacementError = new DfpPlacementService.PlacementError();        
        DfpPlacementService.EntityLimitReachedError EntityLimitReachedError = new DfpPlacementService.EntityLimitReachedError();        
        DfpPlacementService.DateValue DateValue = new DfpPlacementService.DateValue();        

        try{
            PlacementServiceInterfacePort.updatePlacements(new list<DfpPlacementService.Placement>());
        }catch(Exception e){}
        
        try{
            PlacementServiceInterfacePort.createPlacements(new list<DfpPlacementService.Placement>());
        }catch(Exception e){}
        
        try{
            PlacementServiceInterfacePort.getPlacementsByStatement(new DfpPlacementService.Statement());
        }catch(Exception e){}
        
        try{
            PlacementServiceInterfacePort.performPlacementAction(new DfpPlacementService.PlacementAction(),new DfpPlacementService.Statement());
        }catch(Exception e){}
        
    }    
    
    public static testMethod void testDfpLabelService(){
        
        DfpLabelService LabelService = new DfpLabelService();
        DfpLabelService.CommonError CommonError = new DfpLabelService.CommonError();
        DfpLabelService.InternalApiError InternalApiError = new DfpLabelService.InternalApiError();
        //DfpLabelService.Authentication Authentication = new DfpLabelService.Authentication();
        DfpLabelService.StringLengthError StringLengthError = new DfpLabelService.StringLengthError();
        DfpLabelService.updateLabels_element updateLabels_element = new DfpLabelService.updateLabels_element();
        DfpLabelService.BooleanValue BooleanValue = new DfpLabelService.BooleanValue();
        DfpLabelService.UniqueError UniqueError = new DfpLabelService.UniqueError();
        DfpLabelService.RequiredError RequiredError = new DfpLabelService.RequiredError();
        DfpLabelService.AuthenticationError AuthenticationError = new DfpLabelService.AuthenticationError();
        DfpLabelService.createLabelsResponse_element createLabelsResponse_element = new DfpLabelService.createLabelsResponse_element();
        DfpLabelService.PermissionError PermissionError = new DfpLabelService.PermissionError();
        DfpLabelService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpLabelService.PublisherQueryLanguageSyntaxError();
        DfpLabelService.String_ValueMapEntry String_ValueMapEntry = new DfpLabelService.String_ValueMapEntry();
        DfpLabelService.Value Value = new DfpLabelService.Value();
        //DfpLabelService.OAuth OAuth = new DfpLabelService.OAuth();                                                                                                                        
        DfpLabelService.performLabelAction_element performLabelAction_element = new DfpLabelService.performLabelAction_element();
        DfpLabelService.TypeError TypeError = new DfpLabelService.TypeError();
        DfpLabelService.NumberValue NumberValue = new DfpLabelService.NumberValue();
        DfpLabelService.updateLabelsResponse_element updateLabelsResponse_element = new DfpLabelService.updateLabelsResponse_element();
        DfpLabelService.SoapResponseHeader SoapResponseHeader = new DfpLabelService.SoapResponseHeader();
        DfpLabelService.ActivateLabels ActivateLabels = new DfpLabelService.ActivateLabels();
        DfpLabelService.NotNullError NotNullError = new DfpLabelService.NotNullError();
        DfpLabelService.getLabelsByStatement_element getLabelsByStatement_element = new DfpLabelService.getLabelsByStatement_element();
        DfpLabelService.LabelAction LabelAction = new DfpLabelService.LabelAction();
        DfpLabelService.LabelError LabelError = new DfpLabelService.LabelError();
        DfpLabelService.DateTimeValue DateTimeValue = new DfpLabelService.DateTimeValue();
        DfpLabelService.Statement Statement = new DfpLabelService.Statement();
        DfpLabelService.performLabelActionResponse_element performLabelActionResponse_element = new DfpLabelService.performLabelActionResponse_element();   
        DfpLabelService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpLabelService.PublisherQueryLanguageContextError();
        DfpLabelService.ApiError ApiError = new DfpLabelService.ApiError();
        DfpLabelService.createLabels_element createLabels_element = new DfpLabelService.createLabels_element();
        DfpLabelService.Date_x Date_x = new DfpLabelService.Date_x();
        DfpLabelService.SoapRequestHeader SoapRequestHeader = new DfpLabelService.SoapRequestHeader();
        DfpLabelService.NullError NullError = new DfpLabelService.NullError();
        DfpLabelService.ApiException ApiException = new DfpLabelService.ApiException();
        DfpLabelService.LabelPage LabelPage = new DfpLabelService.LabelPage();
        DfpLabelService.QuotaError QuotaError = new DfpLabelService.QuotaError();
        DfpLabelService.ApplicationException ApplicationException = new DfpLabelService.ApplicationException();
        DfpLabelService.LabelServiceInterfacePort LabelServiceInterfacePort = new DfpLabelService.LabelServiceInterfacePort();
        DfpLabelService.ParseError ParseError = new DfpLabelService.ParseError();
        DfpLabelService.ApiVersionError ApiVersionError = new DfpLabelService.ApiVersionError();
        DfpLabelService.ServerError ServerError = new DfpLabelService.ServerError();
        DfpLabelService.DateTime_x DateTime_x = new DfpLabelService.DateTime_x();
        DfpLabelService.StatementError StatementError = new DfpLabelService.StatementError();   
        DfpLabelService.TextValue TextValue = new DfpLabelService.TextValue();
        DfpLabelService.DeactivateLabels DeactivateLabels = new DfpLabelService.DeactivateLabels();
        DfpLabelService.getLabelsByStatementResponse_element getLabelsByStatementResponse_element = new DfpLabelService.getLabelsByStatementResponse_element();
        DfpLabelService.UpdateResult UpdateResult = new DfpLabelService.UpdateResult();
        DfpLabelService.Label Label = new DfpLabelService.Label();
        DfpLabelService.CreativeWrapperError CreativeWrapperError = new DfpLabelService.CreativeWrapperError();
        DfpLabelService.SetValue SetValue = new DfpLabelService.SetValue();
        DfpLabelService.FeatureError FeatureError = new DfpLabelService.FeatureError();
        DfpLabelService.DateValue DateValue = new DfpLabelService.DateValue();

        try{
            LabelServiceInterfacePort.createLabels(new list<DfpLabelService.Label>());
        }catch(Exception e){}            

        try{            
            LabelServiceInterfacePort.updateLabels(new list<DfpLabelService.Label>());
        }catch(Exception e){}

        try{                    
            LabelServiceInterfacePort.performLabelAction(new DfpLabelService.LabelAction(),new DfpLabelService.Statement());
        }catch(Exception e){}
                    
        try{
            LabelServiceInterfacePort.getLabelsByStatement(new DfpLabelService.Statement());
        }catch(Exception e){}
                    
        
    }    
    
    public static testMethod void testDfpUserService(){
        
        DfpUserService DfpUserService = new DfpUserService();
        DfpUserService.CommonError CommonError = new DfpUserService.CommonError();
        DfpUserService.getCurrentUserResponse_element getCurrentUserResponse_element = new DfpUserService.getCurrentUserResponse_element();
        DfpUserService.InternalApiError InternalApiError = new DfpUserService.InternalApiError();
        DfpUserService.UserServiceInterfacePort DfpUserServiceInterfacePort = new DfpUserService.UserServiceInterfacePort();
        //DfpUserService.Authentication Authentication = new DfpUserService.Authentication();
        DfpUserService.performUserActionResponse_element performUserActionResponse_element = new DfpUserService.performUserActionResponse_element();
        DfpUserService.getUsersByStatementResponse_element getUsersByStatementResponse_element = new DfpUserService.getUsersByStatementResponse_element();
        DfpUserService.BooleanValue BooleanValue = new DfpUserService.BooleanValue();
        DfpUserService.RequiredError RequiredError = new DfpUserService.RequiredError();
        DfpUserService.AuthenticationError AuthenticationError = new DfpUserService.AuthenticationError();
        DfpUserService.PermissionError PermissionError = new DfpUserService.PermissionError();
        DfpUserService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpUserService.PublisherQueryLanguageSyntaxError();
        DfpUserService.createUsers_element createUsers_element = new DfpUserService.createUsers_element();
        DfpUserService.getAllRolesResponse_element getAllRolesResponse_element = new DfpUserService.getAllRolesResponse_element();
        DfpUserService.String_ValueMapEntry String_ValueMapEntry = new DfpUserService.String_ValueMapEntry();
        DfpUserService.Value Value = new DfpUserService.Value();
       // DfpUserService.OAuth OAuth = new DfpUserService.OAuth();
        DfpUserService.UserPage UserPage = new DfpUserService.UserPage();
        DfpUserService.performUserAction_element performUserAction_element = new DfpUserService.performUserAction_element();
        DfpUserService.createUsersResponse_element createUsersResponse_element = new DfpUserService.createUsersResponse_element();        
        DfpUserService.SoapResponseHeader SoapResponseHeader  = new DfpUserService.SoapResponseHeader();        
        DfpUserService.NotNullError NotNullError  = new DfpUserService.NotNullError();        
        DfpUserService.DateTimeValue DateTimeValue  = new DfpUserService.DateTimeValue();        
        DfpUserService.Statement Statement  = new DfpUserService.Statement();        
        DfpUserService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError  = new DfpUserService.PublisherQueryLanguageContextError();        
        DfpUserService.ApiError ApiError  = new DfpUserService.ApiError();        
        DfpUserService.Date_x Date_x  = new DfpUserService.Date_x();        
        DfpUserService.SoapRequestHeader SoapRequestHeader  = new DfpUserService.SoapRequestHeader();        
        DfpUserService.getUsersByStatement_element getUsersByStatement_element  = new DfpUserService.getUsersByStatement_element();        
        DfpUserService.User_x User_x  = new DfpUserService.User_x();        
//        DfpUserService.ApiException ApiException  = new DfpUserService.ApiException();        
        DfpUserService.getAllRoles_element getAllRoles_element  = new DfpUserService.getAllRoles_element();        
        DfpUserService.QuotaError QuotaError  = new DfpUserService.QuotaError();        
        DfpUserService.UserRecord UserRecord  = new DfpUserService.UserRecord();        
//        DfpUserService.ApplicationException ApplicationException  = new DfpUserService.ApplicationException();        
        DfpUserService.ParseError ParseError  = new DfpUserService.ParseError();        
        DfpUserService.ApiVersionError ApiVersionError  = new DfpUserService.ApiVersionError();        
        DfpUserService.ServerError ServerError  = new DfpUserService.ServerError();        
        DfpUserService.DateTime_x DateTime_x  = new DfpUserService.DateTime_x();        
        DfpUserService.StatementError StatementError  = new DfpUserService.StatementError();        
        DfpUserService.TextValue TextValue  = new DfpUserService.TextValue();        
        DfpUserService.getCurrentUser_element getCurrentUser_element  = new DfpUserService.getCurrentUser_element();        
        DfpUserService.Role Role  = new DfpUserService.Role();        
        DfpUserService.UpdateResult UpdateResult  = new DfpUserService.UpdateResult();        
        DfpUserService.DeactivateUsers DeactivateUsers  = new DfpUserService.DeactivateUsers();        
        DfpUserService.ActivateUsers ActivateUsers  = new DfpUserService.ActivateUsers();        
        DfpUserService.updateUsersResponse_element updateUsersResponse_element  = new DfpUserService.updateUsersResponse_element();        
        DfpUserService.TypeError TypeError  = new DfpUserService.TypeError();        
        DfpUserService.NumberValue NumberValue  = new DfpUserService.NumberValue();        
        DfpUserService.SetValue SetValue = new DfpUserService.SetValue();                
        DfpUserService.UniqueError UniqueError = new DfpUserService.UniqueError();                
        DfpUserService.FeatureError FeatureError = new DfpUserService.FeatureError();                
        DfpUserService.DropDownCustomFieldValue DropDownCustomFieldValue = new DfpUserService.DropDownCustomFieldValue();                
        DfpUserService.BaseCustomFieldValue BaseCustomFieldValue = new DfpUserService.BaseCustomFieldValue();                
        DfpUserService.CustomFieldValue CustomFieldValue = new DfpUserService.CustomFieldValue();                
        DfpUserService.TeamError TeamError = new DfpUserService.TeamError();                
        DfpUserService.CustomFieldValueError CustomFieldValueError = new DfpUserService.CustomFieldValueError();                
        DfpUserService.DateValue DateValue = new DfpUserService.DateValue();                
        DfpUserService.InvalidEmailError InvalidEmailError = new DfpUserService.InvalidEmailError();                

        try{
            DfpUserServiceInterfacePort.getUsersByStatement(new DfpUserService.Statement());
        }catch(Exception e){}
        
        try{           
            DfpUserServiceInterfacePort.performUserAction(new DfpUserService.UserAction(),new DfpUserService.Statement());
        }catch(Exception e){}            
        
        try{    
            DfpUserServiceInterfacePort.createUsers(new list<DfpUserService.User_x>());
        }catch(Exception e){}
        
        try{
            DfpUserServiceInterfacePort.getCurrentUser();
        }catch(Exception e){}
        
        try{
            DfpUserServiceInterfacePort.getAllRoles();
        }catch(Exception e){}
        
        try{
            DfpUserServiceInterfacePort.updateUsers(new list<DfpUserService.User_x>());
        }catch(Exception e){}
        
    }
    

public static testMethod void testDfpReportService(){
        
        DfpReportService DfpReportService = new DfpReportService();
        DfpReportService.CommonError CommonError = new DfpReportService.CommonError();
        DfpReportService.DateTimeValue DateTimeValue = new DfpReportService.DateTimeValue();
        DfpReportService.InternalApiError InternalApiError = new DfpReportService.InternalApiError();
        DfpReportService.Statement Statement = new DfpReportService.Statement();
        DfpReportService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError = new DfpReportService.PublisherQueryLanguageContextError();
        DfpReportService.ApiError ApiError = new DfpReportService.ApiError();
        DfpReportService.Date_x Date_x = new DfpReportService.Date_x();
        DfpReportService.runReportJobResponse_element runReportJobResponse_element = new DfpReportService.runReportJobResponse_element();
        DfpReportService.SoapRequestHeader SoapRequestHeader = new DfpReportService.SoapRequestHeader();
        //DfpReportService.Authentication Authentication = new DfpReportService.Authentication();
        DfpReportService.getReportDownloadURL_element getReportDownloadURL_element = new DfpReportService.getReportDownloadURL_element();
        DfpReportService.getReportDownloadURLResponse_element getReportDownloadURLResponse_element = new DfpReportService.getReportDownloadURLResponse_element();
        DfpReportService.BooleanValue BooleanValue = new DfpReportService.BooleanValue();
        DfpReportService.ApiException ApiException = new DfpReportService.ApiException();
        DfpReportService.RequiredError RequiredError = new DfpReportService.RequiredError();
        DfpReportService.AuthenticationError AuthenticationError = new DfpReportService.AuthenticationError();
        DfpReportService.PermissionError PermissionError = new DfpReportService.PermissionError();
        DfpReportService.QuotaError QuotaError = new DfpReportService.QuotaError();
        DfpReportService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError = new DfpReportService.PublisherQueryLanguageSyntaxError();
        DfpReportService.ReportQuery ReportQuery = new DfpReportService.ReportQuery();
        DfpReportService.String_ValueMapEntry String_ValueMapEntry = new DfpReportService.String_ValueMapEntry();
        DfpReportService.ApplicationException ApplicationException = new DfpReportService.ApplicationException();
        DfpReportService.Value Value = new DfpReportService.Value();
        //DfpReportService.getReportJob_element getReportJob_element = new DfpReportService.getReportJob_element();
        DfpReportService.ApiVersionError ApiVersionError = new DfpReportService.ApiVersionError();
        DfpReportService.ReportError ReportError = new DfpReportService.ReportError();
        //DfpReportService.OAuth OAuth = new DfpReportService.OAuth();
        DfpReportService.ServerError ServerError = new DfpReportService.ServerError();
        DfpReportService.DateTime_x DateTime_x = new DfpReportService.DateTime_x();
        DfpReportService.NumberValue NumberValue = new DfpReportService.NumberValue();
        DfpReportService.TextValue TextValue = new DfpReportService.TextValue();
        DfpReportService.ReportServiceInterfacePort ReportServiceInterfacePort = new DfpReportService.ReportServiceInterfacePort();
        DfpReportService.SoapResponseHeader SoapResponseHeader = new DfpReportService.SoapResponseHeader();
        DfpReportService.ReportJob ReportJob = new DfpReportService.ReportJob();
        DfpReportService.runReportJob_element runReportJob_element = new DfpReportService.runReportJob_element();
//        DfpReportService.getReportJobResponse_element getReportJobResponse_element = new DfpReportService.getReportJobResponse_element();
        DfpReportService.NotNullError NotNullError = new DfpReportService.NotNullError();
        DfpReportService.getReportDownloadUrlWithOptionsResponse_element getReportDownloadUrlWithOptionsResponse_element = new DfpReportService.getReportDownloadUrlWithOptionsResponse_element();
        DfpReportService.getReportDownloadUrlWithOptions_element getReportDownloadUrlWithOptions_element = new DfpReportService.getReportDownloadUrlWithOptions_element();
        DfpReportService.ReportDownloadOptions ReportDownloadOptions = new DfpReportService.ReportDownloadOptions();
        DfpReportService.StatementError StatementError = new DfpReportService.StatementError();
        DfpReportService.SetValue SetValue = new DfpReportService.SetValue();        
        DfpReportService.FeatureError FeatureError = new DfpReportService.FeatureError();        
        DfpReportService.DateValue DateValue = new DfpReportService.DateValue();        
        DfpReportService.ParseError ParseError = new DfpReportService.ParseError();        

        try{
            ReportServiceInterfacePort.runReportJob(new DfpReportService.ReportJob());
        }catch(Exception e){}
        
        try{
      //      ReportServiceInterfacePort.getReportJob(0);
        }catch(Exception e){}
        
        try{
            ReportServiceInterfacePort.getReportDownloadURL(0,'') ;
        }catch(Exception e){}
        
        try{
            ReportServiceInterfacePort.getReportDownloadUrlWithOptions(0,new DfpReportService.ReportDownloadOptions());
        }catch(Exception e){}        

    }


    public static testMethod void testDfpTeamService(){
        
        DfpTeamService DfpTeamService = new DfpTeamService();
        DfpTeamService.CommonError CommonError  = new DfpTeamService.CommonError();
        DfpTeamService.createTeams_element createTeams_element  = new DfpTeamService.createTeams_element();
        DfpTeamService.DateTimeValue DateTimeValue  = new DfpTeamService.DateTimeValue();
        DfpTeamService.InternalApiError InternalApiError  = new DfpTeamService.InternalApiError();
        DfpTeamService.Statement Statement  = new DfpTeamService.Statement();
        DfpTeamService.PublisherQueryLanguageContextError PublisherQueryLanguageContextError  = new DfpTeamService.PublisherQueryLanguageContextError();
        DfpTeamService.ApiError ApiError  = new DfpTeamService.ApiError();
        DfpTeamService.Date_x Date_x  = new DfpTeamService.Date_x();
        DfpTeamService.SoapRequestHeader SoapRequestHeader  = new DfpTeamService.SoapRequestHeader();
        DfpTeamService.createTeamsResponse_element createTeamsResponse_element  = new DfpTeamService.createTeamsResponse_element();
        DfpTeamService.TeamError TeamError  = new DfpTeamService.TeamError();
        //DfpTeamService.Authentication Authentication  = new DfpTeamService.Authentication();
        DfpTeamService.TeamPage TeamPage  = new DfpTeamService.TeamPage();
        DfpTeamService.BooleanValue BooleanValue  = new DfpTeamService.BooleanValue();
        DfpTeamService.NullError NullError  = new DfpTeamService.NullError();
        DfpTeamService.ApiException ApiException  = new DfpTeamService.ApiException();
        DfpTeamService.UniqueError UniqueError  = new DfpTeamService.UniqueError();
        DfpTeamService.RequiredError RequiredError  = new DfpTeamService.RequiredError();
        DfpTeamService.getTeamsByStatement_element getTeamsByStatement_element  = new DfpTeamService.getTeamsByStatement_element();
        DfpTeamService.AuthenticationError AuthenticationError  = new DfpTeamService.AuthenticationError();
        DfpTeamService.QuotaError QuotaError  = new DfpTeamService.QuotaError();
        DfpTeamService.PermissionError PermissionError  = new DfpTeamService.PermissionError();
        DfpTeamService.PublisherQueryLanguageSyntaxError PublisherQueryLanguageSyntaxError  = new DfpTeamService.PublisherQueryLanguageSyntaxError();
        DfpTeamService.getTeamsByStatementResponse_element getTeamsByStatementResponse_element  = new DfpTeamService.getTeamsByStatementResponse_element();
        DfpTeamService.ApplicationException ApplicationException  = new DfpTeamService.ApplicationException();
        DfpTeamService.String_ValueMapEntry String_ValueMapEntry  = new DfpTeamService.String_ValueMapEntry();
        DfpTeamService.Value Value  = new DfpTeamService.Value();
        DfpTeamService.ApiVersionError ApiVersionError  = new DfpTeamService.ApiVersionError();
        //DfpTeamService.OAuth OAuth  = new DfpTeamService.OAuth();
        DfpTeamService.ServerError ServerError  = new DfpTeamService.ServerError();
        DfpTeamService.DateTime_x DateTime_x  = new DfpTeamService.DateTime_x();
        DfpTeamService.Team Team  = new DfpTeamService.Team();
        DfpTeamService.StatementError StatementError  = new DfpTeamService.StatementError();
        DfpTeamService.TeamServiceInterfacePort TeamServiceInterfacePort  = new DfpTeamService.TeamServiceInterfacePort();
        DfpTeamService.updateTeams_element updateTeams_element  = new DfpTeamService.updateTeams_element();
        DfpTeamService.TypeError TypeError  = new DfpTeamService.TypeError();
        DfpTeamService.NumberValue NumberValue  = new DfpTeamService.NumberValue();
        DfpTeamService.TextValue TextValue  = new DfpTeamService.TextValue();
        DfpTeamService.SoapResponseHeader SoapResponseHeader  = new DfpTeamService.SoapResponseHeader();
        DfpTeamService.updateTeamsResponse_element updateTeamsResponse_element  = new DfpTeamService.updateTeamsResponse_element();
        DfpTeamService.NotNullError NotNullError  = new DfpTeamService.NotNullError();
        DfpTeamService.SetValue SetValue = new DfpTeamService.SetValue();        
        DfpTeamService.FeatureError FeatureError = new DfpTeamService.FeatureError();        
        DfpTeamService.DateValue DateValue = new DfpTeamService.DateValue();        

        try{
            TeamServiceInterfacePort.createTeams(new list<DfpTeamService.Team>());
        }catch(Exception e){}        

        try{
            TeamServiceInterfacePort.getTeamsByStatement(new DfpTeamService.Statement());
        }catch(Exception e){}

        try{
            TeamServiceInterfacePort.updateTeams(new list<DfpTeamService.Team>());
        }catch(Exception e){}
        
    }

}