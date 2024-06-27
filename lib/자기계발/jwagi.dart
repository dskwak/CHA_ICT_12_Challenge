import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Jwagigabal(),
    );
  }
}

class Jwagigabal extends StatefulWidget {
  const Jwagigabal({super.key});

  @override
  _JwagigabalState createState() => _JwagigabalState();
}

class _JwagigabalState extends State<Jwagigabal> {
  late List<Map<String, String>> imageAssets = [];
  late List<Map<String, String>> filteredImageAssets = [];
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int _itemsToLoad = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadJsonData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('assets/output.json');
      final data = await json.decode(response) as List;
      setState(() {
        imageAssets = data.map((item) => {
          'image': item['image'] as String,
          'title': item['explain'] as String,
          'writter': item['name'] as String? ?? 'Unknown writer',
          'link': item['link'] as String,
        }).toList();
        filteredImageAssets = imageAssets.take(_itemsToLoad).toList();
      });
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && searchController.text.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    setState(() {
      _itemsToLoad += 10;
      filteredImageAssets = imageAssets.take(_itemsToLoad).toList();
      _isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredImageAssets = imageAssets
            .where((image) => image['title']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        filteredImageAssets = imageAssets.take(_itemsToLoad).toList();
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CHA 앱 - 결과'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                labelText: "검색",
                hintText: "검색어를 입력하세요",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  if (filteredImageAssets.isNotEmpty)
                    for (int i = 0; i < filteredImageAssets.length; i++)
                      buildCard(context, i),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _launchURL(filteredImageAssets[index]['link']!);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      filteredImageAssets[index]['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filteredImageAssets[index]['title']!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        filteredImageAssets[index]['writter']!,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '무료',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
