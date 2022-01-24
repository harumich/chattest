import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:untitled/model/message.dart';
import 'package:untitled/model/talk_room.dart';
import 'package:untitled/utils/firebase.dart';

class TalkRoomPage extends StatefulWidget {
  final TalkRoom room;
  TalkRoomPage(this.room);
  @override
  _TalkRoomState createState() => _TalkRoomState();
}

class _TalkRoomState extends State<TalkRoomPage> {
  List<Message> messageList = [];
  TextEditingController controller = TextEditingController();

  Future<void> getMessages() async{
    messageList = await Firestore.getMessages(widget.room.roomId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(widget.room.talkUser!.name.toString()),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.messageSnapshot(widget.room.roomId.toString()),
              builder: (context, snapshot) {
                return FutureBuilder(
                  future: getMessages(),
                  builder: (context, snapshot){
                    return ListView.builder(
                        physics: RangeMaintainingScrollPhysics(),
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: messageList.length,
                        itemBuilder: (context, index) {
                          Message _message = messageList[index];
                          DateTime sendTime = _message.sendTime!.toDate();
                          return Padding(
                            padding: EdgeInsets.only(top: 10, right: 10, left: 10, bottom: index == 0 ? 10 : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              textDirection: messageList[index].isMe! ? TextDirection.rtl : TextDirection.ltr, //三項演算子(?=Trueの時、:=falseの時)
                              children: [
                                Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                        color: messageList[index].isMe! ? Colors.green : Colors.white, //三項演算子(?=Trueの時、:=falseの時)
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Text(_message.message!)),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(intl.DateFormat('HH:mm').format(sendTime), style: TextStyle(fontSize: 10),)
                                )
                              ],
                            ),
                          );
                        });
                  }
                );
              }
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60, color: Colors.white,
              child: Row(
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder()
                      ),
                    ),
                  )),
                  IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        print('送信');
                        if(controller.text.isNotEmpty) {
                          await Firestore.sendMessage(widget.room.roomId.toString(), controller.text);
                          controller.clear();
                        }
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
