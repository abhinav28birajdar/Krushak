# 🌾 Krushak - FarmerOS

A comprehensive Flutter application designed to empower farmers with modern digital tools for farm management, crop diagnosis, market access, and financial tracking.

## ✨ Features

### 🏠 **Home Dashboard**
- Real-time weather information
- Market price updates
- Quick access to all features
- Farm overview and statistics

### 🩺 **AI-Powered Crop Diagnosis**
- Upload crop images for disease detection
- AI analysis with treatment recommendations
- Expert tips and preventive measures
- Historical diagnosis tracking

### 🌱 **Farm Management**
- Multiple farm tracking
- Crop lifecycle management
- Planting and harvest scheduling
- Farm location mapping

### 💰 **Financial Management**
- Income and expense tracking
- Profit/loss analysis
- Category-wise financial reports
- Budget planning tools

### 🏪 **Marketplace**
- Real-time commodity pricing
- Buy and sell agricultural products
- Direct farmer-to-buyer connections
- Market trends and analysis

### 🎓 **Learning Hub**
- Agricultural best practices
- Video tutorials and guides
- Expert articles and tips
- Community knowledge sharing

### 👥 **Community**
- Farmer discussion forums
- Q&A platform
- Experience sharing
- Local farming groups

### 🏦 **Loan Management**
- Bank loan applications
- Government scheme information
- Eligibility checker
- Application tracking

### ⚙️ **Account Management**
- Profile settings
- Farm information
- Financial overview
- App preferences

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### 🛠️ Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/krushak_app.git
   cd krushak_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file with your actual API keys:
   ```env
   SUPABASE_URL=https://your-project-url.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   GOOGLE_API_KEY=your-google-api-key-here
   GEMINI_API_KEY=your-gemini-api-key-here
   ```

4. **Setup Supabase Database**
   - Create a new Supabase project
   - Run the SQL schema from `database_schema_updated.sql`
   - Configure Row Level Security policies
   - Update your Supabase URL and anon key in the app

5. **Configure Google Services**
   - Enable Google Maps API
   - Add API key to your environment configuration
   - For Android: Update `android/app/src/main/AndroidManifest.xml`

6. **Setup AI Services**
   - Get Gemini AI API key for crop diagnosis
   - Configure the key in your environment

### 🏃‍♂️ Running the App

**Web (Development)**
```bash
flutter run -d chrome
```

**Android**
```bash
flutter run -d android
```

**iOS**
```bash
flutter run -d ios
```

**Build for Production**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🏗️ Architecture

The app follows Clean Architecture principles with the following structure:

```
lib/
├── core/                    # Core utilities and services
│   ├── constants/          # App constants and themes
│   ├── services/           # External services (Supabase, APIs)
│   ├── theme/             # App theming
│   └── navigation/        # Navigation logic
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── home/             # Dashboard
│   ├── diagnosis/        # Crop diagnosis
│   ├── market/           # Marketplace
│   ├── account/          # User account
│   └── ...
└── shared/               # Shared widgets and utilities
```

## 🗄️ Database Schema

The app uses Supabase (PostgreSQL) with the following main tables:

- **users** - User profiles and farmer information
- **farms** - Farm details and locations
- **crops** - Crop management and tracking
- **financial_records** - Income and expense tracking
- **market_prices** - Real-time commodity pricing
- **orders** - Marketplace transactions
- **announcements** - Community announcements
- **crop_diagnoses** - AI diagnosis results

## 🔧 Technologies Used

- **Frontend**: Flutter/Dart
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **State Management**: Riverpod
- **AI Services**: Google Gemini AI
- **Maps**: Google Maps
- **Weather**: OpenWeatherMap API
- **Authentication**: Supabase Auth
- **Real-time Updates**: Supabase Realtime

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Google for AI and Maps services
- The farming community for inspiration

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Email: support@krushak-app.com
- Website: https://krushak-app.com

---

**Made with ❤️ for farmers everywhere** 🌾
