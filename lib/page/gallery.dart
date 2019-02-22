import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:Rainbow/model/feed.dart';
import 'dart:math';
import 'package:Rainbow/supplemental/action.dart';
import 'package:Rainbow/view/feed_toolbar.dart';

class GalleryPage extends StatefulWidget {
  final List<Feed> feedList;
  final int index;
  final String refPageTag;
  const GalleryPage({Key key, this.feedList, this.index, this.refPageTag}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _GalleryPageState();
  }
}

class _GalleryPageState extends State<GalleryPage> {
  Feed currentFeed;
  PageController _pageController = PageController();
  @override
  void initState() {
    _pageController = PageController(
      initialPage: min(max(widget.index, 0), widget.feedList.length),
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PhotoViewGallery(
            pageOptions: _buidGalleryPageOptions(context),
            pageController: _pageController,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            transitionOnUserGestures: true,
            onPageChanged: (page) {
              setState(() {
                this.currentFeed = widget.feedList[page];
              });
            },
          ),
          Positioned(
            left: 24,
            top: 36,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.white,
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 36,
            height: 48,
            child: FeedToolBar(
              feed: this.currentFeed,
              color: Colors.white,
              likeCallBack: (feed){
                like(feed);
              },
            ),
          )
        ],
      ),
    );
  }

  List<PhotoViewGalleryPageOptions> _buidGalleryPageOptions(
      BuildContext context) {
    return widget.feedList.map((feed) {
      return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(feed.src),
          heroTag:  widget.refPageTag + feed.id.toString(),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 3);
    }).toList();
  }

  void like(Feed feed) {
    Action.like(context, feed, (){
      setState(() { 
            });
    }, (){

    });
  }
}
