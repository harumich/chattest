import 'package:untitled/model/user.dart';

class TalkRoom {
  String? roomId;
  User? talkUser;
  String? lastMessage;

  TalkRoom({this.roomId, this.talkUser, this.lastMessage});
}