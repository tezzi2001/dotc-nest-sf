import { Toasts } from 'c/toast';

const handleControllerError = (result, context) => {
    Toasts.showErrorToast(result.errorMessage, context);
    console.error(result.fullErrorMessage);
}

const handleFatalError = (error, context) => {
    Toasts.showErrorToast('An error occured in the system. Please contact system administrator.', context);
    console.error(error);
}

const Utils = {
    handleControllerError,
    handleFatalError,
}
export { Utils };