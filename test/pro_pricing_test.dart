import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:picstools/core/services/monetization/in_app_purchase_service.dart';
import 'package:picstools/features/pro/presentation/bloc/pro_bloc.dart';
import 'package:picstools/features/pro/presentation/views/pro_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('ProBloc loads localized pricing into ProLoadedState', () async {
    final mockIap = MockInAppPurchaseServiceImpl();
    mockIap.setPricingForTesting(
      const ProSubscriptionPricing(
        annualPriceFormatted: '৳ 2,150.00',
        annualPerMonthFormatted: '৳ 179',
        monthlyPriceFormatted: '৳ 350.00',
        currencySymbol: '৳',
        currencyCode: 'BDT',
      ),
    );

    final bloc = ProBloc(purchaseService: mockIap);
    bloc.add(LoadProStatusEvent());

    await expectLater(
      bloc.stream,
      emits(
        predicate<ProState>((state) {
          if (state is ProLoadedState) {
            return state.pricing.annualPriceFormatted == '৳ 2,150.00' &&
                state.pricing.monthlyPriceFormatted == '৳ 350.00' &&
                state.pricing.annualPerMonthFormatted == '৳ 179';
          }
          return false;
        }),
      ),
    );

    await bloc.close();
  });

  testWidgets('ProView displays localized local currency on paywall', (
    WidgetTester tester,
  ) async {
    final mockIap = MockInAppPurchaseServiceImpl();
    mockIap.setPricingForTesting(
      const ProSubscriptionPricing(
        annualPriceFormatted: '৳ 2,150.00',
        annualPerMonthFormatted: '৳ 179',
        monthlyPriceFormatted: '৳ 350.00',
        currencySymbol: '৳',
        currencyCode: 'BDT',
      ),
    );

    getIt.registerSingleton<InAppPurchaseService>(mockIap);
    getIt.registerFactory<ProBloc>(
      () => ProBloc(purchaseService: getIt<InAppPurchaseService>()),
    );

    await tester.pumpWidget(const MaterialApp(home: ProView()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify annual localized price is shown on plan selector
    expect(
      find.text('7 Days Free Trial • Billed ৳ 2,150.00 / yr'),
      findsOneWidget,
    );
    expect(find.text('৳ 179'), findsOneWidget);

    // Verify CTA button has annual localized price
    expect(find.text('START 7-DAY FREE TRIAL • ৳ 2,150.00/YR'), findsOneWidget);

    // Tap monthly flexible plan
    await tester.tap(find.text('MONTHLY FLEXIBLE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify CTA button now reflects monthly localized price
    expect(find.text('UPGRADE NOW • ৳ 350.00 / MONTH'), findsOneWidget);
  });
}
