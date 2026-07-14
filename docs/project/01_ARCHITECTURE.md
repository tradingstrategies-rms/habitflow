# Architecture

Pattern

Feature First

State

Riverpod

Routing

GoRouter

Backend

Firebase

Repositories

Controllers

Widgets

Rules

No business logic inside Widgets.

Repositories talk to Firebase.

Controllers manage state.

Widgets remain presentation only.

Bootstrap.initialize()

owns

Firebase initialization

SharedPreferences

ProviderContainer

ApplicationInitializer