import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_synology_controller.dart';

class FileUploadButton extends StatelessWidget {
  final SynologyFileManagerController controller;

  const FileUploadButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed: controller.isUploading.value ? null : controller.pickAndUploadFiles,
          child: controller.isUploading.value
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Uploading...'),
                  ],
                )
              : const Text('Upload Files'),
        ));
  }
}
