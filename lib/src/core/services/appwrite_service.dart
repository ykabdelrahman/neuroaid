import 'dart:developer';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteService {
  static String get endpoint =>
      dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://db.baselembaby.cloud/v1';
  static String get projectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
  static String get databaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';

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
