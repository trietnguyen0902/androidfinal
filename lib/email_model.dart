class Email {
  final String id;
  final String from;
  final String to;
  final String subject;
  final String body;
  final DateTime date;
  final bool isRead;
   bool isStarred;
  final List<String> labels;
  final bool isTrashed;
  final bool isDraft;

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
    required this.isDraft,
  });

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'subject': subject,
      'body': body,
      'date': date,
      'isRead': isRead,
      'isStarred': isStarred,
      'labels': labels,
      'isTrashed': isTrashed,
      'isDraft': isDraft,
    };
  }
}
