class Item {
  late String title;
  late bool done;

  Item({required this.title, required this.done});

  Item.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    done = json['done'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //final define uma váriavel que só pode ser atribuida uma unica vez.
    data['title'] = title;
    data['done'] = done;
    return data;
  }
}
