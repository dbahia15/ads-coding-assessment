# Clinical Trial Data API

A FastAPI application that serves adverse-event data, supports dynamic cohort filtering, and calculates subject safety risk scores.

## Clone the Repository

Clone the GitHub repository:

```bash
git clone https://github.com/dbahia15/ads-coding-assessment.git
```

Move into the API folder:

```bash
cd ads-coding-assessment/question_5_api
```

## Installation

Install the required Python packages:

```bash
python -m pip install fastapi "uvicorn[standard]" pandas
```

## Data

The API uses `adae.csv`, exported from `pharmaverseadam::adae`. The CSV file is stored in the same folder as `main.py`.

## Run the API

Start the API from the `question_5_api` folder:

```bash
uvicorn main:app --reload
```

The API will run at:

```text
http://127.0.0.1:8000
```

FastAPI’s interactive documentation is available at:

```text
http://127.0.0.1:8000/docs
```

## API Endpoints

### `GET /`

Returns a welcome message confirming that the API is running.

```bash
curl http://127.0.0.1:8000/
# {"message":"Clinical Trial Data API is running"}
```

### `POST /ae-query`

Filters the adverse-event cohort by severity and/or treatment arm.

Both filters are optional. If a filter is missing or `null`, it is ignored.

```bash
curl -X POST http://127.0.0.1:8000/ae-query \
  -H "Content-Type: application/json" \
  -d '{"severity":["MILD","MODERATE"],"treatment_arm":"Placebo"}'
```

The response contains:

* The number of matching adverse-event records.
* A list of unique subject IDs in the filtered cohort.

### `GET /subject-risk/{subject_id}`

Calculates the weighted safety risk score for a subject.

```bash
curl http://127.0.0.1:8000/subject-risk/01-701-1015
# {"subject_id":"01-701-1015","risk_score":3,"risk_category":"Low"}
```

Severity points are assigned as follows:

* `MILD`: 1 point
* `MODERATE`: 3 points
* `SEVERE`: 5 points

Risk categories are assigned as follows:

* `Low`: score below 5
* `Medium`: score from 5 to 14
* `High`: score of 15 or above

If the subject ID does not exist, the API returns a `404` error.


