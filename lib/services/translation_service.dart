import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _apiKey = 'AIzaSyBkHfzZU2crbS1a2WPE-DQZCFaNEBDR9LA';
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';

  static Future<String> translateText(String text, String targetLanguage, String sourceLanguage) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'source': sourceLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        // Fallback to offline translation
        return _getFallbackTranslation(text, targetLanguage, sourceLanguage);
      }
    } catch (e) {
      // If API fails, use fallback translation
      return _getFallbackTranslation(text, targetLanguage, sourceLanguage);
    }
  }

  static String _getFallbackTranslation(String text, String targetLanguage, String sourceLanguage) {
    // Common fruits and vegetables translations
    Map<String, Map<String, String>> fruitVegetableMapping = {
      // Fruits
      'Apple': {'hi': 'सेब', 'ta': 'ஆப்பிள்', 'te': 'ఆపిల్', 'bn': 'আপেল', 'mr': 'सफरचंद', 'gu': 'સફરજન', 'kn': 'ಸೇಬು', 'ml': 'ആപ്പിൾ', 'pa': 'ਸੇਬ', 'or': 'ଆପଲ', 'as': 'আপেল', 'ur': 'سیب', 'ne': 'स्याउ', 'en': 'Apple'},
      'Banana': {'hi': 'केला', 'ta': 'வாழைப்பழம்', 'te': 'అరటిపండు', 'bn': 'কলা', 'mr': 'केळी', 'gu': 'કેળું', 'kn': 'ಬಾಳೆಹಣ್ಣು', 'ml': 'വാഴപ്പഴം', 'pa': 'ਕੇਲਾ', 'or': 'କଦଳୀ', 'as': 'কল', 'ur': 'کیلا', 'ne': 'केरा', 'en': 'Banana'},
      'Mango': {'hi': 'आम', 'ta': 'மாம்பழம்', 'te': 'మామిడిపండు', 'bn': 'আম', 'mr': 'आंबा', 'gu': 'કેરી', 'kn': 'ಮಾವಿನಹಣ್ಣು', 'ml': 'മാങ്ങ', 'pa': 'ਅੰਬ', 'or': 'ଆମ୍ବ', 'as': 'আম', 'ur': 'آم', 'ne': 'आँप', 'en': 'Mango'},
      'Orange': {'hi': 'संतरा', 'ta': 'ஆரஞ்சு', 'te': 'నారింజ', 'bn': 'কমলা', 'mr': 'संत्री', 'gu': 'નારંગી', 'kn': 'ಕಿತ್ತಳೆ', 'ml': 'ഓറഞ്ച്', 'pa': 'ਸੰਤਰਾ', 'or': 'କମଳା', 'as': 'কমলা', 'ur': 'سنترہ', 'ne': 'सुन्तला', 'en': 'Orange'},
      'Grapes': {'hi': 'अंगूर', 'ta': 'திராட்சை', 'te': 'ద్రాక్ష', 'bn': 'আঙুর', 'mr': 'द्राक्ष', 'gu': 'દ્રાક્ષ', 'kn': 'ದ್ರಾಕ್ಷಿ', 'ml': 'മുന്തിരി', 'pa': 'ਅੰਗੂਰ', 'or': 'ଅଙ୍ଗୁର', 'as': 'আঙুৰ', 'ur': 'انگور', 'ne': 'अंगुर', 'en': 'Grapes'},
      'Watermelon': {'hi': 'तरबूज', 'ta': 'தர்பூசணி', 'te': 'పుచ్చకాయ', 'bn': 'তরমুজ', 'mr': 'टरबूज', 'gu': 'તરબૂચ', 'kn': 'ಕಲ್ಲಂಗಡಿ', 'ml': 'തണ്ണിമത്തൻ', 'pa': 'ਤਰਬੂਜ', 'or': 'ତରଭୁଜ', 'as': 'তৰমুজ', 'ur': 'تربوز', 'ne': 'खर्बुजा', 'en': 'Watermelon'},
      'Pineapple': {'hi': 'अनानास', 'ta': 'அன்னாசி', 'te': 'అనాసపండు', 'bn': 'আনারস', 'mr': 'अननस', 'gu': 'અનાનસ', 'kn': 'ಅನಾನಸ್', 'ml': 'കൈതച്ചക്ക', 'pa': 'ਅਨਾਨਾਸ', 'or': 'ଅନାନାସ', 'as': 'আনাৰস', 'ur': 'انناس', 'ne': 'भुई कटहर', 'en': 'Pineapple'},
      'Papaya': {'hi': 'पपीता', 'ta': 'பப்பாளி', 'te': 'బొప్పాయి', 'bn': 'পেঁপে', 'mr': 'पपई', 'gu': 'પપૈયું', 'kn': 'ಪಪ್ಪಾಯಿ', 'ml': 'പപ്പായ', 'pa': 'ਪਪੀਤਾ', 'or': 'ଅମୃତଭଣ୍ଡା', 'as': 'অমিতা', 'ur': 'پپیتا', 'ne': 'मेवा', 'en': 'Papaya'},
      'Cherry': {'hi': 'चेरी', 'ta': 'செர்ரி', 'te': 'చెర్రీ', 'bn': 'চেরি', 'mr': 'चेरी', 'gu': 'ચેરી', 'kn': 'ಚೆರ್ರಿ', 'ml': 'ചെറി', 'pa': 'ਚੈਰੀ', 'or': 'ଚେରୀ', 'as': 'চেৰী', 'ur': 'چیری', 'ne': 'चेरी', 'en': 'Cherry'},
      'Kiwi': {'hi': 'कीवी', 'ta': 'கீவி', 'te': 'కివీ', 'bn': 'কিউই', 'mr': 'किवी', 'gu': 'કીવી', 'kn': 'ಕಿವಿ', 'ml': 'കിവി', 'pa': 'ਕੀਵੀ', 'or': 'କିଭି', 'as': 'কিৱি', 'ur': 'کیوی', 'ne': 'किवी', 'en': 'Kiwi'},
      'Lychee': {'hi': 'लीची', 'ta': 'லிச்சி', 'te': 'లీచీ', 'bn': 'লিচু', 'mr': 'लिची', 'gu': 'લીચી', 'kn': 'ಲೀಚಿ', 'ml': 'ലിച്ചി', 'pa': 'ਲੀਚੀ', 'or': 'ଲିଚୁ', 'as': 'লিচু', 'ur': 'لیچی', 'ne': 'लिच्ची', 'en': 'Lychee'},
      'Lichi': {'hi': 'लीची', 'ta': 'லிச்சி', 'te': 'లీచీ', 'bn': 'লিচু', 'mr': 'लिची', 'gu': 'લીચી', 'kn': 'ಲೀಚಿ', 'ml': 'ലিച്ചി', 'pa': 'ਲੀਚੀ', 'or': 'ଲିଚୁ', 'as': 'লিচু', 'ur': 'لیچی', 'ne': 'लिच्ची', 'en': 'Lichi'},
      'Pear': {'hi': 'नाशपाती', 'ta': 'பேரிக்காய்', 'te': 'బేరిక్కాయ', 'bn': 'নাশপাতি', 'mr': 'नाशपाती', 'gu': 'નાશપાતી', 'kn': 'ನಾಶಪಾತಿ', 'ml': 'പിയർ', 'pa': 'ਨਾਸ਼ਪਾਤੀ', 'or': 'ନାସପାତି', 'as': 'নাশপাতি', 'ur': 'ناشپاتی', 'ne': 'नाशपाती', 'en': 'Pear'},
      'Pomegranate': {'hi': 'अनार', 'ta': 'மாதுளம்', 'te': 'దానిమ్మ', 'bn': 'ডালিম', 'mr': 'डाळिंब', 'gu': 'દાડમ', 'kn': 'ದಾಳಿಂಬೆ', 'ml': 'മാതളനാരകം', 'pa': 'ਅਨਾਰ', 'or': 'ଡାଳିମ୍ବ', 'as': 'ডালিম', 'ur': 'انار', 'ne': 'अनार', 'en': 'Pomegranate'},
      'Strawberry': {'hi': 'स्ट्रॉबेरी', 'ta': 'ஸ்ட்ராபெர்ரி', 'te': 'స్ట్రాబెర్రీ', 'bn': 'স্ট্রবেরি', 'mr': 'स्ट्रॉबेरी', 'gu': 'સ્ટ્રોબેરી', 'kn': 'ಸ್ಟ್ರಾಬೆರಿ', 'ml': 'സ്ട്രോബെറി', 'pa': 'ਸਟ੍ਰਾਬੇਰੀ', 'or': 'ଷ୍ଟ୍ରବେରୀ', 'as': 'ষ্ট্ৰবেৰী', 'ur': 'اسٹرابیری', 'ne': 'स्ट्रबेरी', 'en': 'Strawberry'},
      'Sugarcane': {'hi': 'गन्ना', 'ta': 'கரும்பு', 'te': 'చెరకు', 'bn': 'আখ', 'mr': 'ऊस', 'gu': 'શેરડી', 'kn': 'ಕಬ್ಬು', 'ml': 'കരിമ്പ്', 'pa': 'ਗੰਨਾ', 'or': 'ଆଖୁ', 'as': 'আখ', 'ur': 'گنا', 'ne': 'उखु', 'en': 'Sugarcane'},
      
      // Vegetables
      'Potato': {'hi': 'आलू', 'ta': 'உருளைக்கிழங்கு', 'te': 'బంగాళాదుంప', 'bn': 'আলু', 'mr': 'बटाटा', 'gu': 'બટાકા', 'kn': 'ಆಲೂಗೆಡ್ಡೆ', 'ml': 'ഉരുളക്കിഴങ്ങ്', 'pa': 'ਆਲੂ', 'or': 'ଆଳୁ', 'as': 'আলু', 'ur': 'آلو', 'ne': 'आलु', 'en': 'Potato'},
      'Tomato': {'hi': 'टमाटर', 'ta': 'தக்காளி', 'te': 'టమోటా', 'bn': 'টমেটো', 'mr': 'टोमॅटो', 'gu': 'ટમેટાં', 'kn': 'ಟೊಮೇಟೊ', 'ml': 'തക്കാളി', 'pa': 'ਟਮਾਟਰ', 'or': 'ଟମାଟୋ', 'as': 'বিলাহী', 'ur': 'ٹماٹر', 'ne': 'गोलभेडा', 'en': 'Tomato'},
      'Onion': {'hi': 'प्याज', 'ta': 'வெங்காயம்', 'te': 'ఉల్లిపాయ', 'bn': 'পেঁয়াজ', 'mr': 'कांदा', 'gu': 'ડુંગળી', 'kn': 'ಈರುಳ್ಳಿ', 'ml': 'സവാള', 'pa': 'ਪਿਆਜ਼', 'or': 'ପିଆଜ', 'as': 'পিয়াঁজ', 'ur': 'پیاز', 'ne': 'प्याज', 'en': 'Onion'},
      'Cabbage': {'hi': 'पत्ता गोभी', 'ta': 'முட்டைகோஸ்', 'te': 'కాబేజీ', 'bn': 'বাঁধাকপি', 'mr': 'कोबी', 'gu': 'કોબી', 'kn': 'ಎಲೆಕೋಸು', 'ml': 'കാബേജ്', 'pa': 'ਬੰਦ ਗੋਭੀ', 'or': 'ବନ୍ଧାକୋବି', 'as': 'বন্ধাকবি', 'ur': 'بند گوبھی', 'ne': 'बन्दागोभी', 'en': 'Cabbage'},
      'Spinach': {'hi': 'पालक', 'ta': 'கீரை', 'te': 'పాలకూర', 'bn': 'পালং শাক', 'mr': 'पालक', 'gu': 'પાલક', 'kn': 'ಸೊಪ್ಪು', 'ml': 'ചീര', 'pa': 'ਪਾਲਕ', 'or': 'ପାଳଙ୍ଗ', 'as': 'পালেং', 'ur': 'پالک', 'ne': 'पालुङ्गो', 'en': 'Spinach'},
      'Cauliflower': {'hi': 'फूल गोभी', 'ta': 'காலிஃப்ளவர்', 'te': 'కాలిఫ్లవర్', 'bn': 'ফুলকপি', 'mr': 'फुलकोबी', 'gu': 'ફૂલકોબી', 'kn': 'ಹೂಕೋಸು', 'ml': 'കോളിഫ്‌ളവർ', 'pa': 'ਫੁੱਲ ਗੋਭੀ', 'or': 'ଫୁଲକୋବି', 'as': 'ফুলকবি', 'ur': 'پھول گوبھی', 'ne': 'काउली', 'en': 'Cauliflower'},
      'Brinjal': {'hi': 'बैंगन', 'ta': 'கத்தரிக்காய்', 'te': 'వంకాయ', 'bn': 'বেগুন', 'mr': 'वांगी', 'gu': 'રીંગણ', 'kn': 'ಬದನೆಕಾಯಿ', 'ml': 'വഴുതന', 'pa': 'ਬੈਂਗਣ', 'or': 'ବାଇଗଣ', 'as': 'বেঙেনা', 'ur': 'بینگن', 'ne': 'भन्टा', 'en': 'Brinjal'},
      'Bitter Gourd': {'hi': 'करेला', 'ta': 'பாகற்காய்', 'te': 'కాకరకాయ', 'bn': 'করলা', 'mr': 'कारळे', 'gu': 'કારેલું', 'kn': 'ಹಾಗಲಕಾಯಿ', 'ml': 'കയ്പക്ക', 'pa': 'ਕਰੇਲਾ', 'or': 'କଳରା', 'as': 'তিতা কেৰেলা', 'ur': 'کریلا', 'ne': 'तीतो करेला', 'en': 'Bitter Gourd'},
      'Bottle Gourd': {'hi': 'लौकी', 'ta': 'சுரைக்காய்', 'te': 'సొరకాయ', 'bn': 'লাউ', 'mr': 'दूधी', 'gu': 'દૂધી', 'kn': 'ಸೋರೆಕಾಯಿ', 'ml': 'ചുരക്ക', 'pa': 'ਲੌਕੀ', 'or': 'ଲାଉ', 'as': 'লাও', 'ur': 'لوکی', 'ne': 'लौका', 'en': 'Bottle Gourd'},
      'Capsicum': {'hi': 'शिमला मिर्च', 'ta': 'குடைமிளகாய்', 'te': 'కాప్సికం', 'bn': 'ক্যাপসিকাম', 'mr': 'भोपली मिर्ची', 'gu': 'ભોપળી મરચું', 'kn': 'ದೊಣ್ಣೆ ಮೆಣಸಿನಕಾಯಿ', 'ml': 'കാപ്സികം', 'pa': 'ਸ਼ਿਮਲਾ ਮਿਰਚ', 'or': 'କାପସିକମ', 'as': 'কেপছিকাম', 'ur': 'شملہ مرچ', 'ne': 'भेडे खुर्सानी', 'en': 'Capsicum'},
      'Chilli': {'hi': 'मिर्च', 'ta': 'மிளகாய்', 'te': 'మిర్చి', 'bn': 'মরিচ', 'mr': 'मिर्ची', 'gu': 'મરચું', 'kn': 'ಮೆಣಸಿನಕಾಯಿ', 'ml': 'മുളക്', 'pa': 'ਮਿਰਚ', 'or': 'ଲଙ୍କା', 'as': 'জলকীয়া', 'ur': 'مرچ', 'ne': 'खुर्सानी', 'en': 'Chilli'},
      'Lady Finger': {'hi': 'भिंडी', 'ta': 'வெண்டைக்காய்', 'te': 'బెండకాయ', 'bn': 'ঢেঁড়স', 'mr': 'भेंडी', 'gu': 'ભીંડા', 'kn': 'ಬೆಂಡೆಕಾಯಿ', 'ml': 'വെണ്ടക്ക', 'pa': 'ਭਿੰਡੀ', 'or': 'ଭେଣ୍ଡି', 'as': 'ভিন্ডি', 'ur': 'بھنڈی', 'ne': 'भिन्डी', 'en': 'Lady Finger'},
      'Mushroom': {'hi': 'मशरूम', 'ta': 'காளான்', 'te': 'కుక్కగుడ్లు', 'bn': 'মাশরুম', 'mr': 'मशरूम', 'gu': 'મશરૂમ', 'kn': 'ಅಣಬೆ', 'ml': 'കൂൺ', 'pa': 'ਖੁੰਭ', 'or': 'ମସରୁମ', 'as': 'মাশৰুম', 'ur': 'مشروم', 'ne': 'च्याउ', 'en': 'Mushroom'},
      'Pumpkin': {'hi': 'कद्दू', 'ta': 'பூசணிக்காய்', 'te': 'గుమ్మడికాయ', 'bn': 'কুমড়া', 'mr': 'भोपळा', 'gu': 'કોળું', 'kn': 'ಕುಂಬಳಕಾಯಿ', 'ml': 'മത്തൻ', 'pa': 'ਕੱਦੂ', 'or': 'କାଖାରୁ', 'as': 'ৰাংগা লাও', 'ur': 'کدو', 'ne': 'फर्सी', 'en': 'Pumpkin'},
    };

    // For individual letters, create meaningful phonetic equivalents
    Map<String, Map<String, String>> letterPhoneticMapping = {
      // Hindi vowels to English phonetics
      'अ': {'en': 'A (as in "but")', 'hi': 'अ', 'ta': 'அ', 'te': 'అ', 'bn': 'অ', 'mr': 'अ', 'gu': 'અ', 'kn': 'ಅ', 'ml': 'അ', 'pa': 'ਅ', 'or': 'ଅ', 'as': 'অ', 'ur': 'ا', 'ne': 'अ'},
      'आ': {'en': 'AA (as in "father")', 'hi': 'आ', 'ta': 'ஆ', 'te': 'ఆ', 'bn': 'আ', 'mr': 'आ', 'gu': 'આ', 'kn': 'ಆ', 'ml': 'ആ', 'pa': 'ਆ', 'or': 'ଆ', 'as': 'আ', 'ur': 'آ', 'ne': 'आ'},
      'इ': {'en': 'I (as in "bit")', 'hi': 'इ', 'ta': 'இ', 'te': 'ఇ', 'bn': 'ই', 'mr': 'इ', 'gu': 'ઇ', 'kn': 'ಇ', 'ml': 'ഇ', 'pa': 'ਇ', 'or': 'ଇ', 'as': 'ই', 'ur': 'ی', 'ne': 'इ'},
      'ई': {'en': 'EE (as in "beet")', 'hi': 'ई', 'ta': 'ஈ', 'te': 'ఈ', 'bn': 'ঈ', 'mr': 'ई', 'gu': 'ઈ', 'kn': 'ಈ', 'ml': 'ഈ', 'pa': 'ਈ', 'or': 'ଈ', 'as': 'ঈ', 'ur': 'ی', 'ne': 'ई'},
      'उ': {'en': 'U (as in "put")', 'hi': 'उ', 'ta': 'உ', 'te': 'ఉ', 'bn': 'উ', 'mr': 'उ', 'gu': 'ઉ', 'kn': 'ಉ', 'ml': 'ഉ', 'pa': 'ਉ', 'or': 'ଉ', 'as': 'উ', 'ur': 'و', 'ne': 'उ'},
      // English letters to various scripts
      'A': {'hi': 'अ', 'ta': 'அ', 'te': 'అ', 'bn': 'অ', 'mr': 'अ', 'gu': 'અ', 'kn': 'ಅ', 'ml': 'അ', 'pa': 'ਅ', 'or': 'ଅ', 'as': 'অ', 'ur': 'ا', 'ne': 'अ', 'en': 'A'},
      'B': {'hi': 'ब', 'ta': 'ப', 'te': 'బ', 'bn': 'ব', 'mr': 'ब', 'gu': 'બ', 'kn': 'ಬ', 'ml': 'ബ', 'pa': 'ਬ', 'or': 'ବ', 'as': 'ব', 'ur': 'ب', 'ne': 'ब', 'en': 'B'},
      'C': {'hi': 'स', 'ta': 'ச', 'te': 'చ', 'bn': 'চ', 'mr': 'स', 'gu': 'સ', 'kn': 'ಸ', 'ml': 'സ', 'pa': 'ਸ', 'or': 'ସ', 'as': 'চ', 'ur': 'س', 'ne': 'स', 'en': 'C'},
    };

    // Check if it's a fruit or vegetable translation
    if (fruitVegetableMapping.containsKey(text)) {
      return fruitVegetableMapping[text]![targetLanguage] ?? text;
    }

    // Check if it's a single letter translation
    if (letterPhoneticMapping.containsKey(text)) {
      return letterPhoneticMapping[text]![targetLanguage] ?? text;
    }

    // For letter explanations, provide a generic fallback
    if (text.contains('This is the letter')) {
      String languageName = getSupportedLanguages()[targetLanguage] ?? 'this language';
      return 'This letter is used in $languageName writing.';
    }

    // Return original text if no translation found
    return text;
  }

  static Map<String, String> getSupportedLanguages() {
    return {
      'en': 'English',
      'hi': 'Hindi',
      'ta': 'Tamil',
      'te': 'Telugu',
      'mr': 'Marathi',
      'bn': 'Bengali',
      'gu': 'Gujarati',
      'kn': 'Kannada',
      'ml': 'Malayalam',
      'pa': 'Punjabi',
      'or': 'Odia',
      'as': 'Assamese',
      'ur': 'Urdu',
      'sd': 'Sindhi',
      'ne': 'Nepali',
    };
  }

  static String getLanguageFlag(String languageCode) {
    const flags = {
      'en': '🇺🇸',
      'hi': '🇮🇳',
      'ta': '🇮🇳',
      'te': '🇮🇳',
      'mr': '🇮🇳',
      'bn': '🇮🇳',
      'gu': '🇮🇳',
      'kn': '🇮🇳',
      'ml': '🇮🇳',
      'pa': '🇮🇳',
      'or': '🇮🇳',
      'as': '🇮🇳',
      'ur': '🇵🇰',
      'sd': '🇵🇰',
      'ne': '🇳🇵',
    };
    return flags[languageCode] ?? '🌐';
  }
}