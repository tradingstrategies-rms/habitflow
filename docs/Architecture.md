# HabitFlow Technical Architecture

Version: 1.0
Status: MVP
Platform: Flutter (Android + iOS)
Architecture: Clean Architecture + Feature First
Author: HabitFlow CTO

---

# Vision

HabitFlow is a premium family habit management platform designed to help individuals and families build better habits through goals, rewards, analytics, and gamification.

The architecture must be:

- Scalable
- Maintainable
- Testable
- Offline-first ready
- Cross-platform
- Startup-ready

---

# Technology Stack

## Framework

Flutter Stable

## Language

Dart

## IDE

Android Studio + Gemini

## Backend

Firebase

- Authentication
- Cloud Firestore
- Storage
- Cloud Messaging
- Analytics
- Crashlytics

## Local Storage

SharedPreferences (Sprint 0)

Offline database (Sprint 3)

Repository abstraction must allow changing the database implementation without affecting business logic.

## State Management

Riverpod

## Navigation

GoRouter

## Charts

fl_chart

## Fonts

Google Fonts (Inter)

---

# Architecture Principles

HabitFlow follows:

- Clean Architecture
- SOLID Principles
- Feature First Architecture
- Repository Pattern
- Dependency Injection using Riverpod

Business logic must never exist inside Widgets.

---

# Application Layers

Presentation

↓

Application

↓

Domain

↓

Infrastructure

↓

Firebase / Local Storage

Each layer must only communicate with adjacent layers.

---

# Folder Structure

lib/

app/

core/
  constants/
  errors/
  extensions/
  router/
  services/
  theme/
  utils/

features/
  authentication/
  onboarding/
  dashboard/
  habits/
  goals/
  rewards/
  family/
  analytics/
  settings/

shared/
  components/
  widgets/
  models/

main.dart

---

# Feature Structure

Each feature follows the same structure.

Example

features/habits/

presentation/

application/

domain/

data/

widgets/

This structure should be used only when feature implementation begins.

Sprint 0 only creates the feature folders.

---

# Navigation

GoRouter

Primary Routes

/

login

register

dashboard

habits

goals

rewards

family

analytics

settings

Navigation should be centralized.

No hardcoded navigation inside widgets.

---

# Theme System

Three Themes

Light

Dark

Kids

Theme switching must be centralized.

Use Material Design 3.

Use Inter font.

Support future dynamic theming.

---

# Design System

Use the attached HabitFlow Design System (HFDS).

Never create UI outside the design system.

Reusable components must be used.

---

# State Management

Riverpod

Rules

Business logic must live inside Providers or Controllers.

Widgets remain as stateless as possible.

Avoid global mutable state.

---

# Repository Pattern

UI

↓

Controller / Provider

↓

Use Case

↓

Repository

↓

Data Source

↓

Firebase / Local Storage

Repositories expose interfaces.

Implementation details remain hidden.

---

# Dependency Injection

Riverpod Providers

Singleton services

Lazy initialization where appropriate

No service locator packages.

---

# Error Handling

Use typed exceptions.

Centralize error messages.

Show user-friendly messages.

Never expose raw exceptions to users.

---

# Logging

Debug logging only during development.

Production logging through Firebase Crashlytics.

---

# Performance Guidelines

Target

60 FPS

Avoid unnecessary rebuilds.

Prefer const widgets.

Lazy load lists.

Keep widget trees shallow.

Avoid expensive operations in build methods.

---

# Responsive Design

Support

Android Phones

Android Tablets (future)

iPhone

iPad (future)

Respect Safe Areas.

No hardcoded dimensions.

---

# Accessibility

High contrast

Dynamic text scaling

Minimum touch target

48dp

Screen reader friendly

Meaningful semantic labels

---

# Offline Strategy

Sprint 0

No offline persistence.

Sprint 3

Introduce local database.

Repository pattern ensures offline implementation can change without affecting business logic.

---

# Security

Authentication through Firebase.

Parent PIN handled locally.

Sensitive data never stored in plain text.

Future encryption support.

---

# Testing Strategy

Unit Tests

Repository Tests

Provider Tests

Widget Tests

Integration Tests

Business logic should be easily testable.

---

# Git Workflow

Main Branch

main

Development Branch

develop

Feature Branches

feature/authentication

feature/dashboard

feature/habits

feature/goals

Commit after every completed task.

---

# Coding Standards

One responsibility per class.

Small widgets.

Small methods.

Meaningful naming.

Prefer composition over inheritance.

Use const whenever possible.

No duplicated code.

No business logic inside widgets.

---

# Project Principles

1. Simplicity over complexity.

2. Reusable components before custom implementations.

3. One source of truth.

4. Offline-ready architecture.

5. Startup-quality code.

6. Cross-platform from day one.

7. Performance is a feature.

8. Every sprint must leave the application in a working state.

---

# MVP Modules

Authentication

Family

Dashboard

Habits

Goals

Rewards

Analytics

Settings

---

# Future Modules

Friends

Community

Marketplace

Habit Templates

Reward Marketplace

Widgets

Watch Support

AI Coach

Family Tree Dashboard

Gamification Events

---

# CTO Rules

Never generate code outside the project architecture.

Never bypass reusable components.

Never hardcode business logic inside UI.

Never introduce dependencies without justification.

Every pull request (or AI-generated change) must keep the project compiling successfully.

When uncertain, prefer maintainability over cleverness.

The objective is to build a startup-quality Flutter application that can scale to hundreds of thousands of users while remaining easy to understand and extend.