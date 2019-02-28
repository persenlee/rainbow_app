import 'package:flutter/material.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rainbow/supplemental/network_image_cache_manager.dart';
import 'feed_toolbar.dart';
import 'package:Rainbow/supplemental/window_adapt.dart';

typedef FeedCardImageTapCallBack = void Function();

class FeedCard extends StatefulWidget {
  final Feed feed;
  final FeedCardImageTapCallBack imageTapCallBack;
  final FeedCardLikeCallBack likeCallBack;
  final FeedCardReportCallBack reportCallBack;
  final FeedCardShareCallBack shareCallBack;

  final Animation<double> animation;
  final String refPageTag;

  const FeedCard(
      {Key key,
      this.feed,
      this.animation,
      this.refPageTag,
      this.imageTapCallBack,
      this.likeCallBack,
      this.reportCallBack,
      this.shareCallBack})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FeedCardState();
  }
}

class _FeedCardState extends State<FeedCard> {
  Feed feed;
  @override
  void initState() {
    feed = widget.feed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.animation != null
        ?
        // SizeTransition(
        //   sizeFactor: widget.animation,
        //   child: _getCard(context)
        // )
        ScaleTransition(
            child: _getCard(context),
            scale: widget.animation,
          )
        : _getCard(context);
  }

  _getCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18 / 11,
            child: GestureDetector(
              child: Hero(
                child: CachedNetworkImage(
                  imageUrl: feed.thumbSrc,
                  cacheManager: NetworkImageCacheManager(),
                ),
                tag: widget.refPageTag + feed.id.toString(),
                transitionOnUserGestures: true,
              ),
              onTap: () {
                widget.imageTapCallBack();
              },
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: EdgeInsets.fromLTRB(WindowAdapt.px(12),
                  WindowAdapt.px(12), WindowAdapt.px(12), WindowAdapt.px(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    feed.title,
                    style: theme.textTheme.subtitle,
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: WindowAdapt.px(8),
                  ),
                  FeedToolBar(
                    feed: feed,
                    likeCallBack: widget.likeCallBack,
                    shareCallBack: widget.shareCallBack,
                    reportCallBack: widget.reportCallBack,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
