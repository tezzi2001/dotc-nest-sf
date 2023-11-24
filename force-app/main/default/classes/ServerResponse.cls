public class ServerResponse {
    @AuraEnabled
    public Object data;
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String errorMessage;
    @AuraEnabled
    public String fullErrorMessage;
    @AuraEnabled
    public String stackTrace;

    public static ServerResponse positive(Object data) {
        ServerResponse serverResponse = new ServerResponse();
        serverResponse.isSuccess = true;
        serverResponse.data = data;
        return serverResponse;
    }

    public static ServerResponse positive() {
        ServerResponse serverResponse = new ServerResponse();
        serverResponse.isSuccess = true;
        return serverResponse;
    }

    private static String prettifyErrorMessage(String errorMessage) {
        List<String> ERROR_MARKS = new List<String>{
                'REQUIRED_FIELD_MISSING',
                'FIELD_CUSTOM_VALIDATION_EXCEPTION'
        };
        String prettyErrorMessage = errorMessage;
        for (String errorMark : ERROR_MARKS) {
            Integer position = errorMessage.indexOf(errorMark);
            if (position != -1) {
                prettyErrorMessage = errorMessage.substring(position + errorMark.length() + 2);
                break;
            }
        }
        prettyErrorMessage = prettyErrorMessage.replace(': []', '');
        return prettyErrorMessage;
    }

    public static ServerResponse negative(Exception ex) {
        ServerResponse serverResponse = new ServerResponse();
        serverResponse.isSuccess = false;
        serverResponse.fullErrorMessage = ex.getMessage();
        serverResponse.errorMessage = prettifyErrorMessage(ex.getMessage());
        serverResponse.stackTrace = ex.getStackTraceString();
        return serverResponse;
    }
}