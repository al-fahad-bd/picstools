import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/bg_remover_params.dart';

abstract class BgRemoverState extends Equatable {
  const BgRemoverState();

  @override
  List<Object?> get props => [];
}

class BgRemoverInitial extends BgRemoverState {}

class BgRemoverProcessing extends BgRemoverState {
  final File originalImage;

  const BgRemoverProcessing(this.originalImage);

  @override
  List<Object?> get props => [originalImage];
}

class BgRemoverSuccess extends BgRemoverState {
  final File originalImage;
  final File processedImage;
  final BgRemoverParams params;

  const BgRemoverSuccess({
    required this.originalImage,
    required this.processedImage,
    required this.params,
  });

  @override
  List<Object?> get props => [originalImage, processedImage, params];
}

class BgRemoverFailure extends BgRemoverState {
  final String errorMessage;

  const BgRemoverFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
