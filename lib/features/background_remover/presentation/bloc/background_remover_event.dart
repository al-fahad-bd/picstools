import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class BackgroundRemoverEvent extends Equatable {
  const BackgroundRemoverEvent();

  @override
  List<Object?> get props => [];
}

class CheckModelStatusEvent extends BackgroundRemoverEvent {}

class DownloadModelEvent extends BackgroundRemoverEvent {}

class CancelDownloadEvent extends BackgroundRemoverEvent {}

class DeleteModelEvent extends BackgroundRemoverEvent {}

class SelectImageEvent extends BackgroundRemoverEvent {
  final File file;
  const SelectImageEvent(this.file);

  @override
  List<Object?> get props => [file.path];
}

class ProcessBackgroundRemovalEvent extends BackgroundRemoverEvent {
  final File file;
  const ProcessBackgroundRemovalEvent(this.file);

  @override
  List<Object?> get props => [file.path];
}

class ResetBackgroundRemoverEvent extends BackgroundRemoverEvent {}
