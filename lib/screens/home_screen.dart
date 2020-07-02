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
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NoteEditor(initialNote: null);
            }));
          }),
    );
  }

  Widget _buildNoteListStream() {
    return StreamBuilder<List<NoteContent>>(
        stream: noteContentRepo.onNoteListChange(),
        builder: (context, snapshot) {
          _noteList = snapshot.data;
          // TODO() => 2 conditions on HomeScreen;
          // on loading show circularProgressIndicator then _buildNoteList() after loaded
          // on empty list show empty
          if (_noteList.length < 1) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return _buildNoteList();
        });
  }

  Widget _buildNoteList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
          itemCount: _noteList.length,
          itemBuilder: (context, index) {
            _item = _noteList[index];
            return Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(_item.title?.value ?? ''),
                    subtitle: Text(
                      _item.content?.value ?? '',
                      maxLines: 6,
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return NoteViewer(
                          noteId: _item.id.value,
                        );
                      }));
                    },
                    // TODO() => Delete item on HomeScreen
                    //onLongPress: ,
                  )
                ],
              ),
            );
          }),
    );
  }
}
