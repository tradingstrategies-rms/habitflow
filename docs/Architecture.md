# HabitFlow Technical Architecture

Version: 1.1
Status: Sprint 2 Completed
Platform: Flutter (Android + iOS)
Architecture: Clean Architecture + Feature First

---

# Technology Stack

## Framework & State Management
- Flutter Stable
- Riverpod (State Management & DI)
- GoRouter (Navigation)

## Backend
- Firebase Authentication
- Cloud Firestore (Profile Persistence)

## Persistence
- Firestore (Profile)
- SharedPreferences (Local Preferences/Habits)

---

# Architecture Overview

HabitFlow implements Clean Architecture with a strict feature-first structure.

## Layers
1. **Presentation**: Widgets and Riverpod Controllers.
2. **Application**: Business logic and State management.
3. **Domain**: Repository interfaces and Entities.
4. **Infrastructure**: FirestoreService, Local storage implementation, Repository implementations.

## Dependency Injection
DI is fully managed via Riverpod `Provider`s, centralizing service creation in `core_providers.dart`.
- `databaseServiceProvider` is now injected with `FirestoreService`.
- Repository pattern used for data abstraction.

## Navigation Flow
- Centralized via GoRouter.
- Dynamic redirection based on Authentication (AuthStateProvider) and Profile completeness (UserProfileProvider).
