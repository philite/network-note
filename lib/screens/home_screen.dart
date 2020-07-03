import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_note/app.dart';
import 'package:network_note/data/note_content.dart';
import 'package:network_note/screens/note_viewer.dart';
import 'package:network_note/screens/note_editor.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteContent> _noteList;
  NoteContent _item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildNoteListStream(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Add new note",
          onPressed: () {
            _onPressFab();
          }),
    );
  }

  void _onPressFab() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditor(initialNote: null),
      ),
    );
  }

  Widget _buildNoteListStream() {
    return StreamBuilder<List<NoteContent>>(
        stream: noteContentRepo.onNoteListChange(),
        builder: (context, snapshot) {
          _noteList = snapshot.data;
          if (_noteList == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (_noteList.length < 1) {
            return Center(
              child: Text("No notes, use plus button to add new note"),
            );
          } else {
            return _buildNoteList();
          }
        });
  }

  Widget _buildNoteList() {
    //var cardKey = [];
    // TODO() => Does UiModel necessary?
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
          itemCount: _noteList.length,
          itemBuilder: (context, index) {
            _item = _noteList[index];
            var cardKey = GlobalKey();
            return Card(
              key: cardKey,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(_item.title?.value ?? ''),
                    subtitle: Text(
                      _item.content?.value ?? '',
                      maxLines: 6,
                    ),
                    onTap: () {
                      _onTapNoteItem();
                    },
                    onLongPress: () async {
                      if (_item.id.value != null) {
                        var result = await _onLongPressNoteItem(
                            _item.id.value, cardKey.currentContext);
                        // TODO() => Investigate on how to make each Card remember its id
                        if (result == "Delete") {
                          await noteContentRepo.deleteNote(_item.id.value);
                        }
                      }
                    },
                  )
                ],
              ),
            );
          }),
    );
  }

  void _onTapNoteItem() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NoteViewer(noteId: _item.id.value)));
  }

  _onLongPressNoteItem(int noteId, BuildContext callerContext) async {
    // TODO() => Use better callback to do actions on click
    return await showMenu(
        context: context,
        position: buttonMenuPositionToCaller(callerContext),
        items: [
          PopupMenuItem(
            child: Text("Delete"),
            value: "Delete",
          )
        ]);
    // No need to setState() [StreamBuilder already observing the changes]
  }

  RelativeRect buttonMenuPositionToCaller(BuildContext callerContext) {
    final RenderBox bar = callerContext.findRenderObject();
    final RenderBox overlay =
        Overlay.of(callerContext).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(bar.size.centerRight(Offset.zero), ancestor: overlay),
        bar.localToGlobal(bar.size.centerRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }
}
