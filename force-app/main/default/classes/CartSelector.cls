public inherited sharing class CartSelector {
    public List<Cart__c> getCartsWithCartItemsByProductNameAndOwnerId(Id ownerId, Set<String> productNames) {
        return [
            SELECT (SELECT ExternalId__c FROM CartItems__r WHERE ProductName__c IN :productNames)
            FROM Cart__c
            WHERE OwnerId = :ownerId AND Status__c = :CartItemSelector.NEW_STATUS
            LIMIT 1
        ];
    }

    public List<Cart__c> getCartsWithCartItemsByOwnerId(Id ownerId) {
        return [
            SELECT (SELECT ExternalId__c, ProductName__c, PricePerEach__c, Quantity__c FROM CartItems__r)
            FROM Cart__c
            WHERE OwnerId = :ownerId AND Status__c = :CartItemSelector.NEW_STATUS
            LIMIT 1
        ];
    }
}