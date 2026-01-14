# QuoteVault Architecture

## Overview
QuoteVault follows a **Clean Architecture** approach with **Feature-First** directory structure. This ensures separation of concerns, scalability, and testability.

## Technology Stack
- **Framework**: Flutter (Latest Stable)
- **Language**: Dart
- **State Management**: Provider (ChangeNotifier)
- **Dependency Injection**: GetIt (recommended) or simple Provider
- **Networking/Backend**: Supabase Flutter SDK
- **Local Storage**: Shared Preferences (for simple settings), Hive or Sqlite (if complex offline caching needed - strictly Supabase offline capabilities should suffice for now)

## Layered Architecture

### 1. Presentation Layer (UI)
- **Widgets**: Reusable UI components.
- **Pages/Screens**: Application screens.
- **Providers/View Models**: Manages state and interacts with Use Cases.
- **Responsibilities**:
    - Displaying data.
    - Handling user input.
    - Managing UI state (loading, error, success).

### 2. Domain Layer (Business Logic)
- **Entities**: Plain Dart objects representing core business data.
- **Repositories (Interfaces)**: Abstract definitions of data operations.
- **Use Cases**: Specific business logic encapsulating single unit of work (optional for simpler apps, but recommended for clean arch).
- **Responsibilities**:
    - Pure Dart code.
    - No dependencies on Flutter libraries (ideally).
    - Defining *what* the app does.

### 3. Data Layer (Data Access)
- **Models**: Data Transfer Objects (DTOs) with manual `fromJson`/`toJson` methods. Mappers to Domain Entities. No code generation libraries like Freezed or json_serializable.
- **Repositories (Implementations)**: Concrete implementation of domain repositories.
- **Data Sources**:
    - **Remote**: Supabase API calls.
    - **Local**: Local database/storage for offline caching.
- **Responsibilities**:
    - Data retrieval and persistence.
    - Exception handling.
    - Mapping data.

## Directory Structure (Feature-First)

```
lib/
├── core/                   # Shared kernels
│   ├── config/             # Env, constants
│   ├── error/              # Faulures, exceptions
│   ├── theme/              # App themes, colors, type
│   ├── utils/              # Helper functions
│   └── widgets/            # Global reusable widgets
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/   # Pages, Providers, Widgets
│   ├── quotes/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── ...
├── main.dart
└── injection_container.dart # DI Setup
```

## State Management Rules
- **Provider** is the single source of truth for UI state.
- Business logic resides in **Repository** implementations or **Use Cases**, NOT in the UI.
- UI observes Providers. Providers call Repositories.
