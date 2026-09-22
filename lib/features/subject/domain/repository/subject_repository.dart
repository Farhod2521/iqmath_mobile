import 'package:my_flutter_template/core/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/subject_response.dart';

abstract class SubjectRepository {
  Future<Either<Failure, List<SubjectResponse>>> getSubjects();
}
