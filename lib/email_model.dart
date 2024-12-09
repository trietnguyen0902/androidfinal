class Email {
  final String id;
  final String from;
  final String to;
  final String subject;
  final String body;
  final DateTime date;
  final bool isRead;
  final bool isStarred;
  final List<String> labels;
  final bool isTrashed;

  Email({
    required this.id,
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    required this.date,
    required this.isRead,
    required this.isStarred,
    required this.labels,
    required this.isTrashed,
  });

  // Add methods to handle metadata, moving to trash, assigning labels, etc.
}
