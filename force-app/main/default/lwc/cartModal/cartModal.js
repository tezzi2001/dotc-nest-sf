import { api } from 'lwc';

import saveToCart from '@salesforce/apex/ExternalProductViewController.saveToCart';

import LightningModal from 'lightning/modal';

export default class CartModal extends LightningModal {
    columns = [
        { label: 'Product Name', fieldName: 'name', hideDefaultActions: true },
        { label: 'Price Per Each', fieldName: 'price', type: 'currency', typeAttributes: { currencyCode: 'USD' }, hideDefaultActions: true },
        { label: 'Quantity', fieldName: 'quantity', type: 'number', hideDefaultActions: true, editable: true },
        { type: 'button-icon', initialWidth: '20', typeAttributes: { name: 'delete', iconName: 'utility:delete', title: 'Delete from Catalog' } },
    ];
    @api cartItems = [];
    draftValues = [];

    get totalPrice() {
        return this.cartItems
            .map((datum) => datum.price * datum.quantity)
            .reduce((result, price) => result + price, 0);
    }

    saveDatatableChanges(e) {
        const draftValues = this.parseDraftValues(e.detail.draftValues);
        this.cartItems = this.cartItems.map((cartItem) => {
            const draftValue = draftValues.find((draftValue) => draftValue.externalId === cartItem.externalId);
            return draftValue ? this.createCartItem(cartItem, draftValue) : cartItem;
        });
        this.draftValues = [];

        const updateEvent = new CustomEvent('update', { detail: draftValues });
        this.dispatchEvent(updateEvent);
    }

    async save() {
        try {
            const result = await saveToCart({ cartItems: JSON.stringify(this.cartItems) });
            if (result && result.isSuccess) {
                // toast success
                const saveEvent = new CustomEvent('save', { detail: this.cartItems });
                this.dispatchEvent(saveEvent);
                this.close();
            } else {
                console.error(result.errorMessage);
            }
        } catch (error) {
            console.error(error);
        }
    }

    cancel() {
        this.close();
    }

    parseDraftValues(draftValues) {
        return draftValues.map((draftValue) => {
            draftValue.quantity = parseInt(draftValue.quantity, 10);
            return draftValue;
        })
    }

    // this method is needed because cartItems array has read-only objects
    createCartItem(existingCartItem, draftValue) {
        return {
            externalId: existingCartItem.externalId,
            name: draftValue.name ? draftValue.name : existingCartItem.name,
            price: draftValue.price ? draftValue.price : existingCartItem.price,
            quantity: draftValue.quantity ? draftValue.quantity : existingCartItem.quantity,
        }
    }
}