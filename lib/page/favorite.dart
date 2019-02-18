import 'package:flutter/material.dart';
import 'package:Rainbow/view/card.dart';
import 'package:Rainbow/page/gallery.dart';
import 'package:Rainbow/api/user_api.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/supplemental/action.dart';
import 'package:Rainbow/supplemental/animatable_list.dart';

class FavoritePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoritePageState();
  }
}

class _FavoritePageState extends State<FavoritePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ScrollController _scrollController;
  bool _isLoading = false;
  int _page = 1;
  AnimatableList<Feed> feedList;

  @override
  void initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    feedList = AnimatableList<Feed>(
      listKey: _listKey,
      removedItemBuilder: _buildRemovedItem,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: Stack(
        children: <Widget>[_buildFeeds(context), _loader()],
      ),
    );
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
    UserAPI.likes(_page, 10).then((response) {
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

  Widget _buildRemovedItem(
      int pos, BuildContext context, Animation<double> animation) {
    return FeedCard(
      feed: feedList[pos],
    );
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return FeedCard(
        feed: feedList[index],
        animation: animation,
        imageTapCallBack: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new GalleryPage(feedList: feedList.unwrapList(), index: index);
          }));
        },
        likeCallBack: (feed) {
          like(feed);
        });
  }

  _buildFeeds(BuildContext context) {
    if (feedList == null || feedList.length == 0) {
      return SizedBox();
    } else {
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedList(
          initialItemCount: 0,
          controller: _scrollController,
          key: _listKey,
          itemBuilder: _buildItem,
        ),
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
            alignment: feedList.length == 0
                ? FractionalOffset.center
                : FractionalOffset.bottomCenter,
          )
        : new SizedBox(
            width: 0.0,
            height: 0.0,
          );
  }

  void like(Feed feed) {
    Action.like(context, feed, () {
      setState(() {
        feedList.remove(feed);
      });
    }, () {});
  }
}
