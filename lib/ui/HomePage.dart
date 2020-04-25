import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'  as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'GifPage.dart';


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
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=djQ3MZ4rQBr8FElPV0rVR6lOtJO1Jeea&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
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
                  _offset = 0;
                });
              },
              onChanged: (text){
                if (text == ""){
                  setState(() {
                    _search = null;
                    _offset = 0;
                  });
                }
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

int _getCount(List data){
    if (_search == null){
    return data.length;
  }else{
    return data.length + 1;
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
    itemCount: _getCount(snapshot.data["data"]), 
    itemBuilder: (context,index){
      if(_search == null || index < snapshot.data["data"].length){
        return GestureDetector(
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage, 
            image: snapshot.data["data"][index]["images"]["fixed_height_small"]["url"],
            height: 300.0,
            fit: BoxFit.cover,
          ),
          onTap: (){
            Navigator.push(context, 
              MaterialPageRoute(builder: (context)=>GifPage(snapshot.data["data"][index]))
            );
          },
          onLongPress: (){
            Share.share("Veja este gif que legal. \n "+snapshot.data["data"][index]["images"]["fixed_height_small"]["url"]);
          },
        );
      }else{
        return Container(
          padding: EdgeInsets.only(top:40),
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                Icon(Icons.add, color: Colors.white, size: 70,),
                Text("Carregar mais...",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
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
      
    }
  );
}
}