import 'package:network_note/data/note_content.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class NoteContentRepository {
  NoteContentRepository(this._appDatabase);

  final Database _appDatabase;
  static const String noteContentTable = "NoteContent";
  final _table = intMapStoreFactory.store(noteContentTable);

  // Stream of data

  var noteListToStreamTransformer = StreamTransformer<
      List<RecordSnapshot<int, Map<String, dynamic>>>,
      List<NoteContent>>.fromHandlers(handleData: (snapshotList, sink) {
    sink.add(NoteContentList(snapshotList));
  });

  var noteToStreamTransformer = StreamTransformer<
      RecordSnapshot<int, Map<String, dynamic>>,
      NoteContent>.fromHandlers(handleData: (snapshot, sink) {
    sink.add(snapshotToNote(snapshot));
  });

  // Listen for changes on any note
  Stream<List<NoteContent>> onNoteListChange() {
    return _table
        .query(finder: Finder(sortOrders: [SortOrder('date', false)]))
        .onSnapshots(_appDatabase)
        .transform(noteListToStreamTransformer);
    //.handleError((e) => {print(e.toString())});
  }

  // Listed for changes on a given note
  Stream<NoteContent> onNoteChange(int id) {
    return _table
        .record(id)
        .onSnapshot(_appDatabase)
        .transform(noteToStreamTransformer)
        .handleError((e) => {print(e.toString())});
  }

  // CRUD operations

  Future<NoteContent> getNote(int id) async {
    try {
      var map = await _table.record(id).get(_appDatabase);
      // devPrint('getNote: ${map}');
      if (map != null) {
        return NoteContent()..fromMap(map, id: id);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future saveNote(NoteContent updatedNote) async {
    try {
      if (updatedNote.id.value != null) {
        await _table
            .record(updatedNote.id.value)
            .put(_appDatabase, updatedNote.toMap());
      } else {
        updatedNote.id.value =
            await _table.add(_appDatabase, updatedNote.toMap());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future deleteNote(int id) async {
    try {
      if (id != null) {
        await _table.record(id).delete(_appDatabase);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future clearAllNotes() async {
    try {
      await _table.delete(_appDatabase);
    } catch (e) {
      print(e.toString());
    }
  }

  Future closeDb() async {
    try {
      await _appDatabase.close();
    } catch (e) {
      print(e.toString());
    }
  }
}
