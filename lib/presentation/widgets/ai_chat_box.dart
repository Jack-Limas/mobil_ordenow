import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiChatBox extends StatefulWidget {
  const AiChatBox({
    super.key,
    required this.onSend,
    this.hintText = 'Describe un sabor o antojo...',
    this.isLoading = false,
  });

  final Future<void> Function(String prompt) onSend;
  final String hintText;
  final bool isLoading;

  @override
  State<AiChatBox> createState() => _AiChatBoxState();
}

class _AiChatBoxState extends State<AiChatBox> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) {
      setState(() => _speechAvailable = available);
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      localeId: 'es_CO',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    _controller.clear();
    await widget.onSend(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2522),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _isListening ? 'Escuchando...' : widget.hintText,
                      hintStyle: TextStyle(
                        color: _isListening
                            ? const Color(0xFFFF6F22)
                            : const Color(0xFF8A7E76),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _send,
                  child: Icon(
                    Icons.send_rounded,
                    color: widget.isLoading
                        ? const Color(0xFF4A4A4A)
                        : const Color(0xFFFFBBA0),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onLongPressStart: (_) => _toggleListening(),
          onLongPressEnd: (_) async {
            if (_isListening) {
              await _speech.stop();
              setState(() => _isListening = false);
            }
          },
          onTap: _toggleListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isListening
                    ? const [Color(0xFFFF3B30), Color(0xFFFF6F22)]
                    : const [Color(0xFFFFA167), Color(0xFFFF6B00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isListening
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFFFF6F22))
                      .withValues(alpha: 0.40),
                  blurRadius: _isListening ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.black,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
