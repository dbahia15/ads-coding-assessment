# Clinical Trial Data API

A FastAPI application that serves adverse-event data, supports dynamic cohort filtering, and calculates subject safety risk scores.

## Clone the Repository

Clone the GitHub repository:

```bash
git clone https://github.com/dbahia15/ads-coding-assessment.git
cd ads-coding-assessment

## Installation

Install the required Python packages:

```bash
python -m pip install fastapi "uvicorn[standard]" pandas
```

## Data

The API uses `adae.csv`, exported from `pharmaverseadam::adae`. The CSV file must be in the same folder as `main.py`.

## Run the API

From the root of the repository, move into the Question 5 folder:

```bash
cd question_5_api
```

Start the API:

```bash
uvicorn main:app --reload
```

The API will run at:

```text
http://127.0.0.1:8000
```

Interactive API documentation is available at:

```text
http://127.0.0.1:8000/docs
```

## Endpoints

### `GET /`

Returns a welcome message confirming that the API is running.

```json
{
  "message": "Clinical Trial Data API is running"
}
```

### `POST /ae-query`

Filters adverse-event records by severity and/or treatment arm.

Example request:

```json
{
  "severity": ["MILD", "MODERATE"],
  "treatment_arm": "Placebo"
}
```

Both filters are optional. A missing or `null` field is ignored.

The response contains the number of matching AE records and the unique subject IDs.

### `GET /subject-risk/{subject_id}`

Calculates a safety risk score for the requested subject.

Severity scores are:

* `MILD`: 1 point
* `MODERATE`: 3 points
* `SEVERE`: 5 points

Risk categories are:

* `Low`: score below 5
* `Medium`: score from 5 to 14
* `High`: score of 15 or above

The API returns a `404` error if the subject ID does not exist.
