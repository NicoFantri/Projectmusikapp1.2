import 'package:musicapp/app/data//model/track.dart';

class ChatRoom {
  String? id;
  String? name;
  String? description;
  String? image;
  String? created;
  bool? pinned;
  List<Members>? members;
  List<Messages>? messages;

  ChatRoom(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.created,
      this.pinned,
      this.members,
      this.messages});

  ChatRoom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    created = json['created'];
    pinned = json['pinned'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(Members.fromJson(v));
      });
    }
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['created'] = created;
    data['pinned'] = pinned;
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static List<ChatRoom> fromJsonToList(List<dynamic> jsonList) {
    List<ChatRoom> chatRooms = [];
    for (var json in jsonList) {
      chatRooms.add(ChatRoom.fromJson(json));
    }
    return chatRooms;
  }
}

class Members {
  int? id;
  String? username;
  String? status;

  Members({this.id, this.username, this.status});

  Members.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['status'] = status;
    return data;
  }
}

class Messages {
  int? id;
  Sender? sender;
  String? timestamp;
  String? content;
  Tracks? tracks;

  Messages({this.id, this.sender, this.timestamp, this.content, this.tracks});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    timestamp = json['timestamp'];
    content = json['content'];
    tracks = json['tracks'] != null ? Tracks.fromJson(json['tracks']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    data['timestamp'] = timestamp;
    data['content'] = content;
    if (tracks != null) {
      data['tracks'] = tracks!.toJson();
    }
    return data;
  }
}

class Sender {
  int? id;
  String? username;

  Sender({this.id, this.username});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    return data;
  }
}
