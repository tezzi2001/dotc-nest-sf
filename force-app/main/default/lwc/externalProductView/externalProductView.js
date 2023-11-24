import { LightningElement } from 'lwc';

import getProductsByLimitAndOffset from '@salesforce/apex/ExternalProductViewController.getProductsByLimitAndOffset';
import deleteProductById from '@salesforce/apex/ExternalProductViewController.deleteProductById';
import addProduct from '@salesforce/apex/ExternalProductViewController.addProduct';
import updateProducts from '@salesforce/apex/ExternalProductViewController.updateProducts';
import getCartItems from '@salesforce/apex/ExternalProductViewController.getCartItems';

import { Utils } from 'c/util';
import { Toasts } from 'c/toast';
import AddProductModal from 'c/addProductModal';
import CartModal from 'c/cartModal';

const ACTIONS = {
    add: 'add',
    delete: 'delete',
}

export default class ExternalProductView extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'name', hideDefaultActions: true },
        { label: 'Description', fieldName: 'description', hideDefaultActions: true },
        { label: 'Price', fieldName: 'price', type: 'currency', typeAttributes: { currencyCode: 'USD' }, hideDefaultActions: true },
        { label: 'Quantity', fieldName: 'quantity', type: 'number', hideDefaultActions: true },
        { label: 'Available', fieldName: 'available', type: 'boolean', hideDefaultActions: true },
        { type: 'button-icon', initialWidth: '20', typeAttributes: { name: ACTIONS.add, variant: 'Brand', iconName: 'utility:cart', title: 'Add to Cart' } },
        { type: 'button-icon', initialWidth: '20', typeAttributes: { name: ACTIONS.delete, iconName: 'utility:delete', title: 'Delete from Catalog' } },
    ];
    data = [];
    allQuantityByProductId = new Map();
    cartItems = [];

    async connectedCallback() {
        try {
            await this.getProductsByLimitAndOffset(10, 0);
            await this.getCartItems();
        } catch (error) {
            Utils.handleFatalError(error, this);
        }
    }

    async getProductsByLimitAndOffset(alimit, offset) {
        const result = await getProductsByLimitAndOffset({ alimit, offset });
        if (result && result.isSuccess && result.data) {
            this.data = result.data;
            this.data.forEach((datum) => this.updateAllQuantityByProductId(datum.id, datum.quantity));
        } else {
            Utils.handleControllerError(result, this);
        }
    }

    async getCartItems() {
        const result = await getCartItems();
        if (result && result.isSuccess && result.data) {
            this.cartItems = result.data;
            this.cartItems.forEach((cartItem) => this.updateAllQuantityByProductId(cartItem.externalId, cartItem.quantity))
        } else {
            Utils.handleControllerError(result, this);
        }
    }

    updateAllQuantityByProductId(productId, quantity) {
        let existingQuantity = 0;
        if (this.allQuantityByProductId.has(productId)) {
            existingQuantity = this.allQuantityByProductId.get(productId);
        }
        this.allQuantityByProductId.set(productId, existingQuantity + quantity);
    }

    async handleRowAction(e) {
        const action = e.detail.action;
        const row = e.detail.row;

        try {
            switch (action.name) {
                case ACTIONS.add:
                    if (row.quantity === 0) break;
                    row.quantity--;
                    const existingItem = this.cartItems.find((cartItem) => cartItem.externalId === row.id);
                    if (existingItem) {
                        existingItem.quantity++;
                    } else {
                        this.cartItems.push({ name: row.name, price: row.price, quantity: 1, externalId: row.id });
                    }
                    this.refreshData();
                    break;
                case ACTIONS.delete:
                    const result = await deleteProductById({ id: row.id });
                    if (result && result.isSuccess) {
                        this.data = this.data.filter((datum) => datum.id !== row.id);
                        Toasts.showSuccessToast('Deleted the Product from the Catatalog from the Nest database', this);
                    } else {
                        Utils.handleControllerError(result, this);
                    }
                    break;
                default:
                    break;
            }
        } catch (error) {
            Utils.handleFatalError(error, this);
        }
    }

    async openCartModal() {
        await CartModal.open({
            size: 'medium',
            cartItems: this.cartItems,
            onupdate: (e) => {
                e.stopPropagation();
                e.detail.forEach((product) => {
                    const datum = this.data.find((datum) => datum.id === product.externalId);
                    datum.quantity = this.allQuantityByProductId.get(product.externalId) - product.quantity;

                    const existingItem = this.cartItems.find((cartItem) => cartItem.externalId === product.externalId);
                    existingItem.quantity = product.quantity;
                });
                this.refreshData();
            },
            onsave: (e) => {
                e.stopPropagation();
                const products = e.detail.map((cartItem) => this.data.find((datum) => datum.id === cartItem.externalId));
                this.updateProducts(products);
            }
        });
    }

    async openAddModal() {
        await AddProductModal.open({
            size: 'medium',
            onsave: (e) => {
                e.stopPropagation();
                this.addProduct(e.detail);
            }
        });
    }

    async addProduct(product) {
        try {
            const result = await addProduct({ product: JSON.stringify(product) });
            if (result && result.isSuccess && result.data) {
                this.data.push(...result.data);
                this.refreshData();
                Toasts.showSuccessToast('Added a new Product to the Catatalog to the Nest database', this);
            } else {
                Utils.handleControllerError(result, this);
            }
        } catch (error) {
            Utils.handleFatalError(error, this);
        }
    }

    async updateProducts(products) {
        try {
            const result = await updateProducts({ products: JSON.stringify(products) });
            if (result && result.isSuccess) {
                Toasts.showSuccessToast('Saved Cart to the Catatalog to the Nest database', this);
            } else {
                Utils.handleControllerError(result, this);
            }
        } catch (error) {
            Utils.handleFatalError(error, this);
        }
    }

    // @track is not working for datatable for some reason
    refreshData() {
        this.data = this.data.map((d) => d);
    }
}