/**
 * @description Controller class to send REST request to Catalog service and get/save Cart Items
 *
 * @author Bohdan Bondarenko
 * @date 2023-11-26
 */
public with sharing class ExternalProductViewController {
    private final static CalloutService calloutService = new CalloutService('https://2895-95-158-43-79.ngrok-free.app/v1/catalog');
    private final static CartSelector cartSelector = new CartSelector();

    /**
     * @description finds Products in the Catalog by limit and offet
     *
     * @param Integer alimit. Products record amount.
     * @param Integer offset. Products record offset from the start of the database.
     * 
     * @return ServerResponse. Response with found Products
     * 
     * @author Bohdan Bondarenko
     */
    @AuraEnabled
    public static ServerResponse getProductsByLimitAndOffset(Integer alimit, Integer offset) {
        try {
            return ServerResponse.positive(JSON.deserialize(calloutService.get('/products?limit=' + alimit + '&offset=' + offset).getBody(), List<Product>.class));
        } catch (Exception e) {
            return ServerResponse.negative(e);
        }
    }

    /**
     * @description adds Products to the Catalog
     *
     * @param String product. Stringified Product JSON to be added to the Catalog.
     * 
     * @return ServerResponse. Response with added Products
     * 
     * @author Bohdan Bondarenko
     */
    @AuraEnabled
    public static ServerResponse addProduct(String product) {
        try {
            return ServerResponse.positive(JSON.deserialize(calloutService.post('/product', product).getBody(), List<Product>.class));
        } catch (Exception e) {
            return ServerResponse.negative(e);
        }
    }

    /**
     * @description updates Product in the Catalog
     *
     * @param String product. Stringified Product JSON to be updated in the Catalog.
     * 
     * @return ServerResponse. Response with updated Products
     * 
     * @author Bohdan Bondarenko
     */
    @AuraEnabled
    public static ServerResponse updateProducts(String products) {
        try {
            calloutService.post('/products', products);
            return ServerResponse.positive();
        } catch (Exception e) {
            return ServerResponse.negative(e);
        }
    }

    /**
     * @description deletes Product from the Catalog
     *
     * @param String id. Id of the Product to be deleted from the Catalog.
     * 
     * @return ServerResponse. Empty response
     * 
     * @author Bohdan Bondarenko
     */
    @AuraEnabled
    public static ServerResponse deleteProductById(String id) {
        try {
            return ServerResponse.positive(calloutService.del('/product/' + id).getBody());
        } catch (Exception e) {
            return ServerResponse.negative(e);
        }
    }

    /**
     * @description finds CartItems__c in the Salesforce by the related Cart__c with Status__c = 'New' and Onwer = Current User
     * 
     * @return ServerResponse. Response with found CartItems__c
     * 
     * @author Bohdan Bondarenko
     */
    @AuraEnabled
    public static ServerResponse getCartItems() {
        try {
            List<Cart__c> carts = cartSelector.getCartsWithCartItemsByOwnerId(UserInfo.getUserId());
            List<CartItem__c> cartItemSObejcts = carts.isEmpty() ? new List<CartItem__c>() : carts[0].CartItems__r;

            List<CartItem> cartItems = new List<CartItem>();
            for (CartItem__c cartItemSObejct : cartItemSObejcts) {
                cartItems.add(new CartItem(cartItemSObejct));
            }
            return ServerResponse.positive(cartItems);
        } catch (Exception e) {
            return ServerResponse.negative(e);
        }
    }

    /**
     * @description adds CartItems__c to Salesforce
     *
     * @param String cartItems. Stringified CartItems__c JSON to be added to the Salesforce.
     * 
     * @return ServerResponse. Empty response
     * 
     * @author Bohdan Bondarenko
     */
    @AuraEnabled
    public static ServerResponse saveToCart(String cartItems) {
        try {
            List<CartItem> newCartItems = (List<CartItem>)JSON.deserialize(cartItems, List<CartItem>.class);

            Set<String> productNames = new Set<String>();
            for (CartItem cartItem : newCartItems) {
                productNames.add(cartItem.name);
            }

            List<Cart__c> carts = cartSelector.getCartsWithCartItemsByProductNameAndOwnerId(UserInfo.getUserId(), productNames);

            Cart__c cart;
            if (carts.isEmpty()) {
                cart = new Cart__c();
                insert cart;
            } else {
                cart = carts[0];
            }
            Map<String, CartItem__c> cartItemsByExternalId = new Map<String, CartItem__c>();
            for (CartItem__c cartItem : cart.CartItems__r) {
                cartItemsByExternalId.put(cartItem.ExternalId__c, cartItem);
            }

            List<CartItem__c> cartItemsToUpdate = new List<CartItem__c>();
            for (CartItem newCartItem : newCartItems) {
                if (cartItemsByExternalId.containsKey(newCartItem.externalId)) {
                    CartItem__c cartItem = cartItemsByExternalId.get(newCartItem.externalId);
                    cartItem.Quantity__c = newCartItem.quantity;
                    cartItemsToUpdate.add(cartItem);
                } else {
                    cartItemsToUpdate.add(newCartItem.toSObject(cart.Id));
                }
            }
            upsert cartItemsToUpdate;

            return ServerResponse.positive();
        } catch (Exception e) {
            return ServerResponse.negative(e);
        }
    }

    public class Product {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Decimal price;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public Boolean available;

        public Product(CartItem cartItem) {
            this.id = cartItem.externalId;
            this.name = cartItem.name;
            this.price = cartItem.price;
            this.quantity = cartItem.quantity;
        }
    }

    public class CartItem {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal price;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public String externalId;

        public CartItem(CartItem__c cartItem) {
            this.externalId = cartItem.ExternalId__c;
            this.price = cartItem.PricePerEach__c;
            this.quantity = Integer.valueOf(cartItem.Quantity__c);
            this.name = cartItem.ProductName__c;
        }

        public CartItem__c toSObject(Id cartId) {
            return new CartItem__c(
                ExternalId__c = this.externalId,
                ProductName__c = this.name,
                PricePerEach__c = this.price,
                Quantity__c = this.quantity,
                Cart__c = cartId
            );
        }
    }
}