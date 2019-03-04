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
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final String pageTag = 'favorite_feed';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ScrollController _scrollController;
  bool _isLoading = false;
  int _page = 1;
  bool _bottomRefresh =false;
  AnimatableList<Feed> feedList;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(_scrollListener);
    feedList = AnimatableList<Feed>(
      listKey: _listKey,
      removedItemBuilder: _buildRemovedItem,
    );
    _fetchData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        child: _buildFeeds(context),
        onRefresh: _handlePaginator,
      ),
    );
  }


  Future<Null> _handlePaginator() async{
    //prefresh or paginator
    _isLoading = true;
    _page =_bottomRefresh ? _page : 1;
    var response = await UserAPI.likes(_page, 10);
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

  Widget _buildRemovedItem(Feed item, BuildContext context, Animation<double> animation) {
    return FeedCard(
      feed: item,
      animation: animation,
    );
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: FeedCard(
        feed: feedList[index],
        animation: animation,
        refPageTag: pageTag,
        imageTapCallBack: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new GalleryPage(feedList: feedList.unwrapList(), index: index, refPageTag: pageTag,);
          }));
        },
        likeCallBack: (feed) {
          like(feed);
        }),
    );
  }

  _buildFeeds(BuildContext context) {
    if (feedList == null || feedList.length == 0) {
      return _isLoading ? 
      Center(child: CircularProgressIndicator()) 
      : 
       Center(
         child:
         Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
            Text('No Favorite Data Yet'),
            SizedBox(height: 12,),
            FlatButton(
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: Text('Retry'),
          onPressed: (){
            _fetchData();
          }
         )
         ],)
        );
    } else {
      return  AnimatedList(
          initialItemCount: feedList.length,
          controller: _scrollController,
          key: _listKey,
          itemBuilder: _buildItem,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
    }
  }

  void like(Feed feed) {
    Action.like(context, feed, () {
      setState(() {
        feedList.remove(feed);
      });
    }, () {});
  }
}
