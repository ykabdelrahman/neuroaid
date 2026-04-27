import 'dart:developer';

import 'package:appwrite/appwrite.dart';

import '../models/doctor_model.dart';
import 'appwrite_service.dart';

class DoctorsService {
  final AppwriteService _appwrite;

  DoctorsService(this._appwrite);

  Future<List<DoctorModel>> getDoctors() async {
    log('DoctorsService: Fetching doctors from Appwrite...');
    try {
      final result = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.doctorsCollection,
      );
      return result.documents
          .map((d) => DoctorModel.fromJson(d.data..addAll({'\$id': d.$id})))
          .toList();
    } on AppwriteException catch (e) {
      log('DoctorsService: Error: ${e.message}');
      throw Exception(e.message ?? 'Failed to load doctors');
    }
  }

  Future<List<DoctorModel>> getFavorites(String userId) async {
    log('DoctorsService: Fetching favorites for $userId');
    try {
      final result = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        queries: [Query.equal('userId', userId)],
      );

      if (result.documents.isEmpty) return [];

      final doctorIds = result.documents.map((d) => d.data['doctorId'] as String).toList();

      final List<DoctorModel> doctors = [];
      for (final doctorId in doctorIds) {
        try {
          final doc = await _appwrite.databases.getDocument(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.doctorsCollection,
            documentId: doctorId,
          );
          doctors.add(DoctorModel.fromJson(doc.data..addAll({'\$id': doc.$id})));
        } catch (_) {}
      }
      return doctors;
    } on AppwriteException catch (e) {
      log('DoctorsService: Error fetching favorites: ${e.message}');
      return [];
    }
  }

  Future<void> addToFavorites(String userId, String doctorId) async {
    log('DoctorsService: Adding doctor $doctorId to favorites for $userId');
    try {
      // Check if already favorited
      final existing = await _appwrite.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('doctorId', doctorId),
        ],
      );
      if (existing.documents.isNotEmpty) return;

      await _appwrite.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.favoritesCollection,
        documentId: ID.unique(),
        data: {'userId': userId, 'doctorId': doctorId},
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to add favorite');
    }
  }

  Future<void> removeFromFavorites(String userId, String doctorId) async {
    log('DoctorsService: Removing doctor $doctorId from favorites for $userId');
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
      }
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to remove favorite');
    }
  }
}
