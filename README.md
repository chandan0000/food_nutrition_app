# Food Nutrition App

This project is a comprehensive solution to identify food items from images and provide detailed nutritional information. It combines a FastAPI backend with a Gradio web interface and a Flutter mobile application. The solution leverages the Vision Transformer model from Hugging Face for image classification.

## Table of Contents

- [Project Overview](#project-overview)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Running the Project](#running-the-project)
- [API Endpoints](#api-endpoints)
- [Gradio Interface](#gradio-interface)
- [Flutter Application](#flutter-application)
- [Acknowledgments](#acknowledgments)

## Project Overview

This project allows users to upload an image of a food item, identify the food using a Vision Transformer model, and retrieve its nutritional information from an external API.

## Technology Stack

- **Backend**:
  - FastAPI
  - Transformers (Hugging Face)
  - PIL (Python Imaging Library)
  - Uvicorn
- **Web Interface**:
  - Gradio
- **Mobile Application**:
  - Flutter
  - Dio
  - TalkerDioLogger

## Installation

### Prerequisites

- Python 3.7 or higher
- Flutter SDK
- Dart
- Node.js and npm (for Flutter web support)

### Backend Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/food-nutrition-app.git
   cd food-nutrition-app



Create a virtual environment and activate it:

sh

```cd server```



Install the required Python packages:

sh

pip install -r requirements.txt

Set your API key in the src/app.py file:

python

    api_key = 'your_api_key'

Flutter Setup

    Ensure Flutter is installed and configured. Follow the Flutter installation guide.

    Navigate to the Flutter project directory:

    sh

cd flutter_app

Get the dependencies:

sh

    flutter pub get

Running the Project
Backend and Gradio Interface

    Navigate to the src directory:

    sh

cd src

Run the backend and Gradio interface:

sh

    python app.py

This will start the FastAPI server on http://0.0.0.0:8000 and the Gradio interface on a public URL that will be displayed in the terminal.
Flutter Application

    Ensure you are in the flutter_app directory.
    Run the Flutter application on your device/emulator:

    sh

    flutter run

API Endpoints
Identify and Get Nutrition

Endpoint: /identify_and_get_nutrition

Method: POST

Description: Upload an image to identify the food item and get its nutritional information.

Request:

    File: file (image file)

Response: JSON containing nutritional information.

Example:

sh

curl -X POST "http://localhost:8000/identify_and_get_nutrition" -F "file=@path/to/your/image.jpg"

Gradio Interface

The Gradio interface provides a web-based way to interact with the food identification and nutrition information retrieval system.
Accessing Gradio Interface

Once the app.py is running, a Gradio URL will be displayed in the terminal. Open this URL in your browser to access the interface.

Usage:

    Upload an image of a food item.
    The system will identify the food and display its nutritional information in a table format.

Flutter Application

The Flutter mobile application allows users to:

    Pick an image from their gallery.
    Upload the image to the FastAPI backend.
    Display the identified food and its nutritional information in a well-designed UI.

Running the Flutter App

    Ensure you are in the flutter_app directory.
    Run the application:

    sh

    flutter run

Acknowledgments

    Hugging Face for providing the Vision Transformer model.
    API Ninjas for the nutritional information API.
    Gradio for the easy-to-use web interface.
    Flutter for the cross-platform mobile development framework.