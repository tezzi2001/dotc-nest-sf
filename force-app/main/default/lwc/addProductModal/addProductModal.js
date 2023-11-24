import LightningModal from 'lightning/modal';

export default class AddProductModal extends LightningModal {
    fields = [
        {
            label: 'Name',
            name: 'name',
            type: 'text',
        },
        {
            label: 'Description',
            name: 'description',
            type: 'text',
        },
        {
            label: 'Price',
            name: 'price',
            type: 'number',
            formatter: 'currency',
            step: 0.01,
        },
        {
            label: 'Quantity',
            name: 'quantity',
            type: 'number',
        },
        {
            label: 'Available',
            name: 'available',
            type: 'checkbox',
        }
    ];
    data = {
        name: null,
        description: null,
        price: null,
        quantity: null,
        available: null,
    }

    updateField(e) {
        const fieldName = e.target.dataset.name;
        const fieldType = e.target.dataset.type;
        const fieldValue = e.target.value;
        this.data[fieldName] = this.getFieldValue(fieldType, fieldValue);
    }

    getFieldValue(fieldType, rowFieldValue) {
        switch (fieldType) {
            case 'number':
                return parseInt(rowFieldValue, 10);
            case 'checkbox':
                return !!rowFieldValue;
            default:
                return rowFieldValue;
        }
    }

    save() {
        const saveEvent = new CustomEvent('save', { detail: this.data });
        this.dispatchEvent(saveEvent);
        this.close();
    }

    cancel() {
        this.close();
    }
}