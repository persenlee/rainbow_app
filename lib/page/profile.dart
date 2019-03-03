import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:Rainbow/model/user.dart';
import 'package:Rainbow/supplemental/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:Rainbow/api/user_api.dart';
import 'package:Rainbow/view/gender_dialog.dart';
import 'package:Rainbow/supplemental/util.dart';
import 'package:Rainbow/api/base_api.dart';

typedef ResultCallBack = Function(bool success);

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
  final FocusNode _nameFocusNode =FocusNode();
  TextEditingController _nameController = TextEditingController();
  User user;
  FileImage _localAvatar;
  bool _edit = false;
  int _selectedAge;
  int _selectedGender;
  bool _loading = false;

  @override
  void initState() {
    _edit = false;
    UserStorage.getInstance().readUser().then((user) {
      setState(() {
        this.user = user;
        _nameController =TextEditingController(text:user.name);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('Profile'),
        // actions: <Widget>[
        //     IconButton(
        //       icon: Icon(
        //         Icons.edit,
        //         semanticLabel: 'edit',
        //       ),
        //       onPressed: () {
        //         setState(() {
        //           _edit = true;
        //         });
        //       },
        //     ),
        //   ],
      ),
      body: SafeArea(
        child: Stack(children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                color: Colors.grey[200],
                child: ListTile(
                  title: Text('Email'),
                  trailing: Text(user == null ? '' : user.email),
                ),
              ),
              Divider(),
              ListTile(
                title: Text('Avatar'),
                trailing: CircleAvatar(
                  backgroundImage: 
                  _localAvatar !=null
                  ? 
                  _localAvatar
                  :
                  ((user == null || user.avatar.length == 0)
                      ? AssetImage('assets/default-avatar.png')
                      : NetworkImage(user.avatar)),
                ),
                onTap: () {
                  _modifyavatar(context);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Name'),
                trailing: _edit
                    ? Container(
                        width: 260,
                        child: TextField(
                          focusNode:_nameFocusNode,
                          decoration: InputDecoration(
                              filled: true, hintText: 'user name'),
                          enabled: !_loading,
                          controller: _nameController,
                          onEditingComplete: () {
                            _modifyName(context);
                            setState(() {
                              _edit = false;
                            });
                          },
                        ),
                      )
                    : Text((user == null) ? '' : user.name),
                onTap: () {
                  setState(() {
                    _edit = true;
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                  });
                },
              ),
              Divider(),
              ListTile(
                title: Text('Age'),
                trailing: Text(_selectedAge != null
                    ? _selectedAge.toString()
                    : ((user == null) ? '' : user.age.toString())),
                onTap: () {
                  _modifyAge(context);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Gender'),
                trailing: Text(_selectedGender != null
                    ? Util.genderConvert(_selectedGender)
                    : ((user == null) ? '' : Util.genderConvert(user.gender))),
                onTap: () {
                  _modifyGender(context);
                },
              ),
              Divider(),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: _loading ? 1 : 0,
              child: CircularProgressIndicator(),
              duration: Duration(milliseconds: 100),
            ),
          ),
        ]),
      ),
    );
  }

  _modifyavatar(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('album'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _pickImage(ImageSource source) {
    ImagePicker.pickImage(source: source).then((imageFile) {
      _cropImage(imageFile);
    });
  }

  _cropImage(File imageFile) {
    ImageCropper.cropImage(
            sourcePath: imageFile.path,
            ratioX: 1.0,
            ratioY: 1.0,
            maxWidth: 256,
            maxHeight: 256,
            circleShape: true)
        .then((croppedImageFile) {

      setState(() {
        _localAvatar = FileImage(croppedImageFile);
      });
      _uploadImage(croppedImageFile);
    });
  }

  _uploadImage(File file){
    BaseAPI.uploadFile(file, (int uploaded,int total){

    }).then((response){
      if (response.code ==WrapCode.Ok) {
        User temp = User();
        temp.avatar = response.result;
        _modifyProfile(temp, (bool success){
          _localAvatar =null;
          if (success) {
            user.avatar =response.result;
          } 
        });
      }
    });
  }

  _modifyName(BuildContext context) {
    if (_nameController.text != null 
    && _nameController.text.trim().length != 0) {
      User temp = User();
      temp.name = _nameController.text;
      _modifyProfile(temp, (bool success) {
        if (success) {
          user.name = _nameController.text;
        } 
      });
    }
  }

  _modifyGender(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenderDialog(
            initalGender: user != null ? user.gender : 0,
            valueChangedCallback: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          );
        }).then((result) {
      _selectedGender = result;
      if (result != null) {
        User temp = User();
        temp.gender = result;
        _modifyProfile(temp, (bool success) {
          if (success) {
            user.gender = _selectedAge;
            _selectedAge = null;
          } else {
            _selectedAge = null;
          }
        });
      }
    });
  }

  _modifyAge(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 216,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: user != null ? user.age : 0),
                backgroundColor: Colors.white,
                itemExtent: 32,
                useMagnifier: true,
                onSelectedItemChanged: ((index) {
                  setState(() {
                    _selectedAge = index;
                  });
                }),
                children: List<Widget>.generate(150, (int index) {
                  return Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  );
                }),
              ));
        }).then((result) {
      User temp = User();
      temp.age = _selectedAge;
      _modifyProfile(temp, (bool success) {
        if (success) {
          user.age = _selectedAge;
          _selectedAge = null;
        } else {
          _selectedAge = null;
        }
        
      });
    });
  }

  _modifyProfile(User user, ResultCallBack callback) {
    setState(() {
      _loading = true;
    });
    UserAPI.editProfile(user).then((response) {
      if (response.code !=WrapCode.Ok) {
           final SnackBar snackbar = SnackBar(
          content: Text(response.msg),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        );
        _scaffoldState.currentState.showSnackBar(snackbar);
      }
      if (mounted) {
        setState(() {
        _loading = false;
        callback(response.code ==WrapCode.Ok);
      });
      }
    });
  }
}
