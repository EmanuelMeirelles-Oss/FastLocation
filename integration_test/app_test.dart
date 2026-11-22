// Teste de ponta a ponta: abre o app num emulador Android, usa cada
// funcionalidade e salva um print de cada tela (pasta docs/screenshots).
//
// Rodar localmente (com emulador aberto):
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_test.dart
import 'package:fast_location/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Espera em tempo real, redesenhando a tela (dá tempo de ver no vídeo).
  Future<void> wait(WidgetTester tester, [int ms = 1500]) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Espera até [finder] aparecer (consultas reais à API levam alguns segundos).
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    int timeoutSeconds = 25,
  }) async {
    final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    throw TestFailure('Não apareceu a tempo: $finder');
  }

  var shot = 0;
  Future<void> screenshot(WidgetTester tester, String name) async {
    await tester.pump();
    shot++;
    await binding.takeScreenshot('${shot.toString().padLeft(2, '0')}-$name');
  }

  Future<void> openNewSearch(WidgetTester tester) async {
    await tester.tap(find.text('Nova consulta'));
    await waitFor(tester, find.text('Consultar'));
    await wait(tester, 800);
  }

  Future<void> submit(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await wait(tester, 600);
    await tester.tap(find.text('Consultar'));
  }

  testWidgets('FastLocation de ponta a ponta', (tester) async {
    // Dá tempo de a gravação de tela começar antes de o app abrir.
    await Future<void>.delayed(const Duration(seconds: 3));

    app.main();
    await binding.convertFlutterSurfaceToImage();

    // 1. Tela de abertura animada, que redireciona sozinha para a Home.
    await wait(tester, 1200);
    await screenshot(tester, 'abertura');
    await waitFor(tester, find.text('Nova consulta'));
    await wait(tester);
    await screenshot(tester, 'home-vazia');

    // 2. Consulta de endereço por CEP.
    await openNewSearch(tester);
    await tester.enterText(find.byType(TextField).first, '88015200');
    await wait(tester, 800);
    await screenshot(tester, 'consulta-por-cep');
    await submit(tester);
    await waitFor(tester, find.text('Último endereço consultado'));
    await wait(tester, 2500);
    await screenshot(tester, 'resultado-cep');
    expect(find.textContaining('Felipe Schmidt'), findsWidgets);

    // 3. Busca de CEP por endereço (parcial).
    await openNewSearch(tester);
    await tester.tap(find.text('Por endereço'));
    await wait(tester, 800);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'SC');
    await tester.enterText(fields.at(1), 'Florianópolis');
    await tester.enterText(fields.at(2), 'Felipe Schmidt');
    await wait(tester, 800);
    await screenshot(tester, 'consulta-por-endereco');
    await submit(tester);
    await waitFor(tester, find.textContaining('Resultados'));
    await wait(tester, 2500);
    await screenshot(tester, 'resultados-endereco');

    // Escolhe o primeiro resultado: vira o "último endereço consultado".
    await tester.tap(find.byIcon(Icons.place_outlined).first);
    await wait(tester, 2500);
    await screenshot(tester, 'endereco-selecionado');

    // 4. CEP inexistente: componente de "não encontrado".
    await openNewSearch(tester);
    await tester.enterText(find.byType(TextField).first, '99999999');
    await submit(tester);
    await waitFor(tester, find.text('Endereço não encontrado'));
    await wait(tester, 2500);
    await screenshot(tester, 'nao-encontrado');

    // 5. Histórico de consultas (carrega sozinho ao abrir).
    await tester.tap(find.byTooltip('Histórico de consultas'));
    await waitFor(tester, find.text('Histórico'));
    await wait(tester, 2500);
    await screenshot(tester, 'historico');
    expect(find.textContaining('CEP '), findsWidgets);

    // Volta para a Home.
    await tester.pageBack();
    await waitFor(tester, find.text('Nova consulta'));
    await wait(tester, 1500);
    await screenshot(tester, 'home-com-historico');

    // 6. Traçar rota: abre o app de mapas do aparelho (aparece no vídeo).
    await tester.tap(find.text('Traçar rota'));
    await wait(tester, 8000);
  });
}
