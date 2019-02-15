// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:Rainbow/api/feed_api.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/model/user.dart';
import 'dart:io';
import 'package:Rainbow/supplemental/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'gallery.dart';
import 'package:Rainbow/supplemental/action.dart';
import 'package:Rainbow/view/card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController;
  bool _isLoading = false;
  int _page = 1;
  List<Feed> feedList = List();
  User _user = User();
  FileImage _localAvatar;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
    UserStorage.getInstance().readUser().then((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rainbow'),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(
            //     Icons.search,
            //     semanticLabel: 'search',
            //   ),
            //   onPressed: () {
            //     print('Search button');
            //   },
            // ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: new Stack(
          children: <Widget>[
            _buildFeeds(context),
            _loader(),
          ],
        ));
  }

  _buildDrawer(BuildContext context) {
    final backgroundColor = Colors.lightBlue; // Color.fromARGB(1, 7, 71, 199);
    return Drawer(
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Container(
            color: backgroundColor,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 24,
                ),
                UserAccountsDrawerHeader(
                  accountName: Text(
                    _user.name == null ? 'acd' : _user.name,
                    style: TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text(
                    _user.email == null ? 'a@b.com' : _user.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  currentAccountPicture: new GestureDetector(
                      onTap: () {
                        _changeAvatar(context);
                      },
                      child: ClipOval(
                        child: FadeInImage(
                          width: 100,
                          height: 100,
                          fit: BoxFit.fitWidth,
                          placeholder: AssetImage('assets/default-avatar.png'),
                          image: _localAvatar != null
                              ? _localAvatar
                              : NetworkImage(
                                  _user.avatar == null ? '' : _user.avatar),
                        ),
                      )),
                  decoration: BoxDecoration(color: backgroundColor),
                ),
                ListTile(
                  title: Text(
                    'Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.verified_user,
                    color: Colors.white,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Favorite',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(Icons.favorite, color: Colors.white),
                ),
                Divider(
                  color: Colors.white,
                ),
                ListTile(
                  title: Text(
                    'Setting',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(Icons.settings, color: Colors.white),
                ),
                ListTile(
                  title: Text(
                    'About',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(Icons.info, color: Colors.white),
                ),
                SizedBox(
                  height: 46,
                ),
                Container(
                  width: 46,
                  height: 32,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: _buidLoginButton(context),
                )
              ],
            ),
          )),
    );
  }

//login or logout
  _buidLoginButton(BuildContext context) {
    return _user.id > 0
        ? RaisedButton(
            color: Colors.red[200],
            textColor: Colors.white,
            child: Text('Logout'),
            onPressed: () {
              UserStorage.getInstance().deleteUser().then(() {
                setState(() {
                  _user = User();
                });
              });
            },
          )
        : RaisedButton(
            color: Colors.red[200],
            textColor: Colors.white,
            child: Text('Login'),
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
          );
  }

  _changeAvatar(BuildContext context) {
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
    });
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _startLoader();
    }
  }

  _startLoader() {
    if (false == _isLoading) {
      setState(() {
        _isLoading = true;
        _fetchData();
      });
    }
  }

  _fetchData() {
    FeedAPI.getFeeds(_page, 10).then((response) {
      List<Feed> feeds = response.result;
      if (feeds != null && feeds.length > 0) {
        setState(() {
          feedList.addAll(feeds);
          _page++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  _buildFeeds(BuildContext context) {
    if (feedList == null || feedList.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.all(16.0),
        controller: _scrollController,
        itemCount: feedList.length,
        itemBuilder: (BuildContext context, int pos) {
          return FeedCard(
              feed: feedList[pos],
              imageTapCallBack: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return new GalleryPage(feedList: feedList, index: pos);
                }));
              },
              likeCallBack: (feed) {
                like(feed);
              });
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 8.0 / 10.0),
      );
    }
  }

  Widget _loader() {
    return _isLoading
        ? new Align(
            child: new Container(
              width: 70.0,
              height: 70.0,
              child: new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: new Center(child: new CircularProgressIndicator())),
            ),
            alignment: FractionalOffset.bottomCenter,
          )
        : new SizedBox(
            width: 0.0,
            height: 0.0,
          );
  }

  void like(Feed feed) {
    Action.like(context, feed, () {
      setState(() {});
    }, () {});
  }
}
