import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as path;

import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  await Permission.storage.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecordAudioScreen(),
    );
  }
}

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({super.key});

  @override
  _RecordAudioScreenState createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  late FlutterSoundRecorder _audioRecorder;
  bool _isRecording = false;
  String _recordedFilePath = "";
  Codec codec = Codec.defaultCodec;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _audioRecorder.openRecorder().then((value) {
      print("Audio session opened: $value");
    });
  }

  Future<void> _checkPermissionAndStartRecording() async {
    if (await Permission.microphone.request().isGranted) {
      _startRecording();
    } else {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  Future<String> _getRecordedFilePath(String extension) async {
    /* / Directory appDir = await getApplicationDocumentsDirectory(); / */
    String folderPath = "/sdcard/Download/";
    final random = Random();
    final fileName = 'audio_${random.nextInt(10000)}.$extension';
    return path.join(folderPath, fileName);
  }

  String getExtension(Codec codec) {
    String extension = "aac";

    switch (codec) {
      case Codec.defaultCodec:
        extension = "aac";
      case Codec.opusCAF:
      case Codec.pcm16CAF:
        extension = "caf";
      case Codec.pcm16:
      case Codec.pcm8:
      case Codec.pcmFloat32:
        extension = "pcm";
      case Codec.pcm16WAV:
        extension = "wav";
      case Codec.pcmWebM:
      case Codec.opusWebM:
      case Codec.vorbisWebM:
        extension = "webm";
      case Codec.pcm16AIFF:
        extension = "aiff";
      case Codec.aacADTS:
      case Codec.aacMP4:
        extension = "aac";
        break;
      case Codec.amrNB:
      case Codec.amrWB:
        extension = "amr";
        break;
      case Codec.flac:
        extension = "flac"; // not supported
        break;
      case Codec.opusOGG:
      case Codec.vorbisOGG:
        extension = "opus";
        break;
      case Codec.mp3:
        extension = "mp3"; // not supported
        break;
    }

    return extension;
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      //kiểm tra xem liệu ứng dụng có đang trong trạng thái ghi âm
      _recordedFilePath = await _getRecordedFilePath(getExtension(
          codec)); //Hàm _getRecordedFilePath() trả về đường dẫn tới tệp ghi âm
      await _audioRecorder.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.values.where((element) => element == codec).first,
      );
      setState(() {
        _isRecording = true;
      });
      print(codec);
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Widget getTextWidgets(List<Codec> strings) {
    return Wrap(
        children: strings
            .map((item) => GestureDetector(
                  onTap: () {
                    setState(() {
                      codec = item;
                    });
                  },
                  child: Chip(
                    backgroundColor: codec == item ? Colors.red : Colors.white,
                    label: Text(item.toString()),
                  ),
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi âm và lưu thành tệp WAV'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.amber,
            child: getTextWidgets(Codec.values.map((e) => e).toList()),
          ),
          const SizedBox(
            height: 100,
          ),
          const Text(
            'Đường dẫn tệp ghi âm:',
          ),
          Text(
            _recordedFilePath,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _isRecording
              ? ElevatedButton(
                  onPressed: _stopRecording,
                  child: Text('Dừng ghi âm'),
                )
              : ElevatedButton(
                  onPressed: _checkPermissionAndStartRecording,
                  child: Text('Bắt đầu ghi âm'),
                ),
        ],
      ),
    );
  }
}
