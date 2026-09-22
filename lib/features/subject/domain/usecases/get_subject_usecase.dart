import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/subject/data/models/subject_response.dart';

import '../repository/subject_repository.dart';

class GetSubjectUseCase extends UseCase<List<SubjectResponse>, NoParams> {
  final SubjectRepository subjectRepository;

  GetSubjectUseCase(this.subjectRepository);

  @override
  Future<Either<Failure, List<SubjectResponse>>> call(NoParams params) async {
    return await subjectRepository.getSubjects();
  }
}
