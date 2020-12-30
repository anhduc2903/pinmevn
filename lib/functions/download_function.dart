import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:archive/archive.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class Download {
  String dir, zipPath, localZipFileName = 'advertisement.zip';
  List<String> imageFileNames = List();
  List<String> videoFileNames = List();
  List<String> fileNames = List();

  Future<void> initDir() async {
    if (dir == null) {
      dir = (await getExternalStorageDirectory()).path;
    }
  }

  Future<void> deleteFile(String fileName) async {
    File file = File('$dir/$fileName');
    FileSystemEntity fileSystemEntity = await file.delete(recursive: true);
    // print(fileSystemEntity.path);
  }

  Future<void> downloadZip() async {
    File zippedFile = await downloadFile(zipPath, localZipFileName);
    // await downloadFile(zipPath, localZipFileName);
    await unarchiveAndSave(zippedFile);
  }

  Future<File> downloadFile(String url, String fileName) async {
    // Dio dio = Dio();
    // await dio.download(url, '$dir/$fileName');
    // dio.close();
    http.Response res = await http.Client().get(Uri.parse(url));
    http.Client().close();
    File file = File('$dir/$fileName');
    file = await file.create(recursive: true);
    File zipFile = await file.writeAsBytes(res.bodyBytes);

    return zipFile;
  }

  Future<void> unarchiveAndSave(zippedFile) async {
    List<int> bytes = zippedFile.readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        fileNames.add(file.name);
      }

      List<String> fileType = lookupMimeType(file.name).split('/');
      if (fileType[0] == 'image') imageFileNames.add('${file.name}');
      if (fileType[0] == 'video') videoFileNames.add('${file.name}');
    }

    try {
      await FlutterArchive.unzip(
          zipFile: zippedFile, destinationDir: Directory(dir));
    } catch (error) {
      print(error);
    }
  }
}
