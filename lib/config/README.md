# API Configuration

This directory contains API configuration files for the VaaniMitra app.

## Setup Instructions

1. **Copy the template file:**
   ```
   Copy `api_config.dart.template` to `api_config.dart`
   ```

2. **Add your API keys:**
   - Open `api_config.dart`
   - Replace `YOUR_GOOGLE_TRANSLATE_API_KEY_HERE` with your actual Google Translate API key
   - Add any other API keys as needed

3. **Security Note:**
   - The `api_config.dart` file is automatically ignored by Git (listed in `.gitignore`)
   - Never commit actual API keys to version control
   - Each developer should maintain their own `api_config.dart` file locally

## Getting API Keys

### Google Translate API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Cloud Translation API
4. Create credentials (API Key)
5. Restrict the API key to only the Translation API for security

## File Structure
```
lib/config/
├── api_config.dart.template  # Template file (committed to repo)
├── api_config.dart          # Your actual config (ignored by Git)
└── README.md               # This file
```