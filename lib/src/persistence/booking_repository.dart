import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itec27001/src/persistence/repository.dart';

import '../entities/booking.dart';
import '../util/timestamp_formatter.dart';

class BookingRepository extends Repository {
  BookingRepository() : super('bookings') {
    init();
  }

  Future<List<Booking>> GetAll(int floorId, DateTime effectiveDate) async {
    List<Booking> bookings = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('effective_date', isEqualTo: (TimestampFormatter.Format(effectiveDate)))
        .get();
    for (var element in querySnapshot.docChanges) {
      DocumentSnapshot documentSnapshot = element.doc;
      bookings.add(Booking.create(documentSnapshot));
    }
    return bookings;
  }

  Future<Booking?> GetLatest() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    if (querySnapshot.size == 0){
      return null;
    }
    DocumentSnapshot documentSnapshot = querySnapshot.docChanges.single.doc;
    return Booking.create(documentSnapshot);
  }

  Future<void> Add(Booking booking) async {
    Booking? latestBooking = await GetLatest();
    booking.setId(latestBooking != null ? (latestBooking.id! + 1) : 1);
    if (booking.id == null){
      throw Exception("Id is required for document to be saved.");
    }
    await FirebaseFirestore.instance
        .collection(collectionName)
        .add(booking.createFBObject());
  }
}