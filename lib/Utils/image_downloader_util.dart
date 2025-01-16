import 'dart:developer';
import 'dart:io';
import 'package:blogit/main.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageDownloader {
  static Future<String> downloadAndSaveImage(String url, String fileName) async {
    // Get the directory to save the image
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, fileName);

    // Check if the file already exists
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }

    // Download the image
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Save the image to the file
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Failed to download image');
    }
  }

  static Future<File?> getImageFile(String fileName,{ required String url,required String imagefileName, required String localName}) async {

    try {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = path.join(directory.path, fileName);
  var file = File(filePath);
  
  if (await file.exists() && filePath.contains(imagefileName)) {
    log(localName);
    log(filePath);
    log(prefs!.getString('splash_logo').toString());
    log(imagefileName);
    return file;
  
  } else {
  
      var s = await downloadAndSaveImage(url, imagefileName);
      file = File(s);
  
      prefs!.setString(localName, s);
      return file;
  
  }
} on Exception catch (e,stack) {
   log(e.toString());
   log(stack.toString());
}
    return null;
  }
}