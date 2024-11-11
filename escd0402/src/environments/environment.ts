const urlBase = new URL(window.location.href);
export const environment = {
  production: true,
  apiUrl: urlBase.origin + '/' ,

};

