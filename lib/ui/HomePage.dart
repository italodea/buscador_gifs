import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'  as http;


class HomePage extends StatefulWidget {
  

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offset = 0;
  
  Future<Map> _getGifs() async{
    http.Response response;

    if(_search == null){
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=djQ3MZ4rQBr8FElPV0rVR6lOtJO1Jeea&limit=20&rating=G");

    }else{
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=djQ3MZ4rQBr8FElPV0rVR6lOtJO1Jeea&q=$_search&limit=20&offset=$_offset&rating=G&lang=en");
    }

    return json.decode(response.body);
  }
  
  @override
  void initState(){
    super.initState();
    _getGifs().then((map){
      print(map);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.white
            ),
            child: TextField(
              onSubmitted: (text){
                setState(() {
                  _search = text;
                });
              },
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                
                hintText: "Pesquise um gif",
                hintStyle: TextStyle(
                  color: Colors.grey[700]
                )

              ),
              
            ),  
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      )
                    );
                  default:
                    if (snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                }
              }
            )
          ),
          
        ],
      ),

    );
  }
}

Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
  return GridView.builder(
    padding: EdgeInsets.all(10.0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10
    ),
    itemCount: snapshot.data["data"].length, 
    itemBuilder: (context,index){
      return GestureDetector(
        child: Image.network(
          snapshot.data["data"][index]["images"]["fixed_height_small"]["url"],
          fit: BoxFit.cover,
          height: 300,
          ),
      );
    }
  );
}