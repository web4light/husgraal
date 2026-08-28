#!/bin/bash
# HusGraal — Google Cloud Run deployment
# Iustitia omnibus.

set -e

PROJECT_ID=${GOOGLE_CLOUD_PROJECT:-"cs-poc-plxitf0grqkl6qme9nyxwkr"}
SERVICE_NAME="husgraal-legal-agent"
REGION="europe-west1"

echo "⚔️  Deploying HusGraal to Google Cloud Run..."
echo "   Iustitia omnibus."

gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME .

gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --min-instances 0 \
    --max-instances 3 \
    --memory 512Mi \
    --cpu 1 \
    --set-env-vars="GEMINI_MODEL=gemini-2.0-flash"

echo "✅ HusGraal deployed. Iustitia omnibus."
