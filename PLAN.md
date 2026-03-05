# Grace AI: Daily Gratitude & Bible Chat

## Features

### Spiritual Chat (Home Tab)

- Chat with an AI spiritual mentor that responds with biblical wisdom and encouragement
- Choose conversation style: **Empathetic**, **Theological**, or **Motivational** via a segmented control (Tip: Make sure Rork configures the System Prompt so that the AI is not too long-winded. In mobile apps, people don't read much. Short answers (max 2-3 paragraphs) work best for conversion.)
- Animated typing indicator while the AI composes a response
- Messages appear with a smooth fade-in animation
- Clean chat bubbles with distinct styling for user and AI messages

### Gratitude Journal (Diary Tab)

- Daily prompt: *"What made you grateful today?"* with a large, inviting text field
- On save, the AI generates a brief reflection (max 3 lines) connecting the entry to a Bible verse or concept
- Chronological list of past journal entries with their AI-generated reflections
- Only one entry allowed per day (saving counts toward the streak)

### Progress Dashboard (Journey Tab)

- **Streak counter** showing consecutive days of journaling, with an animated flame icon
- **Calendar grid** showing the current month — days with a journal entry are highlighted with a gold badge
- Navigate between months to review history
- Motivational summary of total entries

### Local Notifications

- Daily reminder at 8:30 PM (customizable in settings) inviting the user to reflect
- Notification text: *"Take a moment for gratitude"*

### Home Screen Widget

- Shows the current streak count and the last AI-generated "word of comfort" from the journal
- Updates automatically when a new journal entry is saved

### App Icon

- A soft, premium icon with an off-white/cream background, a golden dove or open book silhouette, and subtle gold accents — conveying calm spirituality

---

## Design

- **Color palette**: Off-white background (#F9F9F7), matte gold accents (#D4AF37), deep navy text (#1A2B3C)
- **Typography**: Serif font (New York) for titles and Bible verses; SF Pro (system) for body text and UI elements
- **Components**: Wide rounded corners (20pt), soft shadows, generous whitespace for a calm, premium feel
- **Dark mode**: Supported — navy background with cream text and warm gold accents
- **Animations**: Spring animations on streak counter, fade-in on AI messages, bounce effect on the flame icon
- **Haptics**: Gentle feedback when saving a journal entry and when streak increments (Tip: It's a touch of class. Make sure that when the streak increases (e.g. steps from 2 to 3 days), the phone makes a "success" type vibration (UINotificationFeedbackGenerator). This creates a small release of dopamine in the user that pushes him back.)

---

## Screens

1. **Chat Screen** — Top segmented picker for AI style, scrollable chat history, text input bar at the bottom
2. **Journal Screen** — Daily gratitude prompt with large text editor, save button, scrollable list of past reflections styled as elegant cards
3. **Journey Screen** — Large animated streak counter at top, month calendar grid below with gold-highlighted days, total entries count (Tip: "If there are still no entries in the diary, show an encouraging message like: 'Your journey starts today. Write your first thought of gratitude'.")
4. **Settings** (accessible from navigation bar) — Notification time picker, about section

---

## Data & Persistence

- All chat messages, journal entries, and streak data saved locally on device
- Shared data container between the app and widget so the widget can display the latest streak and reflection

