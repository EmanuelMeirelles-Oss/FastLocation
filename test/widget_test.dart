import 'package:fast_location/src/modules/home/components/empty_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptySearch mostra a mensagem de não encontrado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptySearch(notFound: true))),
    );
    expect(find.text('Endereço não encontrado'), findsOneWidget);
  });

  testWidgets('EmptySearch mostra o estado inicial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptySearch())),
    );
    expect(find.text('Nenhuma consulta ainda'), findsOneWidget);
  });
}
