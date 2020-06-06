// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_data.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PostData on _PostData, Store {
  Computed<int> _$lengthComputed;

  @override
  int get length => (_$lengthComputed ??=
          Computed<int>(() => super.length, name: '_PostData.length'))
      .value;

  final _$postsAtom = Atom(name: '_PostData.posts');

  @override
  ObservableList<dynamic> get posts {
    _$postsAtom.reportRead();
    return super.posts;
  }

  @override
  set posts(ObservableList<dynamic> value) {
    _$postsAtom.reportWrite(value, super.posts, () {
      super.posts = value;
    });
  }

  final _$_PostDataActionController = ActionController(name: '_PostData');

  @override
  void insertItem(int index, DocumentSnapshot newPost) {
    final _$actionInfo =
        _$_PostDataActionController.startAction(name: '_PostData.insertItem');
    try {
      return super.insertItem(index, newPost);
    } finally {
      _$_PostDataActionController.endAction(_$actionInfo);
    }
  }

  @override
  void insertAllItems(int index, List<DocumentSnapshot> listOfPosts) {
    final _$actionInfo = _$_PostDataActionController.startAction(
        name: '_PostData.insertAllItems');
    try {
      return super.insertAllItems(index, listOfPosts);
    } finally {
      _$_PostDataActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addAllItems(List<DocumentSnapshot> listOfPosts) {
    final _$actionInfo =
        _$_PostDataActionController.startAction(name: '_PostData.addAllItems');
    try {
      return super.addAllItems(listOfPosts);
    } finally {
      _$_PostDataActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
posts: ${posts},
length: ${length}
    ''';
  }
}
