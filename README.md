 🎟️ Event Tracker

Event Tracker is a full-stack event management application developed with **Flutter** and **Django REST Framework** as part of an internship project.

The application provides role-based interfaces for participants and organizers. Participants can discover and join events, while organizers can create events and manage registrations.

🚀 Features

 👤 Participant

* Register and log in
* Search and filter published events
* View event details
* Join or leave events
* Add events to favorites
* View joined events on a calendar
* Update profile information and profile image

 🧑‍💼 Organizer

* Sign in through a separate organizer login
* Create and update events
* Save events as draft or published
* Manage event status
* View registered participants
* Access event reports

Organizers can only manage their own events. Organizer accounts are created through the Django admin panel.

 🔐 Authentication and Security

* JWT access and refresh tokens
* Secure token storage
* Automatic access-token renewal
* Refresh-token rotation and blacklist support
* Role-based authorization
* Login and registration rate limiting
* Capacity and duplicate-registration checks

 🔎 Search and Filtering

Events can be searched, ordered, and filtered by:

* Category
* City
* Date
* Price
* Upcoming status

The API also supports page-based pagination.

📊 Organizer Reports

Organizers can view event capacity, registered participants, cancelled registrations, remaining capacity, and participant details.

🛠️ Technologies

### Backend

* Python
* Django
* Django REST Framework
* Simple JWT
* Django Filter
* Django CORS Headers
* SQLite
* Pillow

### Mobile

* Flutter and Dart
* Riverpod
* Dio
* Flutter Secure Storage
* Cached Network Image
* Image Picker
* Table Calendar
* Intl

 ⚙️ Installation

 Clone the Repository

```bash
git clone https://github.com/gokcekurtaran/Event_Tracker.git
cd Event_Tracker
```

### Backend Setup

```bash
cd backend
python -m venv venv
```

Activate the virtual environment on Windows:

```bash
venv\Scripts\activate
```

Install the dependencies and start the server:

```bash
pip install django djangorestframework djangorestframework-simplejwt django-filter django-cors-headers pillow
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver 0.0.0.0:8000
```

Django admin panel:

```text
http://127.0.0.1:8000/admin/
```

### Mobile Setup

```bash
cd mobile
flutter pub get
flutter run
```

Run the application with a custom backend address:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_IP_ADDRESS:8000/api
```

The mobile device and computer must be connected to the same network when using a local IP address.

 🔗 Main API Endpoints

 Authentication

```text
POST   /api/auth/register/
POST   /api/auth/participant/login/
POST   /api/auth/organizer/login/
POST   /api/auth/refresh/
GET    /api/auth/profile/
PATCH  /api/auth/profile/
POST   /api/auth/logout/
```

 Events

```text
GET    /api/categories/
GET    /api/events/
GET    /api/events/{id}/
POST   /api/events/
PATCH  /api/events/{id}/
GET    /api/events/my-events/
```

 Participation and Favorites

```text
POST   /api/events/{id}/join/
POST   /api/events/{id}/leave/
POST   /api/events/{id}/favorite/
DELETE /api/events/{id}/favorite/
GET    /api/me/attendances/
GET    /api/me/favorites/
```

 Organizer

```text
GET /api/organizer/events/{id}/participants/
GET /api/organizer/events/{id}/report/
```

 📈 Future Improvements

* E-mail verification and password reset
* Push notifications
* Map and online payment integration
* Exportable reports
* Dark mode
* Multi-language support

 🎯 Learning Outcomes

This project provided practical experience in REST API development, Flutter–Django integration, JWT authentication, Riverpod state management, role-based authorization, filtering, pagination, image uploads, relational data modeling, and Git/GitHub workflows.

👩‍💻 Developer

Developed by **Gökçe Kurtaran** as part of an internship project.



