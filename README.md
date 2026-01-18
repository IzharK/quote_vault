# QuoteVault

**QuoteVault** is a premium, offline-first mobile application designed for quote enthusiasts to discover, curate, and personalize their favorite wisdom. It features a stunning, aesthetically pleasing UI with dynamic theming, daily inspirations, and seamless cloud synchronization.

---

## 🚀 Features

### **Discovery & Inspiration**
-   **Quote of the Day**: Start your day with a fresh, hand-picked quote.
-   **Infinite Feed**: Scroll through thousands of quotes with high-performance pagination.
-   **Search**: Find quotes by keyword or author instantly.
-   **Categories**: Browse curated topics like Motivation, Love, Stoicism, and more.

### **Personalization**
-   **Dynamic Theming**: Choose from a palette of premium colors (Emerald, Royal Blue, Crimson, Gold, etc.) that tint the entire app.
-   **Dark Mode**: A carefully crafted dark theme (`#101322`) for comfortable night reading.
-   **Font Scaling**: Adjust text size globally (80% - 140%) to suit your reading preference.

### **Curation**
-   **Favorites**: Save quotes to your library with one tap.
-   **Cloud Sync**: Your favorites are backed up to Supabase and synced across devices.
-   **Share**: Generate beautiful quote images or share as text to social media.

---

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/) (SDK 3.x)
-   **Language**: Dart
-   **Backend**: [Supabase](https://supabase.com/) (Auth, PostgreSQL Database)
-   **State Management**: `provider`
-   **Navigation**: `go_router`
-   **Architecture**: Clean Architecture (Presentation, Domain, Data layers)

### Key Packages
-   `google_fonts`: For typography (Playfair Display, Inter).
-   `shared_preferences`: Local persistence for settings.
-   `supabase_flutter`: Backend integration.
-   `share_plus` / `path_provider`: Sharing functionality.

---

## 📂 Project Structure

The project follows a **Feature-First Clean Architecture**:

```
lib/
├── app.dart                   # Root Widget & Global Providers
├── main.dart                  # Entry Point
├── core/                      # Core utilities, widgets, and theme
│   ├── constants/             # Strings, Assets
│   ├── di/                    # Dependency Injection
│   ├── providers/             # Global Providers (Theme)
│   ├── routes/                # GoRouter config
│   ├── theme/                 # AppTheme & Colors
│   └── widgets/               # Reusable UI (Gradient, Cards)
└── features/                  # Feature Modules
    ├── auth/                  # Authentication (Login, Signup)
    ├── favorites/             # Favorites & Sync
    ├── profile/               # User Settings & Profile
    ├── quotes/                # Home Feed, Search, Quote of the Day
    └── settings/              # Appearance & Preferences
```

Each feature folder is split into:
-   **Data**: Repositories, Models, Data Sources.
-   **Domain**: Entities, Abstract Repositories, Use Cases (optional).
-   **Presentation**: Widgets, Screens, Providers.

---

## ⚡ Quick Start

### Prerequisites
1.  **Flutter SDK**: Installed and configured ([Guide](https://docs.flutter.dev/get-started/install)).
2.  **Supabase Account**: A project with Authentication and Database enabled.

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/quote_vault.git
    cd quote_vault
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup**
    Create a `.env` file (or update `lib/core/constants/app_secrets.dart` - *Note: Use environment variables in production*) with your Supabase credentials:
    ```dart
    const supabaseUrl = 'YOUR_SUPABASE_URL';
    const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📖 Key Documentation

For deep dives into specific implementations:
-   [**Setup Guide**](docs/setup_guide.md): Detailed backend SQL and local setup.
-   [**Architecture**](docs/architecture.md): Implementation details of State Management and Data Flow.
-   [**Features**](docs/features.md): User guide and feature inventory.

---

## 🎨 Design System

**QuoteVault** uses a "Seed Color" system.
-   **Primary**: User-selected color.
-   **Background**: Dynamic gradient blending `Surface` + `Primary`.
-   **Typography**:
    -   *Headings*: Playfair Display (Serif)
    -   *Body*: Inter (Sans-serif)

---

## 🤝 Contributing

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
