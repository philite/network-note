import 'package:flutter/material.dart';
import 'package:network_note/app.dart';
import 'package:network_note/data/note_content.dart';
import 'package:network_note/screens/note_editor.dart';

class NoteViewer extends StatefulWidget {
  const NoteViewer({Key key, @required this.noteId}) : super(key: key);

  final int noteId;

  @override
  State<StatefulWidget> createState() => _NoteViewerState();
}

class _NoteViewerState extends State<NoteViewer> {
  NoteContent _note;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NoteContent>(
      stream: noteContentRepo.onNoteChange(widget.noteId),
      builder: (context, snapshot) {
        _note = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              if (_note != null)
                IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _onPressEditNote();
                    })
            ],
          ),
          body: _buildNoteContainer(),
        );
      },
    );
  }

  void _onPressEditNote() {
    if (_note != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return NoteEditor(
          initialNote: _note,
        );
      }));
    }
  }

  Widget _buildNoteContainer() {
    if (_note == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        child: ListView(
          children: <Widget>[
            ListTile(
                title: Text(
              _note.title?.value ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
            ListTile(
                title: Text(
              _note.content?.value ?? '',
              style: TextStyle(fontSize: 16),
            ))
          ],
        ),
      );
    }
  }
}
