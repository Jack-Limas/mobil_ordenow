import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiChatBox extends StatefulWidget {
  const AiChatBox({
    super.key,
    required this.onSend,
    this.hintText = 'Habla o escribe aquí...',
    this.isLoading = false,
    this.onListeningChanged,
  });

  final Future<void> Function(String prompt) onSend;
  final String hintText;
  final bool isLoading;
  final ValueChanged<bool>? onListeningChanged;

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
      onError: (_) => _setListening(false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') _setListening(false);
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  void _setListening(bool value) {
    setState(() => _isListening = value);
    widget.onListeningChanged?.call(value);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;
    if (_isListening) {
      await _speech.stop();
      _setListening(false);
      return;
    }
    _setListening(true);
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.keyboard_alt_outlined,
                  color: Color(0xFF636366),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: _isListening
                          ? 'Escuchando...'
                          : widget.hintText,
                      hintStyle: TextStyle(
                        color: _isListening
                            ? const Color(0xFFFF6F22)
                            : const Color(0xFF636366),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _toggleListening,
          onLongPressStart: (_) => _toggleListening(),
          onLongPressEnd: (_) async {
            if (_isListening) {
              await _speech.stop();
              _setListening(false);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6F22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6F22)
                      .withValues(alpha: _isListening ? 0.6 : 0.25),
                  blurRadius: _isListening ? 20 : 8,
                  spreadRadius: _isListening ? 4 : 0,
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
