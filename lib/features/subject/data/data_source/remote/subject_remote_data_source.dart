
import '../../models/subject_response.dart';


abstract class SubjectRemoteDataSource {

 Future<List<SubjectResponse>> getSubjects();
}
