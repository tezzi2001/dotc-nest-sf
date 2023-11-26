@IsTest
public class ExternalProductViewControllerTest {
    private static final String TEST_USER_NAME = ExternalProductViewControllerTest.class.getName();
    private static final String PROFILE_SYS_ADMIN = 'System Administrator';
    private static final Integer CART_ITEMS_SIZE = 10;

    @TestSetup
    static void initData() {
        User testUser = TestDataFactory.createTestUser(TEST_USER_NAME, PROFILE_SYS_ADMIN, new List<String>());

        System.runAs(testUser) {
            Cart__c cart = TestDataFactory.createCarts(1)[0];
            insert cart;
            List<CartItem__c> cartItems = TestDataFactory.createCartItems(cart, CART_ITEMS_SIZE);
            insert cartItems;
        }
    }

    @IsTest
    static void getCartItems_hasCartItems_positive() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            ServerResponse response = ExternalProductViewController.getCartItems();
            Test.stopTest();

            Assert.isTrue(response.isSuccess);
            Assert.isNotNull(response.data);

            List<ExternalProductViewController.CartItem> data = (List<ExternalProductViewController.CartItem>)response.data;
            Assert.areEqual(CART_ITEMS_SIZE, data.size());
        }
    }

    @IsTest
    static void getCartItems_noCartItems_positive() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            delete getCartItems();

            Test.startTest();
            ServerResponse response = ExternalProductViewController.getCartItems();
            Test.stopTest();

            Assert.isTrue(response.isSuccess);
            Assert.isNotNull(response.data);

            List<ExternalProductViewController.CartItem> data = (List<ExternalProductViewController.CartItem>)response.data;
            Assert.areEqual(0, data.size());
        }
    }

    @IsTest
    static void getCartItems_finishedCart_positive() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Cart__c cart = getCart();
            cart.Status__c = CartSelector.STATUS_FINISHED;
            update cart;

            Test.startTest();
            ServerResponse response = ExternalProductViewController.getCartItems();
            Test.stopTest();

            Assert.isTrue(response.isSuccess);
            Assert.isNotNull(response.data);

            List<ExternalProductViewController.CartItem> data = (List<ExternalProductViewController.CartItem>)response.data;
            Assert.areEqual(0, data.size());
        }
    }

    static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = :TEST_USER_NAME LIMIT 1];
    }

    static List<CartItem__c> getCartItems() {
        return [SELECT Id FROM CartItem__c];
    }

    static Cart__c getCart() {
        return [SELECT Id FROM Cart__c LIMIT 1];
    }
}