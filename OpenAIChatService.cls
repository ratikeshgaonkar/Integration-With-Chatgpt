public with sharing class OpenAIChatService {
    // Annotate the method here
    @AuraEnabled(cacheable=false)
    public static String callChatGPT(String userPrompt) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.openai.com/v1/chat/completions');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer key');

        // Build the JSON payload
        Map<String, Object> payload = new Map<String, Object>{
            'model'       => 'gpt-3.5-turbo',
            'messages'    => new List<Object>{
                new Map<String, String>{'role'=>'system','content'=>'You are a helpful assistant'},
                new Map<String, String>{'role'=>'user','content'=>userPrompt}
            },
            'max_tokens'  => 150,
            'temperature' => 0.7
        };	
        String body = JSON.serialize(payload);
        
        System.debug(LoggingLevel.INFO, 'Request Payload: ' + body);
        req.setBody(body);
        req.setTimeout(60000);

        try {
            HttpResponse res = http.send(req);
            System.debug(LoggingLevel.INFO, 'Status: ' + res.getStatusCode());
            System.debug(LoggingLevel.INFO, 'Response: ' + res.getBody());
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> jsonResp = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> choices = (List<Object>) jsonResp.get('choices');
                if (!choices.isEmpty()) {
                    Map<String, Object> msg = (Map<String, Object>) ((Map<String,Object>)choices[0]).get('message');
                    return (String) msg.get('content');
                }
                return 'No choices returned';
            } else {
                return 'HTTP Error ' + res.getStatusCode() + ': ' + res.getBody();
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
            return 'Exception: ' + e.getMessage();
        }
    }
}
