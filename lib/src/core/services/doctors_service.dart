import 'dart:developer';

import 'package:appwrite/appwrite.dart';

import '../models/doctor_model.dart';
import 'appwrite_service.dart';

class DoctorsService {
  final AppwriteService _appwrite;

  DoctorsService(this._appwrite);

  Future<List<DoctorModel>> getDoctors() async {
    log('👨‍⚕️ DoctorsService: Fetching doctors [${AppwriteService.endpoint}/databases/${AppwriteService.databaseId}/collections/${AppwriteService.doctorsCollection}]');
    try {
      final result = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.doctorsCollection,
      );
      log('✅ DoctorsService: Fetched ${result.documents.length} doctor(s)');
      return result.documents
          .map((d) => DoctorModel.fromJson(d.data..addAll({'\$id': d.$id})))
          .toList();
    } on AppwriteException catch (e) {
      log('❌ DoctorsService: getDoctors failed [code: ${e.code}] — ${e.message}');
      throw Exception(e.message ?? 'Failed to load doctors');
    }
  }

  Future<List<DoctorModel>> getFavorites(String userId) async {
    log('⭐ DoctorsService: Fetching favorites for userId: $userId');
    try {
      final result = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        queries: [Query.equal('userId', userId)],
      );

      if (result.documents.isEmpty) {
        log('DoctorsService: No favorites found for $userId');
        return [];
      }

      final doctorIds = result.documents.map((d) => d.data['doctorId'] as String).toList();
      log('DoctorsService: Found ${doctorIds.length} favorite(s), fetching doctor details...');

      final List<DoctorModel> doctors = [];
      for (final doctorId in doctorIds) {
        try {
          final doc = await _appwrite.databases.getDocument(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.doctorsCollection,
            documentId: doctorId,
          );
          doctors.add(DoctorModel.fromJson(doc.data..addAll({'\$id': doc.$id})));
        } catch (e) {
          log('⚠️ DoctorsService: Could not fetch doctor $doctorId — $e');
        }
      }
      log('✅ DoctorsService: Fetched ${doctors.length} favorite doctor(s)');
      return doctors;
    } on AppwriteException catch (e) {
      log('❌ DoctorsService: getFavorites failed [code: ${e.code}] — ${e.message}');
      return [];
    }
  }

  Future<void> addToFavorites(String userId, String doctorId) async {
    log('➕ DoctorsService: addToFavorites — userId: $userId, doctorId: $doctorId');
    try {
      final existing = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('doctorId', doctorId),
        ],
      );
      if (existing.documents.isNotEmpty) {
        log('DoctorsService: Already favorited — skipping');
        return;
      }

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        documentId: ID.unique(),
        data: {'userId': userId, 'doctorId': doctorId},
      );
      log('✅ DoctorsService: Favorite created — docId: ${doc.$id}');
    } on AppwriteException catch (e) {
      log('❌ DoctorsService: addToFavorites failed [code: ${e.code}] — ${e.message}');
      throw Exception(e.message ?? 'Failed to add favorite');
    }
  }

  Future<void> removeFromFavorites(String userId, String doctorId) async {
    log('➖ DoctorsService: removeFromFavorites — userId: $userId, doctorId: $doctorId');
    try {
      final result = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('doctorId', doctorId),
        ],
      );
      for (final doc in result.documents) {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.favoritesCollection,
          documentId: doc.$id,
        );
        log('DoctorsService: Deleted favorite doc ${doc.$id}');
      }
      log('✅ DoctorsService: Removed ${result.documents.length} favorite(s)');
    } on AppwriteException catch (e) {
      log('❌ DoctorsService: removeFromFavorites failed [code: ${e.code}] — ${e.message}');
      throw Exception(e.message ?? 'Failed to remove favorite');
    }
  }
}
