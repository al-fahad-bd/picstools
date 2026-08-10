class IdPhotoPreset {
  final String id;
  final String title;
  final String country;
  final double widthMm;
  final double heightMm;
  final int targetWidthPx; // @ 300 DPI
  final int targetHeightPx; // @ 300 DPI
  final String description;

  const IdPhotoPreset({
    required this.id,
    required this.title,
    required this.country,
    required this.widthMm,
    required this.heightMm,
    required this.targetWidthPx,
    required this.targetHeightPx,
    required this.description,
  });

  double get aspectRatio => widthMm / heightMm;

  static const List<IdPhotoPreset> defaultPresets = [
    IdPhotoPreset(
      id: 'us_passport',
      title: 'US Passport / Visa',
      country: 'United States 🇺🇸',
      widthMm: 51.0, // 2 x 2 inches
      heightMm: 51.0,
      targetWidthPx: 600,
      targetHeightPx: 600,
      description: '2 x 2 inches (51 x 51 mm) • Plain White background',
    ),
    IdPhotoPreset(
      id: 'eu_uk_passport',
      title: 'EU / UK / Schengen',
      country: 'Europe / UK 🇪🇺 🇬🇧',
      widthMm: 35.0,
      heightMm: 45.0,
      targetWidthPx: 413,
      targetHeightPx: 531,
      description: '35 x 45 mm • Light Gray or White background',
    ),
    IdPhotoPreset(
      id: 'india_passport',
      title: 'India Passport / OCI',
      country: 'India 🇮🇳',
      widthMm: 35.0,
      heightMm: 45.0,
      targetWidthPx: 413,
      targetHeightPx: 531,
      description: '35 x 45 mm (or 2 x 2 in) • White background',
    ),
    IdPhotoPreset(
      id: 'canada_passport',
      title: 'Canada Passport',
      country: 'Canada 🇨🇦',
      widthMm: 50.0,
      heightMm: 70.0,
      targetWidthPx: 591,
      targetHeightPx: 827,
      description: '50 x 70 mm • White background',
    ),
    IdPhotoPreset(
      id: 'china_visa',
      title: 'China Visa',
      country: 'China 🇨🇳',
      widthMm: 33.0,
      heightMm: 48.0,
      targetWidthPx: 390,
      targetHeightPx: 567,
      description: '33 x 48 mm • White background',
    ),
    IdPhotoPreset(
      id: 'japan_passport',
      title: 'Japan Passport',
      country: 'Japan 🇯🇵',
      widthMm: 35.0,
      heightMm: 45.0,
      targetWidthPx: 413,
      targetHeightPx: 531,
      description: '35 x 45 mm • Plain White background',
    ),
    IdPhotoPreset(
      id: 'australia_passport',
      title: 'Australia Passport',
      country: 'Australia 🇦🇺',
      widthMm: 35.0,
      heightMm: 45.0,
      targetWidthPx: 413,
      targetHeightPx: 531,
      description: '35 x 45 mm • Plain Light background',
    ),
  ];
}
