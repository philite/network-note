import 'package:network_note/data/base/base_name_value.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

// RecordSnapshot comes from Stream of data
// RecordSnapshot<id, BaseNameValue<name, value>> is the form of data

NoteContent snapshotToNote(RecordSnapshot<int, Map<String, dynamic>> snapshot) {
  NoteContent note;
  if (snapshot != null) {
    // Create new NoteContent then map (map: snapshot.value, id: snapshot.key)
    note = NoteContent()..fromMap(snapshot.value, id: snapshot.key);
  }
  return note;
}

class NoteContent extends BaseNameValueObject {
  final title = toStringNameValue('title');
  final content = toStringNameValue('content');
  final date = toIntNameValue('date');

  @override
  List<BaseNameValue> get objectAttributes => [title, content, date];
}

class NoteContentList extends ListBase<NoteContent> {
  // Receive RecordSnapshot then covert to list
  NoteContentList(this.list) {
    _cacheNotes = List.generate(list.length ?? 0, (index) => null);
  }

  final List<RecordSnapshot<int, Map<String, dynamic>>> list;
  List<NoteContent> _cacheNotes;

  @override
  NoteContent operator [](int index) {
    return _cacheNotes[index] ??= snapshotToNote(list[index]);
  }

  @override
  int get length => list.length;

  @override
  void operator []=(int index, NoteContent value) => throw 'read-only';

  @override
  set length(int newLength) => throw 'read-only';
}
