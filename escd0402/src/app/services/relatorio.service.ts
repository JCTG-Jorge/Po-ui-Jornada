import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class RelatorioService {

  APIURL = environment.apiUrl
  constructor(private http: HttpClient) { }

  imprimir(payload: any){
    let url = this.APIURL + 'api/cie/v1/escd0402ws'
    return this.http.post<any>(url, payload)
  }


  downloadArquivos(base64: string, arquvio: string, contentType: string) {
    const byteArray = new Uint8Array(
      atob(base64)
        .split("")
        .map(char => char.charCodeAt(0))
    );
    const file = new Blob([byteArray], { type: contentType });
    const fileURL = URL.createObjectURL(file);
    let pdfName = arquvio;

      // Construct the 'a' element
      let link = document.createElement("a");
      link.download = pdfName;
      link.target = "_blank";

      // Construct the URI
      link.href = fileURL;
      document.body.appendChild(link);
      link.click();

      // Cleanup the DOM
      document.body.removeChild(link);

  }

  apiServiceRpw() {
    return (
      this.APIURL + 'dts/datasul-rest/resources/prg/btb/v1/servidoresExecucao'
    );
  }
  jobAgendamento(payload: any) {
    let url =
      this.APIURL + 'dts/datasul-rest/resources/prg/framework/v1/jobScheduler';

    return this.http.post<any>(url, payload);
  }

}
