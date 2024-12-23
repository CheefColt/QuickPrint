class PrintConfig {
  final bool color;
  final bool doubleSided;
  final int copies;

  PrintConfig({
    this.color = false,
    this.doubleSided = false,
    this.copies = 1,
  });

  factory PrintConfig.fromJson(Map<String, dynamic> json) {
    return PrintConfig(
      color: json['color'] ?? false,
      doubleSided: json['double_sided'] ?? false,
      copies: json['copies'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color,
    'double_sided': doubleSided,
    'copies': copies,
  };
}