import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_locator.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/compressor/presentation/views/compress_view.dart';
import '../../features/resizer/presentation/views/resize_view.dart';
import '../../features/cropper/presentation/views/crop_view.dart';
import '../../features/converter/presentation/views/convert_view.dart';
import '../../features/pdf/presentation/views/pdf_view.dart';
import '../../features/id_photo/presentation/views/id_photo_view.dart';
import '../../features/signature/presentation/views/signature_view.dart';
import '../../features/tool_placeholder_view.dart';

abstract class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final prefs = getIt<SharedPreferences>();
          final completed = prefs.getBool('onboarding_completed') ?? false;
          if (completed) {
            return '/home';
          }
          return '/onboarding';
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/compress',
        builder: (context, state) => const CompressView(),
      ),
      GoRoute(
        path: '/tool/resize',
        builder: (context, state) => const ResizeView(),
      ),
      GoRoute(
        path: '/tool/crop',
        builder: (context, state) => const CropView(),
      ),
      GoRoute(
        path: '/tool/convert',
        builder: (context, state) => const ConvertView(),
      ),
      GoRoute(
        path: '/tool/pdf',
        builder: (context, state) => const PdfView(),
      ),
      GoRoute(
        path: '/tool/id_photo',
        builder: (context, state) => const IdPhotoView(),
      ),
      GoRoute(
        path: '/tool/signature',
        builder: (context, state) => const SignatureView(),
      ),
      GoRoute(
        path: '/tool/:name',
        builder: (context, state) {
          final name = state.pathParameters['name'] ?? 'Tool';
          final titleMap = {
            'social': 'Social Media Resize',
          };
          return ToolPlaceholderView(title: titleMap[name] ?? 'Image Tool');
        },
      ),
    ],
  );
}
