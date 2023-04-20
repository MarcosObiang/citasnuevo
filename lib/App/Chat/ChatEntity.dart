import '../ProfileViewer/ProfileEntity.dart';
import '../../core/globalData.dart';
import 'MessageEntity.dart';


/// At the start the app only loads the 10 most recent messages per [Chat].
///
/// When the user wats to load earlier messages, the process is going to have 4 states
enum AdditionalMessagesLoadState {
  READY,
  LOADING,
  ERROR,
  NOT_LOADED_YET,
  NO_MORE_MESSAGES,
  INACTIVE
}

enum SenderProfileLoadingState {
  READY,
  LOADING,
  ERROR,
  NOT_LOADED_YET,
 
}

class Chat {
  int unreadMessages;
  bool matchCreated;
  bool isBeingDeleted=false;
  bool removePending=false;
  bool userBlocked;
  String chatId;
  String remitentId;
  String messagesId;
  String remitentPicture;
  String remitentName;
  String notificationToken;
  Message? lastMessage;
  Profile? senderProfile;
  List<Message> messagesList = [];
  AdditionalMessagesLoadState additionalMessagesLoadState =
      AdditionalMessagesLoadState.NOT_LOADED_YET;

  SenderProfileLoadingState senderProfileLoadingState=SenderProfileLoadingState.NOT_LOADED_YET;
  




  Chat({
    required this.userBlocked,
    required this.unreadMessages,
    required this.matchCreated,
    required this.chatId,
    required this.remitentId,
    required this.messagesId,
    required this.remitentPicture,
    required this.remitentName,
    required this.notificationToken,
  });

  Future<AdditionalMessagesLoadState> stateTimer(
      AdditionalMessagesLoadState newState) async {
    late AdditionalMessagesLoadState newState2;
    newState2 = newState;

    await Future.delayed(Duration(milliseconds: 500))
        .then((value) {});

    return newState2;
  }

  // ignore: unused_element
  void calculateUnreadMessages(String userId) {
    unreadMessages=0;
    for (int i = 0; i < messagesList.length; i++) {
      if (messagesList[i].read == false &&
          messagesList[i].senderId != userId&&messagesList[i].messageType!=MessageType.DATE) {
        unreadMessages = unreadMessages + 1;
      }
      if (messagesList[i].read == true) {
        break;
      }
    }
  }
}