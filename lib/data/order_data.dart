class Order {
  final String id;
  final String documentName;
  final String status;
  final PrintConfig printConfig;

  Order({
    required this.id,
    required this.documentName,
    required this.status,
    required this.printConfig,
  });
}

class PrintConfig {
  final String paperSize;
  final bool isColorPrint;
  final bool isDuplexPrint;
  final int copies;

  PrintConfig({
    required this.paperSize,
    required this.isColorPrint,
    required this.isDuplexPrint,
    required this.copies,
  });
}