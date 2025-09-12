# 🚀 BizNest - Complete Entrepreneurial Toolkit Mobile App

<div align="center">
  <img src="assets/images/biznest.png" alt="BizNest Logo" width="120" height="120">
  
  **A comprehensive mobile application supporting young entrepreneurs with startup toolkits**
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

</div>

---

## 📋 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [✨ Key Features](#-key-features)
- [🏗️ Architecture](#️-architecture)
- [📱 Screenshots](#-screenshots)
- [🛠️ Installation](#️-installation)
- [🚀 Getting Started](#-getting-started)
- [📚 Features Documentation](#-features-documentation)
- [🔧 Technical Stack](#-technical-stack)
- [📊 Project Structure](#-project-structure)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🎯 Project Overview

**BizNest** is a comprehensive mobile application designed to support young entrepreneurs and startup founders with a complete toolkit for business development. Built as part of the **SDG 9: Industry, Innovation and Infrastructure** initiative, this app provides real-time analytics, AI-powered tools, and collaborative features to help entrepreneurs succeed.

### 🎓 Academic Context
- **Course**: SE3050 – User Experience Engineering
- **Lab**: Lab Practical 02 – SDG Selection & UX roles
- **Group**: Y3S1-WE-40 (Pebbles)
- **SDG Focus**: Industry, Innovation and Infrastructure

---

## ✨ Key Features

### 🧠 **Member 1: UX Researcher - Entrepreneurial Skill Building**
- **Real-Time Quiz Analytics** with instant feedback and performance tracking
- **Adaptive Learning Engine** with personalized tutorial recommendations
- **Gamified Microlearning** featuring badges, levels, and leaderboards
- **Progress Visualization Dashboards** with detailed analytics and insights

### 🎨 **Member 2: UX Designer - Startup Planning & Business Toolkit**
- **AI-Powered Business Plan Generator** using OpenRouter API
- **Market Research Assistant** with web scraping and competitor analysis
- **Document Templates & Smart Checklists** for comprehensive business planning
- **Interactive Business Model Canvas** with drag-and-drop functionality

### 👥 **Member 3: UI Designer - Mentorship, Networking & Collaboration**
- **Automatic Mentor Matching** based on goals, location, and experience
- **Real-Time Communication Tools** including chat, video calls, and forums
- **Community Idea Board** for peer feedback and collaborative innovation
- **Professional Networking Platform** with advanced search and filtering

### 💰 **Member 4: UX Tester - Funding Assistance & Financial Tracking**
- **Funding Suggestion Engine** with 9+ funding sources and AI recommendations
- **Crowdsourced Funding Platform** for community resource sharing
- **Financial Analytics Dashboard** with predictive insights and risk analysis
- **Automated Expense & Revenue Tracking** with real-time financial monitoring

---

## 🏗️ Architecture

### Core Services
```
lib/core/services/
├── quiz_service.dart              # Real-time quiz analytics
├── learning_engine.dart           # Adaptive learning system
├── ai_business_plan_service.dart  # AI-powered business planning
├── market_research_service.dart   # Market analysis and research
├── mentor_matching_service.dart   # Mentor matching algorithm
└── funding_service.dart           # Funding suggestions and tracking
```

### Modern UI/UX Features
- **Glassmorphism Design** with translucent, blurred glass effects
- **Advanced Animations** including particle systems and morphing buttons
- **Responsive Layout** optimized for all screen sizes
- **Dark/Light Theme Support** with adaptive theming
- **60fps Smooth Animations** for premium user experience

---

## 📱 Screenshots

<div align="center">
  <img src="assets/images/biznest.png" alt="App Logo" width="200">
  
  *Modern, intuitive interface with your custom BizNest logo*
</div>

### Key Screens
- **Dashboard**: Real-time analytics and business health monitoring
- **Quiz System**: Interactive skill assessment with instant feedback
- **Learning Hub**: Personalized tutorials and progress tracking
- **Business Tools**: AI-powered business plan generation
- **Financial Tracking**: Comprehensive financial analytics
- **Networking**: Mentor matching and community features
- **Community**: Idea sharing and collaborative innovation

---

## 🛠️ Installation

### Prerequisites
- Flutter SDK (>=3.2.6)
- Dart SDK
- Android Studio / VS Code
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/entrepreneur_toolkit.git
   cd entrepreneur_toolkit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure assets**
   - Ensure your `biznest.png` logo is in `assets/images/`
   - Update API keys in service files if needed

4. **Run the application**
   ```bash
   flutter run
   ```

---

## 🚀 Getting Started

### First Time Setup
1. **Launch the app** - You'll see the beautiful splash screen with your BizNest logo
2. **Complete onboarding** - Follow the guided setup process
3. **Take the skill assessment** - Get personalized recommendations
4. **Explore features** - Navigate through the comprehensive toolkit

### Key Workflows
- **Skill Assessment** → **Personalized Learning** → **Business Planning** → **Funding** → **Networking**
- **Real-time Progress Tracking** throughout your entrepreneurial journey
- **AI-powered recommendations** based on your specific needs and goals

---

## 📚 Features Documentation

### 🧠 Learning & Skill Development
- **Adaptive Quiz System**: 10+ questions across 6 categories
- **Personalized Tutorials**: Content tailored to your skill level
- **Badge System**: 8+ achievement badges for motivation
- **Progress Tracking**: Visual analytics and performance insights

### 💼 Business Planning Tools
- **AI Business Plan Generator**: Complete business plans with OpenRouter API
- **Market Research**: Industry analysis and competitor insights
- **Document Templates**: Professional business document templates
- **SWOT Analysis**: Strategic planning and risk assessment

### 🤝 Networking & Mentorship
- **Smart Mentor Matching**: AI-powered mentor recommendations
- **Real-time Communication**: Chat, video calls, and discussion forums
- **Community Platform**: Idea sharing and peer collaboration
- **Professional Profiles**: Detailed mentor and user profiles

### 💰 Financial Management
- **Funding Suggestions**: 9+ funding sources with AI recommendations
- **Financial Analytics**: Real-time tracking and predictive insights
- **Expense Management**: Automated tracking and categorization
- **Growth Projections**: Financial forecasting and planning

---

## 🔧 Technical Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Material Design 3** - Modern UI components
- **Custom Animations** - Smooth 60fps animations

### Backend Services
- **OpenRouter API** - AI-powered business plan generation
- **Web Scraping** - Market research and competitor analysis
- **Real-time Communication** - WebSocket integration
- **Local Storage** - Offline data persistence

### Dependencies
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.6
  http: ^1.1.0
  lottie: ^2.7.0
  shimmer: ^3.0.0
  fl_chart: ^0.65.0
  web_socket_channel: ^2.4.0
  shared_preferences: ^2.2.2
```

---

## 📊 Project Structure

```
lib/
├── core/
│   ├── services/          # Core business logic
│   ├── theme/            # App theming and styling
│   └── widgets/          # Reusable UI components
├── screens/              # App screens and pages
│   ├── auth/            # Authentication screens
│   ├── onboarding/      # Onboarding flow
│   └── splash/          # Splash screen
└── main.dart            # App entry point

assets/
└── images/
    └── biznest.png      # Your custom logo
```

---

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#3B82F6` - Trust and professionalism
- **Secondary Purple**: `#8B5CF6` - Innovation and creativity
- **Accent Green**: `#10B981` - Growth and success
- **Warning Orange**: `#F59E0B` - Attention and alerts

### Typography
- **Headings**: Bold, modern sans-serif
- **Body Text**: Clean, readable typography
- **Code**: Monospace for technical content

### Components
- **Glassmorphism Cards**: Translucent, blurred backgrounds
- **Gradient Buttons**: Smooth color transitions
- **Animated Icons**: Dynamic visual feedback
- **Progress Indicators**: Real-time status updates

---

## 🚀 Performance Features

### Optimization
- **60fps Animations** - Smooth, responsive UI
- **Lazy Loading** - Efficient memory management
- **Caching** - Fast data retrieval
- **Offline Support** - Works without internet

### User Experience
- **Intuitive Navigation** - Easy-to-use interface
- **Real-time Updates** - Live data synchronization
- **Personalization** - Adaptive content and recommendations
- **Accessibility** - Screen reader and keyboard support

---

## 🤝 Contributing

We welcome contributions to improve BizNest! Here's how you can help:

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Standards
- Follow Flutter/Dart conventions
- Write comprehensive tests
- Document new features
- Maintain clean, readable code

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **SDG 9 Initiative** - Industry, Innovation and Infrastructure
- **Flutter Community** - Amazing mobile development framework
- **OpenRouter API** - AI-powered business plan generation
- **Material Design** - Beautiful UI components and guidelines

---

## 📞 Contact

**Group Y3S1-WE-40 (Pebbles)**
- **Course**: SE3050 – User Experience Engineering


---

<div align="center">
  <p><strong>Built with ❤️ for entrepreneurs worldwide</strong></p>
  <p>Supporting SDG 9: Industry, Innovation and Infrastructure</p>
</div>