import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if(_search == null || _search .isEmpty)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=f2hHggLWSZqWGvwIpmztoaCh0juXg3hr&limit=19&rating=G");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=f2hHggLWSZqWGvwIpmztoaCh0juXg3hr&q=${_search}&limit=19&offset=${_offset}&rating=G&lang=en");

    return json.decode(response.body);
  }

  int _getCount(List data){
    if(_search == null || _search .isEmpty)
      return data.length;
    else
      return data.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(
                  color: Colors.white,),
                border: OutlineInputBorder(),
                ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            )
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                    break;
                  default:
                    if(snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                }
              }
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map){
      print(map);
    });
  }

  Widget _createGifTable(BuildContext c, AsyncSnapshot s){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0
      ),
      itemCount: _getCount(s.data['data']),
      itemBuilder: (context, index){
        if(_search == null || _search .isEmpty || index < s.data['data'].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              image: s.data['data'][index]['images']['fixed_height']['url'],
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: kTransparentImage,
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(s.data['data'][index])
                )
              );
            },
            onLongPress: (){
              Share.share(s.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0
                    ),
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
    );
  }
}
