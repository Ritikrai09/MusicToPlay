import 'package:flutter/material.dart';

class JobException implements Exception {

  String message,subMessage;
  JobException({this.message="Something Went Wrong!!",this.subMessage=''});

  String printStack() {
    return 'Job Exception: $message\n$subMessage';
  }

  Widget showErrorToast(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 16,
            children: [
              const Icon(Icons.info_outline_rounded, size: 26),
              const SizedBox(width: 12),
              Text(message,
              style : const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red
              )),
            ],
          ),
          const SizedBox(height: 16),
          Text(message,
          style : const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.red
          ))
        ],
      ),
    );
  }
}