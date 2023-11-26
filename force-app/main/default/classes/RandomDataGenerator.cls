public inherited sharing class RandomDataGenerator {
    public static Integer generateRandomNumber(Integer lengthOfNumber) {
        String result = '';
        while(result.length() < lengthOfNumber){
            result += String.valueOf(Math.abs(Crypto.getRandomLong()));
        }
        
        return Integer.valueOf(result.substring(0, lengthOfNumber));
    }
    
    public static String generateRandomString(Integer lengthOfString) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < lengthOfString) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}