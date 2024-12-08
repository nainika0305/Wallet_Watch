# 💸 **Finance Tracker App - Wallet Watch**

## 🚀 **Project Overview**
The **Wallet Watch** app is a finance tracker designed to help users monitor and manage their expenses, income, and budgets. Built with **Flutter** for the front-end and **Firebase** for user authentication and data storage, this app ensures secure and seamless financial management. As of now, we’ve established a solid foundation with key features such as user authentication, transaction management, and a user-friendly dashboard.

---

## 🛠️ **Features Implemented So Far**
1. **🔑 Authentication**
   - **Login**: Secure login using Firebase Authentication.
   - **Register**: New users can sign up by providing details such as Name, Email, Password, and preferred Currency.
   - **Password Strength Check**: Password must meet specific criteria to ensure security.
 

2. **💬 User Interface**
   - **Hi Page**: A warm welcome page that displays a motivational quote and leads users to the **AuthPage**.
   - **AuthPage**: Allows users to either log in or register. A toggle between login and registration screens ensures a smooth flow.
   - **Home Page**: The user’s dashboard where financial summaries are displayed, including total available money, along with quick access to transactions, tips, and budget management.

3. **👤 Profile Management**
   - Profile page for managing personal details, currency preferences, and exporting reports.

4. **⚙️ Navigation & Settings**
   - **Bottom Navigation Bar**: Provides easy access to key sections like Home, Transactions, Budgets, and Profile.
   - **Settings Page**: Includes options for currency change, exporting reports, and more.

---

## 📅 **Future Work**
- **📊 Advanced Analytics**: Implement graphs and charts for a visual representation of expenses, income, and budget overviews.
- **💰 Budget Tracking**: Complete the budgeting feature to allow users to set, track, and visualize their financial goals.
- **🌍 Multi-Currency Support**: Enhance functionality by supporting multiple currencies, providing global usability.
- **⚠️ Notifications**: Introduce alerts for upcoming bills, budget limits, or transaction reminders.

---

## 📱 **App Flow**
1. **Hi Page (Motivational Quote)**  
   The journey begins with a motivational quote on the **HiPage**, welcoming the user and guiding them to the **AuthPage** for login or registration.

2. **AuthPage (Login or Register)**  
   On this screen, users can either log in to their existing account or register as a new user.  
   - **Login:** Enter email and password to log in.  
   - **Register:** Sign up with first name, last name, email, password, and currency preferences.

3. **RegisterPage (User Registration)**  
   When the user chooses to sign up, they are prompted to fill out their personal information. Once they submit their details, the app creates a new account, stores user information in Firebase, and redirects them to the **HomePage**.

4. **HomePage (Dashboard)**  
   Upon successful login or registration, users are taken to their **HomePage**, where they can manage their financial details, view transaction summaries, set budgets, and track progress.

---
