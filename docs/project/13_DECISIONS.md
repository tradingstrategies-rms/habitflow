# Architectural Decisions

## Sprint 2 Decisions

### 1. Database Service Injection (NoOp vs Firestore)
- **Decision**: Replaced `NoOpDatabaseService` with `FirestoreService` in `databaseServiceProvider`.
- **Reason**: To enable real-time cloud profile persistence and synchronize profile completion state across sessions.

### 2. Navigation Pop Safety
- **Decision**: Standardized `context.pop()` calls with `canPop()` verification and fallback to `context.go(RoutePaths.dashboard)`.
- **Reason**: To prevent `GoError: There is nothing to pop` in initial onboarding scenarios.

### 3. Profile Completion Redirection
- **Decision**: Logic moved into the `GoRouter` redirect function watching `userProfileProvider`.
- **Reason**: Ensures declarative route enforcement as soon as a user session exists without a profile.
