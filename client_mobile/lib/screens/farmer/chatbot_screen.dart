import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
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

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    // Add a welcoming message from the bot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.insert(0, ChatMessage("Hello! Ask me a question with your voice or by typing.", false));
      });
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle the case where the user denies permission
      print('Microphone permission not granted');
      return;
    }
    await _recorder.openRecorder();
  }

  // --- Voice Logic ---
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndSend();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/chatbot_audio.aac';
    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
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
      if (_filePath == null) throw Exception("File path is null.");
      
      final file = File(_filePath!);
      if (!await file.exists()) throw Exception("Audio file not found.");

      final audioBytes = await file.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      
      // We will create this 'chatbot/voice' endpoint on the server next
      final response = await _apiService.postData('chatbot/voice', {
        'audio': audioBase64,
        'role': 'farmer'
      });
      
      final String botResponse = response['response'] ?? 'Sorry, I had trouble with that voice message.';
      setState(() => _messages.insert(0, ChatMessage(botResponse, false)));

    } catch (e) {
      print("Error sending audio: $e");
      setState(() => _messages.insert(0, ChatMessage("Sorry, an error occurred with the voice input.", false)));
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
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
      final response = await _apiService.postData('prescriptions/chatbot', {'query': text, 'role': 'farmer'});
      final String botResponse = response['response'] ?? 'Sorry, I had trouble understanding that.';
      setState(() => _messages.insert(0, ChatMessage(botResponse, false)));
    } catch (e) {
      print("Chatbot Error: $e");
      setState(() => _messages.insert(0, ChatMessage("Sorry, I couldn't connect. Please try again.", false)));
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
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
              decoration: const InputDecoration.collapsed(hintText: "Type a message..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
          // Voice recording button
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