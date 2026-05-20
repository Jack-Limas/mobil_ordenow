import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiChatBox extends StatefulWidget {
  const AiChatBox({
    super.key,
    required this.onSend,
    this.onVoiceSend,
    this.hintText = 'Escribe aquí...',
    this.isLoading = false,
    this.onListeningChanged,
  });

  /// Called when the user sends a typed text message.
  final Future<void> Function(String prompt) onSend;

  /// Called when a voice message is captured and auto-sent.
  /// If null, falls back to [onSend].
  final Future<void> Function(String prompt)? onVoiceSend;

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

  // Accumulates the transcription internally — never written to the text field.
  String _lastRecognized = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  // Lazy init: requests microphone permission only on first tap.
  Future<bool> _ensureSpeechReady() async {
    if (_speechInitialized) return _speechAvailable;
    final available = await _speech.initialize(
      onError: (_) => _onVoiceDone(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') _onVoiceDone();
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
      // User tapped stop — finalize the voice message.
      await _speech.stop();
      // _onVoiceDone is also called by the onStatus callback; guard handles double calls.
      return;
    }
    final ready = await _ensureSpeechReady();
    if (!ready) return;

    _lastRecognized = '';
    _setListening(true);

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        // Accumulate transcription internally — NOT shown in the text field.
        _lastRecognized = result.recognizedWords;
      },
      localeId: 'es_CO',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  /// Fires when voice recording ends (either by user stop or silence timeout).
  /// Auto-sends the transcription as a voice message without writing it to the field.
  void _onVoiceDone() {
    if (!_isListening) return;
    _setListening(false);

    final text = _lastRecognized.trim();
    _lastRecognized = '';

    if (text.isEmpty || widget.isLoading) return;

    final sendFn = widget.onVoiceSend ?? widget.onSend;
    sendFn(text);
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
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
        // ── Voice button (left) ────────────────────────────────────────────
        // Tap to start recording. Tap again to stop & auto-send voice message.
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
                  : Theme.of(context).colorScheme.surface,
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

        // ── Text field (center) ────────────────────────────────────────────
        // Disabled while recording so the two channels don't interfere.
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isListening
                    ? const Color(0xFFFF6F22).withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: TextField(
              controller: _controller,
              enabled: !_isListening,
              style: TextStyle(
                color: _isListening
                    ? const Color(0xFF636366)
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              onSubmitted: (_) => _sendText(),
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

        // ── Send button (right) ────────────────────────────────────────────
        // Appears only when the text field has content AND not recording.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: (_hasText && !_isListening)
              ? Padding(
                  key: const ValueKey('send'),
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: widget.isLoading ? null : _sendText,
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
