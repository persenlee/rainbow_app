import 'package:flutter/material.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Rainbow/supplemental/network_image_cache_manager.dart';
import 'package:Rainbow/supplemental/config_storage.dart';

typedef FeedCardLikeCallBack = void Function(Feed feed);
typedef FeedCardImageTapCallBack = void Function();
typedef FeedCardReportCallBack = void Function(Feed feed,int reportId);

class FeedCard extends StatefulWidget {
  final Feed feed;
  final FeedCardLikeCallBack likeCallBack;
  final FeedCardImageTapCallBack imageTapCallBack;
  final FeedCardReportCallBack reportCallBack;
  final Animation<double> animation;
  final String refPageTag;

  const FeedCard(
      {Key key,
      this.feed,
      this.animation,
      this.refPageTag,
      this.imageTapCallBack,
      this.likeCallBack,
      this.reportCallBack})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FeedCardState();
  }
}

class _FeedCardState extends State<FeedCard> {
  Feed feed;
  List<Report> reports;
  @override
  void initState() {
    feed = widget.feed;
    ConfigStorage.getInstance().then((ConfigStorage storage) {
      setState(() {
        reports = storage.reports();
      });
    });
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
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
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
                    height: 6.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FlatButton.icon(
                      padding: EdgeInsets.zero,
                      label: Text(
                        feed.likeCount == null
                            ? '0'
                            : feed.likeCount.toString(),
                        style: theme.textTheme.body2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Icon(
                        feed.like != null && feed.like
                            ? Icons.favorite
                            : Icons.favorite_border,
                        semanticLabel: 'like',
                      ),
                      onPressed: () {
                        widget.likeCallBack(feed);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.report,
                        semanticLabel: 'report',
                      ),
                      itemBuilder: _reportsItemBuilder,
                      onSelected: (reportId){
                        widget.reportCallBack(feed,reportId);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<dynamic>> _reportsItemBuilder(BuildContext context) {
    return reports.map((Report report) {
      return PopupMenuItem(
        value: report.id,
        child: Text(report.reason),
      );
    }).toList();
  }
}
