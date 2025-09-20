# talent_assessment

<p align="center">
  </p>

<h1 align="center">Talent Assessment</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter Version">
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green" alt="Platform">
</p>

<p align="center">
  <i>Unleash athletic potential with AI-powered video analysis.</i>
</p>

An application built with Flutter to assess athletic talent through video. This app provides performance analysis, gamification, and detailed feedback to help athletes track and improve their skills.

---

## ✨ Key Features

* **🎯 AI-Powered Analysis (Simulated):** A framework for cheat detection and pose estimation to validate tests and count repetitions.
* **📹 Video-Based Assessments:** Record fitness tests (like sit-ups and push-ups) directly in the app using the device's camera.
* **📊 Detailed Results:** An enhanced results screen provides instant feedback on performance, authenticity, and form quality.
* **🏆 Gamification & Leaderboards:** Earn badges for completing milestones and compete with other users on a live leaderboard.
* **👤 User Dashboard & Profile:** A personalized home screen welcomes the user and displays key stats. The profile tracks all recent assessment history.
* **🔒 Secure Authentication:** A complete user sign-up and login flow powered by Firebase Authentication.

---


## 🛠️ Tech Stack

-   **Frontend:** Flutter & Dart
-   **Backend & Authentication:** Firebase (Firestore, Firebase Auth)
-   **AI / Machine Learning Framework:** Google ML Kit (Pose Detection)
-   **State Management:** Provider

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

-   You must have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
-   A Firebase project connected to your account.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Dpstroke/talent_assessment.git](https://github.com/Dpstroke/talent_assessment.git)
    ```
2.  **Navigate into the project directory:**
    ```bash
    cd talent_assessment
    ```
3.  **Install all dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Configure Firebase for your project:**
    This command connects the app to your Firebase backend and generates the necessary `firebase_options.dart` file.
    ```bash
    flutterfire configure
    ```
5.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📝 Roadmap

The core application structure is complete. The next major phase is to replace the simulated AI services with real, functional implementations.

-   [ ] **Implement Real Pose Estimation:** Replace the mock data with a real implementation using `google_mlkit_pose_detection` to analyze video frames.
-   [ ] **Develop Rep Counting Algorithms:** Write the logic to analyze the sequence of pose data to accurately count repetitions for various exercises.
-   [ ] **Enhance Cheat Detection:** Move from a simulation to a rule-based system for validating the authenticity of assessments.
-   [ ] **Add More Tests:** Expand the app to include analysis for push-ups, vertical jumps, and other fitness tests.

---

## 📜 License

This is a proprietary project. All rights are reserved by the owner.

You are not permitted to copy, distribute, or modify the code without explicit written permission from the repository owner.
