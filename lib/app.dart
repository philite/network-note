import 'package:flutter/material.dart';
import 'package:network_note/repositories/application_database.dart';
import 'package:network_note/repositories/note_content_repository.dart';
import 'package:network_note/screens/home_screen.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

// TODO() => Make this project TDD;
// TODO() => Localization
// TODO() => Consistent dimension resource

// TODO() => Theme (later)
// TODO() => Interface design (later)
// TODO() => Reusable widget (later)

ApplicationDatabase appDatabase;
NoteContentRepository noteContentRepo;
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareAppDatabase();
  prepareRepository();
  runApp(NetworkNoteApp());
}

Future prepareAppDatabase() async {
  var packageName = 'com.example.network_note';
  var databaseFactory = getDatabaseFactory(packageName: packageName);
  appDatabase = ApplicationDatabase(databaseFactory);
  await appDatabase.initDatabase;
}

void prepareRepository() {
  noteContentRepo = NoteContentRepository(appDatabase.database);
}

class NetworkNoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
    );
  }
}
