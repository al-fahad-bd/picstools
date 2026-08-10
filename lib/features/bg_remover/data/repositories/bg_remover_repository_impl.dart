import 'dart:io';
import '../../domain/entities/bg_remover_params.dart';
import '../../domain/repositories/bg_remover_repository.dart';
import '../services/segmentation_service.dart';

class BgRemoverRepositoryImpl implements BgRemoverRepository {
  final SegmentationService _segmentationService;

  BgRemoverRepositoryImpl(this._segmentationService);

  @override
  Future<File> removeBackground({
    required File imageFile,
    required BgRemoverParams params,
  }) async {
    return await _segmentationService.processSegmentation(
      imageFile: imageFile,
      params: params,
    );
  }
}
