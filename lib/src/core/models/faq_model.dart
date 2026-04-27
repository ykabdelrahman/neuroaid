class FaqModel {
  final int id;
  final String question;
  final String answer;

  FaqModel({required this.id, required this.question, required this.answer});

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer};
  }
}
