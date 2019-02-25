import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:Rainbow/model/feed.dart';
import 'dart:math';
import 'package:Rainbow/supplemental/action.dart';
import 'package:Rainbow/view/feed_toolbar.dart';
import 'package:flutter_tags/selectable_tags.dart' as TagsView;
import 'package:Rainbow/view/tags_dialog.dart';

class GalleryPage extends StatefulWidget {
  final List<Feed> feedList;
  final int index;
  final String refPageTag;
  const GalleryPage({Key key, this.feedList, this.index, this.refPageTag})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _GalleryPageState();
  }
}

class _GalleryPageState extends State<GalleryPage> {
  Feed currentFeed;
  PageController _pageController = PageController();
  List<TagsView.Tag> _tags = List<TagsView.Tag>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: min(max(widget.index, 0), widget.feedList.length),
    );
    currentFeed = widget.feedList[widget.index];
    _upateTags();
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
                _upateTags();
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
              bottom: 100,
              child: TagsView.SelectableTags(
                backgroundContainer: Colors.transparent,
                textColor: Colors.white,
                color: Color.fromARGB(255, 78, 125, 120),
                activeColor: Color.fromARGB(255, 78, 125, 120),
                tags: _tags,
                columns: 3, // default 4
                symmetry: false, // default false
                onPressed: (tag) {
                  if (tag.id == -100) {
                    _addTag(context, tag);
                  }
                },
              )),
          Positioned(
            left: 24,
            right: 24,
            bottom: 36,
            height: 48,
            child: FeedToolBar(
              feed: this.currentFeed,
              color: Colors.white,
              likeCallBack: (feed) {
                like(feed);
              },
            ),
          )
        ],
      ),
    );
  }

  _addTag(BuildContext context, TagsView.Tag tag) {
    showDialog(context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return TagsDialog(feed: this.currentFeed);
    });
  }

 

  _upateTags() {
    TagsView.Tag addTag = TagsView.Tag(
        title: 'add', icon: Icons.add_circle, id: -100, active: true);
    _tags.removeRange(0, _tags.length);
    if (currentFeed.tags == null || currentFeed.tags.length == 0) {
      _tags.add(addTag);
    } else {
      List<TagsView.Tag> tags = currentFeed.tags.map((Tag tag) {
        return TagsView.Tag(title: tag.name, id: tag.id, active: false);
      }).toList();
      tags.add(addTag);
      _tags.addAll(tags);
    }
  }

  List<PhotoViewGalleryPageOptions> _buidGalleryPageOptions(
      BuildContext context) {
    return widget.feedList.map((feed) {
      return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(feed.src),
          heroTag: widget.refPageTag + feed.id.toString(),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 3);
    }).toList();
  }

  void like(Feed feed) {
    Action.like(context, feed, () {
      setState(() {});
    }, () {});
  }
}
