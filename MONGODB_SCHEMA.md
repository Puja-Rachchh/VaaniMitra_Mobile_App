# MongoDB Schema Mapping

## Your Database Schema

```json
{
  "_id": "6910d877a3e70bd99db01776",
  "english": "apple",
  "language": "hindi",
  "translation": "सेब",
  "verified": true,
  "created_at": "2025-11-09T18:07:51.077+00:00",
  "updated_at": "2025-11-09T18:07:51.077+00:00"
}
```

## Schema Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `_id` | ObjectId | Unique document ID | Auto-generated |
| `english` | String | English word (lowercase) | "apple" |
| `language` | String | Target language (full name) | "hindi" |
| `translation` | String | Translated word | "सेब" |
| `verified` | Boolean | Translation verified flag | true |
| `created_at` | Date | Creation timestamp | ISO 8601 |
| `updated_at` | Date | Last update timestamp | ISO 8601 |

## Language Code Mapping

The app uses ISO 639-1 codes (hi, ta, te), but your database uses full language names.

### Automatic Conversion

| ISO Code | Database Name | Language |
|----------|---------------|----------|
| `en` | `english` | English |
| `hi` | `hindi` | Hindi |
| `ta` | `tamil` | Tamil |
| `te` | `telugu` | Telugu |
| `mr` | `marathi` | Marathi |
| `bn` | `bengali` | Bengali |
| `gu` | `gujarati` | Gujarati |
| `kn` | `kannada` | Kannada |
| `ml` | `malayalam` | Malayalam |
| `pa` | `punjabi` | Punjabi |
| `or` | `odia` | Odia |
| `as` | `assamese` | Assamese |
| `ur` | `urdu` | Urdu |
| `ne` | `nepali` | Nepali |

**The `LanguageMapper` utility automatically converts between these formats.**

## Query Examples

### Find Translation
```javascript
db.translations.findOne({
  english: "apple",
  language: "hindi"
})
```

### Insert Translation
```javascript
db.translations.insertOne({
  english: "banana",
  language: "hindi",
  translation: "केला",
  verified: true,
  created_at: new Date(),
  updated_at: new Date()
})
```

### Update Translation
```javascript
db.translations.updateOne(
  { english: "apple", language: "hindi" },
  { 
    $set: { 
      translation: "सेब",
      updated_at: new Date() 
    }
  }
)
```

### Find All Translations for a Language
```javascript
db.translations.find({ language: "hindi" })
```

## Important Notes

1. **Lowercase English**: Always store English words in lowercase
   ```javascript
   english: "apple"  // ✅ Correct
   english: "Apple"  // ❌ Wrong
   ```

2. **Full Language Names**: Use full names, not ISO codes
   ```javascript
   language: "hindi"  // ✅ Correct
   language: "hi"     // ❌ Wrong
   ```

3. **Verified Flag**: Should be set to `true` for production translations
   ```javascript
   verified: true   // For reviewed translations
   verified: false  // For auto-generated translations
   ```

4. **Case Sensitivity**: Queries are case-sensitive
   ```javascript
   // This will NOT find { english: "Apple" }
   db.translations.findOne({ english: "apple" })
   ```

## Index Recommendations

Create these indexes for optimal performance:

```javascript
// Unique index for lookups
db.translations.createIndex(
  { english: 1, language: 1 },
  { unique: true }
)

// Index for language queries
db.translations.createIndex({ language: 1 })

// Index for verified flag
db.translations.createIndex({ verified: 1 })
```

## How the App Uses This Schema

1. **User selects Hindi (ISO code: hi)**
2. **App converts to "hindi" using LanguageMapper**
3. **Queries MongoDB:**
   ```javascript
   { english: "apple", language: "hindi" }
   ```
4. **Returns:** `{ translation: "सेब" }`

## Adding Bulk Translations

### Via MongoDB Compass
1. Connect to your cluster
2. Navigate to `vaanimitra.translations`
3. Click "Insert Document"
4. Paste JSON array:
```json
[
  {
    "english": "apple",
    "language": "hindi",
    "translation": "सेब",
    "verified": true,
    "created_at": {"$date": "2025-11-09T00:00:00.000Z"},
    "updated_at": {"$date": "2025-11-09T00:00:00.000Z"}
  },
  {
    "english": "banana",
    "language": "hindi",
    "translation": "केला",
    "verified": true,
    "created_at": {"$date": "2025-11-09T00:00:00.000Z"},
    "updated_at": {"$date": "2025-11-09T00:00:00.000Z"}
  }
]
```

### Via MongoDB Shell
```javascript
use vaanimitra

db.translations.insertMany([
  {
    english: "mango",
    language: "hindi",
    translation: "आम",
    verified: true,
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    english: "orange",
    language: "hindi",
    translation: "संतरा",
    verified: true,
    created_at: new Date(),
    updated_at: new Date()
  }
])
```

## Troubleshooting

### Translation Not Found
Check:
1. English word is lowercase: `"apple"` not `"Apple"`
2. Language is full name: `"hindi"` not `"hi"`
3. Document exists in database
4. No typos in english word

### Duplicate Key Error
The combination of `english` + `language` must be unique.
If inserting duplicate, use `updateOne` instead:
```javascript
db.translations.updateOne(
  { english: "apple", language: "hindi" },
  { 
    $set: { translation: "सेब" },
    $setOnInsert: { created_at: new Date(), verified: true },
    $currentDate: { updated_at: true }
  },
  { upsert: true }
)
```

## Testing

After updating schema, test with:
```dart
// Should now work with your database!
String? translation = await MongoDBService.getTranslation(
  text: 'Apple',  // Will be converted to lowercase
  fromLanguage: 'en',
  toLanguage: 'hi',  // Will be converted to 'hindi'
);
// Expected: सेब
```

Console output:
```
🔍 MongoDB: Querying for english="apple", language="hindi"
   Query result: Found document
✅ MongoDB: Translation found for "Apple" → "सेब"
```
