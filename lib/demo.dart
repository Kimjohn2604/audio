import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
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
  late FlutterSoundRecord _audioRecorder;
  bool _isRecording = false;
  String _recordedFilePath = "";
  AudioEncoder _audioEncoder = AudioEncoder.AAC;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecord();
  }

  Future<void> _checkPermissionAndStartRecording() async {
    if (await Permission.microphone.request().isGranted) {
      _startRecording();
    } else {
      print("Microphone permission denied.");
    }
  }

  Future<String> _getRecordedFilePath(String extension) async {
    // Directory appDir = await getApplicationDocumentsDirectory();
    String folderPath = "/sdcard/Download/";
    final random = Random();
    final fileName = 'audio_${random.nextInt(10000)}.$extension';
    return path.join(folderPath, fileName);
  }

  String getExtension(AudioEncoder audioEncoder) {
    String extension = "aac";
    if (AudioEncoder.AAC == audioEncoder) extension = "aac";
    if (AudioEncoder.AAC_HE == audioEncoder) extension = "aac";
    if (AudioEncoder.AAC_LD == audioEncoder) extension = "aac";
    if (AudioEncoder.AMR_NB == audioEncoder) extension = "amr";
    if (AudioEncoder.AMR_WB == audioEncoder) extension = "amr"; // not support
    return extension;
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      //kiểm tra xem liệu ứng dụng có đang trong trạng thái ghi âm
      _recordedFilePath = await _getRecordedFilePath(getExtension(
          _audioEncoder)); //Hàm _getRecordedFilePath() trả về đường dẫn tới tệp ghi âm
      await _audioRecorder.start(
        path: _recordedFilePath,
        encoder: _audioEncoder,
      );
      setState(() {
        _isRecording = true;
      });
      print(_recordedFilePath);
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget getTextWidgets(List<AudioEncoder> strings) {
    return Wrap(
        children: strings
            .map((item) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _audioEncoder = item;
                    });
                  },
                  child: Chip(
                    backgroundColor: _audioEncoder == item ? Colors.red : Colors.white,
                    label: Text(item.name),
                  ),
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi âm và lưu thành tệp WAV'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.amber,
            child: getTextWidgets(AudioEncoder.values.map((e) => e).toList()),
          ),
          const SizedBox(
            height: 100,
          ),
          const Text(
            'Đường dẫn tệp ghi âm:',
          ),
          Text(
            _recordedFilePath,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _isRecording
              ? ElevatedButton(
                  onPressed: _stopRecording,
                  child: const Text('Dừng ghi âm'),
                )
              : ElevatedButton(
                  onPressed: _checkPermissionAndStartRecording,
                  child: const Text('Bắt đầu ghi âm'),
                ),
        ],
      ),
    );
  }
}
