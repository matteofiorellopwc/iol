//Generated by wsdl2apex

public class DFPCustomFieldService {
    public class CommonError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class updateCustomFieldOptions_element {
        public DFPCustomFieldService.CustomFieldOption[] customFieldOptions;
        private String[] customFieldOptions_type_info = new String[]{'customFieldOptions','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'customFieldOptions'};
    }
    public class getCustomFieldOptionResponse_element {
        public DFPCustomFieldService.CustomFieldOption rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class DeactivateCustomFields {
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class InternalApiError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class CollectionSizeError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class createCustomFieldsResponse_element {
        public DFPCustomFieldService.CustomField[] rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class SetValue {
        public DFPCustomFieldService.Value[] values;
        private String[] values_type_info = new String[]{'values','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'values'};
    }
    public class CustomFieldPage {
        public Integer totalResultSetSize;
        public Integer startIndex;
        public DFPCustomFieldService.CustomField[] results;
        private String[] totalResultSetSize_type_info = new String[]{'totalResultSetSize','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] startIndex_type_info = new String[]{'startIndex','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] results_type_info = new String[]{'results','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'totalResultSetSize','startIndex','results'};
    }
    public class DateTime_x {
        public DFPCustomFieldService.Date_x date_x;
        public Integer hour;
        public Integer minute;
        public Integer second;
        public String timeZoneID;
        private String[] date_x_type_info = new String[]{'date','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] hour_type_info = new String[]{'hour','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] minute_type_info = new String[]{'minute','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] second_type_info = new String[]{'second','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] timeZoneID_type_info = new String[]{'timeZoneID','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'date_x','hour','minute','second','timeZoneID'};
    }
    public class Date_x {
        public Integer year;
        public Integer month;
        public Integer day;
        private String[] year_type_info = new String[]{'year','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] month_type_info = new String[]{'month','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] day_type_info = new String[]{'day','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'year','month','day'};
    }
    public class BooleanValue {
        public Boolean value;
        private String[] value_type_info = new String[]{'value','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class CustomFieldError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class UniqueError {
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class RequiredError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class FeatureError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class AuthenticationError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class PermissionError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class PublisherQueryLanguageSyntaxError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class String_ValueMapEntry {
        public String key;
        public DFPCustomFieldService.Value value;
        private String[] key_type_info = new String[]{'key','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] value_type_info = new String[]{'value','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'key','value'};
    }
    public class CustomField {
        public Long id;
        public String name;
        public String description;
        public Boolean isActive;
        public String entityType;
        public String dataType;
        public String visibility;
        public String CustomField_Type;
        private String[] id_type_info = new String[]{'id','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] name_type_info = new String[]{'name','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] description_type_info = new String[]{'description','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] entityType_type_info = new String[]{'entityType','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] dataType_type_info = new String[]{'dataType','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] visibility_type_info = new String[]{'visibility','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] CustomField_Type_type_info = new String[]{'CustomField.Type','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'id','name','description','isActive','entityType','dataType','visibility','CustomField_Type'};
    }
    public class Value {
        public String Value_Type;
        private String[] Value_Type_type_info = new String[]{'Value.Type','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'Value_Type'};
    }
    public class CustomFieldOption {
        public Long id;
        public Long customFieldId;
        public String displayName;
        private String[] id_type_info = new String[]{'id','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] customFieldId_type_info = new String[]{'customFieldId','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] displayName_type_info = new String[]{'displayName','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'id','customFieldId','displayName'};
    }
    public class createCustomFieldOptionsResponse_element {
        public DFPCustomFieldService.CustomFieldOption[] rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class CustomFieldAction {
        public String CustomFieldAction_Type;
        private String[] CustomFieldAction_Type_type_info = new String[]{'CustomFieldAction.Type','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'CustomFieldAction_Type'};
    }
    public class getCustomFieldsByStatementResponse_element {
        public DFPCustomFieldService.CustomFieldPage rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class TypeError {
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class NumberValue {
        public String value;
        private String[] value_type_info = new String[]{'value','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class SoapResponseHeader {
        public String requestId;
        public Long responseTime;
        private String[] requestId_type_info = new String[]{'requestId','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] responseTime_type_info = new String[]{'responseTime','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'requestId','responseTime'};
    }
    public class ActivateCustomFields {
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class getCustomFieldsByStatement_element {
        public DFPCustomFieldService.Statement filterStatement;
        private String[] filterStatement_type_info = new String[]{'filterStatement','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'filterStatement'};
    }
    public class NotNullError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class ApplicationException extends Exception {
        public String message;
        public String ApplicationException_Type;
        private String[] message_type_info = new String[]{'message','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] ApplicationException_Type_type_info = new String[]{'ApplicationException.Type','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'message','ApplicationException_Type'};
    }
    public class updateCustomFields_element {
        public DFPCustomFieldService.CustomField[] customFields;
        private String[] customFields_type_info = new String[]{'customFields','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'customFields'};
    }
    public class EntityLimitReachedError {
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class DateTimeValue {
        public DFPCustomFieldService.DateTime_x value;
        private String[] value_type_info = new String[]{'value','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class Statement {
        public String query;
        public DFPCustomFieldService.String_ValueMapEntry[] values;
        private String[] query_type_info = new String[]{'query','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] values_type_info = new String[]{'values','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'query','values'};
    }
    public class PublisherQueryLanguageContextError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class ApiError {
        public String fieldPath;
        public String trigger_x;
        public String errorString;
        public String ApiError_Type;
        private String[] fieldPath_type_info = new String[]{'fieldPath','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] trigger_x_type_info = new String[]{'trigger','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] errorString_type_info = new String[]{'errorString','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] ApiError_Type_type_info = new String[]{'ApiError.Type','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'fieldPath','trigger_x','errorString','ApiError_Type'};
    }
    public class updateCustomFieldOptionsResponse_element {
        public DFPCustomFieldService.CustomFieldOption[] rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class performCustomFieldActionResponse_element {
        public DFPCustomFieldService.UpdateResult rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class performCustomFieldAction_element {
        public DFPCustomFieldService.CustomFieldAction customFieldAction;
        public DFPCustomFieldService.Statement filterStatement;
        private String[] customFieldAction_type_info = new String[]{'customFieldAction','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] filterStatement_type_info = new String[]{'filterStatement','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'customFieldAction','filterStatement'};
    }
    public class SoapRequestHeader {
        public String networkCode;
        public String applicationName;
        private String[] networkCode_type_info = new String[]{'networkCode','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] applicationName_type_info = new String[]{'applicationName','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'networkCode','applicationName'};
    }
    public class ApiException extends Exception {
        public DFPCustomFieldService.ApiError[] errors;
        private String[] errors_type_info = new String[]{'errors','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'errors'};
    }
    public class NullError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class createCustomFieldOptions_element {
        public DFPCustomFieldService.CustomFieldOption[] customFieldOptions;
        private String[] customFieldOptions_type_info = new String[]{'customFieldOptions','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'customFieldOptions'};
    }
    public class QuotaError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class createCustomFields_element {
        public DFPCustomFieldService.CustomField[] customFields;
        private String[] customFields_type_info = new String[]{'customFields','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'customFields'};
    }
    public class DateValue {
        public DFPCustomFieldService.Date_x value;
        private String[] value_type_info = new String[]{'value','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class getCustomFieldOption_element {
        public Long customFieldOptionId;
        private String[] customFieldOptionId_type_info = new String[]{'customFieldOptionId','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'customFieldOptionId'};
    }
    public class ApiVersionError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class ParseError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class ServerError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class updateCustomFieldsResponse_element {
        public DFPCustomFieldService.CustomField[] rval;
        private String[] rval_type_info = new String[]{'rval','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'rval'};
    }
    public class StatementError {
        public String reason;
        private String[] reason_type_info = new String[]{'reason','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'reason'};
    }
    public class TextValue {
        public String value;
        private String[] value_type_info = new String[]{'value','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }
    public class DropDownCustomField {
        public DFPCustomFieldService.CustomFieldOption[] options;
        private String[] options_type_info = new String[]{'options','https://www.google.com/apis/ads/publisher/v201405',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'options'};
    }
    public class UpdateResult {
        public Integer numChanges;
        private String[] numChanges_type_info = new String[]{'numChanges','https://www.google.com/apis/ads/publisher/v201405',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405','true','false'};
        private String[] field_order_type_info = new String[]{'numChanges'};
    }
    public class CustomFieldServiceInterfacePort {
        public String endpoint_x = 'https://ads.google.com/apis/ads/publisher/v201405/CustomFieldService';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public DFPCustomFieldService.SoapRequestHeader RequestHeader;
        public DFPCustomFieldService.SoapResponseHeader ResponseHeader;
        private String RequestHeader_hns = 'RequestHeader=https://www.google.com/apis/ads/publisher/v201405';
        private String ResponseHeader_hns = 'ResponseHeader=https://www.google.com/apis/ads/publisher/v201405';
        private String[] ns_map_type_info = new String[]{'https://www.google.com/apis/ads/publisher/v201405', 'DFPCustomFieldService'};
        public DFPCustomFieldService.CustomFieldOption[] updateCustomFieldOptions(DFPCustomFieldService.CustomFieldOption[] customFieldOptions) {
            DFPCustomFieldService.updateCustomFieldOptions_element request_x = new DFPCustomFieldService.updateCustomFieldOptions_element();
            request_x.customFieldOptions = customFieldOptions;
            DFPCustomFieldService.updateCustomFieldOptionsResponse_element response_x;
            Map<String, DFPCustomFieldService.updateCustomFieldOptionsResponse_element> response_map_x = new Map<String, DFPCustomFieldService.updateCustomFieldOptionsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'updateCustomFieldOptions',
              'https://www.google.com/apis/ads/publisher/v201405',
              'updateCustomFieldOptionsResponse',
              'DFPCustomFieldService.updateCustomFieldOptionsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
        public DFPCustomFieldService.CustomField[] updateCustomFields(DFPCustomFieldService.CustomField[] customFields) {
            DFPCustomFieldService.updateCustomFields_element request_x = new DFPCustomFieldService.updateCustomFields_element();
            request_x.customFields = customFields;
            DFPCustomFieldService.updateCustomFieldsResponse_element response_x;
            Map<String, DFPCustomFieldService.updateCustomFieldsResponse_element> response_map_x = new Map<String, DFPCustomFieldService.updateCustomFieldsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'updateCustomFields',
              'https://www.google.com/apis/ads/publisher/v201405',
              'updateCustomFieldsResponse',
              'DFPCustomFieldService.updateCustomFieldsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
        public DFPCustomFieldService.UpdateResult performCustomFieldAction(DFPCustomFieldService.CustomFieldAction customFieldAction,DFPCustomFieldService.Statement filterStatement) {
            DFPCustomFieldService.performCustomFieldAction_element request_x = new DFPCustomFieldService.performCustomFieldAction_element();
            request_x.customFieldAction = customFieldAction;
            request_x.filterStatement = filterStatement;
            DFPCustomFieldService.performCustomFieldActionResponse_element response_x;
            Map<String, DFPCustomFieldService.performCustomFieldActionResponse_element> response_map_x = new Map<String, DFPCustomFieldService.performCustomFieldActionResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'performCustomFieldAction',
              'https://www.google.com/apis/ads/publisher/v201405',
              'performCustomFieldActionResponse',
              'DFPCustomFieldService.performCustomFieldActionResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
        public DFPCustomFieldService.CustomFieldOption[] createCustomFieldOptions(DFPCustomFieldService.CustomFieldOption[] customFieldOptions) {
            DFPCustomFieldService.createCustomFieldOptions_element request_x = new DFPCustomFieldService.createCustomFieldOptions_element();
            request_x.customFieldOptions = customFieldOptions;
            DFPCustomFieldService.createCustomFieldOptionsResponse_element response_x;
            Map<String, DFPCustomFieldService.createCustomFieldOptionsResponse_element> response_map_x = new Map<String, DFPCustomFieldService.createCustomFieldOptionsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'createCustomFieldOptions',
              'https://www.google.com/apis/ads/publisher/v201405',
              'createCustomFieldOptionsResponse',
              'DFPCustomFieldService.createCustomFieldOptionsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
        public DFPCustomFieldService.CustomFieldOption getCustomFieldOption(Long customFieldOptionId) {
            DFPCustomFieldService.getCustomFieldOption_element request_x = new DFPCustomFieldService.getCustomFieldOption_element();
            request_x.customFieldOptionId = customFieldOptionId;
            DFPCustomFieldService.getCustomFieldOptionResponse_element response_x;
            Map<String, DFPCustomFieldService.getCustomFieldOptionResponse_element> response_map_x = new Map<String, DFPCustomFieldService.getCustomFieldOptionResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'getCustomFieldOption',
              'https://www.google.com/apis/ads/publisher/v201405',
              'getCustomFieldOptionResponse',
              'DFPCustomFieldService.getCustomFieldOptionResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
        public DFPCustomFieldService.CustomField[] createCustomFields(DFPCustomFieldService.CustomField[] customFields) {
            DFPCustomFieldService.createCustomFields_element request_x = new DFPCustomFieldService.createCustomFields_element();
            request_x.customFields = customFields;
            DFPCustomFieldService.createCustomFieldsResponse_element response_x;
            Map<String, DFPCustomFieldService.createCustomFieldsResponse_element> response_map_x = new Map<String, DFPCustomFieldService.createCustomFieldsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'createCustomFields',
              'https://www.google.com/apis/ads/publisher/v201405',
              'createCustomFieldsResponse',
              'DFPCustomFieldService.createCustomFieldsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
        public DFPCustomFieldService.CustomFieldPage getCustomFieldsByStatement(DFPCustomFieldService.Statement filterStatement) {
            DFPCustomFieldService.getCustomFieldsByStatement_element request_x = new DFPCustomFieldService.getCustomFieldsByStatement_element();
            request_x.filterStatement = filterStatement;
            DFPCustomFieldService.getCustomFieldsByStatementResponse_element response_x;
            Map<String, DFPCustomFieldService.getCustomFieldsByStatementResponse_element> response_map_x = new Map<String, DFPCustomFieldService.getCustomFieldsByStatementResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'https://www.google.com/apis/ads/publisher/v201405',
              'getCustomFieldsByStatement',
              'https://www.google.com/apis/ads/publisher/v201405',
              'getCustomFieldsByStatementResponse',
              'DFPCustomFieldService.getCustomFieldsByStatementResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.rval;
        }
    }
}