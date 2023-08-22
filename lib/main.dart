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
      print("Microphone permission denied.");
    }
  }

  Future<String> _getRecordedFilePath(String extension) async {
    /* Directory appDir = await getApplicationDocumentsDirectory(); */
    String folderPath = "/sdcard/Download/";
    final random = Random();
    final fileName = 'audio_${random.nextInt(10000)}.$extension';
    return path.join(folderPath, fileName);
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      //kiểm tra xem liệu ứng dụng có đang trong trạng thái ghi âm
      _recordedFilePath = await _getRecordedFilePath(
          "wav"); //Hàm _getRecordedFilePath() trả về đường dẫn tới tệp ghi âm
      await _audioRecorder.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
      print(_recordedFilePath);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi âm và lưu thành tệp WAV'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Đường dẫn tệp ghi âm:',
            ),
            Text(
              _recordedFilePath,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
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
      ),
    );
  }
}
