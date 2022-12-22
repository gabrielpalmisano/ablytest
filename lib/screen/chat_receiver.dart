import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../config.dart';
import '../datalayer/Message.dart';
import 'package:ably_flutter/ably_flutter.dart' as ably;

import 'chat.dart';

class ChatScreenReceiver extends StatefulWidget {
  const ChatScreenReceiver({Key? key}) : super(key: key);

  @override
  State<ChatScreenReceiver> createState() => _ChatScreenReceiverState();
}

class _ChatScreenReceiverState extends State<ChatScreenReceiver> {
  double spaceResponsiveH = 0;
  double spaceResponsiveW = 0;

  late ably.Realtime realtimeInstance;
  var newMsgFromAbly;
  late ably.RealtimeChannel chatChannel;
  var myInputController = TextEditingController();
  var myRandomClientId = '';

  @override
  void initState() {
    super.initState();
    createAblyRealtimeInstance();
  }

  @override
  void dispose() {
    myInputController.dispose();
    super.dispose();
  }

  void createAblyRealtimeInstance() async {
    var uuid = Uuid();
    myRandomClientId = uuid.v4();
    var clientOptions = ably.ClientOptions.fromKey(AblyAPIKey);
    clientOptions.clientId = myRandomClientId;
    try {
      realtimeInstance = ably.Realtime(options: clientOptions);
      print('Ably instantiated');
      chatChannel = realtimeInstance.channels.get('flutter-chat');
      subscribeToChatChannel();
      realtimeInstance.connection
          .on(ably.ConnectionEvent.connected)
          .listen((ably.ConnectionStateChange stateChange) async {
        print('Realtime connection state changed: ${stateChange.event}');
      });
    } catch (error) {
      print('Error creating Ably Realtime Instance: $error');
      rethrow;
    }
  }

  void subscribeToChatChannel() {
    var messageStream = chatChannel.subscribe();
    messageStream.listen((ably.Message message) {
      Message newChatMsg;
      newMsgFromAbly = message.data;
      print("New message arrived ${message.data}");
      var hoursIn12HrFormat = message.timestamp!.hour > 12
          ? (message.timestamp!.hour - 12)
          : (message.timestamp!.hour);
      var timeOfDay = message.timestamp!.hour < 12 ? ' AM' : ' PM';
      var msgTime = "$hoursIn12HrFormat:${message.timestamp!.minute}$timeOfDay";
      if (message.clientId == myRandomClientId) {
        newChatMsg = Message(
          sender: currentUser,
          time: msgTime,
          text: newMsgFromAbly["text"],
          unread: false,
        );
      } else {
        newChatMsg = Message(
          sender: randomChatUser,
          time: msgTime,
          text: newMsgFromAbly["text"],
          unread: false,
        );
      }

      setState(() {
        messages.insert(0, newChatMsg);
      });
    });
  }

  void publishMyMessage() async {
    var myMessage = myInputController.text;
    myInputController.clear();
    chatChannel.publish(name: "chatMsg", data: {
      "sender": "randomChatUser",
      "text": myMessage,
    });
  }

  _buildMessage(Message message, bool isMe) {
    final Container msg = Container(
      margin: isMe
          ? const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 80.0,
      )
          : const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).primaryColor : Colors.blueGrey,
        borderRadius: isMe
            ? const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        )
            : const BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isMe ? [
          Text(
            message.time!,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            message.text!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
        : [
          Text(
            message.time!,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            message.text!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
      ),
    );
    if (isMe) {
      return msg;
    }
    return Row(
      children: <Widget>[
        msg,
      ],
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: myInputController,
              onChanged: (value) {},
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can send messages only from the other view")));;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: const Text(
            'Ably Chat',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.switch_account),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(pageBuilder: (_, __, ___) => const ChatScreen(), transitionDuration: const Duration(seconds: 0))
                );
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.only(top: 15.0),
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Message message = messages[index];
                        final bool isMe = message.sender!.id == randomChatUser.id;
                        return _buildMessage(message, isMe);
                      },
                    ),
                  ),
                ),
              ),
              _buildMessageComposer(),
            ],
          ),
        ),
      ),
    );
  }
}
