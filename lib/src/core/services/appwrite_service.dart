import 'dart:developer';
import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static const String endpoint = 'https://db.baselembaby.cloud/v1';
  static const String projectId = 'nero-app';
  static const String databaseId = 'nero-database';

  static const String usersCollection = 'users';
  static const String doctorsCollection = 'doctors';
  static const String patientsCollection = 'patients';
  static const String bookingsCollection = 'bookings';
  static const String favoritesCollection = 'favorites';

  late final Client client;
  late final Account account;
  late final Databases databases;

  AppwriteService() {
    log('🔌 AppwriteService: Connecting to $endpoint (project: $projectId)');
    client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId)
      ..setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    log('✅ AppwriteService: Client initialized — database: $databaseId');
  }
}
