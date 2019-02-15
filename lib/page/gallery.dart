import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:Rainbow/model/feed.dart';
import 'dart:math';
import 'package:Rainbow/supplemental/action.dart';

class GalleryPage extends StatefulWidget {
  final List<Feed> feedList;
  final int index;
  const GalleryPage({Key key, this.feedList, this.index}) : super(key: key);
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PhotoViewGallery(
            pageOptions: _buidGalleryPageOptions(context),
            pageController: _pageController,
            backgroundDecoration: BoxDecoration(color: Colors.black87),
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
            bottom: 24,
            child: IconButton(
              iconSize: 36,
              icon: ((this.currentFeed == null || this.currentFeed.like == false) ?  Icon(Icons.favorite_border) : Icon(Icons.favorite)),
              color: Colors.red,
              onPressed: (){
                like(this.currentFeed);
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
          heroTag: feed.id.toString(),
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
