# Money Manager App

A modern, modular Flutter application for personal finance management.

## Features

- **User Authentication**
  - Sign up and log in with Firebase Auth
  - Secure user sessions

- **Dashboard**
  - Overview of income, expenses, and total balance
  - Quick access to recent transactions
  - Glassmorphism UI and smooth animations

- **Transactions**
  - Add, edit, and delete income/expense transactions
  - Category selection with consistent icons
  - Swipe-to-delete with confirmation
  - Search and filter by category/type
  - Filter by month

- **Analytics**
  - Visualize spending and income by category (pie chart)
  - Filter analytics by month
  - See breakdowns for each category

- **Budget Planning**
  - Set monthly spending limits per category
  - Track progress with progress bars
  - Get real-time notifications when approaching or exceeding limits
  - Reset all budgets with one tap

- **Profile**
  - View and edit user profile
  - Change profile picture

- **Other**
  - Glassmorphism and modern UI
  - Modular, feature-first folder structure
  - Global and feature-specific reusable widgets

## Project Structure

```
lib/
  core/
    models/         # Data models
    services/       # Firebase and business logic
    theme/          # App colors and styles
    utils/          # Utilities (formatting, etc.)
    widgets/        # Global reusable widgets
  features/
    account_manager/
      login/
      sign_up/
    analytics/
    home/
      dashboard/
      widgets/
    profile/
    splash/
    transactions/
      widgets/
  main.dart
  firebase_options.dart
```

## Getting Started

1. Clone the repo
2. Run `flutter pub get`
3. Set up Firebase (see `lib/firebase_options.dart`)
4. Run the app with `flutter run`

---

**Enjoy managing your money with Money Manager!**
