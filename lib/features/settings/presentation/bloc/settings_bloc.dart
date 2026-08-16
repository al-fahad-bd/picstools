import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/audio_service.dart';
import '../../../background_remover/data/datasources/model_storage_datasource.dart';
import '../../../background_remover/domain/entities/ai_model_info.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class ToggleSoundEvent extends SettingsEvent {
  final bool isEnabled;
  const ToggleSoundEvent(this.isEnabled);
  @override
  List<Object?> get props => [isEnabled];
}

class ChangeThemeModeEvent extends SettingsEvent {
  final ThemeMode themeMode;
  const ChangeThemeModeEvent(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class TapDeveloperEvent extends SettingsEvent {}

class DeleteAiModelEvent extends SettingsEvent {}

class RefreshAiModelStatusEvent extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitialState extends SettingsState {}

class SettingsLoadedState extends SettingsState {
  final bool isSoundEnabled;
  final bool isDeveloperUnlocked;
  final ThemeMode themeMode;
  final int developerTapCount;
  final AiModelInfo? aiModelInfo;
  final bool isDeletingModel;
  final String? toastMessage;
  final bool isDeveloperNewlyUnlocked;

  const SettingsLoadedState({
    required this.isSoundEnabled,
    required this.isDeveloperUnlocked,
    this.themeMode = ThemeMode.system,
    this.developerTapCount = 0,
    this.aiModelInfo,
    this.isDeletingModel = false,
    this.toastMessage,
    this.isDeveloperNewlyUnlocked = false,
  });

  SettingsLoadedState copyWith({
    bool? isSoundEnabled,
    bool? isDeveloperUnlocked,
    ThemeMode? themeMode,
    int? developerTapCount,
    AiModelInfo? aiModelInfo,
    bool? isDeletingModel,
    String? toastMessage,
    bool clearToast = false,
    bool? isDeveloperNewlyUnlocked,
  }) {
    return SettingsLoadedState(
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isDeveloperUnlocked: isDeveloperUnlocked ?? this.isDeveloperUnlocked,
      themeMode: themeMode ?? this.themeMode,
      developerTapCount: developerTapCount ?? this.developerTapCount,
      aiModelInfo: aiModelInfo ?? this.aiModelInfo,
      isDeletingModel: isDeletingModel ?? this.isDeletingModel,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isDeveloperNewlyUnlocked: isDeveloperNewlyUnlocked ?? false,
    );
  }

  @override
  List<Object?> get props => [
        isSoundEnabled,
        isDeveloperUnlocked,
        themeMode,
        developerTapCount,
        aiModelInfo,
        isDeletingModel,
        toastMessage,
        isDeveloperNewlyUnlocked,
      ];
}

// BLoC Implementation
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AudioService audioService;
  final SharedPreferences prefs;
  final ModelStorageDataSource modelStorageDataSource;

  SettingsBloc({
    required this.audioService,
    required this.prefs,
    required this.modelStorageDataSource,
  }) : super(SettingsInitialState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ToggleSoundEvent>(_onToggleSound);
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<TapDeveloperEvent>(_onTapDeveloper);
    on<DeleteAiModelEvent>(_onDeleteAiModel);
    on<RefreshAiModelStatusEvent>(_onRefreshAiModelStatus);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final isSound = audioService.isSoundEnabled;
    final isDevUnlocked = prefs.getBool('developer_mode_unlocked') ?? false;
    final modelInfo = await modelStorageDataSource.getStoredModelInfo();

    final modeStr = prefs.getString('app_theme_mode');
    ThemeMode themeMode = ThemeMode.system;
    if (modeStr == 'light') {
      themeMode = ThemeMode.light;
    } else if (modeStr == 'dark') {
      themeMode = ThemeMode.dark;
    }

    emit(SettingsLoadedState(
      isSoundEnabled: isSound,
      isDeveloperUnlocked: isDevUnlocked,
      themeMode: themeMode,
      aiModelInfo: modelInfo,
    ));
  }

  Future<void> _onToggleSound(
    ToggleSoundEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await audioService.setSoundEnabled(event.isEnabled);
    if (state is SettingsLoadedState) {
      final current = state as SettingsLoadedState;
      emit(current.copyWith(isSoundEnabled: event.isEnabled, clearToast: true));
    }
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    String modeStr = 'system';
    if (event.themeMode == ThemeMode.light) {
      modeStr = 'light';
    } else if (event.themeMode == ThemeMode.dark) {
      modeStr = 'dark';
    }
    await prefs.setString('app_theme_mode', modeStr);

    if (state is SettingsLoadedState) {
      final current = state as SettingsLoadedState;
      emit(current.copyWith(themeMode: event.themeMode, clearToast: true));
    }
  }

  Future<void> _onTapDeveloper(
    TapDeveloperEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadedState) return;
    final current = state as SettingsLoadedState;

    if (current.isDeveloperUnlocked) return;

    final newCount = current.developerTapCount + 1;
    final remaining = 10 - newCount;

    if (newCount >= 10) {
      await prefs.setBool('developer_mode_unlocked', true);
      emit(current.copyWith(
        developerTapCount: newCount,
        isDeveloperUnlocked: true,
        isDeveloperNewlyUnlocked: true,
        toastMessage: '🎉 Developer Details Unlocked!',
      ));
    } else if (newCount >= 4) {
      emit(current.copyWith(
        developerTapCount: newCount,
        toastMessage:
            'You are $remaining tap(s) away from finding the developer.',
      ));
    } else {
      emit(current.copyWith(developerTapCount: newCount, clearToast: true));
    }
  }

  Future<void> _onDeleteAiModel(
    DeleteAiModelEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadedState) return;
    final current = state as SettingsLoadedState;

    emit(current.copyWith(isDeletingModel: true, clearToast: true));
    try {
      await modelStorageDataSource.deleteModel();
      final modelInfo = await modelStorageDataSource.getStoredModelInfo();
      emit(current.copyWith(
        isDeletingModel: false,
        aiModelInfo: modelInfo,
        toastMessage: '🗑️ AI Model deleted from disk',
      ));
    } catch (e) {
      emit(current.copyWith(
        isDeletingModel: false,
        toastMessage: 'Failed to delete model: $e',
      ));
    }
  }

  Future<void> _onRefreshAiModelStatus(
    RefreshAiModelStatusEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoadedState) return;
    final current = state as SettingsLoadedState;
    final modelInfo = await modelStorageDataSource.getStoredModelInfo();
    emit(current.copyWith(aiModelInfo: modelInfo, clearToast: true));
  }
}
