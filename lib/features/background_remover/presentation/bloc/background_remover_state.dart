import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_model_info.dart';
import '../../domain/entities/background_removal_result.dart';

abstract class BackgroundRemoverState extends Equatable {
  const BackgroundRemoverState();

  @override
  List<Object?> get props => [];
}

class BackgroundRemoverInitial extends BackgroundRemoverState {}

class BackgroundRemoverLoadingState extends BackgroundRemoverState {
  final String message;
  const BackgroundRemoverLoadingState(this.message);

  @override
  List<Object?> get props => [message];
}

class ModelNotDownloadedState extends BackgroundRemoverState {
  final AiModelInfo modelInfo;
  const ModelNotDownloadedState(this.modelInfo);

  @override
  List<Object?> get props => [modelInfo];
}

class ModelDownloadingState extends BackgroundRemoverState {
  final double progress; // 0.0 to 1.0
  final int receivedBytes;
  final int totalBytes;
  final AiModelInfo modelInfo;

  const ModelDownloadingState({
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
    required this.modelInfo,
  });

  String get formattedReceivedSize {
    final mb = receivedBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedTotalSize {
    final mb = totalBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  int get percentage => (progress * 100).toInt().clamp(0, 100);

  @override
  List<Object?> get props => [progress, receivedBytes, totalBytes, modelInfo];
}

class ModelReadyState extends BackgroundRemoverState {
  final AiModelInfo modelInfo;
  final File? selectedImage;

  const ModelReadyState({
    required this.modelInfo,
    this.selectedImage,
  });

  @override
  List<Object?> get props => [modelInfo, selectedImage?.path];
}

class BackgroundRemovingState extends BackgroundRemoverState {
  final File originalImage;
  final String statusText;

  const BackgroundRemovingState({
    required this.originalImage,
    this.statusText = 'Removing background with on-device AI...',
  });

  @override
  List<Object?> get props => [originalImage.path, statusText];
}

class BackgroundRemovalSuccessState extends BackgroundRemoverState {
  final BackgroundRemovalResult result;

  const BackgroundRemovalSuccessState(this.result);

  @override
  List<Object?> get props => [result];
}

class BackgroundRemoverErrorState extends BackgroundRemoverState {
  final String message;
  final bool canRetry;
  final AiModelInfo? modelInfo;

  const BackgroundRemoverErrorState({
    required this.message,
    this.canRetry = true,
    this.modelInfo,
  });

  @override
  List<Object?> get props => [message, canRetry, modelInfo];
}
