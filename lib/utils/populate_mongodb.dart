import 'package:flutter/foundation.dart';
import '../services/mongodb_service.dart';

/// Utility to populate MongoDB with translations from hardcoded data
/// This should be run once to seed the database
class MongoDBPopulator {
  static Future<void> populateTranslations() async {
    debugPrint('🚀 Starting MongoDB population...');
    
    // Connect to MongoDB
    final connected = await MongoDBService.connect();
    if (!connected) {
      debugPrint('❌ Failed to connect to MongoDB');
      return;
    }

    int successCount = 0;
    int errorCount = 0;

    // Fruits translations
    final fruits = [
      {'en': 'Apple', 'hi': 'सेब'},
      {'en': 'Banana', 'hi': 'केला'},
      {'en': 'Mango', 'hi': 'आम'},
      {'en': 'Orange', 'hi': 'संतरा'},
      {'en': 'Grapes', 'hi': 'अंगूर'},
      {'en': 'Watermelon', 'hi': 'तरबूज'},
      {'en': 'Pineapple', 'hi': 'अनानास'},
      {'en': 'Papaya', 'hi': 'पपीता'},
      {'en': 'Cherry', 'hi': 'चेरी'},
      {'en': 'Kiwi', 'hi': 'कीवी'},
      {'en': 'Lychee', 'hi': 'लीची'},
      {'en': 'Pear', 'hi': 'नाशपाती'},
      {'en': 'Pomegranate', 'hi': 'अनार'},
      {'en': 'Strawberry', 'hi': 'स्ट्रॉबेरी'},
      {'en': 'Sugarcane', 'hi': 'गन्ना'},
    ];

    debugPrint('📝 Populating fruits...');
    for (var fruit in fruits) {
      try {
        // Note: Using 'hindi' as language code to match your schema
        await MongoDBService.saveTranslation(
          text: fruit['en']!,
          fromLanguage: 'en',
          toLanguage: 'hindi',
          translation: fruit['hi']!,
        );
        successCount++;
      } catch (e) {
        debugPrint('❌ Error saving ${fruit['en']}: $e');
        errorCount++;
      }
    }

    // Vegetables
    final vegetables = [
      {'en': 'Potato', 'hi': 'आलू'},
      {'en': 'Tomato', 'hi': 'टमाटर'},
      {'en': 'Onion', 'hi': 'प्याज'},
      {'en': 'Cabbage', 'hi': 'पत्ता गोभी'},
      {'en': 'Spinach', 'hi': 'पालक'},
      {'en': 'Cauliflower', 'hi': 'फूल गोभी'},
      {'en': 'Brinjal', 'hi': 'बैंगन'},
      {'en': 'Bitter Gourd', 'hi': 'करेला'},
      {'en': 'Bottle Gourd', 'hi': 'लौकी'},
      {'en': 'Capsicum', 'hi': 'शिमला मिर्च'},
      {'en': 'Chilli', 'hi': 'मिर्च'},
      {'en': 'Lady Finger', 'hi': 'भिंडी'},
      {'en': 'Mushroom', 'hi': 'मशरूम'},
      {'en': 'Pumpkin', 'hi': 'कद्दू'},
    ];

    debugPrint('📝 Populating vegetables...');
    for (var veg in vegetables) {
      try {
        await MongoDBService.saveTranslation(
          text: veg['en']!,
          fromLanguage: 'en',
          toLanguage: 'hi',
          translation: veg['hi']!,
        );
        successCount++;
      } catch (e) {
        debugPrint('❌ Error saving ${veg['en']}: $e');
        errorCount++;
      }
    }

    // Animals
    final animals = [
      {'en': 'Bear', 'hi': 'भालू'},
      {'en': 'Butterfly', 'hi': 'तितली'},
      {'en': 'Camel', 'hi': 'ऊंट'},
      {'en': 'Cat', 'hi': 'बिल्ली'},
      {'en': 'Cow', 'hi': 'गाय'},
      {'en': 'Crane', 'hi': 'सारस'},
      {'en': 'Crow', 'hi': 'कौवा'},
      {'en': 'Dog', 'hi': 'कुत्ता'},
      {'en': 'Donkey', 'hi': 'गधा'},
      {'en': 'Duck', 'hi': 'बत्तख'},
      {'en': 'Eagle', 'hi': 'चील'},
      {'en': 'Elephant', 'hi': 'हाथी'},
      {'en': 'Fish', 'hi': 'मछली'},
      {'en': 'Flamingo', 'hi': 'फ्लेमिंगो'},
      {'en': 'Fox', 'hi': 'लोमड़ी'},
      {'en': 'Goat', 'hi': 'बकरी'},
      {'en': 'Hen', 'hi': 'मुर्गी'},
      {'en': 'Horse', 'hi': 'घोड़ा'},
      {'en': 'Lion', 'hi': 'शेर'},
      {'en': 'Monkey', 'hi': 'बंदर'},
      {'en': 'Mouse', 'hi': 'चूहा'},
      {'en': 'Owl', 'hi': 'उल्लू'},
      {'en': 'Parrot', 'hi': 'तोता'},
      {'en': 'Peacock', 'hi': 'मोर'},
      {'en': 'Pigeon', 'hi': 'कबूतर'},
      {'en': 'Rabbit', 'hi': 'खरगोश'},
      {'en': 'Sheep', 'hi': 'भेड़'},
      {'en': 'Snake', 'hi': 'सांप'},
      {'en': 'Tiger', 'hi': 'बाघ'},
    ];

    debugPrint('📝 Populating animals...');
    for (var animal in animals) {
      try {
        await MongoDBService.saveTranslation(
          text: animal['en']!,
          fromLanguage: 'en',
          toLanguage: 'hi',
          translation: animal['hi']!,
        );
        successCount++;
      } catch (e) {
        debugPrint('❌ Error saving ${animal['en']}: $e');
        errorCount++;
      }
    }

    debugPrint('✅ Population complete!');
    debugPrint('   Success: $successCount');
    debugPrint('   Errors: $errorCount');
  }
}
