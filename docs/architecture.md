# Architecture & Design

**QuoteVault** is built using a strict **Feature-First Clean Architecture** within Flutter. This ensures scalability, testability, and separation of concerns.

## 🏗 High-Level Overview

```mermaid
graph TD
    User([User]) --> UI[Presentation Layer]
    UI --> Provider[State Management (Provider)]
    Provider --> Repo[Repository Layer]
    Repo --> Remote[Remote Data (Supabase)]
    Repo --> Local[Local Data (SharedPrefs)]
```

---

## 🧩 Layers

### 1. Presentation Layer
-   **Responsibility**: Rendering UI and handling user interactions.
-   **Components**:
    -   `Pages`: Full screens (e.g., `HomeScreen`, `ProfileScreen`).
    -   `Widgets`: Reusable UI components (e.g., `QuoteCard`, `BackgroundGradient`).
    -   `Providers`: `ChangeNotifier` classes that hold UI state and expose methods.

### 2. Domain Layer
-   **Responsibility**: Business logic and entity definitions.
-   **Components**:
    -   `Entities`: Pure Dart objects (e.g., `Quote`, `UserProfile`).
    -   `Repositories (Abstract)`: Interfaces defining the contract for data operations.

### 3. Data Layer
-   **Responsibility**: Data retrieval and persistence.
-   **Components**:
    -   `Models`: Data Transfer Objects (DTOs) with `fromJson`/`toJson`. Extend Entities.
    -   `Repositories (Implementation)`: Concrete classes that fetch data from Supabase or SharedPreferences.

---

## ⚙️ Key Systems

### State Management (`Provider`)
We use the `provider` package for Dependency Injection and State Management.
-   **Global Providers**: `ThemeProvider`, `AuthProvider`.
-   **Feature Providers**: `QuoteProvider`, `FavoritesProvider`.
-   **Injection**: `MultiProvider` in `app.dart` injects all necessary providers at the root.

### Theming Engine
The app features a dynamic theming system.
-   **Source of Truth**: `ThemeProvider` stores `primaryColor`, `themeMode`, and `textScaleFactor`.
-   **Generation**: `AppTheme` generates the entire `ThemeData` using `ColorScheme.fromSeed`.
-   **Persistence**: Settings are saved to `SharedPreferences` for instant restoration on launch.

### Routing
We use `go_router` for declarative routing.
-   **ShellRoute**: Used for the persistent Bottom Navigation Bar (`ScaffoldWithNavBar`).
-   **Guards**: `redirect` logic in `AppRouter` handles Auth protection (redirecting unauthenticated users to Login).

---

## 🗄 Database & Auth
-   **Supabase Auth**: Manages sessions and user identity.
-   **RLS (Row Level Security)**: Ensures users can only edit their own profile and favorites.
