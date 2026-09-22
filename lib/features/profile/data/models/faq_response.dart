/// count : 0
/// faqs : [{"answer":"string","id":"string","question":"string"}]

class FaqResponse {
  FaqResponse({
      this.count, 
      this.faqs,});

  FaqResponse.fromJson(dynamic json) {
    count = json['count'];
    if (json['faqs'] != null) {
      faqs = [];
      json['faqs'].forEach((v) {
        faqs?.add(Faqs.fromJson(v));
      });
    }
  }
  num? count;
  List<Faqs>? faqs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = count;
    if (faqs != null) {
      map['faqs'] = faqs?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// answer : "string"
/// id : "string"
/// question : "string"

class Faqs {
  Faqs({
      this.answer, 
      this.id, 
      this.question,});

  Faqs.fromJson(dynamic json) {
    answer = json['answer'];
    id = json['id'];
    question = json['question'];
  }
  String? answer;
  String? id;
  String? question;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['answer'] = answer;
    map['id'] = id;
    map['question'] = question;
    return map;
  }

}