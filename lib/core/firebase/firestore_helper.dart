import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:movies_app/data/models/firebase_movie_model.dart';
import 'package:movies_app/data/models/user_model.dart';

@singleton
class FireStoreHelper {
  static CollectionReference<UserModel> getUserCollections() {
    var refernce = FirebaseFirestore.instance.collection("User").withConverter(
      fromFirestore: (snapshot, options) {
        Map<String, dynamic>? data = snapshot.data();
        return UserModel.fromFireStore(data ?? {});
      },
      toFirestore: (UserModel user, options) {
        return user.toFirestore();
      },
    );
    return refernce;
  }

  static Future<void> addUser({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    var document = getUserCollections().doc(userId);
    await document.set(UserModel(
        email: email,
        userid: userId,
        firstName: firstName,
        lastName: lastName));
  }

  static Future<UserModel?> getUser({required String userId}) async {
    var userDoc = getUserCollections().doc(userId);
    var snapShot = await userDoc.get();
    UserModel? user = snapShot.data();
    return user;
  }

  static CollectionReference<FireBaseMovieModel>? getMovieCollections(
      {required String userid}) {
    var refernce =
        getUserCollections().doc(userid).collection("MyMovies").withConverter(
      fromFirestore: (snapshot, options) {
        Map<String, dynamic>? data = snapshot.data();
        return FireBaseMovieModel.fromJson(data ?? {});
      },
      toFirestore: (FireBaseMovieModel movie, options) {
        return movie.toJson();
      },
    );
    return refernce;
  }

  static addMovie(
      {required String userid, required FireBaseMovieModel movie}) async {
    await getMovieCollections(userid: userid)!.add(movie);
  }

  static Stream<List<FireBaseMovieModel>> getIsCheck(
      {required String userID, required int id}) async* {
    var filter = getMovieCollections(userid: userID)!
        .where("id", isEqualTo: id)
        .snapshots();
    Stream<List<FireBaseMovieModel>> snapshot =
        filter.map((event) => event.docs.map((e) => e.data()).toList());
    yield* snapshot;
  }

  Stream<List<FireBaseMovieModel>> getMovies({required String userid}) async* {
    Stream<QuerySnapshot<FireBaseMovieModel>> movie =
        Stream.value(await getMovieCollections(userid: userid)!.get());
    Stream<List<FireBaseMovieModel>> movieList =
        movie.map((event) => event.docs.map((e) => e.data()).toList());
    yield* movieList;
  }
  //   static Stream<List<TaskModel>> listenToTasks(
  //     {required String UserID, required int date}) async* {
  //   Stream<QuerySnapshot<TaskModel>> taskStream =
  //       getTaskCollection(UserID).where("date", isEqualTo: date).snapshots();
  //   Stream<List<TaskModel>> tasks = taskStream
  //       .map((event) => event.docs.map((snapshot) => snapshot.data()).toList());
  //   yield* tasks;
  // }
}
