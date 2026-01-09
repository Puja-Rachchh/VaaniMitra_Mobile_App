# Troubleshooting MongoDB Connection

Based on your logs, here's what's happening and how to fix it:

## Current Issue

The app is:
1. ❌ NOT connecting to MongoDB successfully
2. ❌ NOT calling Google Translate API
3. ✅ Falling back to offline translations

## Diagnostic Steps

### Step 1: Check MongoDB Connection

Run the app and look for these logs at startup:

**Expected (Success):**
```
🔄 MongoDB: Connecting to database...
   Connection string: mongodb+srv://...
✅ MongoDB: Connected successfully to vaanimitra
   Collections available: [...]
✅ TranslationService: MongoDB initialized
```

**If you see (Failure):**
```
❌ MongoDB: Connection failed: ...
⚠️ TranslationService: MongoDB connection failed, using fallback
```

**Common causes:**
- No internet connection
- MongoDB Atlas cluster is paused/stopped
- IP not whitelisted (set to 0.0.0.0/0 for testing)
- Wrong credentials

### Step 2: Test Google Translate API

Look for these logs when requesting translation:

**Expected (if MongoDB fails):**
```
🌐 Attempting Google Translate API...
   API Key available: true
   API Response status: 200
✅ Translation from Google API: "Apple" → "सेब"
```

**If API fails:**
```
   API Response status: 403 (or other error)
❌ API returned error: 403 - {...}
```

**Common causes:**
- API key not enabled
- API key restrictions
- Billing not enabled on Google Cloud

## Quick Fix Options

### Option 1: Populate MongoDB Manually (Recommended)

1. Open MongoDB Compass
2. Connect using: `mongodb+srv://pujarachchh:FWcrDD77m3tAh9zQ@cluster0.m9pcbed.mongodb.net/`
3. Navigate to database: `vaanimitra`
4. Create collection: `translations` (if doesn't exist)
5. Insert sample document:
```json
{
  "text": "Apple",
  "fromLanguage": "en",
  "toLanguage": "hi",
  "translation": "सेब",
  "createdAt": {"$date": "2025-01-09T00:00:00.000Z"},
  "updatedAt": {"$date": "2025-01-09T00:00:00.000Z"}
}
```

### Option 2: Use the Populator Script

1. Edit `lib/main.dart`
2. Uncomment this line:
```dart
await MongoDBPopulator.populateTranslations();
```
3. Run the app once (it will populate the database)
4. Comment the line again
5. Run the app normally

### Option 3: Check MongoDB Atlas

1. Go to https://cloud.mongodb.com/
2. Login with your account
3. Check if cluster is running
4. Go to "Network Access" → Add IP Address → Allow from Anywhere (0.0.0.0/0)
5. Go to "Database Access" → Verify user `pujarachchh` exists

### Option 4: Fix Google Translate API

1. Go to https://console.cloud.google.com/
2. Select your project
3. Enable "Cloud Translation API"
4. Enable billing (required for API to work)
5. Check API key is not restricted

## Expected Logs After Fix

### With Working MongoDB:
```
📝 Translation request: "Apple" (en → hi)
🔍 MongoDB: Querying for text="Apple", from="en", to="hi"
   Query result: Found document
✅ MongoDB: Translation found for "Apple" → "सेब"
✅ Translation from MongoDB: "Apple" → "सेब"
```

### With Working Google API (if MongoDB empty):
```
📝 Translation request: "Apple" (en → hi)
🔍 MongoDB: Querying for text="Apple", from="en", to="hi"
   Query result: No document found
ℹ️ MongoDB: No translation found for "Apple" (en → hi)
   Total documents in collection: 0
🌐 Attempting Google Translate API...
   API Key available: true
   API Response status: 200
✅ Translation from Google API: "Apple" → "सेब"
   Saving to MongoDB...
✅ MongoDB: Translation saved for "Apple"
```

## Testing the Fix

After implementing a fix, test with:

1. **Stop the app**
2. **Clear app data** (to ensure fresh start)
3. **Run app** with enhanced logging
4. **Navigate to Fruits screen**
5. **Watch console** for detailed logs

The logs will tell you exactly what's working and what's not.

## Quick Database Population via MongoDB Shell

If you have MongoDB shell installed:

```bash
mongosh "mongodb+srv://pujarachchh:FWcrDD77m3tAh9zQ@cluster0.m9pcbed.mongodb.net/"

use vaanimitra

db.translations.insertMany([
  {
    text: "Apple",
    fromLanguage: "en",
    toLanguage: "hi",
    translation: "सेब",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    text: "Banana",
    fromLanguage: "en",
    toLanguage: "hi",
    translation: "केला",
    createdAt: new Date(),
    updatedAt: new Date()
  }
])
```

## Next Steps

1. Run the app with enhanced logging
2. Copy the full console output showing:
   - MongoDB connection attempt
   - First translation request
   - Any error messages
3. Based on the logs, we can identify the exact issue

The enhanced logging I just added will show you exactly where the problem is!
