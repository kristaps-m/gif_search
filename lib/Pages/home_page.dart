import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'gif_page.dart';
import '/utils/delay.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  String _key = '_enter_your_api_key_here_';
  String _search = '';
  int _offset = 0;
  int _limit = 20;
  // 1 second = 1000 milliseconds
  int _liveSearchRequestMilliseconds  = 5000;

  int GetCount(List data) {
    if (_search == null || _search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Future<Map> GetGifs() async {
    http.Response response;
    // results will appear after _liveSearchRequestMilliseconds
    await delay(_liveSearchRequestMilliseconds);
    if (_search == null) {

      response = await http.get(
          Uri.parse('https://api.giphy.com/v1/gifs/trending?api_key=$_key&$_limit&rating=G'));
    } else {
      response = await http.get(
          Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=$_key&q=$_search&$_limit&offset=$_offset&rating=G&lang=en')          );
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
            'Search Giphy gifs APP!',)//Image.network('https://picsum.photos/id/180/200/200'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent, width: 3.0),
                  ),
                  labelText: 'Search here!',
                  labelStyle: TextStyle(color: Colors.amber),
                ),
                style: TextStyle(color: Colors.white, fontSize: 20.0),
                textAlign: TextAlign.center,
                onSubmitted: (submittedText){
                  setState(() {
                    _search = submittedText;
                  });
                },
              )
          ),
          Expanded(
              child: FutureBuilder(
                  future: GetGifs(),
                  builder: (context, snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if(snapshot.hasError)
                          return Container();
                        else
                          return CreateGifTable(context, snapshot);
                    }
                  },
              ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget CreateGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: GetCount(snapshot.data['data']),
      // Creates a scrollable, 2D array of widgets that are created on demand.
      itemBuilder: (context, index){
        if (_search == null || index < snapshot.data['data'].length){
          //Creates a widget that detects gestures
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
              ['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data['data'][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        }else {
          return Container(
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    'Load more...',
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
        }
      },
    );
  }
}