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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String pageTag = 'home_feed';
  ScrollController _scrollController;
  bool _isLoading = false;
  int _page = 1;
  List<Feed> feedList = List();

  @override
  void initState() {
    super.initState();
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
        body: new Stack(
          children: <Widget>[
            _buildFeeds(context),
            _loader(),
          ],
        ));
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
              refPageTag: pageTag,
              imageTapCallBack: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return new GalleryPage(feedList: feedList, index: pos,refPageTag: pageTag,);
                }));
              },
              likeCallBack: (feed) {
                like(feed);
              },
              reportCallBack: (feed,reportId){
                Action.report(context, feed, reportId, null, null);
              }
              ,);
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 8.0 / 11.3),
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

  CupertinoActionSheet _sheet;

  getSheet(BuildContext context){
    if (_sheet ==null) {
      _sheet = CupertinoActionSheet(
            title: Text('API http domain switch'),
            message: Text('switch api domain only for develop using'),
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            actions: 
          <Widget>[
            CupertinoActionSheetAction(
              child: Text('Company [http://192.168.0.200:8000]'),
              onPressed: (){
                Navigator.pop(context);
              }),
            CupertinoActionSheetAction(
              child: Text('Home [http://192.168.3.5:8000]'),
              onPressed: (){
                Navigator.pop(context);
              }),
          ]);
    }
    return _sheet;
  }

  _baseUrlChange(BuildContext context) {
    if (Util.buildMode() ==BuildMode.debug) {
      Util.listenMotionShake((result){
        if (result && _sheet ==null) {
          showCupertinoModalPopup(
            context: context,
            builder:(BuildContext context) => getSheet(context)
          ).then((value){
            HttpManager.sharedInstance().then((manager){
              manager.resetBaseUrl(value);
            });
            _sheet =null;
          });
          
        }
      });
    }
  }
}
