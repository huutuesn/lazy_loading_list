import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _controller = ScrollController();

  bool _isLoading = false;
  List<String> _dummy = List.generate(90, (index) => 'Item $index');
  List<String> _listAllCurrentItems =
      List.generate(9, (index) => 'Item ${index}');
  int itemsPerScreen = 3;
  int i = 0;
  int _lastId = 9;
  int _firstId = 0;
  @override
  void initState() {
    _controller.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _onScroll() {
    double scrollOffset = _controller.position.pixels;
    double viewportHeight = _controller.position.viewportDimension;
    double scrollRange = _controller.position.maxScrollExtent -
        _controller.position.minScrollExtent;

    // print(
    //     'off1 ${_controller.offset} scrollOffset ${scrollOffset} viewportHeight ${viewportHeight} scrollRange ${scrollRange} maxExtent ${_controller.position.maxScrollExtent} minExtent ${_controller.position.minScrollExtent}');
    int firstVisibleItemIndex =
        ((scrollOffset) / (scrollRange + viewportHeight) * _dummy.length)
            .floor();

    // print('firstVisibleItemIndex $firstVisibleItemIndex');

    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        print('loading...... offset ${_controller.offset}');
        _isLoading = true;
      });
      _fetchData();
    }

    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      if (_firstId > 0) {
        print('need reload back');
        setState(() {
          print('loading...... offset ${_controller.offset}');
          _isLoading = true;
        });
        _fetchData(next: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('lazy list'),
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: _isLoading
            ? _listAllCurrentItems.length + 1
            : _listAllCurrentItems.length,
        itemBuilder: (context, index) {
          //print('index $index');
          if (_listAllCurrentItems.length == index) {
            // print('waiting');
            return Center(child: CircularProgressIndicator());
          }
          return //ListTile(title: Text(_dummy[index]));
              Container(
            height: _controller.position.viewportDimension / itemsPerScreen,
            color: index % 2 == 0 ? Colors.yellow : Colors.red,
            child: Center(child: Text(_listAllCurrentItems[index])),
          );
        },
      ),
    );
  }

  Future _fetchData({bool next = true}) async {
    await new Future.delayed(new Duration(seconds: 1));

    setState(() {
      // _dummy.addAll(
      //     List.generate(15, (index) => "New Item ${lastIndex + index}"));
      if (next) {
        List<String> nextBatch =
            List.generate(3, (index) => "New Item ${_lastId + index}");
        print('next batch after remove $nextBatch');

        _listAllCurrentItems.removeRange(0, 3);
        print('new page after remove $_listAllCurrentItems');
        _listAllCurrentItems = _listAllCurrentItems + nextBatch;
        print('new page $_listAllCurrentItems');
        _lastId = _lastId + 3 - 1;
        _firstId = _lastId - _listAllCurrentItems.length + 1;
        print('first $_firstId last $_lastId');
      } else {
        List<String> nextBatch =
            List.generate(3, (index) => "New Item ${_firstId - (3 - index)}");

        print('next batch after remove $nextBatch');

        _listAllCurrentItems.removeRange(
            _listAllCurrentItems.length - 3, _listAllCurrentItems.length);
        print('new page after remove $_listAllCurrentItems');

        _listAllCurrentItems = nextBatch + _listAllCurrentItems;
        print('new page $_listAllCurrentItems');

        _lastId = _lastId - 3;
        _firstId = _lastId - _listAllCurrentItems.length + 1;
        print('first $_firstId last $_lastId');
      }
      _isLoading = false;
    });
  }
}
