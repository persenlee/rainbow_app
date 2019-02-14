import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'model/feed.dart';
import 'dart:math';

class GalleryPage extends StatefulWidget {
final List<Feed> feedList;
final int index ;
const GalleryPage({Key key,this.feedList,this.index}) : super(key:key);
@override
  State<StatefulWidget> createState() {
    return _GalleryPageState(feedList,index);
  }
}

class _GalleryPageState extends State<GalleryPage> {
  List<Feed> feedList = List();
  int index;
  PageController _pageController = PageController();
  _GalleryPageState(feedList,index){
    this.feedList = feedList;
    this.index = index;
    _pageController = PageController(
      initialPage:  min(max(index,0),feedList.length),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoViewGallery(
        pageOptions: _buidGalleryPageOptions(context),
        pageController: _pageController,
        backgroundDecoration: BoxDecoration(color: Colors.black87),
        transitionOnUserGestures: true,
      ),
    );
  }

  List<PhotoViewGalleryPageOptions> _buidGalleryPageOptions(BuildContext context){
    return feedList.map((feed){
      return PhotoViewGalleryPageOptions(
        imageProvider: NetworkImage(feed.src),
        heroTag: feed.id.toString(),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 3
      );
    }).toList();
  }
}