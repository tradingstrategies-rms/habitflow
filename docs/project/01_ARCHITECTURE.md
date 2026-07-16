# HabitFlow Architecture

Version: 1.1
Status: Sprint 2 Completed

## Overview
HabitFlow uses **Clean Architecture** with a **Feature-First** structure.

## Layers
1. **Presentation**: UI widgets, Screen components, and Riverpod StateNotifiers.
2. **Application**: Business logic handlers (Controllers).
3. **Domain**: Entities and Repository interfaces.
4. **Infrastructure**: FirestoreService, StorageService, and concrete Repository implementations.

## Key Technologies
- **DI/State**: Riverpod. All services injected via `core_providers.dart`.
- **Navigation**: GoRouter (centralized in `app_router.dart`).
- **Persistence**: 
    - **Firestore**: User profiles and identity.
    - **SharedPreferences**: Local habit tracking and app settings.

## Folder Structure
- `/lib/core`: Global services (Auth, Database, Storage).
- `/lib/features`: Feature-isolated modules (Auth, Profile, Habits, etc.).
- `/lib/shared`: Common components.
