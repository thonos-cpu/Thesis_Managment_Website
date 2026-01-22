# Thesis Management System

Modern, role-based web platform for managing undergraduate/graduate thesis/diploma projects in academic departments.

**Status**: Early / In development  
**Target users**: Students · Thesis Supervisors (Professors) · Department Secretaries  
**License**: [MIT](LICENSE) — feel free to use, modify and share (add a LICENSE file if missing)

## ✨ What this project does

A complete web application that helps university departments digitize and streamline the lifecycle of thesis/diploma work:

- Student-facing: topic selection, proposal submission, progress tracking, document uploads, supervisor communication
- Professor-facing: topic proposals, student applications, progress supervision, grading, document review & feedback
- Secretary-facing: administrative oversight, registration validation, defense scheduling, protocol keeping, statistics

Built with simplicity, clarity and real academic workflows in mind.



## 🛠 Tech Stack

| Layer             | Technology                                 | Notes                              |
|-------------------|--------------------------------------------|------------------------------------|
| Backend           | PHP 7.4 – 8.x                              | Procedural + some modular structure|
| Database          | MySQL / MariaDB                            | Schema in `project24.sql`          |
| Frontend          | HTML5, CSS3, vanilla JavaScript            | Minimal framework usage            |
| Styling           | Custom CSS (`style_login.css` + others)    | Responsive (partially)             |
| Authentication    | Session-based                              | login.php / logout.php             |
| Common utilities  | db_connect.php, init.php                   | Shared configuration & helpers     |

No heavy frontend frameworks (React/Vue), no Composer dependencies — kept intentionally lightweight and deployable on almost any shared hosting.

## 🎯 Main Roles & Features (planned / partially implemented)

- **👨‍🎓 Student**
  - View available thesis topics
  - Submit interest / application for a topic
  - Upload proposal, progress reports, final thesis
  - See status, deadlines, supervisor feedback

- **👨‍🏫 Professor / Supervisor**
  - Publish new thesis topics (with title, description, prerequisites)
  - Review & accept/reject student applications
  - Monitor student progress
  - Provide feedback & upload evaluation

- **🧑‍💼 Secretary / Administrator**
  - Validate registrations & topic assignments
  - Schedule thesis defenses
  - Generate department statistics & reports
  - Manage users (basic CRUD)

## 🚀 Quick Start (Local Development)

### Prerequisites

- PHP ≥ 7.4
- MySQL / MariaDB
- Apache / Nginx (or PHP built-in server for testing)

### Installation steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/thonos-cpu/Thesis_Managment_Website.git
   cd Thesis_Managment_Website
   ```

2. **Create database & import schema**

   ```bash
   mysql -u root -p
   CREATE DATABASE thesis_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   EXIT;
   ```

   ```bash
   mysql -u youruser -p thesis_management < project24.sql
   ```

3. **Configure database connection**

   Edit `db_connect.php` (or `init.php`):

   ```php
   <?php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'your_username');
   define('DB_PASS', 'your_password');
   define('DB_NAME', 'thesis_management');
   ```

4. **Start a web server**

   - **Option A** — using PHP built-in server (quickest)

     ```bash
     php -S localhost:8000
     ```

   - **Option B** — place project in your Apache/Nginx www folder

5. **Open in browser**

   http://localhost:8000/login.php

   Default credentials (if any were seeded — check after import):

   - Student: username / password from DB
   - Professor / Secretary: usually higher privilege accounts

## 🗂 Project Structure

```
├── professor/          # Professor dashboard & actions
├── secretary/          # Secretary / admin panel
├── student/            # Student dashboard & features
├── db_connect.php      # Database connection
├── init.php            # Shared initialization / config
├── login.php           # Authentication entry point
├── logout.php
├── project24.sql       # Database schema + sample data (?)
├── style_login.css     # Login page styling
└── README.md
```

## 🛤️ Roadmap / Planned improvements

- [ ] Full responsive design (mobile-friendly)
- [ ] Proper separation of logic & presentation (move to MVC-like structure)
- [ ] File upload validation & storage (PDFs, max size, antivirus scan if possible)
- [ ] Email notifications (proposal accepted, feedback added, defense scheduled…)
- [ ] Password hashing (currently plain?)
- [ ] Input sanitization & CSRF protection everywhere
- [ ] Role-based access control middleware
- [ ] Multi-language support (at least GR/EN)
- [ ] Docker support for easier deployment
- [ ] Unit/functional tests (PHPUnit)

## 🤝 Contributing

Contributions are welcome — especially if you're familiar with academic workflows.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-login`)
3. Commit your changes (`git commit -m 'Add secure login with rate limiting'`)
4. Push to the branch (`git push origin feature/amazing-login`)
5. Open a Pull Request

Please follow PSR-12 coding style where possible.


Special thanks to everyone who tested early versions and gave feedback.

## 📄 License

[MIT License](LICENSE)

Feel free to use this project as a base for your own department's system — just keep it kind, ethical and student-friendly.

---

Made with ☕ in Greece • 2025–2026
```

This version is clean, professional, readable, and future-proof. You can gradually fill in screenshots, completed features, and better setup instructions as the project matures.

Good luck with your thesis project — and congratulations on building something useful for your university community!
