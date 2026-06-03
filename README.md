#  Notes App — Flutter Frontend

The mobile client for the Notes App, built with Flutter. Connects to the Django DRF backend for a full-stack note-taking experience.


##  What I Built
A clean, responsive mobile app where users can:
- Register and Login (JWT Auth)
- Create, view, edit and delete notes
- Add and manage subtasks within notes
- Search and paginate through their notes

> Each user can only access their own data, handled securely via the backend.



##  Stack
- **Flutter** — Cross-platform mobile framework
- **Dart** — Primary language
- **HTTP / Dio** — For communicating with the DRF backend
- **SharedPreferences** — For storing JWT tokens locally



##  Getting Started

```bash
git clone [your-repo-link]
cd notes-app-flutter
flutter pub get
flutter run
```

> Make sure the Django backend is running at `http://127.0.0.1:8000/` before launching the app.



##  Where I Struggled
- Managing JWT tokens and handling token refresh on the client side
- Syncing state across screens after create/edit/delete actions
- Understanding how to structure API calls cleanly in Flutter



##  What I Learned
- How to consume a REST API from a Flutter app
- JWT authentication flow on the frontend (storing, sending and refreshing tokens)
- State management and navigation between screens
- Connecting a Flutter frontend to a Django backend end-to-end



Built by **Abhay Singh**
