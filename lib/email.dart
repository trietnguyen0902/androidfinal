class Email {
  String id;
  String sender;
  String recipient;
  String subject;
  String body;
  DateTime date;
  List<String> attachments;
  List<String> labels;
  bool isRead;

  Email({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.subject,
    required this.body,
    required this.date,
    this.attachments = const [],
    this.labels = const [],
    this.isRead = false,
  });
}
