import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_picker_service.dart';
import 'history_service.dart';
import 'file_save_service.dart';
import 'sound_service.dart';
import 'monetization/ad_service.dart';
import 'monetization/in_app_purchase_service.dart';
import '../../features/compressor/services/image_compressor_service.dart';
import '../../features/resizer/services/image_resizer_service.dart';
import '../../features/cropper/services/image_cropper_service.dart';
import '../../features/converter/services/image_converter_service.dart';
import '../../features/pdf/services/image_pdf_service.dart';
import '../../features/id_photo/services/id_photo_service.dart';
import '../../features/signature/services/signature_service.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Core Services
  getIt.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
  getIt.registerLazySingleton<HistoryService>(() => HistoryServiceImpl(getIt()));
  getIt.registerLazySingleton<FileSaveService>(() => FileSaveServiceImpl());
  getIt.registerLazySingleton<SoundService>(() => SoundServiceImpl());
  getIt.registerLazySingleton<AdService>(() => MockAdServiceImpl());
  getIt.registerLazySingleton<InAppPurchaseService>(() => MockInAppPurchaseServiceImpl());

  // Feature Processing Services
  getIt.registerLazySingleton<ImageCompressorService>(() => ImageCompressorService());
  getIt.registerLazySingleton<ImageResizerService>(() => ImageResizerService());
  getIt.registerLazySingleton<ImageCropperService>(() => ImageCropperService());
  getIt.registerLazySingleton<ImageConverterService>(() => ImageConverterService());
  getIt.registerLazySingleton<ImagePdfService>(() => ImagePdfService());
  getIt.registerLazySingleton<IdPhotoService>(() => IdPhotoService());
  getIt.registerLazySingleton<SignatureService>(() => SignatureService());
}
