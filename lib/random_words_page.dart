import 'dart:async';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class RandomWords extends StatefulWidget {
  final String title;

  RandomWords({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new RandomWordsState();
  }
}

class RandomWordsState extends State<RandomWords> {
  final _items = <WordPair>[];
  final _saved = new Set<WordPair>();
  bool isLoading = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _items.addAll(generateWordPairs().take(15));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: new RefreshIndicator(
          onRefresh: _handleRefresh,
          child: new ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return _buildLoadText();
                } else {
                  final wordPair = _items[index];
                  final alreadySaved = _saved.contains(wordPair);
                  return ListTile(
                    title: new Text(
                      wordPair.asPascalCase,
                    ),
                    trailing: new Icon(
                      alreadySaved ? Icons.favorite : Icons.favorite_border,
                      color: alreadySaved ? Colors.red : null,
                    ),
                    onTap: () {
                      setState(() {
                        if (alreadySaved) {
                          _saved.remove(wordPair);
                        } else {
                          _saved.add(wordPair);
                        }
                      });
                    },
                  );
                }
              }),
        ));
  }

  Future<Null> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _items.clear();
        _items.addAll(generateWordPairs().take(15));
        return null;
      });
    });
  }

  Future _getMoreData() async {
    if (!isLoading) {
      setState(() => isLoading = true);
      final Iterable<WordPair> newItems = await mokeHttpRequest(5);
      setState(() {
        _items.addAll(newItems);
        isLoading = false;
      });
    }
  }

  Future<Iterable<WordPair>> mokeHttpRequest(int count) async {
    return Future.delayed(Duration(seconds: 2), () {
      return generateWordPairs().take(count);
    });
  }

  Widget _buildLoadText() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Text("加载中……"),
        ),
      ),
      color: Colors.white70,
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
