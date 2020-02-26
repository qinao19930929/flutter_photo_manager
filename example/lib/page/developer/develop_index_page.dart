import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';

import 'dev_title_page.dart';

class DeveloperIndexPage extends StatefulWidget {
  @override
  _DeveloperIndexPageState createState() => _DeveloperIndexPageState();
}

class _DeveloperIndexPageState extends State<DeveloperIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("develop index"),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(
            child: Text("upload file to local to test EXIF."),
            onPressed: _upload,
          ),
          RaisedButton(
            child: Text("Save video to photos."),
            onPressed: _saveVideo,
          ),
          RaisedButton(
            child: Text("Open test title page"),
            onPressed: _navigatorSpeedOfTitle,
          ),
        ],
      ),
    );
  }

  void _upload() async {
    final path = await PhotoManager.getAssetPathList(type: RequestType.image);
    final assetList = await path[0].getAssetListRange(start: 0, end: 5);
    final asset = assetList[0];

    // for (final tmpAsset in assetList) {
    //   await tmpAsset.originFile;
    // }

    final file = await asset.originFile;

    print("file length = ${file.lengthSync()}");

    http.BaseClient client = http.Client();
    final req = http.MultipartRequest(
      "post",
      Uri.parse("http://172.16.100.7:10001/upload/file"),
    );

    req.files
        .add(await http.MultipartFile.fromPath("file", file.absolute.path));

    req.fields["type"] = "jpg";

    final response = await client.send(req);
    final body = await utf8.decodeStream(response.stream);
    print(body);
  }

  void _saveVideo() async {
    // String url = "http://172.16.100.7:5000/QQ20181114-131742-HD.mp4";
    String url =
        "http://172.16.100.7:5000/Kapture%202019-11-20%20at%2017.07.58.mp4";

    final client = HttpClient();
    final req = await client.getUrl(Uri.parse(url));
    final resp = await req.close();
    final tmp = Directory.systemTemp;
    final title = "${DateTime.now().millisecondsSinceEpoch}.mp4";
    final f = File("${tmp.absolute.path}/$title");
    if (f.existsSync()) {
      f.deleteSync();
    }
    f.createSync();

    resp.listen((data) {
      f.writeAsBytesSync(data, mode: FileMode.append);
    }, onDone: () async {
      client.close();
      print("the video file length = ${f.lengthSync()}");
      final result = await PhotoManager.editor.saveVideo(f, title: title);
      if (result != null) {
        print("result : ${(await result.originFile)?.path}");
      } else {
        print("result is null");
      }
    });
  }

  void _navigatorSpeedOfTitle() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      final widget = DevelopingExample();
      return widget;
    }));
  }
}
