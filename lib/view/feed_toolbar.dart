import 'package:flutter/material.dart';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/supplemental/config_storage.dart';

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
  List<Report> reports;
  @override
  void initState() {
    feed = widget.feed;
    _getReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
              widget.shareCallBack(feed);
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
    ConfigStorage storage = await ConfigStorage.getInstance();
    setState(() {
      reports = storage.reports();
    });
  }

  List<PopupMenuEntry<dynamic>> _reportsItemBuilder(BuildContext context) {
    if (reports == null) {
      return null;
    }
    return reports.map((Report report) {
      return PopupMenuItem(
        value: report.id,
        child: Text(report.reason),
      );
    }).toList();
  }
}
