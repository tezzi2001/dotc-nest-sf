public inherited sharing class TestDataFactory {
    public static User createTestUser(String userLastName, String profileName, List<String> permisionSetNames) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name IN :permisionSetNames];

        User user = new user();
        user.LastName = userLastName;
        user.Email = userLastName + '@' + userLastName + '.com';
        user.Alias = RandomDataGenerator.generateRandomString(8);
        user.Username = userLastName + '@' + userLastName + '.com';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'GMT';
        user.ProfileId = profile.Id;
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        insert user;

        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet permissionSet : permissionSets) {
            permissionSetAssignments.add(new PermissionSetAssignment(PermissionSetId = permissionSet.Id, AssigneeId = user.Id));
        }
        System.runAs(user) {
            insert permissionSetAssignments;
        }

        return user;
    }

    public static List<Cart__c> createCarts(Integer size) {
        List<Cart__c> carts = new List<Cart__c>();

        for (Integer i = 0; i < size; i++) {
            carts.add(new Cart__c());
        }

        return carts;
    }

    public static List<CartItem__c> createCartItems(Cart__c cart, Integer size) {
        List<CartItem__c> cartItems = new List<CartItem__c>();

        for (Integer i = 0; i < size; i++) {
            cartItems.add(new CartItem__c(
                Cart__c = cart.Id,
                ExternalId__c = RandomDataGenerator.generateRandomString(18),
                ProductName__c = RandomDataGenerator.generateRandomString(10),
                PricePerEach__c = RandomDataGenerator.generateRandomNumber(5) / 100,
                Quantity__c = RandomDataGenerator.generateRandomNumber(5)
            ));
        }

        return cartItems;
    }
}