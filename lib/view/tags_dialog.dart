import 'package:flutter/material.dart';
import 'package:Rainbow/supplemental/config_storage.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/api/base_api.dart';
import 'package:Rainbow/api/feed_api.dart';

typedef SubmitTagsCallBack = void Function(List<Tag>);

class TagsDialog extends StatefulWidget {
  final Feed feed;
  final SubmitTagsCallBack submitCallBack;

  TagsDialog({Key key,this.feed,this.submitCallBack}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return _TagsDialogState();
  }
}

class  _TagsDialogState extends State<TagsDialog> {
  List<Tag> _storageTags = List<Tag>();
  List<Tag> addTagsList =List<Tag>();
  @override
  void initState() {
    super.initState();
    _loadStorageTags();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Add Tag'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                children: tagsWidgets.toList(),
              ),
              SizedBox(height: 24,),
              Text('After You Submit Tag We will Check ASAP,If Tags Above Not be satisfied,Please Contact Us',style: TextStyle(fontSize: 12),),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Submit'),
            onPressed: (){
              _submit(context);
            },
          ), 
        ],
      );
  }

  _submit(BuildContext context) {
    if (widget.submitCallBack != null) {
      widget.submitCallBack(addTagsList);
      Navigator.of(context).pop();
    } 
    FeedAPI.tags(widget.feed.id, addTagsList).then((response){
      if (response.code == WrapCode.Fail) {
        final SnackBar snackbar = SnackBar(
          content: Text(response.msg),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        );
        Scaffold.of(context).showSnackBar(snackbar);
        // _scaffoldState.currentState.showSnackBar(snackbar);
      } else {
        Navigator.pop(context);
      }
    });
  }
    _loadStorageTags() async{
      ConfigStorage storage =await ConfigStorage.getInstance();
      setState(() {
        _storageTags =storage.tags();
      });
  }

  Iterable<Widget> get tagsWidgets{
    return _storageTags.map((Tag tag){
      List<Tag> tags = widget.feed.tags;
      tags =tags ==null ?  List<Tag>() : tags;
      return Padding(
        padding: const EdgeInsets.all(4),
        child: FilterChip(
        avatar: null,
        label: Text(tag.name),
        // disabledColor: Colors.red,
        selected: addTagsList.contains(tag),
        onSelected: !tags.contains(tag) ? (bool value){
            setState(() {
              if (value) {
              addTagsList.add(tag);
            } else {
              addTagsList.remove(tag);
            }
            });
        } :null,
      ),);
    });
  }
}