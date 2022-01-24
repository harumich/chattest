import 'package:flutter/material.dart';
import 'package:untitled/model/talk_room.dart';
import 'package:untitled/model/user.dart';
import 'package:untitled/pages/settings_profile.dart';
import 'package:untitled/pages/talk_room.dart';
import 'package:untitled/utils/firebase.dart';
import 'package:untitled/utils/shared_prefs.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom> talkUserList = [];

  Future<void> createRooms() async {
    String myUid = SharedPrefs.getUid();
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('チャットアプリ'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsProfilePage()));
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: createRooms(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                itemCount: talkUserList.length,
                itemBuilder: (context, index){
                  return InkWell(
                    onTap: () {
                      print(talkUserList[index].roomId);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TalkRoomPage(talkUserList[index])));
                    },
                    child: Container(
                      height: 70,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CircleAvatar(
                              foregroundImage: NetworkImage(talkUserList[index].talkUser!.imagePath.toString()),
                              radius: 30,),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(talkUserList[index].talkUser!.name.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              Text(talkUserList[index].lastMessage.toString(), style: TextStyle(color: Colors.grey),),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
          }else{
            return Center(child: CircularProgressIndicator());
          }

        }
      ),
    );
  }
}
