import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../globals/globals.dart' as globals;

const server = 'api.pinme.vn';

Future<http.Response> signInAPI(
  List<TextEditingController> controllers,
) async {
  String path = '/api/publisher/login';
  Uri uri = Uri.https(server, path);
  Map<String, String> headers = {'Content-Type': 'application/json'};
  int testSerialId = 1001;

  String body = controllers.length == 1
      ? json.encode({
          'user': {
            'login_code': '${controllers[0].text}',
          },
          'device': {
            'name': '${globals.device.name}',
            'serial_id': '${globals.device.serial_id}',
            'width': '${globals.width}',
            'height': '${globals.height}',
            'latitude': '${globals.position.latitude}',
            'longitude': '${globals.position.longitude}',
          }
        })
      : json.encode({
          "user": {
            "email": "${controllers[0].text}",
            "password": "${controllers[1].text}",
          },
          "device": {
            "name": "${globals.device.name}",
            "serial_id": "${globals.device.serial_id}",
            'width': '${globals.width}',
            'height': '${globals.height}',
            'latitude': '${globals.position.latitude}',
            'longitude': '${globals.position.longitude}',
          }
        });

  http.Response response = await http.post(
    uri,
    headers: headers,
    body: body,
  );
  return response;
}
