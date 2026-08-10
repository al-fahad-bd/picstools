import 'package:equatable/equatable.dart';

class BgRemoverParams extends Equatable {
  final double threshold;
  final String bgMode; // 'white', 'black', 'auto'
  final double feather;

  const BgRemoverParams({
    this.threshold = 30.0,
    this.bgMode = 'white',
    this.feather = 1.0,
  });

  BgRemoverParams copyWith({
    double? threshold,
    String? bgMode,
    double? feather,
  }) {
    return BgRemoverParams(
      threshold: threshold ?? this.threshold,
      bgMode: bgMode ?? this.bgMode,
      feather: feather ?? this.feather,
    );
  }

  @override
  List<Object?> get props => [threshold, bgMode, feather];
}
