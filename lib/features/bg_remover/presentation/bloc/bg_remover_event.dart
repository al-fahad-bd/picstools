import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/bg_remover_params.dart';

abstract class BgRemoverEvent extends Equatable {
  const BgRemoverEvent();

  @override
  List<Object?> get props => [];
}

class SelectImageEvent extends BgRemoverEvent {
  final File imageFile;

  const SelectImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class ProcessSegmentationEvent extends BgRemoverEvent {
  final BgRemoverParams params;

  const ProcessSegmentationEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class ResetBgRemoverEvent extends BgRemoverEvent {}
