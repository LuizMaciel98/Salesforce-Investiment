public class CalloutRequester {
    
    public static HttpResponse getResponse(String endpoint){
        HttpResponse result;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        result = http.send(request);
        
        return result;
    }

}