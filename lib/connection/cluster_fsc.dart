import 'package:flowstorage_fsc/connection/auth_config.dart';
import 'package:mysql_client/mysql_client.dart';

class SqlConnection {

  static final dbClusterFsc = MySQLConnectionPool(
    host: AuthConfig.auth0,
    port: AuthConfig.auth01,
    userName: AuthConfig.auth02,
    password: AuthConfig.auth002,
    databaseName: AuthConfig.authLast,
    maxConnections: 12,
  );

  static Future<MySQLConnectionPool> insertValueParams() async {
    return dbClusterFsc;
  }
}