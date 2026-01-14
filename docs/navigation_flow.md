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
    - Tap -> Navigate to **Quote Detail Screen**.

#### tab B: Search (Discovery)
- **Search Bar**: Keyword search.
- **Category Chips**: Horizontal list (Motivation, Love, etc.).
- **Results View**: List of quotes filtering by query/category.

#### tab C: Collections (Favorites/Saved)
- **Favorites Tile**: Tapping opens **Favorites Screen**.
- **My Collections List**: Grid/List of user collections.
    - Tap Collection -> **Collection Detail Screen**.
    - FAB (+) -> **Create Collection Dialog**.

#### tab D: Profile (Settings)
- **User Info**: Avatar, Name (Editable).
- **Settings List**:
    - Dark/Light Mode Toggle.
    - Notification Preferences (Time picker).
    - Font Size Slider.
    - Logout Button.

## Detailed Screens

- **Quote Detail Screen**:
    - Large view of quote.
    - Actions: Favorite, Share, Add to Collection.
- **Share/Export Screen**:
    - Preview Card.
    - Style Selector (Carousel of themes).
    - "Save Image" / "Share Text" buttons.
- **Collection Detail Screen**:
    - List of quotes in the collection.
    - Edit Name / Delete Collection options.
