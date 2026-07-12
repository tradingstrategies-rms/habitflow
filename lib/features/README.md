# Features Layer

The `features/` directory follows a feature-first approach. Each folder represents a specific functional module of the app.

## Current Features
- `authentication`: User login, signup, and session management.
- `onboarding`: First-time user experience and walkthroughs.
- `dashboard`: The main landing view and summary.
- `habits`: Habit creation, tracking, and listing.
- `goals`: Long-term goal setting and progress.
- `rewards`: Gamification and achievement systems.
- `family`: Collaborative features and group tracking.
- `analytics`: Usage data and performance metrics.
- `settings`: User preferences and app configurations.

## Recommended Sub-structure (per feature)
Each feature should ideally follow Clean Architecture principles internally:
- `data/`: Repositories, Data Sources, and Models.
- `domain/`: Entities, Repository Interfaces, and Use Cases.
- `presentation/`: UI Components, Screens, and Controllers/Providers.
