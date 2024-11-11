import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { Observable } from 'rxjs';

export class AuthInterceptor implements HttpInterceptor {

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
 /**
      const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': 'Basic ' + btoa('jorge:pffd')
    });

    // Clonando a requisição para adicionar os novos cabeçalhos
    req = req.clone({ headers });
*/


    // Utilizando o método `handle` do `HttpHandler` para passar a requisição adiante
    return next.handle(req);
  }
}
