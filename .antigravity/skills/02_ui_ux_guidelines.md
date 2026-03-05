# Grace AI - UI/UX & Design System Guidelines

## Core Aesthetics
The app must convey calmness, peace, and a premium feel. Do not use harsh colors or default iOS blue unless explicitly requested.

## Color Palette
Whenever building new UI components, use these semantic colors (or their closest SwiftUI equivalents):
- **Background:** Off-white / Cream (`#F9F9F7`)
- **Accents & Highlights:** Matte Gold (`#D4AF37`)
- **Text & Primary Elements:** Deep Navy (`#1A2B3C`)

## Typography
- **Titles & Bible Verses:** Use a Serif font (e.g., `Font.custom("New York", size: ...)`).
- **Body Text & UI Controls:** Use standard iOS Sans-Serif (`.font(.system(...))` / SF Pro).

## UI Components & Styling
- **Corners:** Use wide, soft rounded corners (`.cornerRadius(20)`).
- **Shadows:** Use very soft, subtle drop shadows (`.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)`).
- **Spacing:** Embrace generous whitespace and padding. Never cram elements together.
- **Animations:** Use smooth `.spring()` animations for UI transitions. The Chat UI should have a gentle fade-in effect for new messages, and the Streak flame should have a subtle bounce effect when updated.

## Haptics
- Implement `UIImpactFeedbackGenerator(style: .light)` or `.medium` for key user actions (e.g., saving a journal entry, incrementing the streak).