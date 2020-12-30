import 'package:http/http.dart' as http;

const server = 'api.pinme.vn';

Future<http.Response> downloadAPI(String token, String serialId) async {
  String path = '/api/publisher/download';
  int testSerialId = 1001;
  Map<String, String> queryParameters = {
    'serial_id': '$serialId',
  };
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Uri uri = Uri.https(server, path, queryParameters);

  http.Response response = await http.get(uri, headers: headers);
  return response;
}

Future<http.Response> refreshTokenAPI(String token) async {
  String path = '/api/refresh-token';
  Map<String, String> headers = {
    'Authorization': 'Bearer $token',
  };
  Uri uri = Uri.https(server, path);

  http.Response response = await http.get(uri, headers: headers);
  return response;
}
