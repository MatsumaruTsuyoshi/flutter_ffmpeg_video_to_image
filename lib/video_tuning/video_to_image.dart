import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:intl/intl.dart';
import 'package:fraction/fraction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VideoToImage extends ChangeNotifier {
  String duration = '';
  String realFrameRate = '';
  List pathNameList = [];

  Future<void> videoToImage() async {
    final file = await pickVideo();
    final frameN = await videoConfig(file);
    String path = await localPath();
    pathNameList = await videoFFmpeg(file, path, frameN);
    notifyListeners();
  }

  Future pickVideo() async {
    final picker = ImagePicker();
    final PickedFile pickedFile =
        await picker.getVideo(source: ImageSource.gallery);
    return pickedFile.path;
  }

  Future<String> localPath() async {
    Directory tmpDocDir = await getTemporaryDirectory();
    return tmpDocDir.path;
  }

  Future videoConfig(file) async {
    try {
      final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
      int frameNum =
          await _flutterFFprobe.getMediaInformation("$file").then((info) {
        //動画の時間を取得
        duration = info.getMediaProperties()['duration'];
        if (info.getAllProperties()['streams'][0]['r_frame_rate'] == '0/0') {
          //FPSを取得
          realFrameRate = info.getAllProperties()['streams'][1]['r_frame_rate'];
        } else {
          //FPSを取得
          realFrameRate = info.getAllProperties()['streams'][0]['r_frame_rate'];
        }

        //分数を数値として扱えるようにする
        final fracRealFrameRate = Fraction.fromString(realFrameRate);
        //取得した動画の時間は文字列なので変換する
        final durationDouble = double.parse(duration);
        //動画をスプリットするフレーム数を計算する
        int frameNumber =
            (durationDouble * fracRealFrameRate.toDouble()).toInt();
        return frameNumber;
      });
      return frameNum;
    } catch (e) {
      print(e);
    }
  }

  Future videoFFmpeg(file, path, frameNumber) async {
    try {
      final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd–kk-mm-ss').format(now);
      //スプリットした画像を保存するパスを指定しておく
      String outputPath = "$path" "/${formattedDate}output%04d.jpg";

      //ここで動画を指定したフレーム数に画像変換する
      await _flutterFFmpeg
          .execute("-i $file -vframes $frameNumber $outputPath")
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      pathNameList = [];

      //画像の保存先をリストに追加
      for (int i = 1; i < frameNumber + 1; i++) {
        String pathName =
            '$path/${formattedDate}output${i.toString().padLeft(4, "0")}.jpg';
        pathNameList.add(pathName);
      }
      return pathNameList;
    } catch (e) {
      print(e);
    }
  }
}
