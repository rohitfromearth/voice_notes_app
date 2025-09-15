import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../db/database_service.dart';
class NotesController extends GetxController {
  final SpeechToText _speechToText = SpeechToText();
  
  final RxBool _isListening = false.obs;
  final RxBool _isAvailable = false.obs;
  final RxString _recognizedText = ''.obs;
  final RxList<Note> _notes = <Note>[].obs;
  final RxString _errorMessage = ''.obs;

  bool get isListening => _isListening.value;
  bool get isAvailable => _isAvailable.value;
  String get recognizedText => _recognizedText.value;
  List<Note> get notes => _notes;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSpeech();
    _loadNotes();
  }

  Future<void> _initializeSpeech() async {
    try {
      _isAvailable.value = await _speechToText.initialize(
        onError: (error) {
          _handleSpeechError(error.errorMsg, error.permanent);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening.value = false;
            if (_recognizedText.value.isEmpty) {
              _setError('No speech detected. Please try again.');
            }
          }
        },
      );
    } catch (e) {
      _errorMessage.value = 'Failed to initialize speech recognition: $e';
    }
  }

  Future<void> startListening() async {
    if (!_isAvailable.value) {
      _errorMessage.value = 'Speech recognition not available';
      return;
    }

    try {
      final PermissionStatus micStatus = await Permission.microphone.status;
      if (micStatus.isDenied || micStatus.isRestricted) {
        final PermissionStatus requested = await Permission.microphone.request();
        if (!requested.isGranted) {
          _errorMessage.value = 'Microphone permission is required to record voice notes';
          return;
        }
      } else if (micStatus.isPermanentlyDenied) {
        _errorMessage.value = 'Microphone permission is permanently denied. Please enable it in Settings.';
        openAppSettings();
        return;
      }

      _errorMessage.value = '';
      _recognizedText.value = '';
      
      await _speechToText.listen(
        onResult: (result) {
          _recognizedText.value = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        onSoundLevelChange: (level) {},
        listenOptions: SpeechListenOptions(
          partialResults: true,
        ),
      );
      
      _isListening.value = true;
    } catch (e) {
      _setError('Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening.value = false;
    } catch (e) {
      _setError('Failed to stop listening: $e');
    }
  }

  Future<void> saveNote() async {
    if (_recognizedText.value.trim().isEmpty) {
      _errorMessage.value = 'No text to save';
      return;
    }

    try {
      final note = Note(
        id: const Uuid().v4(),
        content: _recognizedText.value.trim(),
        timestamp: DateTime.now(),
      );

      await DatabaseService.addNote(note);
      _loadNotes();
      
      _recognizedText.value = '';
      _errorMessage.value = '';

      Get.snackbar(
        'Success',
        'Note saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _errorMessage.value = 'Failed to save note: $e';
    }
  }

  void _loadNotes() {
    try {
      _notes.value = DatabaseService.getAllNotes();
    } catch (e) {
      _errorMessage.value = 'Failed to load notes: $e';
    }
  }

  void refreshNotes() {
    _loadNotes();
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await DatabaseService.deleteNote(noteId);
      _loadNotes();
      
      Get.snackbar(
        'Success',
        'Note deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _setError('Failed to delete note: $e');
    }
  }

  Future<void> clearAllNotes() async {
    try {
      await DatabaseService.clearAllNotes();
      _loadNotes();
      
      Get.snackbar(
        'Success',
        'All notes cleared successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _setError('Failed to clear notes: $e');
    }
  }

  void clearRecognizedText() {
    _recognizedText.value = '';
    _errorMessage.value = '';
  }

  bool get speechAvailable => _isAvailable.value;

  bool get listeningStatus => _isListening.value;

  @override
  void onClose() {
    _speechToText.stop();
    super.onClose();
  }

  void _setError(String message, {bool showSnackbar = true}) {
    _errorMessage.value = message;
    _isListening.value = false;
    if (showSnackbar) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handleSpeechError(String errorCodeOrMessage, bool permanent) {
    final String msg = _mapSpeechError(errorCodeOrMessage, permanent);
    _setError(msg);
  }

  String _mapSpeechError(String codeOrMsg, bool permanent) {
    final String code = codeOrMsg.toLowerCase();
    if (code.contains('error_permission') || code.contains('permission')) {
      return 'Microphone permission denied${permanent ? ' permanently' : ''}. Please enable it to use voice notes.';
    }
    if (code.contains('error_network') || code.contains('network')) {
      return 'Network error during speech recognition. Please check your connection and try again.';
    }
    if (code.contains('error_no_match') || code.contains('no match')) {
      return 'Didn\'t catch that. Try speaking again.';
    }
    if (code.contains('error_speech_timeout') || code.contains('timeout')) {
      return 'Listening timed out. Please try again.';
    }
    if (code.contains('error_busy') || code.contains('busy')) {
      return 'Speech engine is busy. Please wait a moment and retry.';
    }
    if (code.contains('audio') || code.contains('error_audio_error')) {
      return 'Audio input error. Ensure your microphone is working and try again.';
    }
    if (permanent) {
      return 'Speech recognition is unavailable on this device.';
    }
    return 'Speech recognition error: $codeOrMsg';
  }
}
