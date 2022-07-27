Global class UpdateCryptocurrencyCallout {

    @InvocableMethod(label='Update Cryptocurrency')
    public static void updateCriptocurrency(List<Request> listRequest){
        System.debug(listRequest);
        
        Set<Id> setIdCryptocurrency = new Set<Id>();
        for(Request req : listRequest){
            setIdCryptocurrency.add(req.recordId);
        }
        
        List<Cryptocurrency__c> listCryptocurrency = getCryptocurrencyFromSetId(setIdCryptocurrency);
        
        for(Cryptocurrency__c crypto : listCryptocurrency){
            if(crypto.Name == 'Bitcoin'){
                updateBitcoin(crypto);
            }
        }
        
        update listCryptocurrency;
    }
    
    
    public static void updateBitcoin(Cryptocurrency__c crypto){
		
        String binanceAPIUrl = 'https://api3.binance.com';

        HttpResponse btcUSDTResponse = CalloutRequester.getResponse(binanceAPIUrl + '/api/v3/ticker/price?symbol=BTCUSDT');
        HttpResponse btcBRLResponse = CalloutRequester.getResponse(binanceAPIUrl + '/api/v3/ticker/price?symbol=BTCBRL');

        if(btcUSDTResponse.getStatusCode() == 200) {
			BinanceResponse usdtParsedResponse = (BinanceResponse) JSON.deserialize(btcUSDTResponse.getBody(), UpdateCryptocurrencyCallout.BinanceResponse.class);
            BinanceResponse brlParsedResponse = (BinanceResponse) JSON.deserialize(btcBRLResponse.getBody(), UpdateCryptocurrencyCallout.BinanceResponse.class);

                if(crypto.Name == 'Bitcoin'){
                    List<Crypto_asset__c> bitcoinCryptoAssets = crypto.Crypto_Assets__r;
                    
                    System.debug(crypto);

                    crypto.Price_in_USDT__c = Double.valueOf(usdtParsedResponse.price);
                    crypto.Price_in_BRL__c = Double.valueOf(brlParsedResponse.price);

                    if(!bitcoinCryptoAssets.isEmpty()){
                    	crypto.Total_Cryptocurrency__c = 0;
                    	for(Crypto_Asset__c criptoAsset : bitcoinCryptoAssets){
                            if(criptoAsset.Operation__c == 'Sell') {
                                crypto.Total_Cryptocurrency__c -= criptoAsset.Cryptocurrency_Quantity__c;
                            } else if(criptoAsset.Operation__c == 'Buy') {
                                crypto.Total_Cryptocurrency__c += criptoAsset.Cryptocurrency_Quantity__c;
                            }
                    	}
                    }
                }
            //}
            
            //update criptoCurrency;
            
        }
        
        
    }
    
    private static List<Cryptocurrency__c> getCryptocurrencyFromSetId(Set<Id> setIdCryptocurrency){
        return [SELECT Id, Name, (SELECT Id, Operation__c, Cryptocurrency__c, Cryptocurrency_price_in_BRL__c, Cryptocurrency_Quantity__c FROM Crypto_Assets__r) FROM Cryptocurrency__c WHERE Id in: setIdCryptocurrency];
    }
    
    class BinanceResponse {
        public String symbol;
        public String price;
    }
    
    global class Request {
        @InvocableVariable
        global String recordId;
    }

}