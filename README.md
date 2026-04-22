# UniMates

**UniMates** is a student-only mobile application purpose-built to consolidate campus services into one cohesive platform. It provides a verified environment for university students to engage in community discussions, trade goods in a peer-to-peer marketplace, and recover lost items.

## Core Features

- **Community Hub**: Share posts, comment on discussions, like content, and announce campus events.
- **P2P Marketplace**: A specialized marketplace supporting four transaction types: **Buy, Sell, Borrow, and Exchange**. Includes category filtering and wishlists.
- **Lost & Found**: Streamlined reporting and recovery of misplaced items across campus with resolution tracking.
- **Verified Access**: Secure authentication using **Firebase** with mandatory university email verification.
- **Messaging & Reviews**: Integrated direct messaging for secure communication and a review/rating system to build trust within the community.

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Django REST Framework (Python)
- **Database**: SQLite (Development) / PostgreSQL (Production ready)
- **Authentication**: Firebase Authentication & Firebase Admin SDK
- **Push Notifications**: Firebase Cloud Messaging (FCM)

---

## Getting Started

### Backend Setup (Django)

1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```

2. **Create and activate a virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run migrations**:
   ```bash
   python manage.py migrate
   ```

5. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

### Frontend Setup (Flutter)

1. **Navigate to the frontend directory**:
   ```bash
   cd frontend
   ```

2. **Get Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

---

## Architecture

UniMates follows a modern client-server architecture:
- **Mobile Client**: Built with Flutter, using a service-layer pattern for clean separation of concerns.
- **REST API**: A robust Django backend organized into modular applications (Users, Community, Marketplace, Messaging, Lost & Found, Reviews).
- **Security**: Every API request is verified server-side using Firebase ID tokens.

## License
This project was developed as a Computer Science Final Project at the University of Westminster.
