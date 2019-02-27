import 'package:flutter/material.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/supplemental/config_storage.dart';
import 'package:Rainbow/supplemental/util.dart';

typedef FeedCardLikeCallBack = void Function(Feed feed);
typedef FeedCardReportCallBack = void Function(Feed feed, int reportId);
typedef FeedCardShareCallBack = void Function(Feed feed);

class FeedToolBar extends StatefulWidget {
  final Feed feed;
  final FeedCardLikeCallBack likeCallBack;
  final FeedCardReportCallBack reportCallBack;
  final FeedCardShareCallBack shareCallBack;
  final Color color;
  const FeedToolBar(
      {Key key,
      this.feed,
      this.color,
      this.likeCallBack,
      this.reportCallBack,
      this.shareCallBack})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FeedToolBarState();
  }
}

class _FeedToolBarState extends State<FeedToolBar> {
  Feed feed;
  ConfigStorage storage;
  @override
  void initState() {
    super.initState();
    feed = widget.feed;
    _getReports();
  }

  @override
  Widget build(BuildContext context) {
    feed = widget.feed;
    return ButtonTheme(
      minWidth: 36,
      buttonColor: widget.color,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
            padding: EdgeInsets.zero,
            label: Text(
              feed == null ? '0' : feed.likeCount.toString(),
              style: TextStyle(
                color: widget.color
              ),
              overflow: TextOverflow.ellipsis,
              
            ),
            icon: Icon(
              feed != null && feed.like
                  ? Icons.favorite
                  : Icons.favorite_border,
              semanticLabel: 'like',
              color: widget.color,
            ),
            onPressed: () {
              widget.likeCallBack(feed);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              semanticLabel: 'share',
              color: widget.color,
            ),
            onPressed: () {
              if (widget.shareCallBack !=null) {
                widget.shareCallBack(feed);
              } else {
                Util.share('Share Rainbow Image', feed.src, feed.thumbSrc);
              }
            },
          ),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.report,
              semanticLabel: 'report',
              color: widget.color,
            ),
            itemBuilder: _reportsItemBuilder,
            onSelected: (reportId) {
              widget.reportCallBack(feed, reportId);
            },
          ),
        ],
      ),
    );
  }

  _getReports() async {
    storage = await ConfigStorage.getInstance();
  }

  List<PopupMenuEntry<dynamic>> _reportsItemBuilder(BuildContext context) {
    if (storage.reports() == null) {
      return null;
    }
    return storage.reports().map((Report report) {
      return PopupMenuItem(
        value: report.id,
        child: Text(report.reason),
      );
    }).toList();
  }
}
