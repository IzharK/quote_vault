# Features Manual

This document provides a detailed breakdown of the features implemented in **QuoteVault**.

## 1. Authentication
-   **Sign Up**: Create an account using Email/Password.
-   **Login**: Access your account.
-   **Forgot Password**: Request a password reset link (Supabase handler).
-   **Logout**: Securely key-flush and exit.

## 2. Discovery (Home)
-   **Daily Quote**: A special quote pinned to the top of the feed to inspire you daily.
-   **Infinite Feed**: Seamless scrolling through thousands of quotes.
-   **Pull-to-Refresh**: Refresh the feed anytime.
-   **Categories**: Filter quotes by Topic (e.g., Wisdom, Friendship).

## 3. Search
-   **Global Search**: Search the entire quote database.
-   **Real-time Results**: Results update as you type (debounced).
-   **Author Search**: Find all quotes by a specific person.

## 4. Favorites
-   **Save Quotes**: Tap the heart icon on any quote to save it.
-   **Cloud Backup**: Your favorites are saved to different database tables, ensuring they persist even if you reinstall.
-   **Offline Access**: Favorites are loaded into memory for quick access.

## 5. Personalization (Settings)
-   **Profile Management**: Update your Name and Avatar.
-   **Appearance**:
    -   **Theme Mode**: Auto (System), Light, or Dark.
    -   **Accent Color**: Select from 10+ premium colors.
    -   **Text Size**: Adjust font scale for accessibility.

---

## 6. Sharing
-   **Text Share**: Share the raw text and author of a quote to any app.
-   **Image Share (Coming Soon)**: Generate specific images.
