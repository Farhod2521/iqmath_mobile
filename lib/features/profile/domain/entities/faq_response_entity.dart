import 'package:my_flutter_template/features/profile/data/models/faq_response.dart';
import 'package:equatable/equatable.dart';

class FaqResponseEntity extends Equatable {
  const FaqResponseEntity({
    this.count,
    this.faqs,
  });

  final num? count;
  final List<FaqsSubEntity>? faqs;

  @override
  List<Object?> get props => [count, faqs];
}

class FaqsSubEntity extends Equatable {
  const FaqsSubEntity({
    this.answer,
    this.id,
    this.question,
  });

  final String? answer;
  final String? id;
  final String? question;

  @override
  List<Object?> get props => [answer, id, question];
}

extension FaqResponseEntityX on FaqResponse {
  FaqResponseEntity get toEntity => FaqResponseEntity(
        count: count,
        faqs: faqs
            ?.map(
              (e) => FaqsSubEntity(
                id: e.id,
                question: e.question,
                answer: e.answer,
              ),
            )
            .toList(),
      );
}
