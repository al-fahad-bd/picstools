import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/compressor/presentation/views/compress_view.dart';
import '../../features/resizer/presentation/views/resize_view.dart';
import '../../features/cropper/presentation/views/crop_view.dart';
import '../../features/converter/presentation/views/convert_view.dart';
import '../../features/pdf/presentation/views/pdf_view.dart';
import '../../features/id_photo/presentation/views/id_photo_view.dart';
import '../../features/signature/presentation/views/signature_view.dart';
import '../../features/background_remover/presentation/views/background_remover_view.dart';
import '../../features/settings/presentation/views/privacy_policy_view.dart';
import '../../features/settings/presentation/views/developer_details_view.dart';
import '../../features/tool_placeholder_view.dart';

abstract class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
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
        path: '/privacy_policy',
        builder: (context, state) => const PrivacyPolicyView(),
      ),
      GoRoute(
        path: '/developer',
        builder: (context, state) => const DeveloperDetailsView(),
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
        path: '/tool/remove_bg',
        builder: (context, state) => const BackgroundRemoverView(),
      ),
      GoRoute(
        path: '/tool/:name',
        builder: (context, state) {
          final name = state.pathParameters['name'] ?? 'Tool';
          final titleMap = {
            'remove_bg': 'Remove Background',
            'social': 'Social Media Resize',
          };
          return ToolPlaceholderView(title: titleMap[name] ?? 'Image Tool');
        },
      ),
    ],
  );
}
