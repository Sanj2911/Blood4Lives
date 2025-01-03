#Blood Donation App
A feature-rich mobile application designed to streamline the blood donation process by connecting donors and recipients in real-time. This app offers advanced features such as location tracking, emergency alerts, and donation history management.

#Features
User Authentication: Secure login and registration.
Real-Time Location Tracking: Find donors or recipients nearby.
Blood Type Matching Algorithm: Accurate donor-recipient matches.
Notification System: Alerts for donation requests and confirmations.
Inactive Donor Management: Automatic tracking of donor activity based on donation dates.
User-Friendly Interface: Simple and intuitive design.

#Technology Stack
Frontend: Flutter
Backend: Firebase Realtime Database and Firestore
Notifications: Firebase Cloud Messaging (FCM)

##Getting Started
#Prerequisites
Install Flutter and set up your development environment.
Configure Firebase with your project:
Add google-services.json (Android) or GoogleService-Info.plist (iOS) to your app.

#Install dependencies:
flutter pub get

#Clone this repository
#Navigate to the project directory
#Run the app

##App Structure
lib/: Contains the main app logic and UI components.
screens/: All app screens (e.g., Login, Dashboard, Donation History).
services/: Firebase and backend interaction services.
models/: Data models (e.g., User, Donor, Recipient).
widgets/: Reusable UI components.
