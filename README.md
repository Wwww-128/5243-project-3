# A/B Quiz App (STAT 5243 Project)

## Overview

This project is an A/B testing quiz application built with **R Shiny**.

* **Version A**: Answer all questions at once, then submit
* **Version B**: Answer one question at a time with immediate feedback

All responses are automatically saved to a shared **Google Sheet**.

---

# Quick Start

Follow these steps exactly to run the app locally.

---

## 1. Install R (if not installed)

---

## 2. Open Terminal and go to project folder

```bash
cd path/to/5243-project-3
```

---

## 3. Start R

```bash
R
```

You should now see something like:

```text
>
```

---

## 4. Install required packages (ONLY FIRST TIME)

Copy and run:

```r
install.packages("shiny")
install.packages("tibble")
install.packages("googlesheets4")
```

---

## 5. Load libraries

```r
library(shiny)
library(tibble)
library(googlesheets4)
```

---

## 6. Google Login (IMPORTANT)

Run:

```r
options(gargle_oauth_cache = ".secrets")
gs4_auth()
```

👉 A browser window will open
👉 Log in with the Google account that has access to the Sheet

---

## 7. Run the app

```r
shiny::runApp("app.R")
```

---

## 8. Open the app

It will open automatically in your browser:

```text
http://127.0.0.1:xxxx
```

---

# 🧪 How to Test

1. Open the app
2. You will be randomly assigned to **Version A or B**
3. Complete the quiz
4. Submit answers and feedback

---

# 📊 Where the Data Goes

All responses are saved automatically to:

👉 **Google Sheet (shared with the team)**

Each row contains:

* user_id
* group (A or B)
* timestamps
* score
* answers (q1–q5)
* satisfaction ratings

---

