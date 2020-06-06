import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

part 'posts_data.g.dart';

class PostData = _PostData with _$PostData;

abstract class _PostData with Store {
  @observable
  List<DocumentSnapshot> posts = ObservableList();

  @computed
  int get length => posts.length;

  @action
  void insertItem(int index, DocumentSnapshot newPost) {
    posts.insert(index, newPost);
  }

  @action
  void insertAllItems(int index, List<DocumentSnapshot> listOfPosts) {
    posts.insertAll(index, listOfPosts);
  }

  @action
  void addAllItems(List<DocumentSnapshot> listOfPosts) {
    posts.addAll(listOfPosts);
  }
}
