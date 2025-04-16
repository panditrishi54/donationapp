Food Donor App
A mobile application built with Flutter and Firebase to connect food donors with charities, helping to reduce food waste and ensure surplus food reaches those in need.
Project link https://food-donation-ceafc.web.app/
Table of Contents

About
Features
Tech Stack
Screenshots
Installation
Usage
Contributing
License
Contact

About
The Food Donor App facilitates the donation of surplus food by connecting donors (individuals, restaurants, or businesses) with charities. It aims to reduce food waste through a user-friendly platform that supports secure authentication, real-time donation tracking, and efficient data management.
Features

Secure Authentication: User login and registration via Firebase Authentication.
Donation Management: Donors can list surplus food; charities can request or accept donations.
Real-Time Updates: Track donation status and receive live updates.
Firestore Database: Stores donor and charity details for seamless access.
Intuitive UI: Simple and smooth interface for an enhanced user experience.
Waste Reduction: Streamlines the donation process to minimize food waste.

Tech Stack

Frontend: Flutter (Dart)
Backend: Firebase
Firebase Authentication: Secure user management
Firestore: Database for storing donation and user data


Hosting: Firebase Hosting (for web deployment)

Home Screen
Donation Tracking
User Profile

Note: Replace the placeholder image paths with actual screenshots. Host them in a screenshots/ folder in your repository.
Installation
Follow these steps to set up the project locally.
Prerequisites

Flutter SDK (version >= 3.0.0)
Dart (included with Flutter)
Firebase CLI (optional, for deployment)
Android Studio or VS Code
A Firebase project set up via the Firebase Console

Steps

Clone the repository:
git clone https://github.com/panditrishi54/donationapp.git
cd food-donor-app


Install dependencies:
flutter pub get


Set up Firebase:

Create a Firebase project in the Firebase Console.
Add an Android and/or iOS app to your Firebase project.
Download the google-services.json (for Android) or GoogleService-Info.plist (for iOS) and place them in the android/app/ or ios/Runner/ directories, respectively.
Enable Firebase Authentication (e.g., Email/Password) and Firestore in the Firebase Console.

Run the app:
flutter run



Note: Ensure a compatible device or emulator is set up. For Android, verify minSdkVersion (e.g., 21) in android/app/build.gradle.
Usage

Register/Login: Sign up as a donor or charity using Firebase Authentication.
Donors: Post surplus food details (e.g., type, quantity, location).
Charities: Browse and claim available donations.
Track Donations: Monitor donation progress and view history in real-time.

Contributing
Contributions are welcome! To contribute:

Fork the repository.
Create a feature branch (git checkout -b feature/your-feature).
Commit changes (git commit -m 'Add your feature').
Push to the branch (git push origin feature/your-feature).
Open a Pull Request.

Please follow the Code of Conduct and ensure your code adheres to the project's style guidelines.
License
This project is licensed under the MIT License. See the LICENSE file for details.
Contact
For questions or feedback, reach out via:

Email: your-panditrishi54@example.com





![1 - Copy](https://github.com/user-attachments/assets/fcb4f14d-e876-41b0-ad3a-a1866d094e1c)
