import 'package:http/http.dart' as http;

const server = 'api.pinme.vn';
String path;

Future<dynamic> getCityAPI() async {
  path = '/api/city';
  Uri uri = Uri.https(server, path);
  http.Response response = await http.get(uri);
  return response;
}

Future<dynamic> getDistrictsAPI() async {
  path = '/api/districts';
  Uri uri = Uri.https(server, path);
  http.Response response = await http.get(uri);
  return response;
}

Future<dynamic> getStreetsAPI() async {
  path = '/api/streets';
  Uri uri = Uri.https(server, path);
  http.Response response = await http.get(uri);
  return response;
}
