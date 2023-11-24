import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const showErrorToast = (message, context) => {
    showToast(message, 'error', 'dismissable', context);
}
const showInfoToast = (message, context) => {
    showToast(message, 'info', 'dismissable', context);
}
const showSuccessToast = (message, context)  => {
    showToast(message, 'success', 'dismissable', context);
}

function showToast(message, variant, mode, context) {
    context.dispatchEvent(
        new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode,
            title: variant,
        }),
    );
}

const Toasts = {
    showErrorToast,
    showInfoToast,
    showSuccessToast,
}
export { Toasts };