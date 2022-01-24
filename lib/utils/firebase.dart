import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/model/message.dart';
import 'package:untitled/model/talk_room.dart';
import 'package:untitled/model/user.dart';
import 'package:untitled/utils/shared_prefs.dart';

class Firestore{
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection('user');
  static final roomRef = _firestoreInstance.collection('room');
  static final roomSnapshot = roomRef.snapshots();

  static Future<void> addUser() async{
    try{
      final newDoc = await userRef.add({
        'name': '名無し',
        'image_Path': 'https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/2018gettyimages-1300225970-594x594-1621916164.jpg',
      });
      print('アカウント作成完了');
      await SharedPrefs.setUid(newDoc.id);

      List<String>? userIds = await getUser();
      userIds?.forEach((user) async {
        if(user != newDoc.id) {
          await roomRef.add({
            'joined_user_ids': [user, newDoc.id],
            'updated_time': Timestamp.now()
          });
        }
      });
      print('ルーム作成完了');

    }catch(e) {
      print('失敗しました---$e');
    }
  }

  static Future<List<String>?> getUser() async{
    try{
      final snapshot = await userRef.get();
      List<String> userIds = [];
      snapshot.docs.forEach((user) {
        userIds.add(user.id);
      });

      return userIds;
    }catch(e) {
      print('所得失敗---$e');
      return null;
    }
    }

    static Future<User> getProfile(String uid) async{
      final profile = await userRef.doc(uid).get();
      User myProfile = User(
        name: profile.data()!['name'],
        imagePath: profile.data()!['image_path'],
        uid: uid,
      );
      return myProfile;
    }

    static Future<void> updateProfile(User newProfile) async{
      String myUid = SharedPrefs.getUid();
      userRef.doc(myUid).update({
        'name': newProfile.name,
        'image_Path': newProfile.imagePath,
      });
    }

    static Future<List<TalkRoom>> getRooms(String myUid) async{
      final snapshot = await roomRef.get();
      List<TalkRoom> roomList = [];
      await Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(snapshot.docs, (doc) async{
        if(doc.data()['joined_user_ids'].contains(myUid)) {
          print(myUid);
          late String yourUid;
          doc.data()['joined_user_ids'].forEach((id) {
            if(id != myUid) {
              yourUid = id;
              return;
            }
          });
          print(yourUid);
          User yourProfile = await getProfile(yourUid);
          print(yourProfile);
          TalkRoom room = TalkRoom(
            roomId: doc.id,
            talkUser: yourProfile,
            lastMessage: doc.data()['last_message'] ?? ''
          );
          roomList.add(room);
        }
      });
      print(roomList.length);
      return roomList;
    }

    static Future<List<Message>> getMessages(String roomId) async {
      final messageRef = roomRef.doc(roomId).collection('message');
      List<Message> messageList = [];
      final snapshot = await messageRef.get();
      await Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(snapshot.docs, (doc) {
        bool isMe;
        String myUid = SharedPrefs.getUid();
        if(doc.data()['sender_id'] == myUid) {
          isMe = true;
        }else{
          isMe = false;
        }
        Message message = Message(
          message: doc.data()['message'],
          isMe: isMe,
          sendTime: doc.data()['send_time']
        );
        messageList.add(message);
      });
      messageList.sort((a, b) => b.sendTime!.compareTo(a.sendTime!));
      return messageList;
    }

    static Future<void> sendMessage(String roomId, String message) async{
      final messageRef = roomRef.doc(roomId).collection('message');
      String myUid = SharedPrefs.getUid();
      await messageRef.add({
        'message': message,
        'sender_id': myUid,
        'send_time': Timestamp.now()
      });

      roomRef.doc(roomId).update({
        'last_message': message
      });
    }

    static Stream<QuerySnapshot> messageSnapshot(String roomId) {
      return roomRef.doc(roomId).collection('message').snapshots();
    }
  }