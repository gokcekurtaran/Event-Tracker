🎟️ Event Tracker

A full-stack event tracking and management application developed with Flutter and Django REST Framework. The application provides separate interfaces for participants and organizers, allowing users to discover events while organizers manage their own events, participants, and reports.

📌 About the Project

Event Tracker was developed as an internship project to demonstrate mobile and backend integration in a real-world event management scenario.

Participants can create an account, explore published events, search and filter events, join or leave an event, save favorite events, view their registered events on a calendar, and manage their profiles.

Organizers can sign in through a separate organizer login, create and update events, manage event status, view registered participants, and access reports for their own events. Organizer accounts are created through the Django admin panel.

The project consists of:

📱 Flutter Mobile Application<br>⚙️ Django REST Framework API<br>🗄️ SQLite Database<br>🖥️ Django Admin Panel<br>

🚀 Features

🔐 Authentication

Participant registration<br>Separate participant and organizer login<br>JWT access and refresh token authentication<br>Secure token storage with Flutter Secure Storage<br>Automatic access token renewal<br>Refresh token rotation and blacklist support<br>Automatic logout when the session expires<br>Login and registration rate limiting<br>Role-based authorization<br>

👤 Participant Features

Participants can:

View published events<br>Search events<br>Filter events by category, city, date, and price<br>View upcoming events<br>View event details<br>Join an event<br>Cancel an event registration<br>View joined events<br>Add events to favorites<br>Remove events from favorites<br>View joined events on a calendar<br>View and update profile information<br>Upload a profile image<br>

The backend prevents duplicate event registrations and checks the remaining event capacity before accepting a registration.

🧑‍💼 Organizer Features

Organizers can:

Sign in through the organizer login<br>View only the events they created<br>Create events with a cover image<br>Save events as draft or published<br>Update event information<br>Change event status<br>View registered participants<br>View event reports<br>

Organizers can only update, inspect, and report on their own events. The ownership check prevents one organizer from accessing another organizer’s participant information or reports.

📅 Event Management

Each event contains:

Title and description<br>Cover image<br>Category<br>Start and end date<br>City<br>Location name and address<br>Optional latitude and longitude<br>Participant capacity<br>Ticket price<br>Organizer information<br>Event status<br>

Supported event statuses:

Draft<br>Published<br>Cancelled<br>Completed<br>

Only published events appear in the general participant event list.

🔎 Search and Filtering

The event API supports:

Text search<br>Category filtering<br>City filtering<br>Start and end date filtering<br>Free or paid event filtering<br>Upcoming event filtering<br>Result ordering<br>Page-based pagination<br>

Event lists are paginated with a maximum of 20 results per page.

❤️ Favorites and Calendar

Participants can add or remove published events from favorites<br>Duplicate favorite records are prevented<br>Joined events are displayed in the “My Events” section<br>Registered events are marked on an interactive calendar<br>Calendar views can be changed between month, two-week, and week formats<br>

📊 Organizer Reports

The organizer report screen displays:

Event capacity<br>Registered participant count<br>Cancelled registration count<br>Remaining capacity<br>

The participant list includes the participant’s name, e-mail address, profile image, and registration date.

🙍 Profile Management

Users can:

View their profile<br>Update first name and last name<br>Add or update a profile image<br>Update city information<br>Update biography<br>

E-mail address and user role are read-only and cannot be changed from the profile screen.

🛠️ Technologies Used

⚙️ Backend

Python<br>Django<br>Django REST Framework<br>Simple JWT<br>Django Filter<br>Django CORS Headers<br>Pillow<br>Django ORM<br>

📱 Mobile

Flutter<br>Dart<br>Riverpod<br>Dio<br>Flutter Secure Storage<br>Cached Network Image<br>Image Picker<br>Intl<br>Table Calendar<br>

🗄️ Database

SQLite<br>

🧰 Development Tools

Visual Studio Code<br>PyCharm<br>Postman<br>Git<br>GitHub<br>

📂 Project Structure

<pre>
Event_Tracker
│
├── backend
│   ├── accounts
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   └── urls.py
│   │
│   ├── events
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── filters.py
│   │   ├── permissions.py
│   │   ├── views.py
│   │   └── urls.py
│   │
│   ├── attendance
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── organizer_views.py
│   │   ├── permissions.py
│   │   ├── views.py
│   │   └── urls.py
│   │
│   ├── config
│   ├── media
│   ├── db.sqlite3
│   └── manage.py
│
├── mobile
│   ├── lib
│   │   ├── core
│   │   │   ├── constants
│   │   │   ├── network
│   │   │   ├── routing
│   │   │   ├── storage
│   │   │   └── theme
│   │   │
│   │   ├── features
│   │   │   ├── attendance
│   │   │   ├── auth
│   │   │   ├── calendar
│   │   │   ├── events
│   │   │   ├── favorites
│   │   │   ├── organizer
│   │   │   └── profile
│   │   │
│   │   ├── app.dart
│   │   └── main.dart
│   │
│   └── pubspec.yaml
│
└── README.md
</pre>

⚙️ Installation

📥 Clone the Repository

git clone https://github.com/gokcekurtaran/Event_Tracker.gitcd Event_Tracker

⚙️ Backend Setup

cd backendpython -m venv venv

Activate the virtual environment on Windows:

venv\Scripts\activate

Install the required packages:

pip install django djangorestframework djangorestframework-simplejwt django-filter django-cors-headers pillow

Apply the database migrations:

python manage.py migrate

Create an administrator account:

python manage.py createsuperuser

Run the backend:

python manage.py runserver 0.0.0.0:8000

Organizer accounts and event categories can be created from:

http://127.0.0.1:8000/admin/

📱 Mobile Setup

Open a new terminal:

cd mobileflutter pub getflutter run

The API address is defined in:

mobile/lib/core/constants/api_constants.dart

You can also provide the backend address while running the application:

flutter run --dart-define=API_BASE_URL=http://YOUR_IP_ADDRESS:8000/api

The mobile device and the computer running Django must be connected to the same network when a local IP address is used.

🔒 Authentication

The project uses JWT authentication. Access and refresh tokens returned after login or registration are stored with Flutter Secure Storage.

Authorization: Bearer <access_token>

Access tokens are valid for 15 minutes and refresh tokens are valid for 7 days. When an authenticated request returns 401 Unauthorized, the Dio interceptor attempts to renew the access token and repeats the failed request. If renewal fails, saved session information is cleared.

🔗 Main API Endpoints

🔐 Authentication

POST   /api/auth/register/POST   /api/auth/participant/login/POST   /api/auth/organizer/login/POST   /api/auth/refresh/GET    /api/auth/profile/PATCH  /api/auth/profile/POST   /api/auth/logout/

📅 Events

GET    /api/categories/GET    /api/events/GET    /api/events/{id}/POST   /api/events/PATCH  /api/events/{id}/GET    /api/events/my-events/

❤️ Participation and Favorites

POST   /api/events/{id}/join/POST   /api/events/{id}/leave/POST   /api/events/{id}/favorite/DELETE /api/events/{id}/favorite/GET    /api/me/attendances/GET    /api/me/favorites/

🧑‍💼 Organizer

GET    /api/organizer/events/{id}/participants/GET    /api/organizer/events/{id}/report/

📱 Screenshots

<img width="878" height="1600" alt="WhatsApp Image 2026-07-27 at 15 52 08 (3)" src="https://github.com/user-attachments/assets/79deeb12-8166-4e1c-b778-67842560c719" />
<img width="856" height="1600" alt="WhatsApp Image 2026-07-27 at 15 52 08 (2)" src="https://github.com/user-attachments/assets/a5c80179-9c60-4ba4-bae4-81c199366c18" />
<img width="814" height="1600" alt="WhatsApp Image 2026-07-27 at 15 52 08 (1)" src="https://github.com/user-attachments/assets/63ff3ad9-3a94-4cf0-bf2a-208e12428538" />
<img width="852" height="1600" alt="WhatsApp Image 2026-07-27 at 15 52 08" src="https://github.com/user-attachments/assets/85173be5-3be8-4c92-ad52-686b9659d9c7" />

📈 Future Improvements

E-mail verification and password reset<br>Push notifications for upcoming events<br>Map integration for event locations<br>Online payment integration for paid events<br>Exportable event reports<br>Dark mode<br>Multi-language support<br>

🎯 Learning Outcomes

During this project, I gained practical experience in:

Developing RESTful APIs with Django REST Framework<br>Integrating a Flutter application with a Django backend<br>JWT authentication and automatic token renewal<br>Secure token storage<br>Role and object-based authorization<br>State management with Riverpod<br>API communication and interceptors with Dio<br>Search, filtering, ordering, and pagination<br>Image upload with multipart form data<br>Relational data modeling with Django ORM<br>API testing with Postman<br>Git and GitHub workflow<br>

👩‍💻 Developer

Developed by Gökçe Kurtaran as part of an internship project.


