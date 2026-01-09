# Speech Recognition Debug & Fix Guide

## ✅ Issues Fixed

### 1. **Enhanced Error Handling**
- Added comprehensive debug logging throughout the speech recognition flow
- Improved error messages with actionable feedback
- Added retry mechanism with 2 attempts on failure
- Added verification check to ensure listening actually started

### 2. **Better Initialization**
- Each screen now properly awaits speech recognition initialization
- Added screen-specific debug logging for easier troubleshooting
- Initialization failure handling with retry option
- Proper cleanup on component disposal

### 3. **Improved UI Feedback**
- Visual indicator when speech recognition is not initialized (grey card with mic_off icon)
- Clear error messages explaining what might be wrong
- "Retry Initialization" button when speech recognition fails
- Always-visible pronunciation card (not hidden when not initialized)

### 4. **Robust Listening Logic**
- Attempts to reinitialize if not ready when user clicks
- Proper state management (sets _isListening before API call)
- Verification that listening actually started (300ms delay check)
- Fallback to en-US locale if primary locale fails

## 🔍 Debug Steps

### Step 1: Check Permissions
The app requires microphone permission. To verify:

**On Android:**
1. Go to Settings → Apps → VaaniMitra
2. Check Permissions → Microphone should be "Allowed"
3. If denied, grant the permission
4. Restart the app

**In Code:**
- Permissions are automatically requested on first use
- Check Android logcat for permission status messages:
  ```
  🎤 Permission status: granted/denied
  ```

### Step 2: Monitor Debug Logs

Run the app with `flutter run` and watch for these log messages:

#### **Initialization Phase:**
```
🎤 [Screen]Screen: Starting speech recognition initialization...
🎤 Starting speech recognition initialization...
🎤 Requesting microphone permission...
✅ Microphone permission granted
🎤 Simple initialization result: true
✅ Speech recognition fully initialized and ready!
```

#### **Starting Listening Phase:**
```
🎯 === STARTING SPEECH RECOGNITION ===
🎯 Language: [language_code]
🔍 Step 1: Checking initialization...
🔍 Step 2: Checking availability...
🔍 Step 3: Checking current state...
🔍 Step 4: Getting locale...
🌍 Mapped locale: [locale] for language: [code]
🔍 Step 5: Checking locale support...
🌍 Available locales count: [number]
🎯 Using final locale: [locale]
🔍 Step 6: Starting to listen with locale: [locale]
🎤 Listen call result: true
🎤 Verification check - isListening: true
✅ Final speech listening result: true
```

#### **Speech Result Phase:**
```
🎤 Speech result: "[recognized_text]" (confidence: 0.95, final: false)
✅ Final speech result: "[recognized_text]"
```

### Step 3: Common Issues & Solutions

#### Issue 1: "Speech recognition not initialized"
**Symptoms:** Grey pronunciation card, "Retry Initialization" button shown

**Solutions:**
1. Tap "Retry Initialization" button
2. Check microphone permissions in device settings
3. Ensure device supports speech recognition
4. Restart the app
5. Check logcat for initialization errors

**Debug Logs to Check:**
```
❌ Microphone permission denied
❌ Speech recognition initialized but not available
❌ Speech recognition initialization failed completely
```

#### Issue 2: "Failed to start speech recognition"
**Symptoms:** Error message appears, listening doesn't start

**Solutions:**
1. Check internet connection (Google speech service requires internet)
2. Verify microphone is not being used by another app
3. Check if locale is supported (check logcat for available locales)
4. Try switching to a different language (Hindi or English)

**Debug Logs to Check:**
```
❌ Speech recognition not initialized
❌ Speech recognition service not available
⚠️ Locale [locale] not supported
🔄 Using fallback: en-US
```

#### Issue 3: Nothing happens when button is pressed
**Symptoms:** Button press has no effect, no error shown

**Solutions:**
1. Check if _speechInitialized is false (card should be grey)
2. Wait 2-3 seconds after opening the screen (initialization takes time)
3. Check logcat for any exceptions
4. Verify targetLanguage is set correctly

**Debug Logs to Check:**
```
🎤 Starting listening for language: [code]
❌ startListening: Microphone permission not granted
```

#### Issue 4: Listening starts but nothing is recognized
**Symptoms:** Listening indicator shows but no text appears

**Solutions:**
1. Speak clearly and loudly near the microphone
2. Check sound level indicators in logs (should show > 0 when speaking)
3. Ensure quiet environment (background noise can interfere)
4. Try speaking in English first to test
5. Check if the selected locale is supported on your device

**Debug Logs to Check:**
```
🔊 Sound level: [number] (should be > 0 when speaking)
🎤 Speech result: "" (empty result means nothing detected)
```

### Step 4: Device Compatibility Check

**Minimum Requirements:**
- Android 5.0 (API 21) or higher
- Google app installed and updated
- Active internet connection
- Functional microphone

**To Test Device Compatibility:**
1. Open any Google app (Chrome, Assistant, etc.)
2. Try voice input
3. If Google voice input works, the device is compatible

### Step 5: Testing Different Languages

The app supports these locales with fallbacks:
- Hindi: hi-IN
- Tamil: ta-IN
- Telugu: te-IN
- Bengali: bn-IN
- Marathi: mr-IN
- Gujarati: gu-IN
- Kannada: kn-IN
- Malayalam: ml-IN
- Punjabi: pa-IN
- Odia: or-IN
- Assamese: as-IN
- Urdu: ur-IN
- Nepali: ne-IN

**Fallback Order:**
1. Primary locale (e.g., ta-IN for Tamil)
2. hi-IN (Hindi - India)
3. en-IN (English - India)
4. en-US (English - US)

Check logcat to see which locale is being used:
```
🌍 Mapped locale: ta-IN for language: ta
🔄 Using fallback: en-IN
```

## 🛠️ Manual Testing Checklist

- [ ] Open any intermediate lesson (Fruits/Vegetables/Animals/etc.)
- [ ] Check if pronunciation card is visible
- [ ] Verify card shows purple background (initialized) or grey (not initialized)
- [ ] If grey, tap "Retry Initialization"
- [ ] Tap "Start Practice" button
- [ ] Verify listening indicator appears (spinning progress circle)
- [ ] Speak the displayed word clearly
- [ ] Check if recognized text appears
- [ ] Verify pronunciation feedback is displayed
- [ ] Check accuracy percentage
- [ ] Try with different words in the lesson
- [ ] Test with different languages if possible

## 📱 Quick Fixes

### Fix 1: Reset Speech Recognition
If speech recognition stops working:
1. Close the app completely
2. Clear app cache (Settings → Apps → VaaniMitra → Storage → Clear Cache)
3. Reopen the app
4. Try again

### Fix 2: Permission Reset
If microphone permission issues persist:
1. Go to Settings → Apps → VaaniMitra → Permissions
2. Revoke microphone permission
3. Open app again
4. Grant permission when prompted
5. Tap "Retry Initialization"

### Fix 3: Google App Update
Speech recognition uses Google's service:
1. Open Google Play Store
2. Search for "Google"
3. Update the Google app if available
4. Restart device
5. Try again

## 🔧 Advanced Debugging

### Enable Verbose Logging
The app already has comprehensive debug logging. To view:

```bash
# Filter for speech recognition logs
flutter run --verbose | grep -E "🎤|🎯|🌍|✅|❌|⚠️|🔊"

# Or use adb logcat
adb logcat | grep -E "speech|recognition|microphone"
```

### Check Available Locales
When the app starts listening, it logs all available locales. Look for:
```
🌍 Available: hi-IN (Hindi (India))
🌍 Available: en-IN (English (India))
🌍 Available: en-US (English (United States))
...
```

### Verify Speech Service
Check if speech service is running:
```bash
adb shell dumpsys speech_recognition
```

## 📊 Success Indicators

When everything is working correctly, you should see:

1. **Initialization logs:**
   - ✅ Microphone permission granted
   - ✅ Speech recognition fully initialized and ready!

2. **Start listening logs:**
   - 🎤 Listen call result: true
   - 🎤 Verification check - isListening: true

3. **Recognition logs:**
   - 🔊 Sound level: [> 0 when speaking]
   - 🎤 Speech result: "[your_words]"
   - ✅ Final speech result: "[your_words]"

4. **UI indicators:**
   - Purple pronunciation card (not grey)
   - "Start Practice" button (not "Retry Initialization")
   - Listening indicator appears when active
   - Pronunciation feedback shows with accuracy score

## 🆘 Still Not Working?

If speech recognition still doesn't work after all fixes:

1. **Device may not support speech recognition**
   - Some custom ROMs remove Google services
   - Very old devices may not support it
   - Test with Google Assistant or Chrome voice search

2. **Network issues**
   - Speech recognition requires internet
   - Check if other Google services work
   - Try on WiFi instead of mobile data

3. **App reinstall**
   - Uninstall the app completely
   - Reinstall fresh copy
   - Grant all permissions on first launch

## 📝 Reporting Issues

If you need to report an issue, include:
1. Device model and Android version
2. Complete logcat output from app start to error
3. Steps to reproduce
4. Screenshot of the pronunciation card
5. Which language was selected
6. Network connection type (WiFi/Mobile data)

Use this command to capture logs:
```bash
flutter run > debug_log.txt 2>&1
```
