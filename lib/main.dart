import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ffmpeg_video_to_image/video_tuning/video_to_image.dart';

void main() {
  runApp(ChangeNotifierProvider<VideoToImage>(
    create: (context) => VideoToImage(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  VideoToImage videoToImage = VideoToImage();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Video Split Demo"),
        ),
        body: Consumer<VideoToImage>(
          builder: (context, model, child) {
            if (model.pathNameList != null) {
              return Container(
                child: GridView.builder(
                  itemCount: model.pathNameList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 0.5625,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(File(model.pathNameList[index]));
                  },
                ),
              );
            }
            return Container();
          },
        ),
        floatingActionButton: Consumer<VideoToImage>(
          builder: (context, model, child) {
            return FloatingActionButton(
              onPressed: () async {
                await model.videoToImage();
              },
              child: Icon(Icons.image),
            );
          },
        ),
      ),
    );
  }
}
