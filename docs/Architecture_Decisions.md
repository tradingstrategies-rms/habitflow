# HabitFlow Architecture Decisions

This document records the architectural choices made for the HabitFlow project to ensure consistency and maintainability.

## 1. Bootstrap Layer (`core/bootstrap`)
**Decision**: Centralize all application startup logic into a `Bootstrap` pipeline.
**Why**: 
- Keeps `main.dart` clean and small.
- Ensures a strictly defined order for service initialization (e.g., Logger before Database).
- Provides a single point to manage future dependencies like Firebase or local notifications.

## 2. Platform Abstraction Layer (`core/platform`)
**Decision**: All platform-specific behaviors (date pickers, sharing, haptics) must be accessed through a unified interface.
**Why**: 
- Simplifies cross-platform support (Android, iOS, Web).
- Allows UI code to remain platform-agnostic.
- Makes it easier to implement adaptive UI patterns (Material vs. Cupertino) in one place.

## 3. Five-Tab Bottom Navigation
**Decision**: The primary shell navigation is fixed at exactly five tabs (Dashboard, Habits, Goals, Rewards, Family).
**Why**: 
- Optimizes ergonomics for mobile reach.
- Follows the "Five Major Features" rule of the Design System.
- Keeps "Utility" routes like Settings and Profile in the AppBar to reduce primary nav clutter.

## 4. Decoupled Infrastructure
**Decision**: Feature modules never depend directly on implementation details like Firebase, Dio, or SharedPreferences.
**Why**: 
- Allows infrastructure to be swapped (e.g., moving from Firestore to another DB) without rewriting business logic.
- Enables easier unit testing by mocking service interfaces.
- Strictly adheres to Clean Architecture principles.

## 5. Riverpod for Dependency Injection
**Decision**: Wrap all services and controllers in Riverpod providers.
**Why**: 
- Provides a consistent way to access dependencies throughout the app.
- Handles singleton management and lazy loading automatically.
- Facilitates state-driven architecture in the UI layer.

## 6. Design System First (HFDS)
**Decision**: All screens must be built exclusively using components from the `shared/widgets` library.
**Why**: 
- Guarantees visual consistency across the entire product.
- Accelerates development by reusing tested, accessible components.
- Simplifies multi-theme support (Light, Dark, Kids).
