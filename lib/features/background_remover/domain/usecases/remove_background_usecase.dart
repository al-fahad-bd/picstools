import 'dart:io';
import '../entities/background_removal_result.dart';
import '../repositories/background_remover_repository.dart';

class RemoveBackgroundUseCase {
  final BackgroundRemoverRepository repository;

  RemoveBackgroundUseCase(this.repository);

  Future<BackgroundRemovalResult> call({required File imageFile}) async {
    return await repository.removeBackground(imageFile: imageFile);
  }
}
