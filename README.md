# A/B Quiz App (STAT 5243 Project)

## Live App

The quiz app is deployed online and can be accessed here:

 https://w-analytics.shinyapps.io/5243-project-3/

Users can directly open this link and complete the quiz.

---

## Overview

This project is an **A/B testing quiz application** built with **R Shiny**.

Users are randomly assigned to one of two versions:

* **Version A**: answer all questions first, then submit at the end
* **Version B**: answer one question at a time with immediate feedback

All responses are automatically saved to a **Supabase PostgreSQL database**.

---

## How to Use (Testing)

1. Open the app using the link above
2. Complete the quiz (you will be randomly assigned to A or B)
3. Submit your answers and feedback
4. Your data will be automatically recorded

---

## A/B Test Design

### Version A

* All 5 questions shown at once
* Submit at the end
* No immediate feedback

### Version B

* One question at a time
* Submit each answer
* Immediate feedback after each question

---

## Data Storage

All responses are stored in the Supabase table:

```text
quiz_responses
```

Each row contains:

* user_id
* group_name (A / B)
* start_time
* submit_time
* duration_sec
* score
* satisfaction
* ease_of_use
* q1–q5

---

## How to Access Data (For Analysis)

### Step 1: Install packages

```r
install.packages("DBI", repos = "https://cloud.r-project.org")
install.packages("RPostgres", repos = "https://cloud.r-project.org")
```

### Step 2: Load packages

```r
library(DBI)
library(RPostgres)
```

### Step 3: Connect to database

```r
con <- dbConnect(
  RPostgres::Postgres(),
  host = "aws-1-us-west-2.pooler.supabase.com",
  port = 5432,
  dbname = "postgres",
  user = "postgres.vrnffoesrfwutoyovfqz",
  password = "5243-project-3",
  sslmode = "require"
)
```

### Step 4: Load data

```r
data <- dbReadTable(con, "quiz_responses")
```

### Step 5: Disconnect

```r
dbDisconnect(con)
```

---

## Key Variables for A/B Analysis

Use these columns for comparison:

* `group_name` → A vs B
* `score`
* `duration_sec`
* `satisfaction`
* `ease_of_use`

---

