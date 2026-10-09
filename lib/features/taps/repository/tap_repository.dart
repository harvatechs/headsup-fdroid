import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tap_event.dart';
import '../../../core/constants/app_constants.dart';

abstract class BaseTapRepository {
  Stream<List<TapEvent>> watchUserTaps(String userId);
  Stream<List<TapEvent>> watchAllTaps({int limit = 100});
  Future<void> recordTap(TapEvent event);
  Future<void> deleteTap(String tapId);
  Future<void> clearUserTaps(String userId);
}

class FirestoreTapRepository implements BaseTapRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final List<TapEvent> _localFallbackStore = [];
  final _localFallbackStreamController = StreamController<List<TapEvent>>.broadcast();

  FirestoreTapRepository() {
    _localFallbackStreamController.add(_localFallbackStore);
  }

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection(AppConstants.tapsCollection);

  Stream<List<TapEvent>> _watchLocalFallback([String? userId]) async* {
    yield userId == null
        ? List.unmodifiable(_localFallbackStore)
        : List.unmodifiable(_localFallbackStore.where((t) => t.userId == userId).toList());
    await for (final list in _localFallbackStreamController.stream) {
      yield userId == null
          ? list
          : list.where((t) => t.userId == userId).toList();
    }
  }

  @override
  Stream<List<TapEvent>> watchUserTaps(String userId) {
    try {
      final col = _collection;
      if (col == null) {
        return _watchLocalFallback(userId);
      }
      return col
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(200)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TapEvent.fromMap(doc.data(), doc.id))
            .toList();
      }).handleError((error) {
        debugPrint('Firestore watchUserTaps error (using local store): $error');
        return _localFallbackStore.where((t) => t.userId == userId).toList();
      });
    } catch (e) {
      debugPrint('watchUserTaps exception: $e');
      return _watchLocalFallback(userId);
    }
  }

  @override
  Stream<List<TapEvent>> watchAllTaps({int limit = 100}) {
    try {
      final col = _collection;
      if (col == null) {
        return _watchLocalFallback();
      }
      return col
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TapEvent.fromMap(doc.data(), doc.id))
            .toList();
      }).handleError((error) {
        debugPrint('Firestore watchAllTaps error (using local store): $error');
        return _localFallbackStore;
      });
    } catch (e) {
      debugPrint('watchAllTaps exception: $e');
      return _watchLocalFallback();
    }
  }

  @override
  Future<void> recordTap(TapEvent event) async {
    // Optimistically update local store
    _localFallbackStore.insert(0, event);
    _localFallbackStreamController.add(List.unmodifiable(_localFallbackStore));

    try {
      await _collection?.doc(event.id).set(event.toMap());
    } catch (e) {
      debugPrint('Firestore recordTap error: $e');
      // Even if Firestore fails, local fallback maintains the tap
    }
  }

  @override
  Future<void> deleteTap(String tapId) async {
    _localFallbackStore.removeWhere((t) => t.id == tapId);
    _localFallbackStreamController.add(List.unmodifiable(_localFallbackStore));

    try {
      await _collection?.doc(tapId).delete();
    } catch (e) {
      debugPrint('Firestore deleteTap error: $e');
    }
  }

  @override
  Future<void> clearUserTaps(String userId) async {
    _localFallbackStore.removeWhere((t) => t.userId == userId);
    _localFallbackStreamController.add(List.unmodifiable(_localFallbackStore));

    try {
      final col = _collection;
      final firestore = _firestore;
      if (col != null && firestore != null) {
        final snapshot = await col.where('userId', isEqualTo: userId).get();
        final batch = firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Firestore clearUserTaps notice: $e');
    }
  }
}
