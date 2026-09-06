# 🚀 Campus Pay & Finance - Full Stack Application

Welcome to **Campus Pay & Finance**, a comprehensive full-stack ecosystem designed for universities and campus communities. The application features student financial dashboards, scholarship trackers, savings marketplace, reseller store management, app-wide dark mode, and integrated Razorpay payment gateway processing.

---

## 🛠️ Architecture & Technology Stack

### **Backend (`/back/HackBackend`)**
- **Framework**: Java 17 / Spring Boot 3.x
- **Database**: PostgreSQL (Hosted Cloud Database on Supabase)
- **ORM / Persistence**: Spring Data JPA / Hibernate
- **Payment Gateway**: Razorpay REST APIs (`razorpay-java`)
- **Server Port**: `8085`

### **Frontend (`/front`)**
- **Framework**: Flutter 3.x (Dart SDK `^3.12`)
- **Supported Platforms**: Web (Chrome/Edge), Android, iOS, Windows, macOS
- **State Management & Persistence**: `ValueNotifier`, `shared_preferences`
- **UI & Typography**: Google Fonts (`Inter`, `Plus Jakarta Sans`), Custom Emerald & Dark Mode Design System

---

## 📦 Prerequisites

Ensure you have the following installed on your development machine before launching:

1. **Java Development Kit (JDK 17 or higher)**
   - Check version: `java -version`
2. **Apache Maven (3.8+)**
   - Check version: `mvn -version`
3. **Flutter SDK (3.12+ / latest stable)**
   - Check installation: `flutter doctor`
4. **Google Chrome or Microsoft Edge** (For running Flutter Web)

---

## ⚙️ Configuration & Environment

### **Database & Backend Configuration**
The backend connects to a cloud-hosted Supabase PostgreSQL database. Credentials and Razorpay keys are configured in `d:\Init\back\HackBackend\src\main\resources\application.properties`:

```properties
spring.application.name=HackBackend
server.port=8085

# Supabase PostgreSQL Configuration
spring.datasource.url=jdbc:postgresql://aws-0-ap-south-1.pooler.supabase.com:5432/postgres
spring.datasource.username=postgres.medemnxzbugsogwnlioc
spring.datasource.password=sWBltKaHsmXxwLqU
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA / Hibernate Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Razorpay Payment Gateway Credentials
razorpay.key.id=rzp_test_SEO5AnkQEjW8M8
razorpay.key.secret=VLTLuSdC9pI9uT96QnAM7rkx
```

---

## 🚀 Step-by-Step Launch Guide

### **Step 1: Start the Backend (Spring Boot Server)**

1. Open your terminal or Command Prompt and navigate to the backend folder:
   ```cmd
   cd d:\Init\back\HackBackend
   ```
2. Build the project using Maven:
   ```cmd
   mvn clean install
   ```
3. Launch the Spring Boot application:
   ```cmd
   mvn spring-boot:run
   ```
   *Note*: The backend API server will start on **`http://localhost:8085`**.

---

### **Step 2: Start the Frontend (Flutter Application)**

1. Open a new terminal window and navigate to the frontend folder:
   ```cmd
   cd d:\Init\front
   ```
2. Fetch and sync all required Flutter package dependencies:
   ```cmd
   flutter pub get
   ```
3. Run the application in Chrome browser:
   ```cmd
   flutter run -d chrome
   ```
   *(Optional)* To run on other devices:
   ```cmd
   flutter run -d windows
   flutter run -d android
   ```

---

## 🔑 Key Features & User Roles

### 1. **Role-Based Authentication**
- **Student (User Type 0)**: Access campus wallet, fee records, scholarship applications, and student savings tracker.
- **Reseller (User Type 1)**: Access reseller management panel for selling products, updating stock, and tracking store revenue.

### 2. **Marketplace & Razorpay Payments**
- Browse campus marketplace items (textbooks, lab gear, calculators).
- Built-in Razorpay checkout modal for live payment processing.

### 3. **App-Wide Dark Mode**
- Instant toggle between light and dark modes across dashboards, product cards, trackers, profile settings, and login/register screens.

---

## 🌐 API Reference Endpoints

| HTTP Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/auth/register` | Register a new user in PostgreSQL database |
| `POST` | `/api/auth/login` | Authenticate user credentials & return role/type |
| `GET` | `/api/users/{id}` | Retrieve complete user profile details |
| `GET` | `/api/marketplace` | Fetch active campus marketplace listings |
| `POST` | `/api/marketplace` | Post a new item for sale |
| `POST` | `/api/payments/create-order` | Generate Razorpay transaction order ID |
| `POST` | `/api/payments/verify` | Verify payment signature and complete transaction |

---

## ❓ Troubleshooting

- **Database Connection Error**: Ensure your internet connection is active as Supabase PostgreSQL is hosted in the cloud (`aws-0-ap-south-1.pooler.supabase.com:5432`).
- **Android Emulator Backend Access**: If running Flutter on an Android emulator instead of Chrome, change the backend base URL in `lib/services/api_service.dart` to `http://10.0.2.2:8085`.
