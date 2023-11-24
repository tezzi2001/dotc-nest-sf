public inherited sharing class CalloutService {
    private final static String METHOD_GET = 'GET';
    private final static String METHOD_POST = 'POST';
    private final static String METHOD_DELETE = 'DELETE';
    private final static String METHOD_PATCH = 'PATCH';

    private final String baseUrl;

    public CalloutService(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public HttpResponse get(String path) {
        return makeCallout(path, METHOD_GET, null);
    }
    public HttpResponse post(String path, String body) {
        return makeCallout(path, METHOD_POST, body);
    }
    public HttpResponse del(String path) {
        return makeCallout(path, METHOD_DELETE, null);
    }
    public HttpResponse patch(String path, String body) {
        return makeCallout(path, METHOD_PATCH, body);
    }

    private HttpResponse makeCallout(String path, String method, String body) {
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.baseUrl + path);
        req.setMethod(method);
        if (body != null) req.setBody(body);
    
        HttpResponse res = h.send(req);
        if (res.getStatusCode() >= 400) {
            throw new CalloutServiceException(res.getBody());
        }
        return res;
    }

    class CalloutServiceException extends Exception {}
}