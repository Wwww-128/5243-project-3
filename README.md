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
## Statistical Analysis

To evaluate the effectiveness of the A/B test, we conducted a comprehensive statistical analysis based on the collected user data.

The analysis compares Version A and Version B across multiple dimensions:

- performance (quiz score)  
- efficiency (completion time)  
- user experience (satisfaction and ease of use)  

---

### Analysis Files

- `AB test analysis.ipynb`  
  - Data cleaning and preprocessing  
  - Outlier detection and removal  
  - Exploratory data analysis and visualization  

- `Statistical Analysis.ipynb`  
  - Data quality control, including outlier removal for completion time using a 3×IQR rule  
  - Feature engineering to construct analysis variables such as:
    - treatment indicator (`group_B`)  
    - efficiency (score / duration)  
    - behavioral metrics (fast completion, high satisfaction, success rate)  
  - Statistical comparison between Version A and Version B using:
    - two-sample t-tests  
    - non-parametric tests (Mann–Whitney for duration)  
    - proportion tests for categorical outcomes (per-question accuracy and behavioral metrics)  
  - Estimation of mean differences with 95% confidence intervals and effect sizes (Cohen’s d)  
  - Regression modeling to evaluate the impact of Version B on satisfaction and ease of use while controlling for score and completion time  
  - Additional evaluation using derived metrics (efficiency, fast completion rate, success rate) to provide a multi-dimensional assessment of user behavior  

---

### How to Run the Analysis

1. Download the notebooks and the `quiz_responses.csv` dataset  
2. Place the dataset in the same directory as the notebooks  
3. Open the notebooks using Jupyter Notebook or JupyterLab  
4. Run all cells  

---

### Summary of Findings

Overall, Version A provides a smoother and more effective user experience, while Version B may introduce interruptions that reduce efficiency and satisfaction.
