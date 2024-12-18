class PrintConfig {
  static const List<String> VALID_PAPER_SIZES = ['A4', 'A3', 'Letter', 'Legal'];
  static const int MIN_COPIES = 1;
  static const int MAX_COPIES = 100;

  final String paperSize;
  final bool isColor;
  final bool isDuplex;
  final int copies;

  const PrintConfig({
    this.paperSize = 'A4',
    this.isColor = false,
    this.isDuplex = false,
    this.copies = 1,
  });

  PrintConfig copyWith({
    String? paperSize,
    bool? isColor,
    bool? isDuplex,
    int? copies,
  }) {
    return PrintConfig(
      paperSize: paperSize ?? this.paperSize,
      isColor: isColor ?? this.isColor,
      isDuplex: isDuplex ?? this.isDuplex,
      copies: (copies ?? this.copies).clamp(MIN_COPIES, MAX_COPIES),
    );
  }

  Map<String, dynamic> toJson() => {
    'paper_size': paperSize,
    'is_color': isColor,
    'is_duplex': isDuplex,
    'copies': copies,
  };

  factory PrintConfig.fromJson(Map<String, dynamic> json) => PrintConfig(
    paperSize: json['paper_size'] ?? 'A4',
    isColor: json['is_color'] ?? false,
    isDuplex: json['is_duplex'] ?? false,
    copies: (json['copies'] ?? 1).clamp(MIN_COPIES, MAX_COPIES),
  );

  double calculateCost() {
    double baseCost = paperSize == 'A3' ? 0.20 : 0.10;
    if (isColor) baseCost *= 2;
    if (isDuplex) baseCost *= 1.5;
    return baseCost * copies;
  }
}