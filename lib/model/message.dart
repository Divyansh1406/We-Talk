class Message {
  Message({
    required this.msg,
    required this.read,
    required this.toId,
    required this.type,
    required this.fromId,
    required this.sent,
    required this.updated
  });
  late final String msg;
  late final String read;
  late final String toId;
  late final Type type;
  late final String fromId;
  late final String sent;
  late final bool updated;

  Message.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    read = json['read'].toString();
    toId = json['told'].toString();
    type = json['type'].toString()==Type.image.name? Type.image:Type.text;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
    updated=json['updated']??"";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = toId;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['updated']=updated;
    return data;
  }
  }

  enum Type {text,image}