# Question 5: Clinical Data API (FastAPI)
# Create a RESTful API that:
#   serves clinical trial data
#   performs dynamic cohort analysis
#   calculates patient risk scores

#Import libraries
from pathlib import Path
from typing import List, Optional
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

# Create FastAPI application
app = FastAPI(title="Clinical Trial Data API")

# Read CSV file from the same folder as this script
data_path = Path(__file__).parent / "adae.csv"
adae = pd.read_csv(data_path)

### Create GET command and welcome message ###
@app.get("/")
def root():
    return {"message": "Clinical Trial Data API is running"}


### Define Pydantic Models ###
# Define the optional JSON filters accepted by the POST endpoint
class AEQueryRequest(BaseModel):
    severity: Optional[List[str]] = None
    treatment_arm: Optional[str] = None

# Define the JSON returned by the POST endpoint
class AEQueryResponse(BaseModel):
    count: int
    subject_ids: List[str]

# Define output risk score and category
class RiskScoreResponse(BaseModel):
    subject_id: str
    risk_score: int
    risk_category: str

# Filter adverse-event records   
@app.post(
    "/ae-query",
    response_model=AEQueryResponse,
    summary="Dynamic AE cohort filtering",
)
def ae_query(filters: AEQueryRequest) -> AEQueryResponse:
    filtered_ae = adae.copy()
    
    # Apply the severity filter only when it was provided
    if filters.severity is not None:
        filtered_ae = filtered_ae[
            filtered_ae["AESEV"].isin(filters.severity)
        ]

    # Apply the treatment-arm filter only when it was provided
    if filters.treatment_arm is not None:
        filtered_ae = filtered_ae[
            filtered_ae["ACTARM"] == filters.treatment_arm
        ]

    # Return the matching record count and unique subject IDs
    return {
        "count": int(len(filtered_ae)),
        "subject_ids": sorted(
            filtered_ae["USUBJID"].dropna().unique().tolist()
        ),
    }

###  Calculate a "Safety Risk Score" for a specific patient ###

# Points assigned to each adverse-event severity
severity_points = {
    "MILD": 1,
    "MODERATE": 3,
    "SEVERE": 5,
}

# Calculate the safety risk score for one subject
@app.get(
    "/subject-risk/{subject_id}",
    response_model=RiskScoreResponse,
)
def get_subject_risk(subject_id: str) -> RiskScoreResponse:
    # Keep only AE records belonging to the requested subject
    subject_ae = adae[adae["USUBJID"] == subject_id]
    # Return 404 error if the subject does not exist
    if subject_ae.empty:
        raise HTTPException(
            status_code=404,
            detail=f"Subject '{subject_id}' was not found.",
        )

    # Convert severity values to points and add the points
    risk_score = int(
        subject_ae["AESEV"].map(severity_points).fillna(0).sum()
    )
    
    # Assign a category using the specified score thresholds
    if risk_score < 5:
        risk_category = "Low"
    elif risk_score < 15:
        risk_category = "Medium"
    else:
        risk_category = "High"

    return RiskScoreResponse(
        subject_id=subject_id,
        risk_score=risk_score,
        risk_category=risk_category,
    )
