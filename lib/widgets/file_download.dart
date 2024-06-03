import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class FileDownload extends StatelessWidget {
  final String? url;
  final List<String>? urls;
  final String? id;
  final String? fileName;

  const FileDownload({Key? key, this.url, this.urls, this.id, this.fileName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {},
      child: Text('Download File'),
    );
  }

  Future<void> downloadFile(BuildContext context) async {
    if (kIsWeb) {
      var anchorElement = html.AnchorElement(href: url);
      anchorElement.download = url?.split('/').last;
      anchorElement.click();
    } else {
      FileDownloader.downloadFile(
          url: url!,
          name: fileName,
          downloadDestination: DownloadDestinations.publicDownloads,
          notificationType: NotificationType.all,
          onDownloadCompleted: (String path) {
            print('FILE DOWNLOADED TO PATH: $path');
          },
          onDownloadError: (String error) {
            print('DOWNLOAD ERROR: $error');
          });
    }
  }

  Future<List<int>?> downloadFiles(BuildContext context) async {
    List<String> parts = id!.split('/');
    String fileName = parts.last;
    if (kIsWeb) {
      final archive = Archive();
      for (var url in urls!) {
        final response = await http.get(Uri.parse(url));
        final filename = url.split('/').last;
        final bytes = response.bodyBytes;
        final file = ArchiveFile(filename, bytes.length, bytes);
        archive.addFile(file);
      }

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      final base64Data = base64Encode(zipData!);

      final dataUrl = 'data:application/zip;base64,$base64Data';
      final anchor = html.AnchorElement(href: dataUrl)
        ..setAttribute('download', 'BulkDownload$id.zip')
        ..click();
    } else {
      FileDownloader.downloadFiles(
        urls: urls!,
        downloadDestination: DownloadDestinations.publicDownloads,
        notificationType: NotificationType.all,
      );
      // final archive = Archive();

      // for (var url in urls!) {
      //   final response = await http.get(Uri.parse(url));
      //   final filename = url.split('/').last;
      //   final bytes = response.bodyBytes;
      //   final file = ArchiveFile(filename, bytes.length, bytes);
      //   archive.addFile(file);
      // }

      // final zipEncoder = ZipEncoder();
      // final zipData = zipEncoder.encode(archive);

      // final directory = await getExternalStorageDirectory();
      // final defaultDownloadDirectory = '/storage/emulated/0/Download';

      // final zipFilePath =
      //     '$defaultDownloadDirectory/BulkDownload_$fileName.zip';

      // final defaultDownloadDir = Directory(defaultDownloadDirectory);
      // print(defaultDownloadDir);
      // if (await defaultDownloadDir.exists()) {
      //   final zipFile = File(zipFilePath);
      //   try {
      //     await zipFile.writeAsBytes(zipData!);
      //     print('ZIP file created: $zipFilePath');
      //   } catch (e) {
      //     print('Failed to create ZIP file in external storage directory: $e');
      //     final appDirectory = await getExternalStorageDirectory();
      //     final appZipFilePath =
      //         '${appDirectory!.path}/BulkDownload_$fileName.zip';
      //     final appZipFile = File(appZipFilePath);
      //     await appZipFile.writeAsBytes(zipData!);
      //     print('ZIP file created in application directory: $appZipFilePath');
      //   }
      // } else {
      //   print(
      //       "Default download directory does not exist. Using application directory.");
      //   final appDirectory = await getExternalStorageDirectory();
      //   // final appDirectory = await getApplicationDocumentsDirectory();
      //   final appZipFilePath =
      //       '${appDirectory!.path}/BulkDownload_$fileName.zip';
      //   final appZipFile = File(appZipFilePath);
      //   await appZipFile.writeAsBytes(zipData!);
      //   print('ZIP file created in application directory: $appZipFilePath');
      // }
    }
  }
}
