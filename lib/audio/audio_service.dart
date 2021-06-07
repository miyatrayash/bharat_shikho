import 'package:cloud_firestore/cloud_firestore.dart';

class AudioService {
  
  static  final  _firestore =  FirebaseFirestore.instance;
  
  static Future<QuerySnapshot> newsPodcasts = _firestore.collection('podcasts').where('categories',arrayContains: 'news').get();
  static Future<QuerySnapshot> startUpPodcasts = _firestore.collection('podcasts').where('categories',arrayContains: 'startUp').get();
  static Future<QuerySnapshot> motivationPodcasts = _firestore.collection('podcasts').where('categories',arrayContains: 'motivation').get();
  static Future<QuerySnapshot> beforePodcasts = _firestore.collection('podcasts').where('categories',arrayContains: 'before').get();


}