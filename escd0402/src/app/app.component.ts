import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterOutlet } from '@angular/router';

import {
  PoButtonModule,
  PoContainerModule,
  PoFieldModule,
  PoLoadingModule,
  PoMenuModule,
  PoNotificationService,
  PoPageModule,
  PoRadioGroupOption,
  PoTabsModule,
  PoToolbarModule,
} from '@po-ui/ng-components';
import { RelatorioService } from './services/relatorio.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    FormsModule,
    CommonModule,
    RouterOutlet,
    PoToolbarModule,
    PoMenuModule,
    PoPageModule,
    PoTabsModule,
    PoFieldModule,
    PoButtonModule,
    PoContainerModule,
    PoLoadingModule,
  ],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  classFiscalIni: string = '00000000';
  classFiscalFim: string = '99999999';
  itCodigoIni: string = '';
  itCodigoFim: string = 'ZZZZZZZZZZZZZZZZ';

  tipoExceucao: number = 1;

  isHideLoading: boolean = true;

  public readonly execucaoOptions: Array<PoRadioGroupOption> = [
    { label: 'On-Line', value: 1 },
    { label: 'Batch', value: 2 },
  ];

  constructor(
    private service: RelatorioService,
    private poNotification: PoNotificationService
  ) {}

  onExecutar() {
    if (this.tipoExceucao === 1) {
      let parametro = {
        classFiscalIni: this.classFiscalIni,
        classFiscalFim: this.classFiscalFim,
        itCodigoIni: this.itCodigoIni,
        itCodigoFim: this.itCodigoFim,
      };

      this.isHideLoading = false;
      this.service.imprimir(parametro).subscribe({
        next: (resp) => {
          let contentType = 'application/xml';

          this.service.downloadArquivos(
            resp.pRelatorio,
            resp.pNomeArquivo,
            contentType
          );
          this.isHideLoading = true;
          this.poNotification.success(
            'Relatório gerado com sucesso, favor verificar sua pasta de downloads!'
          );

          this.isHideLoading = true;
        },
        error: (err) => {
          this.isHideLoading = true;
        },
      });
    } else {
      this.poNotification.warning('Em construção');
    }
  }
}
