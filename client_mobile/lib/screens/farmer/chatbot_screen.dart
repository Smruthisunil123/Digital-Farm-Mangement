import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// ✅ FIX: Import kIsWeb for web compatibility
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/api_service.dart';

// A simple model for chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Audio variables
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.insert(0, ChatMessage("Hello! I am your AI Farm Assistant. Ask me anything in Kannada or English.", false));
      });
    });
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    _player.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    // On web, permission is handled by the browser automatically when opening the recorder
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission not granted')),
          );
        }
        return;
      }
    }
    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  // --- Voice Logic ---
  Future<void> _toggleRecording() async {
    if (!_isRecorderInitialized) return;
    
    if (_isRecording) {
      await _stopRecordingAndSend();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    // Use a generic extension that works for both, or specific ones
    String ext = kIsWeb ? '.webm' : '.aac';
    _filePath = '${tempDir.path}/chatbot_audio$ext';

    // ✅ THE FIX: Choose the correct codec for Web vs Mobile
    var codec = kIsWeb ? Codec.opusWebM : Codec.aacADTS;
    
    await _recorder.startRecorder(toFile: _filePath, codec: codec);
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecordingAndSend() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isLoading = true;
      _messages.insert(0, ChatMessage("You: (Voice Message)", true));
    });
    _scrollToBottom();

    try {
      String audioBase64;
      
      if (kIsWeb) {
         // For this prototype, we skip voice upload on web to avoid file system errors.
         // In a production app, you would use Blob handling here.
         throw Exception("Voice recording is optimized for the mobile app.");
      } else {
         // Mobile logic
         if (_filePath == null) throw Exception("File path is null.");
         final file = File(_filePath!);
         if (!await file.exists()) throw Exception("Audio file not found.");
         final audioBytes = await file.readAsBytes();
         audioBase64 = base64Encode(audioBytes);
      
        // Send audio to server (Only runs if mobile)
        final response = await _apiService.postData('prescriptions/chatbot', {
            'audio': audioBase64,
            'role': 'farmer',
            'language': 'kn-IN' 
        });
        
        _handleServerResponse(response);
      }

    } catch (e) {
      print("Error sending audio: $e");
      String errorMsg = kIsWeb 
          ? "Voice recording is supported on Mobile." 
          : "Sorry, an error occurred with the voice input.";
      _handleError(errorMsg);
    }
  }

  // --- Text Logic ---
  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text, true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _apiService.postData('prescriptions/chatbot', {
        'query': text,
        'role': 'farmer',
        'language': 'kn-IN'
      });
      print("DEBUG: Raw Server Response: $response");

      _handleServerResponse(response);
    } catch (e) {
      print("Chatbot Error: $e");
      _handleError("Sorry, I couldn't connect. Please try again.");
    }
  }

  void _handleError(String errorText) {
    setState(() {
      _isLoading = false;
      _messages.insert(0, ChatMessage(errorText, false));
    });
    _scrollToBottom();
  }

  void _handleServerResponse(Map<String, dynamic> response) {
    print("DEBUG: Checking for 'text_response': ${response['text_response']}");
    print("DEBUG: Checking for 'audio_response': ${response['audio_response'] != null ? 'FOUND' : 'MISSING'}");
    final String botResponseText = response['text_response'] ?? 'I could not understand.';
    final String? botAudioBase64 = response['audio_response'];

    setState(() {
      _isLoading = false;
      _messages.insert(0, ChatMessage(botResponseText, false));
    });
    _scrollToBottom();

    // Play the audio response
    if (botAudioBase64 != null && botAudioBase64.isNotEmpty) {
      try {
        final audioBytes = base64Decode(botAudioBase64);
        _player.play(BytesSource(audioBytes));
      } catch (e) {
        print("Error playing audio response: $e");
      }
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot Help"),
        backgroundColor: Colors.green.shade800,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
          const Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _handleSubmitted,
              decoration: const InputDecoration.collapsed(hintText: "Type or speak..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
            color: _isRecording ? Colors.redAccent : Theme.of(context).primaryColor,
            iconSize: 30,
            onPressed: _isLoading ? null : _toggleRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(message.text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
