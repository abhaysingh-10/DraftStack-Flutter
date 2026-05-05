# Draft Stack — Flutter Frontend

Built this while learning Flutter and state management.

---

## What I Built

A mobile notes app connected to my Django REST Framework backend.
Handles login, register, full CRUD for notes with subtasks, debounced search, and dark mode.

---

## Stack

- Flutter
- flutter_secure_storage (JWT Storage)
- http (API Integration)

---

## Where I Struggled

- Debugging secure storage persistence on a real iPhone 16e
- Building a debounced search that doesn't spam the API on every keystroke
- Managing form state for notes that have nested subtasks inside them
- Handling loading, success, and error states cleanly across screens

---

## What I Learned

- Flutter widget lifecycle and how to structure a real app
- How to store JWT tokens securely and inject them into every API request
- How to manage UI state using setState across multiple screens
- How to connect a Flutter app to a backend I built myself from scratch

---

## Next Steps

- Migrate state management to Riverpod
- Add offline caching for notes
- Improve UI polish and animations

---

Built by Abhay Singh
