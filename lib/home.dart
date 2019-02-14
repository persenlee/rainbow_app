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
import './api/base_api.dart';
import './api/feed_api.dart';
import 'model/feed.dart';
import 'model/user.dart';
import 'dart:math' show max;
import 'dart:io';
import 'package:Shrine/supplemental/user_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'gallery.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController;
  bool _isLoading = false;
  int _page = 1;
  List<Feed> feedList = List();
  User _user;
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
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_user.userName),
              accountEmail: Text(_user.email),
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
                            : NetworkImage(_user.avatar),
                      ),
                  )
                  // CircleAvatar(
                  //   backgroundImage: NetworkImage(_user.avatar),
                  // ),
                  ),
              decoration: BoxDecoration(color: Colors.lightBlue),
            ),
            ListTile(
              title: Text('i like'),
              trailing: Icon(Icons.favorite, color: Colors.redAccent),
            )
          ],
        ),
      ),
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

  _cropImage(File imageFile){
    ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 256,
      maxHeight: 256,
      circleShape: true
    ).then((croppedImageFile){
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
      return GridView.count(
          controller: _scrollController,
          crossAxisCount: 2,
          padding: EdgeInsets.all(16.0),
          childAspectRatio: 8.0 / 9.0,
          children: _buildGridCards(context));
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

  List<Card> _buildGridCards(BuildContext context) {
    if (feedList == null) {
      return const <Card>[];
    }
    final ThemeData theme = Theme.of(context);
    return feedList.map((feed) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: GestureDetector(
                child: Hero(
                  child: Image.network(feed.thumbSrc),
                  tag: feed.id.toString(),
                  transitionOnUserGestures: true,
                ),
                onTap: (){
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new GalleryPage(feedList:feedList,index:feedList.indexOf(feed));
                  }));
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      feed.title,
                      style: theme.textTheme.subtitle,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            feed.like ? Icons.favorite : Icons.favorite_border,
                            semanticLabel: 'like',
                          ),
                          onPressed: () {
                            like(feed);
                          },
                        ),
                        Text(
                          feed.likeCount == null
                              ? '0'
                              : feed.likeCount.toString(),
                          style: theme.textTheme.body2,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void like(Feed feed) {
    UserStorage.getInstance().readUser().then((user) {
      if (user != null && user.id > 0) {
        FeedAPI.like(feed.id, !feed.like).then((response) {
          if (response.code == WrapCode.Ok) {
            setState(() {
              feed.like = !feed.like;
              int count = (feed.like ? feed.likeCount + 1 : feed.likeCount - 1);
              feed.likeCount = max(count, 0);
            });
          }
        });
      } else {
        Navigator.of(context).pushNamed('/login');
      }
    });
  }
}
