# frontned_laravel

lib/

app/
app.dart
router/
theme/

core/
constants/
network/
errors/
storage/
utils/
widgets/

shared/
models/
providers/
widgets/

features/
auth/
workshops/
categories/
enrollments/

features/workshops/

data/
datasource/
dto/
repository/

domain/
entities/
repository/
usecases/

presentation/
providers/
screens/
widgets/

This is a solid architecture direction. You are making the correct decisions early, which will save
enormous rewrite cost later.

Your backend is already structured like a real SaaS platform, so the frontend should behave like a
real client application — not a Flutter tutorial app.

The most important thing now is:

> establish a stable frontend foundation BEFORE feature velocity starts.

Right now your target is correct:

```text
Public Workshop Catalog
```

That should become the architectural proving ground for everything else.

---

# My Assessment of Your Architecture

You already made the right choices on:

* feature modularization
* Riverpod
* Dio
* GoRouter
* repository pattern
* standardized API envelopes
* backend-driven authorization
* slug-based routing
* pagination-first mindset

This is already beyond typical Flutter projects.

The next challenge is execution discipline.

---

# What Should Happen NEXT

Do NOT start coding screens randomly.

Instead:

# FIRST DELIVERABLE

Build this:

```text
Frontend Core Infrastructure
```

ONLY after that:

```text
Public Workshop Vertical Slice
```

---

# Recommended Real Project Structure

You are close, but I recommend slightly refining it.

```text
lib/

app/
  app.dart
  router/
  theme/

core/
  constants/
  network/
  errors/
  storage/
  utils/
  widgets/

shared/
  models/
  providers/
  widgets/

features/
  auth/
  workshops/
  categories/
  enrollments/
```

Why this matters:

| Folder   | Responsibility                          |
|----------|-----------------------------------------|
| app      | app bootstrapping                       |
| core     | framework-level reusable infrastructure |
| shared   | reusable cross-feature components       |
| features | isolated business modules               |

This separation prevents feature leakage later.

---

# Inside Each Feature

This is the production-grade structure you want.

Example:

```text
features/workshops/

data/
  datasource/
  dto/
  repository/

domain/
  entities/
  repository/
  usecases/

presentation/
  providers/
  screens/
  widgets/
```

---

# CRITICAL ENGINEERING DECISION

## DTO vs Entity Separation

Do NOT use API models directly inside UI.

This becomes catastrophic later.

Use:

```text
DTO -> Entity -> UI
```

Example:

```text
WorkshopDto
WorkshopEntity
WorkshopCardModel (optional)
```

Why?

Because backend contracts WILL evolve.

Entities protect your UI from backend churn.

---

# Strong Recommendation

## Use Freezed Everywhere

This is non-negotiable for scalable Flutter.

Benefits:

* immutable models
* copyWith
* unions/sealed states
* JSON serialization
* safer state management

---

# State Management Strategy

Use Riverpod properly.

NOT:

```dart
StateNotifier with

giant mutable
state
```

Use:

```text
Feature-oriented providers
```

Example:

```dart
workshopListProvider
featuredWorkshopsProvider
workshopDetailProvider
(
slug
)
categoriesProvider
```

This scales beautifully.

---

# Networking Layer Design

This is where most Flutter projects fail.

You should build:

```text
DioClient
  ↓
ApiService
  ↓
RemoteDataSource
  ↓
Repository
  ↓
Provider
  ↓
UI
```

Never skip layers.

---

# Your Core Network Stack

You need these FIRST:

## 1. Dio Client

Responsibilities:

* base URL
* auth token injection
* logging
* timeout handling
* interceptors

---

## 2. Generic API Response Parser

Your backend format is ideal.

Build:

```dart
ApiResponse<T>
```

Generic parser.

This becomes foundational infrastructure.

---

## 3. Failure System

Create typed failures:

```dart
ServerFailure
UnauthorizedFailure

ValidationFailure
NetworkFailure
UnknownFailure
```

Do NOT throw raw exceptions into UI.

---

# Routing Strategy

Use:

## GoRouter

Recommended routes:

```text
/
 /workshops
 /workshops/:slug
 /login
 /register
 /dashboard
```

VERY IMPORTANT:

Public routes use slug.

Never expose IDs publicly.

Correct decision.

---

# Public Workshop Slice

This is your first real validation checkpoint.

---

# What Phase 1 MUST Validate

Before auth:

| Capability            | Must Work |
|-----------------------|-----------|
| pagination            | yes       |
| filtering             | yes       |
| search                | yes       |
| deep links            | yes       |
| slug routing          | yes       |
| loading states        | yes       |
| error states          | yes       |
| empty states          | yes       |
| responsive web layout | yes       |

---

# Flutter Web Reality Check

You are targeting:

```text
Hostinger Shared Hosting
```

So be careful.

Avoid:

* huge JS bundle
* excessive packages
* unnecessary animations
* giant widget trees

Optimize:

* lazy loading
* pagination
* image handling
* caching

---

# Important Recommendation

## Build Responsive Desktop-FIRST

Not mobile-first.

Because:

* Flutter web behaves differently
* admin dashboards need desktop UX
* Hostinger deployment implies browser users

Recommended breakpoints:

```text
< 768   mobile
768-1024 tablet
> 1024 desktop
```

---

# Suggested Initial Screens

ONLY these:

```text
HomePage
WorkshopListingPage
WorkshopDetailPage
SearchResultsPage
```

Do NOT build dashboard/auth yet.

---

# Recommended UI Composition

Example:

```text
HomePage
 ├── HeroSection
 ├── FeaturedWorkshopsSection
 ├── CategoriesSection
 ├── LatestWorkshopsSection
```

Each section independently powered by providers.

This keeps rebuilds isolated.

---

# Search Architecture

You mentioned backend search already exists.

Excellent.

So frontend should:

* debounce search input
* query backend
* avoid local filtering
* preserve pagination state

Do NOT implement fake frontend search.

---

# Pagination Strategy

Do NOT use:

* infinite nested scroll hacks

Instead:

* proper paginated providers
* cursor/page state management

For Flutter web:
classic pagination UI is actually better than mobile infinite feeds.

---

# Biggest Risk In Your Current Plan

This:

```text
building too much infrastructure before validating UX
```

Avoid overengineering.

Your FIRST milestone should be:

# Can user browse workshops smoothly?

Not:

* advanced theming
* dark mode
* animation systems
* admin dashboards
* offline sync

---

# Correct Immediate Action Plan

# Sprint 1

## Foundation

* flutter setup
* folder structure
* dio
* riverpod
* router
* api parser
* error handling

---

# Sprint 2

## Public Workshop Catalog

* homepage
* workshop listing
* workshop details
* categories
* search
* pagination

---

# Sprint 3

## Validation

* responsive testing
* deployment to Hostinger
* route refresh handling
* SEO basics
* loading optimization

---

# AFTER THAT

Only then:

```text
Authentication
Enrollments
Dashboard
RBAC UI
```

.htaccess changes
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /

RewriteRule ^index\.html$ - [L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

RewriteRule . /index.html [L]
</IfModule>

flutter pub run build_runner build --delete-conflicting-outputs