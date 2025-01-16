import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/Utils/urls.dart';
import 'package:blogit/model/blog.dart';

import '../../controller/user_controller.dart';



  Future<Uint8List?> captureScreenshot(GlobalKey previewContainer,{isPost =false})async {
  try {
    RenderRepaintBoundary? boundary =
        previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List screenshotBytes = byteData!.buffer.asUint8List();

    // Load icon images
    ByteData googlePlayIconData = await rootBundle.load('asset/Images/Temp/playstore.png');
    ByteData appStoreIconData = await rootBundle.load('asset/Images/Logo/splash_logo.png');

    // Decode icon images
    ui.Codec googlePlayIconCodec = await ui.instantiateImageCodec(googlePlayIconData.buffer.asUint8List());
    ui.Codec appStoreIconCodec = await ui.instantiateImageCodec(appStoreIconData.buffer.asUint8List(),targetHeight: 85,targetWidth: 85);

    // Convert icons to frames
    ui.FrameInfo googlePlayIconFrame = await googlePlayIconCodec.getNextFrame();
    ui.FrameInfo appStoreIconFrame = await appStoreIconCodec.getNextFrame();

    // Convert frames to images
    ui.Image googlePlayIconImage = googlePlayIconFrame.image;
    ui.Image appStoreIconImage = appStoreIconFrame.image;

    // Create a new blank image with the screenshot dimensions
    int width = image.width;
    int height = image.height;
    ui.PictureRecorder recorder = ui.PictureRecorder();

    // Create a canvas and paint the screenshot onto it
    ui.Canvas canvas = ui.Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());

    // Calculate the position to overlay the icons
    double iconSize = 30.0;
    double padding = 24.0;
    double xPosition = padding+36;
    double yPosition = (height/1.18) - padding - iconSize;
    double yPositionSignal = (height/1.045) - padding - iconSize;

    // Overlay the Google Play Store icon
    canvas.drawImage(googlePlayIconImage, Offset(xPosition, yPosition), Paint());

    // Update the x position for the App Store icon
    // xPosition += iconSize + padding;
     double xPos = width/1.2;
    // Overlay the App Store icon
    canvas.drawImage(appStoreIconImage, Offset(xPos, yPositionSignal), Paint());

    // Convert the final image to bytes
    ui.Picture finalByteData =  recorder.endRecording();
    ui.Image finalImage = await finalByteData.toImage(width, height);
    ByteData? finalByte = await finalImage.toByteData(format: ImageByteFormat.png);
    Uint8List finalBytes = finalByte!.buffer.asUint8List();

    return isPost ? screenshotBytes : finalBytes;
  } catch (e) {
    // debugPrint(e.toString());
    return null;
  }
}


void shareImage(XFile data,String id) async {
  try {
    await Share.shareXFiles(
      [data],
      subject: 'screenshot.png',
      text: "${allMessages.value.shareMessage} ${Urls.mainUrl}share-blog?blog_id=$id",
    );
  } catch (e) {
    //  debugPrint('Error sharing screenshot: $e');
  }
}



void shareText(Blog blog) async {
  try {
    await Share.share("${blog.title}\n${Urls.baseUrl}share-blog?id=${blog.id}\n\n${allMessages.value.shareMessage}",
     // text: allMessages.value.shareMessage,
    );
  } catch (e) {
    //  debugPrint('Error sharing : $e');
  }
}



 Future<XFile> convertToXFile(Uint8List data, {String fileName = 'image.png'}) async {
  
  // Get the temporary directory path
  Directory tempDir = await getTemporaryDirectory();

  String tempPath = tempDir.path;
  // Create a temporary file path
  String filePath = path.join(tempPath, fileName);
  // Save the Uint8List data as a file
  await File(filePath).writeAsBytes(data);
  // Create an XFile from the temporary file path
  XFile xFile = XFile(filePath);

  return xFile;
}