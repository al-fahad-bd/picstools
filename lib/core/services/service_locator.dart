import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_picker_service.dart';
import 'history_service.dart';
import 'file_save_service.dart';
import 'sound_service.dart';
import 'audio_service.dart';
import 'monetization/ad_service.dart';
import 'monetization/in_app_purchase_service.dart';
import '../../features/compressor/services/image_compressor_service.dart';
import '../../features/resizer/services/image_resizer_service.dart';
import '../../features/cropper/services/image_cropper_service.dart';
import '../../features/converter/services/image_converter_service.dart';
import '../../features/pdf/services/image_pdf_service.dart';
import '../../features/id_photo/services/id_photo_service.dart';
import '../../features/signature/services/signature_service.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/pro/presentation/bloc/pro_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/background_remover/data/datasources/model_storage_datasource.dart';
import '../../features/background_remover/data/datasources/model_downloader_datasource.dart';
import '../../features/background_remover/data/datasources/onnx_inference_datasource.dart';
import '../../features/background_remover/data/repositories/background_remover_repository_impl.dart';
import '../../features/background_remover/domain/repositories/background_remover_repository.dart';
import '../../features/background_remover/domain/usecases/check_model_status_usecase.dart';
import '../../features/background_remover/domain/usecases/download_model_usecase.dart';
import '../../features/background_remover/domain/usecases/cancel_model_download_usecase.dart';
import '../../features/background_remover/domain/usecases/delete_model_usecase.dart';
import '../../features/background_remover/domain/usecases/remove_background_usecase.dart';
import '../../features/background_remover/presentation/bloc/background_remover_bloc.dart';

final getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  final audioService = AudioService(prefs);
  await audioService.init();
  getIt.registerSingleton<AudioService>(audioService);

  // Core Services
  getIt.registerLazySingleton<ImagePickerService>(
    () => ImagePickerServiceImpl(),
  );
  getIt.registerLazySingleton<HistoryService>(
    () => HistoryServiceImpl(getIt()),
  );
  getIt.registerLazySingleton<FileSaveService>(() => FileSaveServiceImpl());
  getIt.registerLazySingleton<SoundService>(() => SoundServiceImpl());
  getIt.registerLazySingleton<AdService>(() => MockAdServiceImpl());
  final iapService = InAppPurchaseServiceImpl(prefs);
  await iapService.initialize();
  getIt.registerSingleton<InAppPurchaseService>(iapService);

  // Feature Processing Services
  getIt.registerLazySingleton<ImageCompressorService>(
    () => ImageCompressorService(),
  );
  getIt.registerLazySingleton<ImageResizerService>(() => ImageResizerService());
  getIt.registerLazySingleton<ImageCropperService>(() => ImageCropperService());
  getIt.registerLazySingleton<ImageConverterService>(
    () => ImageConverterService(),
  );
  getIt.registerLazySingleton<ImagePdfService>(() => ImagePdfService());
  getIt.registerLazySingleton<IdPhotoService>(() => IdPhotoService());
  getIt.registerLazySingleton<SignatureService>(() => SignatureService());

  // Background Remover Feature
  getIt.registerLazySingleton<ModelStorageDataSource>(
    () => ModelStorageDataSourceImpl(),
  );
  getIt.registerLazySingleton<ModelDownloaderDataSource>(
    () => ModelDownloaderDataSourceImpl(
      storageDataSource: getIt<ModelStorageDataSource>(),
    ),
  );
  getIt.registerLazySingleton<OnnxInferenceDataSource>(
    () => OnnxInferenceDataSourceImpl(),
  );
  getIt.registerLazySingleton<BackgroundRemoverRepository>(
    () => BackgroundRemoverRepositoryImpl(
      storageDataSource: getIt<ModelStorageDataSource>(),
      downloaderDataSource: getIt<ModelDownloaderDataSource>(),
      inferenceDataSource: getIt<OnnxInferenceDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CheckModelStatusUseCase>(
    () => CheckModelStatusUseCase(getIt<BackgroundRemoverRepository>()),
  );
  getIt.registerLazySingleton<DownloadModelUseCase>(
    () => DownloadModelUseCase(getIt<BackgroundRemoverRepository>()),
  );
  getIt.registerLazySingleton<CancelModelDownloadUseCase>(
    () => CancelModelDownloadUseCase(getIt<BackgroundRemoverRepository>()),
  );
  getIt.registerLazySingleton<DeleteModelUseCase>(
    () => DeleteModelUseCase(getIt<BackgroundRemoverRepository>()),
  );
  getIt.registerLazySingleton<RemoveBackgroundUseCase>(
    () => RemoveBackgroundUseCase(getIt<BackgroundRemoverRepository>()),
  );

  // Feature BLoCs
  getIt.registerFactory<HomeBloc>(() => HomeBloc());
  getIt.registerFactory<HistoryBloc>(
    () => HistoryBloc(historyService: getIt<HistoryService>()),
  );
  getIt.registerFactory<ProBloc>(
    () => ProBloc(purchaseService: getIt<InAppPurchaseService>()),
  );
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      audioService: getIt<AudioService>(),
      prefs: getIt<SharedPreferences>(),
      modelStorageDataSource: getIt<ModelStorageDataSource>(),
    ),
  );
  getIt.registerFactory<BackgroundRemoverBloc>(
    () => BackgroundRemoverBloc(
      checkModelStatusUseCase: getIt<CheckModelStatusUseCase>(),
      downloadModelUseCase: getIt<DownloadModelUseCase>(),
      cancelModelDownloadUseCase: getIt<CancelModelDownloadUseCase>(),
      deleteModelUseCase: getIt<DeleteModelUseCase>(),
      removeBackgroundUseCase: getIt<RemoveBackgroundUseCase>(),
      historyService: getIt<HistoryService>(),
    ),
  );
}
