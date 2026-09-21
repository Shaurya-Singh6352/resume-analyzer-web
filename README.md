# Resume Analyzer: Web

A Flutter web app where you upload a resume and see a score out of 100, a breakdown by category, and specific things to fix. It talks to the Spring Boot API in [resume-analyzer-backend](https://github.com/Shaurya-Singh6352/resume-analyzer-backend).

## Features

- Upload a PDF or Word resume (5 MB limit, checked before uploading)
- Animated score with a points bar showing how much each category earned
- Strengths, a list of fixes (first 5 shown, the rest expandable) and skills worth adding
- Readable error messages from the server (wrong file type, scanned PDF, server offline)
- Responsive layout: two columns on wide screens, stacked on narrow ones

## Tech stack

- Flutter (web) and Dart
- `dio` for HTTP and multipart upload
- `file_picker` for choosing the file in the browser
- `google_fonts` (Fraunces and Figtree)

## Run it locally

**Requirements:** Flutter SDK with Chrome, and the backend running on `http://localhost:8080`.

```
flutter pub get
flutter run -d chrome --web-port 3000
```

Keep the port at 3000, because the backend allows that origin in its CORS settings.

To point at a different backend:

```
flutter run -d chrome --web-port 3000 --dart-define=API_URL=https://your-server
```

## Project structure

```
lib/
  main.dart               App entry and theme
  theme.dart              Colors, text styles, theme
  models/                 AnalysisResult, CategoryScore (mirror the API JSON)
  services/api_service.dart   All HTTP calls in one place
  pages/
    upload_page.dart      Choose a file and start the analysis
    result_page.dart      Score, breakdown, fixes, skills
```

## Roadmap

- [ ] Login and registration
- [ ] Resume history page
- [ ] Drag-and-drop upload
- [ ] Job description matching