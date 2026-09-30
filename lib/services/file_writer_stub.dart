import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> writeFile(String content, String fileName) async {
  final dir = await getTemporaryDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final path = '${dir.path}/${timestamp}_$fileName';
  final file = File(path);
  await file.writeAsString(content);
  return file;
}