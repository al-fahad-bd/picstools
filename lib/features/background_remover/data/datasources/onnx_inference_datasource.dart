import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/background_removal_result.dart';
import '../../domain/entities/mask_result.dart';

abstract class BackgroundRemovalModelAdapter {
  String get modelId;
  int get inputWidth;
  int get inputHeight;
  List<double> get mean;
  List<double> get std;

  Float32List preprocess(img.Image image);
  Float32List postprocess(List<dynamic> rawOutput);
}

class BiRefNetModelAdapter implements BackgroundRemovalModelAdapter {
  @override
  final String modelId = 'birefnet-general-lite';

  @override
  final int inputWidth = 512;

  @override
  final int inputHeight = 512;

  @override
  final List<double> mean = const [0.485, 0.456, 0.406];

  @override
  final List<double> std = const [0.229, 0.224, 0.225];

  @override
  Float32List preprocess(img.Image image) {
    // 1. Resize image to 512x512
    final resized = img.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
      interpolation: img.Interpolation.linear,
    );

    final pixelCount = inputWidth * inputHeight;
    final floatList = Float32List(3 * pixelCount);

    final rOffset = 0;
    final gOffset = pixelCount;
    final bOffset = 2 * pixelCount;

    // 2. Convert to NCHW normalized float tensor
    int i = 0;
    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = resized.getPixel(x, y);

        final rNorm = ((pixel.r / 255.0) - mean[0]) / std[0];
        final gNorm = ((pixel.g / 255.0) - mean[1]) / std[1];
        final bNorm = ((pixel.b / 255.0) - mean[2]) / std[2];

        floatList[rOffset + i] = rNorm;
        floatList[gOffset + i] = gNorm;
        floatList[bOffset + i] = bNorm;

        i++;
      }
    }

    return floatList;
  }

  @override
  Float32List postprocess(List<dynamic> rawOutput) {
    final flatValues = <double>[];
    void extract(dynamic item) {
      if (item is num) {
        flatValues.add(item.toDouble());
      } else if (item is List) {
        for (final child in item) {
          extract(child);
        }
      }
    }
    extract(rawOutput);

    final length = flatValues.length;
    if (length == 0) {
      throw Exception('Postprocessing error: ONNX output tensor contains 0 numeric values');
    }

    final alphaMask = Float32List(length);

    bool hasNegative = false;
    bool hasGreaterThanOne = false;
    for (int i = 0; i < length; i++) {
      if (flatValues[i] < 0.0) hasNegative = true;
      if (flatValues[i] > 1.0) hasGreaterThanOne = true;
      if (hasNegative && hasGreaterThanOne) break;
    }

    final needsSigmoid = hasNegative || hasGreaterThanOne;

    for (int i = 0; i < length; i++) {
      final double val = flatValues[i];
      if (needsSigmoid) {
        alphaMask[i] = 1.0 / (1.0 + math.exp(-val));
      } else {
        alphaMask[i] = val.clamp(0.0, 1.0);
      }
    }

    return alphaMask;
  }
}

class U2NetModelAdapter implements BackgroundRemovalModelAdapter {
  @override
  final String modelId;

  @override
  final int inputWidth;

  @override
  final int inputHeight;

  @override
  final List<double> mean;

  @override
  final List<double> std;

  U2NetModelAdapter({
    this.modelId = 'u2netp',
    this.inputWidth = 320,
    this.inputHeight = 320,
    this.mean = const [0.485, 0.456, 0.406],
    this.std = const [0.229, 0.224, 0.225],
  });

  @override
  Float32List preprocess(img.Image image) {
    final resized = img.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
      interpolation: img.Interpolation.linear,
    );

    final pixelCount = inputWidth * inputHeight;
    final floatList = Float32List(3 * pixelCount);

    final rOffset = 0;
    final gOffset = pixelCount;
    final bOffset = 2 * pixelCount;

    int i = 0;
    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = resized.getPixel(x, y);

        final rNorm = ((pixel.r / 255.0) - mean[0]) / std[0];
        final gNorm = ((pixel.g / 255.0) - mean[1]) / std[1];
        final bNorm = ((pixel.b / 255.0) - mean[2]) / std[2];

        floatList[rOffset + i] = rNorm;
        floatList[gOffset + i] = gNorm;
        floatList[bOffset + i] = bNorm;

        i++;
      }
    }

    return floatList;
  }

  @override
  Float32List postprocess(List<dynamic> rawOutput) {
    final flatValues = <double>[];
    void extract(dynamic item) {
      if (item is num) {
        flatValues.add(item.toDouble());
      } else if (item is List) {
        for (final child in item) {
          extract(child);
        }
      }
    }
    extract(rawOutput);

    final targetLength = inputWidth * inputHeight;
    final usableCount =
        flatValues.length >= targetLength ? targetLength : flatValues.length;

    if (usableCount == 0) {
      throw Exception(
          'Postprocessing error: ONNX output tensor contains 0 numeric values');
    }

    double minVal = double.infinity;
    double maxVal = -double.infinity;
    for (int i = 0; i < usableCount; i++) {
      final val = flatValues[i];
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }

    final diff = maxVal - minVal;
    final alphaMask = Float32List(usableCount);

    if (diff.abs() > 1e-6) {
      for (int i = 0; i < usableCount; i++) {
        alphaMask[i] = ((flatValues[i] - minVal) / diff).clamp(0.0, 1.0);
      }
    } else {
      for (int i = 0; i < usableCount; i++) {
        alphaMask[i] =
            (1.0 / (1.0 + math.exp(-flatValues[i]))).clamp(0.0, 1.0);
      }
    }

    return alphaMask;
  }
}

abstract class OnnxInferenceDataSource {
  Future<BackgroundRemovalResult> runInference({
    required File imageFile,
    required String modelFilePath,
    BackgroundRemovalModelAdapter? adapter,
  });
}

class OnnxInferenceDataSourceImpl implements OnnxInferenceDataSource {
  final OnnxRuntime _ort = OnnxRuntime();

  @override
  Future<BackgroundRemovalResult> runInference({
    required File imageFile,
    required String modelFilePath,
    BackgroundRemovalModelAdapter? adapter,
  }) async {
    final modelAdapter = adapter ??
        (modelFilePath.contains('birefnet')
            ? BiRefNetModelAdapter()
            : U2NetModelAdapter());
    final stopwatch = Stopwatch()..start();

    debugPrint('════════════════════════════════════════════════════════════');
    debugPrint('[BackgroundRemover] ▶ STARTING BACKGROUND REMOVAL INFERENCE');
    debugPrint('[BackgroundRemover] Image file: ${imageFile.path}');
    debugPrint('[BackgroundRemover] Model file: $modelFilePath');

    try {
      // 1. Read and decode original image bytes
      final imageBytes = await imageFile.readAsBytes();
      debugPrint('[BackgroundRemover] Input image size: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB');
      
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Could not decode input image format. Please select a valid PNG, JPG, or WebP image.');
      }

      final origW = originalImage.width;
      final origH = originalImage.height;
      debugPrint('[BackgroundRemover] Image dimensions: ${origW}x$origH');

      // 2. Preprocess to Float32 CHW Tensor
      debugPrint('[BackgroundRemover] Preprocessing to ${modelAdapter.inputWidth}x${modelAdapter.inputHeight} tensor...');
      final inputTensorData = modelAdapter.preprocess(originalImage);
      debugPrint('[BackgroundRemover] Preprocessed tensor elements: ${inputTensorData.length}');

      // 3. Verify model file
      final modelFile = File(modelFilePath);
      if (!await modelFile.exists()) {
        throw Exception('ONNX Model file not found on disk at: $modelFilePath');
      }
      final modelSize = await modelFile.length();
      debugPrint('[BackgroundRemover] Model file size: ${(modelSize / (1024 * 1024)).toStringAsFixed(2)} MB');

      // 4. Create ONNX Session
      debugPrint('[BackgroundRemover] Loading ONNX runtime session...');
      final session = await _ort.createSession(modelFilePath);
      debugPrint('[BackgroundRemover] ONNX session created successfully.');

      final inputNames = session.inputNames;
      final outputNames = session.outputNames;
      debugPrint('[BackgroundRemover] Session input names: $inputNames');
      debugPrint('[BackgroundRemover] Session output names: $outputNames');

      final inputName = inputNames.isNotEmpty ? inputNames.first : 'input_image';
      debugPrint('[BackgroundRemover] Using input name: "$inputName"');

      OrtValue? inputOrt;
      Map<String, OrtValue>? outputs;
      Float32List mask512;

      try {
        inputOrt = await OrtValue.fromList(
          inputTensorData,
          [1, 3, modelAdapter.inputHeight, modelAdapter.inputWidth],
        );

        debugPrint('[BackgroundRemover] Executing ONNX inference run...');
        outputs = await session.run({
          inputName: inputOrt,
        });
        debugPrint('[BackgroundRemover] Inference execution finished. Output keys: ${outputs.keys.toList()}');

        OrtValue? primaryOutput;
        if (outputNames.isNotEmpty && outputs.containsKey(outputNames.first)) {
          primaryOutput = outputs[outputNames.first];
        } else if (outputs.isNotEmpty) {
          primaryOutput = outputs.values.first;
        }

        if (primaryOutput == null) {
          throw Exception('Inference output tensor is empty or null.');
        }

        final rawList = await primaryOutput.asList();
        debugPrint('[BackgroundRemover] Raw output tensor extracted (length: ${rawList.length}). Postprocessing...');

        mask512 = modelAdapter.postprocess(rawList);
        debugPrint('[BackgroundRemover] Postprocessing complete. Alpha mask elements: ${mask512.length}');
      } finally {
        inputOrt?.dispose();
        if (outputs != null) {
          for (final tensor in outputs.values) {
            tensor.dispose();
          }
        }
        await session.close();
        debugPrint('[BackgroundRemover] ONNX session closed and tensors freed.');
      }

      final maskResult = MaskResult(
        alphaValues: mask512,
        width: modelAdapter.inputWidth,
        height: modelAdapter.inputHeight,
      );

      // 5. Composite continuous mask with original RGB image
      debugPrint('[BackgroundRemover] Applying bilinear alpha mask to original ${origW}x$origH image...');
      final transparentImage = _applyAlphaMaskBilinear(
        originalImage: originalImage,
        mask: maskResult,
      );

      // 6. Encode to Transparent PNG
      debugPrint('[BackgroundRemover] Encoding to PNG...');
      final pngBytes = img.encodePng(transparentImage);

      final tempDir = await getTemporaryDirectory();
      final fileName = 'bg_removed_${DateTime.now().millisecondsSinceEpoch}.png';
      final resultFile = File(p.join(tempDir.path, fileName));
      await resultFile.writeAsBytes(pngBytes);

      stopwatch.stop();
      debugPrint('[BackgroundRemover] ✔ SUCCESS: Background removed in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('[BackgroundRemover] Output PNG: ${resultFile.path} (${(pngBytes.length / 1024).toStringAsFixed(1)} KB)');
      debugPrint('════════════════════════════════════════════════════════════');

      return BackgroundRemovalResult(
        originalFile: imageFile,
        transparentPngFile: resultFile,
        width: origW,
        height: origH,
        duration: stopwatch.elapsed,
        originalSizeBytes: imageBytes.length,
        processedSizeBytes: pngBytes.length,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('════════════════════════════════════════════════════════════');
      debugPrint('[BackgroundRemover] ❌ ERROR DURING INFERENCE: $e');
      debugPrint('[BackgroundRemover] StackTrace:\n$stackTrace');
      debugPrint('════════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  /// Bilinearly resizes 512x512 continuous alpha mask back to original resolution and merges with original RGB
  img.Image _applyAlphaMaskBilinear({
    required img.Image originalImage,
    required MaskResult mask,
  }) {
    final origW = originalImage.width;
    final origH = originalImage.height;
    final maskW = mask.width;
    final maskH = mask.height;
    final alphaData = mask.alphaValues;

    final outputImage = img.Image(
      width: origW,
      height: origH,
      numChannels: 4, // RGBA
    );

    final scaleX = (maskW - 1) / (origW > 1 ? (origW - 1) : 1);
    final scaleY = (maskH - 1) / (origH > 1 ? (origH - 1) : 1);

    for (int y = 0; y < origH; y++) {
      final srcY = y * scaleY;
      final y0 = srcY.floor().clamp(0, maskH - 1);
      final y1 = (y0 + 1).clamp(0, maskH - 1);
      final dy = srcY - y0;

      for (int x = 0; x < origW; x++) {
        final srcX = x * scaleX;
        final x0 = srcX.floor().clamp(0, maskW - 1);
        final x1 = (x0 + 1).clamp(0, maskW - 1);
        final dx = srcX - x0;

        // Bilinear interpolation of alpha
        final a00 = alphaData[y0 * maskW + x0];
        final a10 = alphaData[y0 * maskW + x1];
        final a01 = alphaData[y1 * maskW + x0];
        final a11 = alphaData[y1 * maskW + x1];

        final top = a00 * (1.0 - dx) + a10 * dx;
        final bottom = a01 * (1.0 - dx) + a11 * dx;
        final alphaVal = top * (1.0 - dy) + bottom * dy;

        final alphaByte = (alphaVal * 255.0).clamp(0.0, 255.0).toInt();

        final origPixel = originalImage.getPixel(x, y);

        outputImage.setPixelRgba(
          x,
          y,
          origPixel.r,
          origPixel.g,
          origPixel.b,
          alphaByte,
        );
      }
    }

    return outputImage;
  }
}
