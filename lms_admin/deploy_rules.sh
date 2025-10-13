#!/bin/bash

# Firebase Deployment Script for LMS Admin
# This script deploys Firestore security rules

echo "🚀 Deploying Firebase Firestore Rules..."
echo "Make sure you have Firebase CLI installed and are logged in"

# Check if firebase CLI is available
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    echo "❌ firebase.json not found. Make sure you're in the lms_admin directory"
    exit 1
fi

# Check if firestore.rules exists
if [ ! -f "firestore.rules" ]; then
    echo "❌ firestore.rules not found"
    exit 1
fi

echo "📋 Deploying Firestore rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo "✅ Firestore rules deployed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Ensure Email/Password authentication is enabled in Firebase Console"
    echo "2. Make sure your admin user has 'admin' role in Firestore"
    echo "3. Test student creation from the admin panel"
else
    echo "❌ Deployment failed. Please check the errors above."
    exit 1
fi