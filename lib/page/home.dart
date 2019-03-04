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
import 'gallery.dart';
import 'package:Rainbow/supplemental/action.dart';
import 'package:Rainbow/view/card.dart';
import 'home_drawer.dart';
import 'package:Rainbow/supplemental/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:Rainbow/api/http_manager.dart';
import 'package:Rainbow/supplemental/config_storage.dart';
import 'package:Rainbow/supplemental/user_storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final String pageTag = 'home_feed';
  ScrollController _scrollController;
  bool _isLoading = false;
  bool _bottomRefresh =false;
  int _page = 1;
  List<Feed> feedList = List();

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    _baseUrlChange(context);
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
        drawer: HomeDrawerPage(),
        body: 
        RefreshIndicator(
          key: _refreshIndicatorKey,
          child: _buildFeeds(context),
          onRefresh: _handlePaginator,
        )
        );
  }

  Future<Null> _handlePaginator() async{
    //prefresh or paginator
    if (_isLoading) {
      return null;
    }
    _isLoading = true;
    _page =_bottomRefresh ? _page : 1;
    var response = await FeedAPI.getFeeds(_page, 10);
    _isLoading = false;
    List<Feed> feeds = response.result;
      if (feeds != null && feeds.length > 0) {
        if (this.mounted) {
          setState(() {
          if (_page == 1) {
            feedList.clear();
          }
          feedList.addAll(feeds);
          _page++;
        });
        }
      } 
      return null;
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
          _bottomRefresh =true;
          _refreshIndicatorKey.currentState.show(atTop:false);
    } else {
        _bottomRefresh = false;
    }
  }


  _fetchData() {
    setState(() {
    _isLoading =true;
    });
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
      return _isLoading ? 
      Center(child: CircularProgressIndicator()) 
      : 
       Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('No Feed Data Yet'),
                SizedBox(
                  height: 12,
                ),
                FlatButton(
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child: Text('Retry'),
                    onPressed: () {
                      _fetchData();
                    })
              ],
            ));
    } else {
      return GridView.builder(
        padding: EdgeInsets.all(16.0),
        controller: _scrollController,
        itemCount: feedList.length,
        itemBuilder: (BuildContext context, int pos) {
          return FeedCard(
            feed: feedList[pos],
            refPageTag: pageTag,
            imageTapCallBack: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new GalleryPage(
                  feedList: feedList,
                  index: pos,
                  refPageTag: pageTag,
                );
              },fullscreenDialog: false));
            },
            likeCallBack: (feed) {
              like(feed);
            },
            reportCallBack: (feed, reportId) {
              Action.report(context, feed, reportId, null, null);
            },
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 8.0 / 9.3),
      );
    }
  }

  void like(Feed feed) {
    Action.like(context, feed, () {
      setState(() {});
    }, () {});
  }

  _loadConfig() async{
    ConfigStorage storage = await ConfigStorage.getInstance();
    storage.loadFromNetwork();
  }

  CupertinoActionSheet _sheet;

  getSheet(BuildContext context) {
    if (_sheet == null) {
      _sheet = CupertinoActionSheet(
          title: Text('API http domain switch'),
          message: Text('switch api domain only for develop using'),
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
                child: Text('Company[Local]'),
                onPressed: () {
                  Navigator.pop(context, BaseUrlMode.Local_Company);
                }),
            CupertinoActionSheetAction(
                child: Text('Home[Local]'),
                onPressed: () {
                  Navigator.pop(context, BaseUrlMode.Local_Home);
                }),
            CupertinoActionSheetAction(
                child: Text('Test[Remote]'),
                onPressed: () {
                  Navigator.pop(context, BaseUrlMode.Test);
                }),
          ]);
    }
    return _sheet;
  }

  _baseUrlChange(BuildContext context) {
    if (Util.buildMode() == BuildMode.debug) {
      Util.listenMotionShake((result) {
        if (result && _sheet == null) {
          showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => getSheet(context))
              .then((value) {
            if (value != null) {

              UserStorage.getInstance().deleteUser();
              HttpManager.sharedInstance().then((manager) {
                manager.resetUrlMode(value);
              });
            }
            _sheet = null;
          });
        }
      });
    }
  }
}
