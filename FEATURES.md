# TasteFit Feature Overview

- **Platforms**: Flutter app targeting mobile and web with shared codebase (Riverpod state management, Firebase backend).
- **Authentication**: Firebase email/password sign-in and registration flows, with session persistence handled via providers.
- **Recipe discovery**: Home feed shows recipe cards with imagery, prep time, and nutrition highlights; recipes are organized by category.
- **Recipe details**: Dedicated screen for ingredients, steps, nutrition facts (calories, protein, carbs, fats), ratings, and prep time; supports adding servings.
- **Search**: Recipe search with suggestion building from the full catalog; results render recipe cards consistent with home feed.
- **Favorites**: Toggle favorite status on recipes and view a dedicated favorites list, backed by a favorites provider/repository.
- **Shopping list**: Create and edit categorized shopping items with quantity/unit, mark purchased, clear purchased items, and add ingredients directly from a recipe.
- **Nutrition tracker**: Log meals from recipes, auto-calculate macronutrients per serving, and roll up daily totals for calories, protein, carbs, and fats.
- **Navigation**: Bottom navigation links core areas (Home, Search, Nutrition, Shopping, Favorites) and keeps state per tab.
- **Firebase integration**: Uses Firestore for data, Firebase Auth for identity, and Firebase Analytics/Crashlytics hooks for instrumentation and error capture.
