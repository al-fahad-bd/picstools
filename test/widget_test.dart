import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:picstools/core/services/service_locator.dart';
import 'package:picstools/features/home/presentation/bloc/home_bloc.dart';
import 'package:picstools/features/home/presentation/views/home_view.dart';
import 'package:picstools/features/history/presentation/bloc/history_bloc.dart';
import 'package:picstools/features/history/presentation/views/history_view.dart';
import 'package:picstools/features/pro/presentation/bloc/pro_bloc.dart';
import 'package:picstools/features/pro/presentation/views/pro_view.dart';
import 'package:picstools/core/services/history_service.dart';
import 'package:picstools/core/services/monetization/in_app_purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerLazySingleton<HistoryService>(() => HistoryServiceImpl(prefs));
    getIt.registerLazySingleton<InAppPurchaseService>(() => MockInAppPurchaseServiceImpl());
    getIt.registerFactory<HomeBloc>(() => HomeBloc());
    getIt.registerFactory<HistoryBloc>(() => HistoryBloc(historyService: getIt<HistoryService>()));
    getIt.registerFactory<ProBloc>(() => ProBloc(purchaseService: getIt<InAppPurchaseService>()));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('HomeView renders tool cards and header properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeView()),
      ),
    );
    await tester.pump();

    expect(find.text('PicsTools'), findsOneWidget);
    expect(find.text('Compress Image'), findsOneWidget);
    expect(find.text('Image to PDF'), findsOneWidget);
  });

  testWidgets('HistoryView renders empty state when no history', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HistoryView()),
      ),
    );
    await tester.pump();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('No Recent Operations'), findsOneWidget);
  });

  testWidgets('ProView renders upgrade CTA properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProView()),
      ),
    );
    await tester.pump();

    expect(find.text('PicsTools Pro'), findsOneWidget);
    expect(find.text('Unlock maximum image productivity'), findsOneWidget);
  });

  test('HomeBloc filters tools by search and category correctly', () {
    final bloc = HomeBloc();
    expect(bloc.state is HomeLoadedState, true);

    bloc.add(const SearchToolsEvent('pdf'));
    expect(bloc.stream, emits(predicate<HomeState>((s) {
      if (s is! HomeLoadedState) return false;
      return s.filteredTools.any((t) => t.id == 'pdf') && s.filteredTools.length == 1;
    })));
  });
}
