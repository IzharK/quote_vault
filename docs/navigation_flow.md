# QuoteVault Navigation Flow

## Core Navigation Map

### 1. Authentication Flow (Entry)
- **Splash Screen**: Check session state.
    - If Logged In -> **Home Tab**
    - If Logged Out -> **Login Screen**
- **Login Screen**:
    - Email/Password Form.
    - Link to **Signup Screen**.
    - Link to **Forgot Password Screen**.
- **Signup Screen**:
    - Registration Form.
    - On Success -> **Home Tab**.

### 2. Main Tab Navigation (App Shell)
Persistent bottom navigation bar.

#### tab A: Home (Feed)
- **Quote Feed**: Infinite scroll of quotes.
    - **Header**: "Quote of the Day" card.
- **Quote Item Interact**:
    - Tap Heart -> Toggle Favorite.
    - Tap Share -> Open Share Sheet / Card Info.

#### tab B: Search (Discovery)
- **Search Bar**: Keyword search.
- **Category Chips**: Horizontal list (Motivation, Love, etc.).
- **Results View**: List of quotes filtering by query/category.

#### tab C: Favorites
- **Favorites List**: Infinite scroll of user's saved quotes.
- **Quote Item Interact**:
    - Tap Heart -> Remove from Favorites.
    - Tap Share -> Open Share Sheet.

#### tab D: Profile (Settings)
- **User Info**: Avatar, Name (Editable).
- **Settings List**:
    - **Appearance**: Theme Mode (Auto/Light/Dark), Accent Color Selection.
    - **Text Size**: Global font scaling slider.
    - **Notifications**: Preference settings.
    - **Logout Button**.

## Detailed Screens

- **Share/Export Screen**:
    - Preview Card.
    - Style Selector (Carousel of themes).
    - "Save Image" / "Share Text" buttons.
