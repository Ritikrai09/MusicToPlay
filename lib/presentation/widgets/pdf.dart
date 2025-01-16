import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:blogit/presentation/screens/bookmarks.dart';
import '../../Utils/color_util.dart';
import '../../model/news.dart';

class PdfViewWidget extends StatefulWidget {
  const PdfViewWidget({super.key,this.model});

  final ENews? model;

  @override
  State<PdfViewWidget> createState() => _PdfViewWidgetState();
}

class _PdfViewWidgetState extends State<PdfViewWidget> {

  
  int? pages;
   String remotePDFpath = "";
  bool isReady=false;
  bool isLoading=true;
  

Future<String> createFileOfPdfUrl() async {
   final Directory tempDir = await getTemporaryDirectory();
  final String tempPath = tempDir.path;
  final String pdfPath = '$tempPath/sample.pdf';
  final response = await http.get(Uri.parse(widget.model!.pdf));
  
  final file = File(pdfPath);
  await file.writeAsBytes(response.bodyBytes);

  return pdfPath;
}
  // print(widget.model!.pdf);
  //   Completer<File> completer = Completer();
  //   try {
  //     final url = widget.model!.pdf;
  //     final filename = url.substring(url.lastIndexOf("/") + 1);
  //     var request = await HttpClient().getUrl(Uri.parse(url));
  //     var response = await request.close();
  //     var bytes = await consolidateHttpClientResponseBytes(response);
  //     var dir = await getApplicationDocumentsDirectory();
  //     debugPrint("${dir.path}/$filename");
  //     File file = File("${dir.path}/$filename");
    
  //     await file.writeAsBytes(bytes, flush: true);
  //     completer.complete(file);
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     throw Exception('Error parsing asset file!');
  //   }

  //   return completer.future;
  // }


   final Completer<PDFViewController> _controller =
        Completer<PDFViewController>();

 @override
  void initState() {
    createFileOfPdfUrl().then((value) {
   
      setState(() {
        remotePDFpath = value;
      });
  
    });
    super.initState();
  }

  int curr =0;

  @override
  Widget build(BuildContext context) {
     
    return remotePDFpath == '' ? Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ) : Material(
      child: Column(
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: SafeArea(child:Row(
                children: [
                const BackbUT(),
                const SizedBox(width: 16),
                Text(widget.model!.name.toString(),
                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
                   fontWeight:FontWeight.w700
                  )
                 )
                ],
              ),
            )),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                PDFView(
                  filePath:remotePDFpath,
                  enableSwipe: true,
                  nightMode: dark(context),
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                  onRender: (pages) {
                  setState(() {
                    pages = pages;
                    isReady = true;
                  });
                  },
                  onError: (error) {
                  // debugPrint(error.toString());
                  },
                  onPageError: (page, error) {
                  // debugPrint('$page: ${error.toString()}');
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                  },
                  onPageChanged: (int? page, int? total) {
                   curr =page!.toInt()+1;
                   pages = total!.toInt();
                   setState(() {});
                  // debugPrint('page change: $page/$total');
                  },
                ),
                Align(
                  alignment: const Alignment(0,0.95),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                    child: Text('$curr / $pages',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}