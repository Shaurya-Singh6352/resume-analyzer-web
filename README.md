# Resume Analyzer: Web

A Flutter web app where you upload a resume and get a score out of 100, a breakdown by category, and specific things to fix. It talks to the Spring Boot API in [resume-analyzer-backend](https://github.com/Shaurya-Singh6352/resume-analyzer-backend).

## Features

- Register and log in; the session persists across page refreshes
- Upload a PDF or Word resume (5 MB limit, checked before uploading)
- Animated score, plus a points bar showing how much each category earned
- Strengths, a list of fixes (first 5 shown, the rest expandable) and skills worth adding
- Readable error messages from the server (wrong file type, scanned PDF, expired session, server offline)
- Responsive layout: two columns on wide screens, stacked on narrow ones

## Tech stack

- Flutter (web) and Dart
- `dio` for HTTP and multipart file upload, with a JWT attached to every request
- `flutter_secure_storage` for keeping the session token between visits
- `file_picker` for choosing the file in the browser
- `google_fonts` (Fraunces and Figtree)

## Run it locally

**Requirements:** Flutter SDK with Chrome, and the backend running on `http://localhost:8080`.

```
flutter pub get
flutter run -d chrome --web-port 3000
```

Keep the port at 3000, because the backend allows that origin in its CORS settings.

To point the app at a different backend:

```
flutter run -d chrome --web-port 3000 --dart-define=API_URL=https://your-server
```

## Project structure

```
lib/
  main.dart                   App entry point; checks for a saved session on startup
  theme.dart                  Colors, text styles and theme
  models/                     AnalysisResult, CategoryScore, AuthResult (mirror the API's JSON)
  services/
    api_service.dart          All HTTP calls, attaches the JWT automatically
    auth_service.dart         Holds the current session and persists the token
  pages/
    login_page.dart           Log in
    register_page.dart        Create an account
    upload_page.dart          Choose a file and start the analysis
    result_page.dart          Score, breakdown, fixes and skills
```

## How it works

1. On startup, the app checks secure storage for a saved token. If one exists, it goes straight to the upload page; otherwise it shows the login page.
2. Logging in or registering calls the backend, saves the returned JWT, and navigates to the upload page.
3. The user picks a PDF or Word file, which is sent to `POST /api/resumes` as multipart form data, with the JWT attached in the `Authorization` header.
4. The backend returns the new resume's id, and the app then calls `GET /api/resumes/{id}/analysis`, also authenticated.
5. The JSON response is turned into an `AnalysisResult` object and shown on the result page.
6. Logging out clears the token from storage and returns to the login page.

## Roadmap

- [x] Login and registration
- [ ] Resume history page
- [ ] Drag-and-drop upload
- [ ] Job description matching