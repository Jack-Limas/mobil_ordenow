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
  bool _speechInitialized = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  // Lazy init: only asks for mic permission the first time the user taps the mic button.
  Future<bool> _ensureSpeechReady() async {
    if (_speechInitialized) return _speechAvailable;
    final available = await _speech.initialize(
      onError: (_) => _setListening(false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') _setListening(false);
      },
    );
    _speechInitialized = true;
    if (mounted) setState(() => _speechAvailable = available);
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo acceder al micrófono. Verifica los permisos en Ajustes.',
          ),
          backgroundColor: Color(0xFF3A3A3C),
        ),
      );
    }
    return available;
  }

  void _setListening(bool value) {
    if (!mounted) return;
    setState(() => _isListening = value);
    widget.onListeningChanged?.call(value);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      _setListening(false);
      return;
    }
    final ready = await _ensureSpeechReady();
    if (!ready) return;
    _setListening(true);
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
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
    if (_isListening) {
      await _speech.stop();
      _setListening(false);
    }
    _controller.clear();
    await widget.onSend(text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mic button — tap to start, tap again to stop
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? const Color(0xFFFF6F22)
                  : const Color(0xFF2C2C2E),
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF6F22).withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ]
                  : const [],
            ),
            child: Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              color: _isListening ? Colors.white : const Color(0xFF8E8E93),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Text field — shows transcription in real time; editable before sending
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isListening
                    ? const Color(0xFFFF6F22).withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onSubmitted: (_) => _send(),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: _isListening ? 'Escuchando...' : widget.hintText,
                hintStyle: TextStyle(
                  color: _isListening
                      ? const Color(0xFFFF6F22)
                      : const Color(0xFF636366),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        // Send button — appears with animation when text is present
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _hasText
              ? Padding(
                  key: const ValueKey('send'),
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: widget.isLoading ? null : _send,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isLoading
                            ? const Color(0xFF3A3A3C)
                            : const Color(0xFFFF6F22),
                      ),
                      child: widget.isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF636366),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                )
              : const SizedBox(key: ValueKey('empty')),
        ),
      ],
    );
  }
}
