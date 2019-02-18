import 'package:flutter/material.dart';
import 'package:Rainbow/model/feed.dart';

typedef FeedCardLikeCallBack = void Function(Feed feed);
typedef FeedCardImageTapCallBack = void Function();

class FeedCard extends StatefulWidget {
  final Feed feed;
  final FeedCardLikeCallBack likeCallBack;
  final FeedCardImageTapCallBack imageTapCallBack;
  final Animation<double> animation;

  const FeedCard({Key key,this.feed,this.animation,this.imageTapCallBack,this.likeCallBack}): super(key:key);
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
    return widget.animation !=null ? 
      SizeTransition(
        sizeFactor: widget.animation,
        child: _getCard(context)
      ) 
      :
      _getCard(context);
  }
  _getCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: GestureDetector(
                child: Hero(
                  child: Image.network(feed.thumbSrc),
                  tag:  feed.id.toString(),
                  transitionOnUserGestures: true,
                ),
                onTap: () {
                  widget.imageTapCallBack();
                },
              ),
            ),
            //Expanded can not set in listview
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: 
                Column(
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
                    Row(
                      children: <Widget>[
                        IconButton(
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
                        Text(
                          feed.likeCount == null
                              ? '0'
                              : feed.likeCount.toString(),
                          style: theme.textTheme.body2,
                        )
                      ],
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