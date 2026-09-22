import 'package:my_flutter_template/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:hive/hive.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource{
  final Box<dynamic> box;

  AuthLocalDataSourceImpl(this.box);
}