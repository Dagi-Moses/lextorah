import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Lextorah/apis/api_service.dart';
import 'package:Lextorah/constants/constants.dart';
import 'package:Lextorah/hive/boxes.dart';
import 'package:Lextorah/hive/chat_history.dart';
import 'package:Lextorah/hive/settings.dart';
import 'package:Lextorah/hive/user_model.dart';
import 'package:Lextorah/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // list of messages

  ChatProvider() {
    _pageController = PageController(initialPage: currentIndex, keepPage: true);
  }
  final List<Message> _inChatMessages = [];

  // page controller
  late PageController _pageController;

  int _currentIndex = 1;

  // images file list
  List<PlatformFile>? _imagesFileList = [];

  // cuttent chatId
  String _currentChatId = '';

  // initialize generative model
  GenerativeModel? _model;

  // itialize text model
  GenerativeModel? _textModel;

  // initialize vision model
  GenerativeModel? _visionModel;

  // current mode
  String _modelType = 'gemini-pro';

  // loading bool
  bool _isLoading = false;

  // getters
  List<Message> get inChatMessages => _inChatMessages;

  PageController get pageController => _pageController;
  int get currentIndex => _currentIndex;

  List<PlatformFile>? get imagesFileList => _imagesFileList;

  String get currentChatId => _currentChatId;

  GenerativeModel? get model => _model;

  GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

  // setters
  void navigate(int index) {
    _pageController.jumpToPage(index);
    _currentIndex = index;
    notifyListeners();
  }

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive database
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }

      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // load the messages from db
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // open the box of this chatID
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData =
        messageBox.keys.map((e) {
          final message = messageBox.get(e);
          final messageData = Message.fromMap(
            Map<String, dynamic>.from(message),
          );

          return messageData;
        }).toList();
    notifyListeners();
    return newData;
  }

  // set file list
  void setImagesFileList({required List<PlatformFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  // set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model =
          _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.5-pro-exp-03-25'),
            apiKey: ApiService.apiKey,
          );
    } else {
      _model =
          _visionModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.5-pro-vision-exp-03-25'),
            apiKey: ApiService.apiKey,
          );
    }
    notifyListeners();
  }

  // set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  //?Yeha bata copy

  // delete caht
  Future<void> deleteChatMessages({required String chatId}) async {
    // 1. check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      // open the box
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');

      // delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      // delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    // get the current chatId, its its not empty
    // we check if its the same as the chatId
    // if its the same we set it to empty
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId(newChatId: '');
        _inChatMessages.clear();
        notifyListeners();
      }
    }
  }

  // prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    if (!isNewChat) {
      // 1.  load the chat messages from the db
      final chatHistory = await loadMessagesFromDB(chatId: chatID);

      // 2. clear the inChatMessages
      _inChatMessages.clear();

      for (var message in chatHistory) {
        _inChatMessages.add(message);
      }

      // 3. set the current chat id
      setCurrentChatId(newChatId: chatID);
    } else {
      // 1. clear the inChatMessages
      _inChatMessages.clear();

      // 2. set the current chat id
      setCurrentChatId(newChatId: chatID);
    }
  }

  //?yeha samma

  // send message to gemini and get the streamed reposnse
  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    // set the model
    await setModel(isTextOnly: isTextOnly);

    // set loading
    setLoading(value: true);

    // get the chatId
    String chatId = getChatId();

    // list of history messahes
    List<Content> history = [];

    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the imagesUrls
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

    //??Copy
    // open the messages box
    final messagesBox = await Hive.openBox(
      '${Constants.chatMessagesBox}$chatId',
    );

    // get the last user message id
    final userMessageId = messagesBox.keys.length;

    // assistant messageId
    final assistantMessageId = messagesBox.keys.length + 1;

    // ?yeha samma

    // user message
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    // add this message to the list on inChatMessages
    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // ? change is here
    // send the message to the model and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messagesBox: messagesBox,
    );
  }

  // send message to the model and wait for the response
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId, // ? Add this line
    required Box messagesBox,
  }) async {
    // start the chat session - only send history is its text-only
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    // get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

    // assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    // add this message to the list on inChatMessages
    _inChatMessages.add(assistantMessage);
    notifyListeners();

    // wait for stream response
    chatSession
        .sendMessageStream(content)
        .asyncMap((event) {
          return event;
        })
        .listen(
          (event) {
            _inChatMessages
                .firstWhere(
                  (element) =>
                      element.messageId == assistantMessage.messageId &&
                      element.role.name == Role.assistant.name,
                )
                .message
                .write(event.text);
            log('event: ${event.text}');
            notifyListeners();
          },
          onDone: () async {
            log('stream done');
            // save message to hive db
            await saveMessagesToDB(
              chatID: chatId,
              userMessage: userMessage,
              assistantMessage: assistantMessage,
              messagesBox: messagesBox,
            );
            // set loading to false
            setLoading(value: false);
          },
        )
        .onError((erro, stackTrace) {
          log('error: $erro');
          // set loading
          setLoading(value: false);
        });
  }

  // save messages to hive db
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    // save the user messages
    await messagesBox.add(userMessage.toMap());

    // save the assistant messages
    await messagesBox.add(assistantMessage.toMap());

    // save chat history with thae same chatId
    // if its already there update it
    // if not create a new one
    final chatHistoryBox = Boxes.getChatHistory();

    final chatHistory = ChatHistory(
      chatId: chatID,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesUrls: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );
    await chatHistoryBox.put(chatID, chatHistory);

    // close the box
    await messagesBox.close();
  }

  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // Needed for web
    );

    if (result != null && result.files.isNotEmpty) {
      setImagesFileList(listValue: result.files);
    }
  }

  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      final imageBytes =
          _imagesFileList
              ?.where((file) => file.bytes != null)
              .map((file) => Uint8List.fromList(file.bytes!))
              .toList();

      final prompt = TextPart(message);
      final imageParts =
          imageBytes!.map((bytes) => DataPart('image/jpeg', bytes)).toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // // get y=the imagesUrls
  // List<String> getImagesUrls({
  //   required bool isTextOnly,
  // }) {
  //   List<String> imagesUrls = [];
  //   if (!isTextOnly && imagesFileList != null) {
  //     for (var image in imagesFileList!) {
  //       imagesUrls.add(image.path);
  //     }
  //   }
  //   return imagesUrls;
  // }

  List<String> getImagesUrls({required bool isTextOnly}) {
    List<String> imagesUrls = [];

    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        if (image.bytes != null) {
          // Convert bytes to a base64 string for web preview
          final base64Image = base64Encode(image.bytes!);
          final mimeType = 'image/${_getExtension(image.name)}';
          final dataUrl = 'data:$mimeType;base64,$base64Image';
          imagesUrls.add(dataUrl);
        } else if (image.path != null) {
          // Native path (for mobile apps)
          imagesUrls.add(image.path!);
        }
      }
    }

    return imagesUrls;
  }

  // Helper to get file extension (like jpg, png)
  String _getExtension(String fileName) {
    return fileName.split('.').last;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }

    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  // // init Hive box
  // static initHive() async {
  //   final dir = await path.getApplicationDocumentsDirectory();
  //   Hive.init(dir.path);
  //   await Hive.initFlutter(Constants.geminiDB);

  //   // register adapters
  //   if (!Hive.isAdapterRegistered(0)) {
  //     Hive.registerAdapter(ChatHistoryAdapter());

  //     // open the chat history box
  //     await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
  //   }
  //   if (!Hive.isAdapterRegistered(1)) {
  //     Hive.registerAdapter(UserModelAdapter());
  //     await Hive.openBox<UserModel>(Constants.userBox);
  //   }
  //   if (!Hive.isAdapterRegistered(2)) {
  //     Hive.registerAdapter(SettingsAdapter());
  //     await Hive.openBox<Settings>(Constants.settingsBox);
  //   }
  // }
  // init Hive box
  static Future<void> initHive() async {
    // ✅ This works for Web and Mobile
    await Hive.initFlutter(Constants.geminiDB);

    // ✅ Register adapters only once
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
    }

    // ✅ Open boxes
    await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    await Hive.openBox<UserModel>(Constants.userBox);
    await Hive.openBox<Settings>(Constants.settingsBox);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }
}
