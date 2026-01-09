# MongoDB Quick Reference Card

## 🎯 Quick Start

### 1. Connection is Already Set Up!
The app automatically connects to MongoDB when you start it.

### 2. How It Works
```
Translation Request
    ↓
MongoDB (fast!) ✅
    ↓ (if not found)
Google API (slower) ⚠️
    ↓ (saves to MongoDB)
Offline Fallback (last resort) 📖
```

## 📊 MongoDB Details

**Connection String:**
```
mongo_URL
```

**Database:** `vaanimitra`  
**Collection:** `translations`

## 🔍 View Your Data

### Using MongoDB Compass (GUI)
1. Download: https://www.mongodb.com/try/download/compass
2. Paste connection string above
3. Connect
4. Navigate to: `vaanimitra` → `translations`

### Using MongoDB Shell
```bash
mongosh "MONGO_DB_URL"
use vaanimitra
db.translations.find().limit(10)
```

## 📝 Add Translations Manually

### Single Translation
```javascript
db.translations.insertOne({
  text: "Good morning",
  fromLanguage: "en",
  toLanguage: "hi",
  translation: "सुप्रभात",
  createdAt: new Date(),
  updatedAt: new Date()
})
```

### Multiple Translations
```javascript
db.translations.insertMany([
  {
    text: "Thank you",
    fromLanguage: "en",
    toLanguage: "hi",
    translation: "धन्यवाद",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    text: "Welcome",
    fromLanguage: "en",
    toLanguage: "hi",
    translation: "स्वागत है",
    createdAt: new Date(),
    updatedAt: new Date()
  }
])
```

## 🔎 Query Translations

### Find by Text
```javascript
db.translations.find({ text: "Apple" })
```

### Find by Language Pair
```javascript
db.translations.find({
  fromLanguage: "en",
  toLanguage: "hi"
})
```

### Count Translations
```javascript
db.translations.countDocuments()
```

### List All English→Hindi
```javascript
db.translations.find(
  { fromLanguage: "en", toLanguage: "hi" },
  { text: 1, translation: 1, _id: 0 }
)
```

## 🚀 Performance Optimization

### Create Indexes (Do This Once!)
```javascript
// Unique index for lookups
db.translations.createIndex(
  { text: 1, fromLanguage: 1, toLanguage: 1 },
  { unique: true }
)

// Index for language pair queries
db.translations.createIndex({ fromLanguage: 1, toLanguage: 1 })
```

## 🐛 Troubleshooting

### Check Connection
```javascript
db.runCommand({ ping: 1 })
// Expected: { ok: 1 }
```

### Find Missing Translations
Run your app and watch console for:
```
ℹ️ MongoDB: No translation found for "XYZ"
```

### Clear Cache (if needed)
```javascript
db.translations.deleteMany({})
```

## 📱 Using in Your Code

### Get Translation
```dart
String? trans = await MongoDBService.getTranslation(
  text: 'Hello',
  fromLanguage: 'en',
  toLanguage: 'hi',
);
```

### Save Translation
```dart
await MongoDBService.saveTranslation(
  text: 'Hello',
  fromLanguage: 'en',
  toLanguage: 'hi',
  translation: 'नमस्ते',
);
```

## 🎨 Supported Languages

| Code | Language | Code | Language |
|------|----------|------|----------|
| en | English | hi | Hindi |
| ta | Tamil | te | Telugu |
| mr | Marathi | bn | Bengali |
| gu | Gujarati | kn | Kannada |
| ml | Malayalam | pa | Punjabi |
| or | Odia | as | Assamese |
| ur | Urdu | ne | Nepali |

## 📊 Useful Queries

### Find Untranslated
```javascript
db.translations.find({ translation: { $exists: false } })
```

### Recently Added
```javascript
db.translations.find().sort({ createdAt: -1 }).limit(10)
```

### Popular Translations (needs tracking field)
```javascript
db.translations.find().sort({ accessCount: -1 }).limit(20)
```

## 🔧 Maintenance

### Update Translation
```javascript
db.translations.updateOne(
  { text: "Apple", fromLanguage: "en", toLanguage: "hi" },
  { $set: { translation: "सेब", updatedAt: new Date() } }
)
```

### Delete Translation
```javascript
db.translations.deleteOne({
  text: "OldWord",
  fromLanguage: "en",
  toLanguage: "hi"
})
```

## 💡 Pro Tips

1. **Auto-Population**: Just use the app - translations will be saved automatically!
2. **Backup First**: Before bulk operations, export your data
3. **Test Queries**: Use `.limit(1)` when testing queries
4. **Monitor Logs**: Keep console open to see what's happening
5. **Index Early**: Create indexes before database grows large

## 🚨 Common Issues

**Can't connect?**
- Check internet connection
- Verify credentials
- Check MongoDB Atlas cluster status

**Translations not found?**
- Check spelling (case-sensitive!)
- Verify language codes (en, hi, ta, etc.)
- Look at debug logs

**Slow queries?**
- Create indexes (see Performance section)
- Check network latency

## 📞 Need Help?

1. Check debug console logs
2. Review `MONGODB_INTEGRATION.md`
3. Test with MongoDB Compass
4. Verify database schema

---

**Quick Test:**
```dart
// In your app, this should work:
String result = await TranslationService.translateText('Apple', 'hi', 'en');
// Expected: सेब
// Console: ✅ Translation from MongoDB: "Apple" → "सेब"
```
