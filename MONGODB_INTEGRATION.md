# MongoDB Integration Guide

## Overview
VaaniMitra now uses MongoDB Atlas as the primary source for translations, with Google Translate API as a fallback and caching mechanism.

## Architecture

### Translation Flow
1. **MongoDB First**: Check if translation exists in MongoDB database
2. **Google Translate API**: If not found, fetch from Google Translate
3. **Auto-Cache**: Automatically save new translations to MongoDB
4. **Offline Fallback**: Use hardcoded translations if both fail

## Database Structure

### Connection
- **URI**: `mongodb+srv://pujarachchh:FWcrDD77m3tAh9zQ@cluster0.m9pcbed.mongodb.net/`
- **Database**: `vaanimitra`
- **Collection**: `translations`

### Document Schema
```json
{
  "_id": ObjectId,
  "text": "Apple",
  "fromLanguage": "en",
  "toLanguage": "hi",
  "translation": "सेब",
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```

## Setup Instructions

### 1. Verify MongoDB Connection
The app automatically connects to MongoDB on startup. Check debug logs:
```
✅ MongoDB: Connected successfully to vaanimitra
```

### 2. Initialize Translation Service
In your `main.dart`, add initialization before running the app:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MongoDB connection
  await TranslationService.initialize();
  
  runApp(MyApp());
}
```

### 3. Using the Translation Service
The API remains unchanged:
```dart
String translated = await TranslationService.translateText(
  'Hello',
  'hi',  // target language
  'en',  // source language
);
```

## MongoDB Service API

### Connect to Database
```dart
bool connected = await MongoDBService.connect();
```

### Get Translation
```dart
String? translation = await MongoDBService.getTranslation(
  text: 'Hello',
  fromLanguage: 'en',
  toLanguage: 'hi',
);
```

### Save Translation
```dart
bool saved = await MongoDBService.saveTranslation(
  text: 'Hello',
  fromLanguage: 'en',
  toLanguage: 'hi',
  translation: 'नमस्ते',
);
```

### Get All Translations for Language Pair
```dart
List<Map<String, dynamic>> translations = 
  await MongoDBService.getTranslationsForLanguagePair(
    fromLanguage: 'en',
    toLanguage: 'hi',
  );
```

### Close Connection
```dart
await MongoDBService.close();
```

## Adding Missing Translations

### Option 1: Direct Database Insert (MongoDB Compass/Shell)
```javascript
db.translations.insertOne({
  text: "Goodbye",
  fromLanguage: "en",
  toLanguage: "hi",
  translation: "अलविदा",
  createdAt: new Date(),
  updatedAt: new Date()
})
```

### Option 2: Auto-Population via App Usage
Simply use the app - when a translation is not found in MongoDB, it will:
1. Fetch from Google Translate API
2. Automatically save to MongoDB
3. Use MongoDB for subsequent requests

### Option 3: Bulk Import via Script
Create a script to import CSV/JSON of translations:
```dart
void importTranslations() async {
  await MongoDBService.connect();
  
  final translations = [
    {'text': 'Good morning', 'from': 'en', 'to': 'hi', 'translation': 'सुप्रभात'},
    {'text': 'Good night', 'from': 'en', 'to': 'hi', 'translation': 'शुभ रात्रि'},
    // ... more translations
  ];
  
  for (var t in translations) {
    await MongoDBService.saveTranslation(
      text: t['text']!,
      fromLanguage: t['from']!,
      toLanguage: t['to']!,
      translation: t['translation']!,
    );
  }
}
```

## Supported Languages

The following language codes are supported:
- `en` - English
- `hi` - Hindi
- `ta` - Tamil
- `te` - Telugu
- `mr` - Marathi
- `bn` - Bengali
- `gu` - Gujarati
- `kn` - Kannada
- `ml` - Malayalam
- `pa` - Punjabi
- `or` - Odia
- `as` - Assamese
- `ur` - Urdu
- `ne` - Nepali

## Debug Logging

The MongoDB service provides detailed logging:
- ✅ Success operations
- ⚠️ Warnings (connection issues, retries)
- ❌ Errors (query failures, connection errors)
- ℹ️ Informational messages

Example logs:
```
🔄 MongoDB: Connecting to database...
✅ MongoDB: Connected successfully to vaanimitra
✅ MongoDB: Translation found for "Apple"
ℹ️ MongoDB: No translation found for "Goodbye" (en → hi)
✅ MongoDB: Translation saved for "Goodbye"
```

## Performance Benefits

1. **Reduced API Calls**: Cached translations reduce Google Translate API costs
2. **Faster Response**: MongoDB queries are faster than HTTP requests
3. **Offline Capability**: Pre-populated database enables offline mode
4. **Custom Translations**: Override API translations with domain-specific terms
5. **Analytics**: Track which translations are used most

## Troubleshooting

### Connection Issues
If you see:
```
❌ MongoDB: Connection failed: <error>
```

Check:
1. Internet connectivity
2. MongoDB Atlas cluster is running
3. IP whitelist allows your connection (0.0.0.0/0 for public access)
4. Credentials are correct

### Missing Translations
If translations aren't found:
1. Check debug logs for "No translation found" messages
2. Verify language codes match exactly
3. Check database directly via MongoDB Compass
4. Ensure text matches exactly (case-sensitive)

### Fallback Behavior
The app has 3 layers of fallback:
1. MongoDB → 2. Google Translate API → 3. Hardcoded offline translations

This ensures the app always provides some translation even if MongoDB and API are unavailable.

## Future Enhancements

- [ ] Add translation versioning
- [ ] Implement translation quality ratings
- [ ] Support pronunciation phonetics in database
- [ ] Add admin panel for translation management
- [ ] Implement translation suggestions from users
- [ ] Add analytics for popular translations
- [ ] Support multiple translation variants
- [ ] Add context-based translations

## Security Notes

⚠️ **Important**: The MongoDB connection string contains credentials. For production:
1. Move credentials to environment variables
2. Use MongoDB Realm for mobile authentication
3. Implement proper access controls
4. Rotate credentials regularly
5. Use IP whitelisting
6. Enable audit logging

## Contact

For issues or questions about MongoDB integration:
- Check debug logs first
- Verify database schema matches documentation
- Test connection with MongoDB Compass
- Review error messages carefully
