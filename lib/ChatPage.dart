import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }
  List<Color> _rgb = [Color(0xffc17668), Color(0xffe7a05d), Color(0xffeed159), Color(0xff9ce991), Color(0xff939fc7), Color(0xffa06bbf)];
  List<double> _rgbstops = [0.0, 0.16, 0.32, 0.48, 0.64, 0.80];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Color(0x00000000),
        elevation: 0.0,
        title: (isConnecting
            ? Text('Connecting to ' + widget.server.name + '...')
            : isConnected
                ? Text('Connected To ' + widget.server.name)
                : Text('Disconnected from ' + widget.server.name)),

        leading: IconButton(icon:Icon(Icons.keyboard_arrow_left, size: 30,),
          onPressed:() => Navigator.pop(context, false),
        ),
      ),
      body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20,left: 10),
              child: Text("Effects", style: TextStyle(fontSize: 50),),
            ),  
            Card(
              shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(const Radius.circular(35)),
                  ),
                  child: ExpansionTile(   
                   
                    title: Text('Rainbow', style: TextStyle(fontSize: 20),),

                      children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.all(const Radius.circular(20)),
                          gradient: LinearGradient(
                            colors: _rgb,
                            stops: _rgbstops,
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top:20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                            shape: StadiumBorder(),
                            child: Text("Circle"),
                            onPressed: isConnected
                              ? () => _sendMessage("1"  )
                              : null
                          ),
                          RaisedButton(
                            shape: StadiumBorder(),
                            child: Text("Symmetric"),
                            onPressed: isConnected
                              ? () => _sendMessage("0")
                              : null
                          ),
                          RaisedButton(
                            shape: StadiumBorder(),
                            child: Text("Fade"),
                            onPressed: isConnected
                              ? () => _sendMessage("3")
                              : null
                          ),
                          RaisedButton(
                            shape: StadiumBorder(),
                            child: Text("Rain"),
                            onPressed: isConnected
                              ? () => _sendMessage("2")
                              : null
                          ),
                        ],
                      ),
                      
                      Padding(padding: EdgeInsets.only(top:20),),
                    ],
                  ),
            ),
//////////////////////////////////////////////////////////////////////////////////////
            Card(
              shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(const Radius.circular(35)),
                  ),
                  child: ExpansionTile(   
                   
                    title: Text('Single Color', style: TextStyle(fontSize: 20),),

                      children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.all(const Radius.circular(20)),
                          color: Color(0xff9ce991),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top:20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          
                        ],
                      ),
                      
                      Padding(padding: EdgeInsets.only(top:20),),
             
                    ],

                  ),
            ),  

            Card(
              shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(const Radius.circular(35)),
                  ),
                  child: ExpansionTile(   
                   
                    title: Text('Gradient', style: TextStyle(fontSize: 20),),

                      children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.all(const Radius.circular(20)),
                          color: Color(0xff9ce991),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top:20),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                            shape: StadiumBorder(),
                            child: Text("Update"),
                            onPressed: isConnected
                              ? () => _sendMessage("005")
                              : null
                          ),
                        ],
                      ),
                      
                      Padding(padding: EdgeInsets.only(top:20),),
             
                    ],

                  ),
            ),  
          ],
        ),
      
      
    );
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
