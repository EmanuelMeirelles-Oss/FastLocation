# FastLocation

Aplicativo Flutter da **FastDelivery** para os entregadores consultarem endereços pelo CEP e CEPs pelo endereço, sem precisar ligar para a matriz.

Desafio 2 — Desenvolvimento de Sistemas Móveis (ADS · UniSENAI) · Emanuel Yunes de Meirelles

## Funcionalidades

- Consulta de **endereço por CEP** na API pública [ViaCEP](https://viacep.com.br).
- Busca de **CEP por endereço completo ou parcial** (UF + cidade + logradouro).
- **Armazenamento local** com Hive: consultas recorrentes do mesmo CEP saem do aparelho, sem ir à internet.
- **Gerenciamento de estado** com MobX (`Observer` nas telas e `reaction` para os erros de consulta).
- **Tela de loading** durante a consulta externa.
- Componente de **resultado não encontrado**.
- Tela de **histórico** de endereços consultados, carregada automaticamente ao abrir.
- **Traçar rota** da localização atual do aparelho até o último endereço consultado (abre o Google Maps ou outro app de mapas instalado).
- Tela de abertura animada com redirecionamento automático para a Home.

## Tecnologias

| Pacote | Uso |
| --- | --- |
| dio | Requisições HTTP à API ViaCEP |
| mobx, flutter_mobx, mobx_codegen | Estado reativo das telas |
| hive, hive_flutter, hive_generator | Histórico local de consultas |
| path, path_provider | Pasta onde o Hive grava os dados |
| geocoding | Converte o endereço em coordenadas |
| map_launcher | Abre o app de mapas com a rota |
| build_runner | Geração de código (MobX e Hive) |

## Como executar

Pré-requisitos: Flutter 3.x instalado (`flutter doctor` sem erros) e um emulador Android/iOS ou celular conectado.

```bash
git clone <URL-DESTE-REPOSITORIO>
cd fast_location
flutter pub get
flutter run
```

Os arquivos gerados (`*.g.dart`) já estão no repositório. Se alterar um controller ou o model, gere de novo:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Primeira vez, a partir do código-fonte sem as pastas nativas

Se as pastas `android/` e `ios/` ainda não existirem por completo, rode o script de preparo (gera só Android e iOS, instala as dependências e gera o código):

```bash
# Windows (PowerShell)
.\setup.ps1

# macOS / Linux
./setup.sh
```

O `flutter create` não sobrescreve arquivos existentes, então o `lib/` e o `AndroidManifest.xml` já configurado são preservados.

### iOS: permitir abrir apps de mapas

Adicione ao `ios/Runner/Info.plist`, dentro do `<dict>` principal:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>comgooglemaps</string>
  <string>waze</string>
</array>
```

O Apple Maps funciona sem essa configuração.

## Como usar

1. Na Home, toque em **Nova consulta**.
2. Escolha **Por CEP** (ex.: `88015200`) ou **Por endereço** (ex.: SC · Florianópolis · Felipe Schmidt).
3. Na busca por endereço, toque no resultado certo para selecioná-lo.
4. O endereço aparece em destaque como último consultado. Toque em **Traçar rota** para abrir o mapa.
5. O ícone de relógio no topo abre o **histórico** completo.

## Estrutura do projeto

```text
lib/
├── main.dart                        # main() refatorado: inicia o Hive e o app
└── src/
    ├── app_widget.dart              # MaterialApp, tema e rotas
    ├── http/http_client.dart        # configuração do Dio (ViaCEP)
    ├── routes/app_routes.dart       # nomes das rotas
    ├── shared/
    │   ├── colors/app_colors.dart
    │   ├── components/              # AppButton, AppLoading, AddressTile
    │   ├── metrics/app_metrics.dart # espaçamentos e tamanhos
    │   └── storage/                 # HiveConfig e nomes das caixas
    └── modules/
        ├── initial/page/            # tela de abertura animada
        ├── home/
        │   ├── components/          # AddressList, LastAddressCard, EmptySearch, SearchForm
        │   ├── controller/          # HomeController (MobX)
        │   ├── model/               # AddressModel (ViaCEP + Hive)
        │   ├── page/                # HomePage (Observer + reaction)
        │   ├── repositories/        # AddressRepository (API) e AddressLocalRepository (Hive)
        │   └── service/             # AddressService (regras de negócio)
        └── history/
            ├── controller/          # HistoryController (MobX)
            └── page/                # HistoryPage
```

Fluxo de uma consulta: `HomePage` → `HomeController` → `AddressService` → `AddressLocalRepository` (se o CEP já foi consultado) ou `AddressRepository` (ViaCEP) → resultado salvo no Hive → tela atualizada pelo `Observer`.

## Endpoints da API ViaCEP usados

| Consulta | Endpoint |
| --- | --- |
| Endereço por CEP | `GET https://viacep.com.br/ws/{cep}/json/` |
| CEP por endereço | `GET https://viacep.com.br/ws/{UF}/{cidade}/{logradouro}/json/` |

A busca por endereço exige pelo menos 3 letras na cidade e no logradouro (regra da própria API).

## Testes

```bash
flutter test
```

## Solução de problemas

- **Erro de versão ao rodar `flutter pub get`:** as versões das bibliotecas seguem as exigidas no enunciado. Se o seu Flutter for muito mais novo e alguma delas não resolver, rode `flutter pub outdated` para ver qual pacote conflita.
- **"Namespace not specified" no build Android:** algum plugin antigo não declara `namespace` para o Android Gradle Plugin 8. Rode `flutter pub upgrade` (mantém as versões dentro do `^` exigido) e tente de novo.
- **"Nenhum aplicativo de mapas instalado" no emulador:** use um emulador com Google Play (ele já tem o Google Maps) ou um celular físico.
