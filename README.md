# Voice Notes App

A Flutter application that converts speech to text and saves voice notes locally using Hive database.

## Features

- **Voice Recording**: Convert speech to text using device microphone
- **Local Storage**: Save notes locally using Hive database
- **Tab Navigation**: Clean UI with TabBar navigation between Record and Notes screens
- **State Management**: Efficient state management using GetX
- **Responsive Design**: Works well on both small and large screens
- **Date/Time Formatting**: Smart timestamp display with relative time formatting

## Screenshots

### Record Screen
- Real-time speech recognition
- Visual feedback for recording status
- Save transcribed text as notes
- Error handling and user feedback

### Notes Screen
- List of all saved notes
- Formatted timestamps (e.g., "2h ago", "Just now")
- Delete individual notes
- Empty state with call-to-action
- Pull-to-refresh functionality

## Project Structure

```
lib/
├── controllers/
│   └── notes_controller.dart    # GetX controller for state management
├── db/
│   └── database_service.dart     # Hive database operations
├── models/
│   └── note.dart                # Note model with Hive annotations
├── views/
│   ├── main_app.dart           # Main app with TabBar navigation
│   ├── record_screen.dart      # Voice recording screen
│   └── notes_screen.dart      # Notes list screen
└── main.dart                   # App entry point
```

## Dependencies

- **flutter**: SDK
- **get**: State management and navigation
- **speech_to_text**: Speech recognition functionality
- **hive**: Local database storage
- **hive_flutter**: Flutter integration for Hive
- **intl**: Date and time formatting
- **uuid**: Unique ID generation

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd voice_notes_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters:
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Recording Voice Notes

1. Open the app and navigate to the "Record" tab
2. Tap the microphone button to start recording
3. Speak clearly into your device's microphone
4. Tap the stop button when finished
5. Review the transcribed text
6. Tap "Save Note" to store the note

### Managing Notes

1. Navigate to the "Notes" tab to view all saved notes
2. Tap on a note to view full details
3. Use the delete button to remove unwanted notes
4. Pull down to refresh the notes list

## Technical Details

### State Management

The app uses GetX for state management with a single `NotesController` that handles:
- Speech recognition state
- Note CRUD operations
- UI state updates
- Error handling

### Database

Hive is used for local storage with:
- `Note` model with Hive annotations
- Automatic adapter generation
- Efficient local storage
- No external dependencies

### Speech Recognition

The `speech_to_text` package provides:
- Real-time transcription
- Multiple language support
- Error handling
- Permission management

## Permissions

The app requires the following permissions:
- **Microphone**: For voice recording functionality
- **Storage**: For local database storage

## Error Handling

The app includes comprehensive error handling for:
- Speech recognition failures
- Database operations
- Network connectivity issues
- Permission denials

## Future Enhancements

- [ ] Export notes to text files
- [ ] Search functionality
- [ ] Note categories/tags
- [ ] Cloud synchronization
- [ ] Voice commands
- [ ] Dark theme support
- [ ] Multiple language support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Troubleshooting

### Common Issues

1. **Speech recognition not working**: Ensure microphone permissions are granted
2. **Build errors**: Run `flutter clean` and `flutter pub get`
3. **Hive adapter errors**: Run `flutter packages pub run build_runner build`

### Performance Tips

- Close unused apps to free up memory
- Ensure stable internet connection for speech recognition
- Regularly clear old notes to maintain performance

## Support

For support and questions, please open an issue in the repository or contact the development team.