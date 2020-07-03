import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_note/app.dart';
import 'package:network_note/data/note_content.dart';
//import 'dart:developer' as developer;

// TODO() => Possible bug when type nothing but dialog is trigger like note is dirty
// This one might link to "Must check isNotBlank"
// Log on title changed, content changed => use developer.log()

class NoteEditor extends StatefulWidget {
  NoteEditor({Key key, this.initialNote}) : super(key: key);

  final NoteContent initialNote;

  @override
  State<StatefulWidget> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleTextController;
  TextEditingController _contentTextController;

  int get _noteId => widget.initialNote?.id?.value;

  // TODO() => State of Editing and Adding;
  // # (_noteId != null) use to check when 'editing note'
  // So this might means that when 'adding note' (from FAB on HomeScreen)
  // _noteId == null

  // ENUM to 2 states? {Editing, Adding}

  bool get _isEditingNote => _noteId != null;
  //bool get _isAddingNote => _noteId == null;

  // # TODO() => Must check isNotBlank!!!
  // Because right now the content can be blank but is not null with "" value
  bool get _isTitleChanged =>
      _titleTextController.text != widget.initialNote?.title?.value;

  bool get _isContentChanged =>
      _contentTextController.text != widget.initialNote?.content?.value;

  @override
  void initState() {
    super.initState();
    _titleTextController =
        TextEditingController(text: widget.initialNote?.title?.value);
    _contentTextController =
        TextEditingController(text: widget.initialNote?.content?.value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onNoteDirtyWillPop(),
      child: _buildEditorUi(),
    );
  }

  Future<bool> _onNoteDirtyWillPop() async {
    bool isDirtyNote = _checkInitialNoteTextWithController();
    if (isDirtyNote) {
      await _showConfirmExitDialog();
    }
    return true;
  }

  bool _checkInitialNoteTextWithController() {
    if (_isTitleChanged || _isContentChanged) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _showConfirmExitDialog() async {
    return await showDialog<bool>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Do you want to save change you made?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("Don't save and exit"),
                    // Navigator.of(context).pop(result)
                    // return true;
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  RaisedButton(
                    child: Text("Save and exit"),
                    onPressed: () async {
                      await _saveNote();
                      Navigator.pop(context, true);
                    },
                  ),
                  FlatButton(
                    child: Text("Cancel"),
                    // return false;
                    // TODO() => Current: Click cancel = Close the note
                    // Expect: Click cancel = Close dialog and stay on this note
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              );
            }) ?? // ?? is fallback for return
        false;
  }

  Future _saveNote() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
    await noteContentRepo.saveNote(NoteContent()
      ..id.value = _noteId
      ..title.value = _titleTextController?.text
      ..content.value = _contentTextController?.text
      ..date.value = DateTime.now().millisecondsSinceEpoch);
  }

  Widget _buildEditorUi() {
    return Scaffold(
      appBar: AppBar(
        actions: _buildIconButtons(),
      ),
      body: _buildEditorBody(),
    );
  }

  List<Widget> _buildIconButtons() {
    return <Widget>[
      if (_isEditingNote)
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            var confirmDelete = await _showDeleteDialog();
            if (confirmDelete) {
              await noteContentRepo.deleteNote(_noteId);
              // Pop twice to go back to the HomeScreen
              Navigator.pop(context);
              Navigator.pop(context);
            }
          },
        ),
      IconButton(
        icon: Icon(Icons.save),
        // TODO() => When saved notify;
        // After save should have toast notify user

        // TODO() => When saved and not exit; must change mode to editing;
        // After save should make this not adding anymore but editing
        // (Duplicate note found after press save and exit with saving)

        // TODO() => Bug: After saved and press exit immediately after, it still asks to save change
        onPressed: () async =>
            await _saveNote(), // Does this await unnesscary because there's no next command to execute?
      )
    ];
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Are you sure you want to delete this note?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("No"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              );
            }) ??
        false;
  }

  Widget _buildEditorBody() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(children: <Widget>[
        Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                    controller: _titleTextController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Title must not be empty',
                  ),
                  TextFormField(
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Content',
                      hintStyle: TextStyle(fontSize: 16),
                      border: InputBorder.none,
                    ),
                    controller: _contentTextController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ]))
      ]),
    );
  }
}
