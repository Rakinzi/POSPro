import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/bulk%20product%20upload/repo/bulk_upload_repo.dart';
import 'package:mobile_pos/constant.dart';

import '../../../GlobalComponents/glonal_popup.dart';

class BulkUploader extends StatefulWidget {
  const BulkUploader({super.key,});

  @override
  State<BulkUploader> createState() => _BulkUploaderState();
}

class _BulkUploaderState extends State<BulkUploader> {
  File? file;

  String getFileExtension(String fileName) {
    return fileName.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Excel Uploader'),
        ),
        body: Consumer(builder: (context, ref, __) {
          final businessInfo = ref.watch(businessInfoProvider);
          return businessInfo.when(data: (details) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: file != null,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Card(
                            child: ListTile(
                                leading: Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: const Image(image: AssetImage('images/excel.png'))),
                                title: Text(
                                  getFileExtension(file?.path ?? ''),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        file = null;
                                      });
                                    },
                                    child: const Text('Remove')))),
                      ),
                    ),
                    Visibility(
                      visible: file == null,
                      child: const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Image(
                            height: 100,
                            width: 100,
                            image: AssetImage('images/file-upload.png'),
                          )),
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(kMainColor)),
                      onPressed: () async {
                        if (file == null) {
                          await pickAndUploadFile(ref: ref);
                        } else {
                          EasyLoading.show(status: 'Uploading...');
                          await BulkUpLoadRepo().uploadBulkFile(file: file!, ref: ref, context: context);
                          EasyLoading.dismiss();
                        }
                      },
                      child: Text(file == null ? 'Pick and Upload File' : 'Upload', style: const TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () async {
                        await BulkUpLoadRepo().downloadFile(context);
                      },
                      child: const Text('Download Excel Format'),
                    ),
                  ],
                ),
              ),
            );
          }, error: (e, stack) {
            return Text(e.toString());
          }, loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
        }),
      ),
    );
  }

  ///

  Future<void> pickAndUploadFile({required WidgetRef ref}) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Excel Files',
      extensions: ['xlsx'],
    );
    final XFile? fileResult = await openFile(acceptedTypeGroups: [typeGroup]);

    if (fileResult != null) {
      final File files = File(fileResult.path);
      setState(() {
        file = files;
      });
    } else {
      debugPrint("No file selected");
    }
  }
}
