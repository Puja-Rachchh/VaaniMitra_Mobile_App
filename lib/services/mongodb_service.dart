import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';
import '../utils/language_mapper.dart';

/// MongoDB service for handling database connections and operations
class MongoDBService {
  static Db? _db;
  static bool _isConnected = false;

  // MongoDB connection string
  static const String _connectionString =
      'Enter_Mongo_DB_URL_Here';
  
  static const String _databaseName = 'vaanimitra';
  static const String _translationsCollection = 'translations';

  /// Initialize and connect to MongoDB
  static Future<bool> connect() async {
    if (_isConnected && _db != null) {
      debugPrint('✅ MongoDB: Already connected');
      return true;
    }

    try {
      debugPrint('🔄 MongoDB: Connecting to database...');
      debugPrint('   Connection string: $_connectionString$_databaseName');
      _db = await Db.create(_connectionString + _databaseName);
      await _db!.open();
      
      // Test the connection
      await _db!.serverStatus();
      
      _isConnected = true;
      debugPrint('✅ MongoDB: Connected successfully to $_databaseName');
      debugPrint('   Collections available: ${await _db!.getCollectionNames()}');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ MongoDB: Connection failed: $e');
      debugPrint('   Stack trace: $stackTrace');
      _isConnected = false;
      return false;
    }
  }

  /// Get translation from database
  /// Returns the translated text if found, null otherwise
  static Future<String?> getTranslation({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    if (!_isConnected || _db == null) {
      debugPrint('⚠️ MongoDB: Not connected, attempting to connect...');
      final connected = await connect();
      if (!connected) {
        debugPrint('❌ MongoDB: Connection failed, cannot query database');
        return null;
      }
    }

    try {
      final collection = _db!.collection(_translationsCollection);
      
      // Convert ISO code (hi) to database format (hindi)
      final dbLanguage = LanguageMapper.isoToDb(toLanguage);
      
      debugPrint('🔍 MongoDB: Querying for english="${text.toLowerCase()}", language="$dbLanguage"');
      
      // Query for existing translation using your actual schema
      // Your schema: { english: "apple", language: "hindi", translation: "सेब" }
      final result = await collection.findOne(
        where
          .eq('english', text.toLowerCase())
          .eq('language', dbLanguage)
      );

      debugPrint('   Query result: ${result != null ? "Found document" : "No document found"}');
      
      if (result != null && result['translation'] != null) {
        debugPrint('✅ MongoDB: Translation found for "$text" → "${result['translation']}"');
        return result['translation'] as String;
      } else {
        debugPrint('ℹ️ MongoDB: No translation found for "$text" (language: $dbLanguage)');
        
        // Debug: Show what's in the collection
        final count = await collection.count();
        debugPrint('   Total documents in collection: $count');
        
        return null;
      }
    } catch (e) {
      debugPrint('❌ MongoDB: Error fetching translation: $e');
      return null;
    }
  }

  /// Save translation to database
  static Future<bool> saveTranslation({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    required String translation,
  }) async {
    if (!_isConnected || _db == null) {
      debugPrint('⚠️ MongoDB: Not connected, attempting to connect...');
      final connected = await connect();
      if (!connected) return false;
    }

    try {
      final collection = _db!.collection(_translationsCollection);
      
      // Convert ISO code to database format
      final dbLanguage = LanguageMapper.isoToDb(toLanguage);
      
      // Check if translation already exists using your schema
      final existing = await collection.findOne(
        where
          .eq('english', text.toLowerCase())
          .eq('language', dbLanguage)
      );

      if (existing != null) {
        // Update existing translation
        await collection.updateOne(
          where.eq('_id', existing['_id']),
          modify
            .set('translation', translation)
            .set('updated_at', DateTime.now()),
        );
        debugPrint('✅ MongoDB: Translation updated for "$text"');
      } else {
        // Insert new translation using your schema
        await collection.insertOne({
          'english': text.toLowerCase(),
          'language': dbLanguage,
          'translation': translation,
          'verified': true,
          'created_at': DateTime.now(),
          'updated_at': DateTime.now(),
        });
        debugPrint('✅ MongoDB: Translation saved for "$text"');
      }
      return true;
    } catch (e) {
      debugPrint('❌ MongoDB: Error saving translation: $e');
      return false;
    }
  }

  /// Get all translations for a specific language
  static Future<List<Map<String, dynamic>>> getTranslationsForLanguagePair({
    required String fromLanguage,
    required String toLanguage,
  }) async {
    if (!_isConnected || _db == null) {
      debugPrint('⚠️ MongoDB: Not connected, attempting to connect...');
      final connected = await connect();
      if (!connected) return [];
    }

    try {
      final collection = _db!.collection(_translationsCollection);
      
      // Convert ISO code to database format
      final dbLanguage = LanguageMapper.isoToDb(toLanguage);
      
      // Using your schema: query by language field only
      final results = await collection.find(where.eq('language', dbLanguage)).toList();
      
      debugPrint('ℹ️ MongoDB: Found ${results.length} translations for language: $dbLanguage');
      return results;
    } catch (e) {
      debugPrint('❌ MongoDB: Error fetching translations: $e');
      return [];
    }
  }

  /// Close database connection
  static Future<void> close() async {
    if (_db != null && _isConnected) {
      await _db!.close();
      _isConnected = false;
      debugPrint('ℹ️ MongoDB: Connection closed');
    }
  }

  /// Check if connected
  static bool get isConnected => _isConnected;
}
