# Auth App — Flutter + Firebase

Aplicativo Android/Flutter implementado a partir dos dois PDFs fornecidos: autenticação profissional e CRUD de notas com Firestore.

## O que está pronto

- Login, cadastro com confirmação de senha e recuperação por email.
- `AuthPage` com `authStateChanges()`: entrada/saída atualizam a tela automaticamente.
- Tema escuro centralizado, cores `#0B1220`, `#151E31`, `#6C63FF` e degradê até `#4A90FF`.
- Componentes reutilizáveis, mostrar/ocultar senha, indicador de carregamento e mensagens em português.
- Animação Lottie em `assets/animations/login.json` no lugar do ícone nas telas de login e cadastro. Ícone do aplicativo e nome **Auth App**.
- Home simples conforme o PDF: email, cartões Meu perfil/Configurações e menu inferior visual Início/Buscar/Perfil.
- Notas com criação, leitura em tempo real, edição e exclusão confirmada.
- Regras Firestore que isolam os dados de cada conta.
- Google e Apple são demonstrativos, conforme o material da aula.

O CRUD da segunda aula está acessível em **Minhas notas** na Home. A coleção está em `users/{uid}/notes`, em vez de uma coleção compartilhada, para cada conta acessar apenas suas notas. Os campos continuam sendo `note` e `timestamp`, ordenados por timestamp decrescente.

## Executar localmente, sem conta Firebase

Requisitos: Flutter, Android SDK, Node.js 22+ e Java 21+.

```bash
./scripts/configure_local.sh
flutter pub get
npm ci
npm run emulators
```

Deixe o terminal acima aberto. Para abrir o emulador leve deste projeto, execute `./scripts/start_emulator.sh` em outro terminal. Ele usa uma imagem Android 7.0 (API 24), dados isolados e 1 GB de RAM; o emulador pessoal não é alterado. A instalação inicial da imagem oficial é indicada pelo script, caso ainda não exista.

Com o Android iniciado, em outro terminal:

```bash
flutter run -d emulator-5554
```

É Firebase real executado na **Emulator Suite oficial**, com dados de desenvolvimento locais. O projeto de demonstração é `demo-apk-auth`; não há conexão a um projeto Firebase em nuvem. Cadastro e login funcionam com contas criadas no próprio app. Para preparar a conta demonstrativa local, execute `python3 scripts/seed_demo.py`: email `demo@exemplo.com`, senha `Teste123!`.

- Painel local: http://127.0.0.1:4000
- Authentication: porta 9099
- Firestore: porta 8085
- O emulador Android acessa o computador por `10.0.2.2`.
- Dados são exportados em `.emulator-data/` quando `npm run emulators` é encerrado normalmente (Ctrl+C), e importados na próxima execução.
- Recuperação de senha local gera um link no terminal/painel do emulador; **não envia email real**.
- O APK local depende desses serviços no computador. Para um telefone físico, use `adb reverse tcp:9099 tcp:9099` e `adb reverse tcp:8085 tcp:8085`, recompilando com `--dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1`.

O SDK Flutter instalado exige Android 7.0 (API 24) ou superior. Esse é o ajuste de compatibilidade em relação ao `minSdk 23` citado no PDF.

## Compilar APK

```bash
flutter build apk --debug
```

Arquivo: `build/app/outputs/flutter-apk/app-debug.apk`. É uma compilação para teste, assinada com chave de desenvolvimento. Para distribuição, configure a assinatura de release e um projeto Firebase em nuvem.

## Conectar ao Firebase em nuvem

1. Entre em https://console.firebase.google.com/ com uma conta Google e crie um projeto.
2. Em Authentication → Método de login, ative **Email/senha**.
3. Crie o banco **Cloud Firestore**. As coleções surgem ao salvar a primeira nota.
4. Instale as ferramentas e vincule o aplicativo:

```bash
npm exec -- firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=SEU_PROJECT_ID --platforms=android,ios,web
```

O package Android é `com.example.apk_auth`. O comando deve substituir `lib/firebase_options.dart` pela configuração do seu projeto. Se registrar manualmente, coloque `google-services.json` em `android/app/`.

5. Publique as regras incluídas, depois de conferir o ID do projeto:

```bash
npm exec -- firebase deploy --only firestore:rules,firestore:indexes --project SEU_PROJECT_ID
```

6. Execute ou compile desativando os emuladores:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=false
flutter build apk --release --dart-define=USE_FIREBASE_EMULATORS=false
```

A recuperação de senha passará a enviar email pelo Firebase. O Android de desenvolvimento permite HTTP apenas no manifest de debug para os emuladores; conexões de produção usam HTTPS. A configuração e compilação iOS exigem um Mac com Xcode e não foram verificadas neste ambiente Linux.

## Verificação

```bash
flutter analyze
flutter test test
# Com os emuladores Firebase em execução:
python3 scripts/check_emulators.py
# Com Firebase e Android Emulator em execução:
flutter test integration_test/app_test.dart -d emulator-5554
```

Os testes de integração cobrem os formulários, navegação, cadastro, CRUD de notas, logout, erro de senha, solicitação de recuperação e novo login. O script Python verifica as regras com duas contas, acesso anônimo e geração do link de recuperação.

Os arquivos `lib/firebase_options.dart`, `lib/service/firebase_service.dart`, `firebase.json`, `google-services.json`, `GoogleService-Info.plist`, arquivos `.env` e chaves de assinatura estão no `.gitignore`. Os arquivos `.example` contêm somente configuração demonstrativa.
