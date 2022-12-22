import 'User.dart';

class Message {
  User? sender;
  String? time;
  String? text;
  bool? unread;

  Message({
    this.sender,
    this.time,
    this.text,
    this.unread,
  });
}

// CURRENT USER
final User currentUser = User(
  id: 0,
  name: 'Current User',
);

// OTHER USER
final User randomChatUser = User(
  id: 1,
  name: 'Random Chat User',
);

List<Message> messages = [
  Message(
    sender: currentUser,
    time: '4:32 PM',
    text: "Hi Jack!",
    unread: true,
  ),
  Message(
    sender: randomChatUser,
    time: '4:30 PM',
    text: "What's up?",
    unread: true,
  ),
  Message(
    sender: randomChatUser,
    time: '4:30 PM',
    text: "Hey Jimmy, that's my number",
    unread: true,
  ),
];