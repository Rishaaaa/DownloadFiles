import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sample_api/widgets/file_download.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String dropdownValue = 'Siri';
  String id = '';
  TextEditingController invoiceController = TextEditingController();
  List<dynamic> products = [];
  Color defaultColor1 = Colors.grey.withOpacity(0.1);
  Color defaultColor2 = Colors.grey.withOpacity(0.1);
  RegExp alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  String _downloadedFilePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          'Bulk Download',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: invoiceController,
                        inputFormatters: [],
                        decoration: const InputDecoration(
                          hintText: 'Enter Invoice ID',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      String invoiceId = invoiceController.text.trim();
                      if (invoiceId.isEmpty) {
                        showSnackBar(context, 'Error: Please Enter Invoice ID');
                      } else {
                        setState(() {
                          _downloadedFilePath = '';
                          id = invoiceId;
                        });
                        fetchData(invoiceId);
                      }
                    },
                    child: const Text('Fetch'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (products.length != 0)
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: defaultColor2,
                        ),
                        child: MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              defaultColor2 = Colors.grey.withOpacity(0.3);
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              defaultColor2 = Colors.grey.withOpacity(0.1);
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var product in products)
                                buildImageTile(product['url'], product['name']),
                              const SizedBox(height: 20),
                              Center(
                                child: Container(
                                  width: 150,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        List<String> allImageUrls = products
                                            .map((product) =>
                                                product['url'] as String)
                                            .toList();
                                        downloadImages(allImageUrls, id);
                                      },
                                      child: const Text('Download Bulk'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageTile(String url, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      title: Row(
        children: [
          const SizedBox(height: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text('• $title', style: const TextStyle(fontSize: 14.0)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              downloadImage(url, title, context);
            },
            child: const Icon(Icons.download_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> downloadImage(
    String url,
    String title,
    BuildContext context,
  ) async {
    showSnackBar(context, 'Downloading...');
    try {
      await FileDownload(url: url, fileName: title).downloadFile(context);

      showSnackBar(context, 'File Downloaded Successfully');
    } catch (e) {
      showSnackBar(context, 'Unable to download File');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> downloadImages(List<String> urls, String id) async {
    showSnackBar(context, 'Downloading...');
    try {
      await FileDownload(urls: urls, id: id).downloadFiles(context);
      showSnackBar(context, 'Files Downloaded Successfully');
    } catch (e) {
      showSnackBar(context, 'Unable to download Files');
    }
  }

  Future<void> fetchData(String id) async {
    try {
      print("Sending request to the server with ID: $id");

      final response = await http.get(
        Uri.parse(
            'http://35.154.130.252:8101/bulk_download?transaction_id=$id'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        if (responseBody != null && responseBody['success'] == true) {
          final List<dynamic> urlList = responseBody['data']['url'];

          if (urlList.isNotEmpty) {
            List<Map<String, dynamic>> newProducts = [];
            for (var item in urlList) {
              if (item is String) {
                final dynamic urlMap = json.decode(item);
                if (urlMap != null && urlMap is Map<String, dynamic>) {
                  urlMap.forEach((key, value) {
                    String name = _extractNameFromUrl(value);
                    newProducts.add({'name': name, 'url': value});
                  });
                }
              }
            }
            setState(() {
              products = newProducts;
            });
          } else {
            showSnackBar(context, 'URL list is empty');
          }
        } else {
          print("Error: Success flag is false or missing in response");
        }
      } else {
        showSnackBar(context, 'Cannot Fetch data. Please Check the Invoice Id');
      }
    } catch (e) {
      showSnackBar(context, 'Cannot Fetch data. Please Check the Invoice Id');
    }
  }

  String _extractNameFromUrl(String url) {
    // Extract the last part of the URL
    RegExp regExp = RegExp(r'([^/]+$)');
    Match? match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return 'Unknown';
  }
}
