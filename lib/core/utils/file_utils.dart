import 'dart:math';

abstract class FileUtils {
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static double calculateSavingsPercentage(int originalSize, int compressedSize) {
    if (originalSize <= 0 || compressedSize >= originalSize) return 0.0;
    final saved = originalSize - compressedSize;
    return ((saved / originalSize) * 100).clamp(0.0, 100.0);
  }
}
