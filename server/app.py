from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from transformers import ViTFeatureExtractor, ViTForImageClassification
from PIL import Image
import requests
import io
import warnings
import gradio as gr
import threading
import uvicorn

warnings.filterwarnings('ignore')

# Load the pre-trained Vision Transformer model and feature extractor
model_name = "google/vit-base-patch16-224"
feature_extractor = ViTFeatureExtractor.from_pretrained(model_name)
model = ViTForImageClassification.from_pretrained(model_name)

# API key for the nutrition information
# https://api-ninjas.com/ 
api_key = 'your api key '

app = FastAPI()

def identify_image(image: Image.Image):
    """Identify the food item in the image."""
    inputs = feature_extractor(images=image, return_tensors="pt")
    outputs = model(**inputs)
    logits = outputs.logits
    predicted_class_idx = logits.argmax(-1).item()
    predicted_label = model.config.id2label[predicted_class_idx]
    food_name = predicted_label.split(',')[0]
    return food_name

def get_calories(food_name: str):
    """Get the calorie information of the identified food item."""
    api_url = f'https://api.api-ninjas.com/v1/nutrition?query={food_name}'
    response = requests.get(api_url, headers={'X-Api-Key': api_key})
    if response.status_code == requests.codes.ok:
        return response.json()
    else:
        raise HTTPException(status_code=response.status_code, detail=response.text)

@app.post("/identify_and_get_nutrition")
async def identify_and_get_nutrition(file: UploadFile = File(...)):
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))
    food_name = identify_image(image)
    nutrition_info = get_calories(food_name)
    if len(nutrition_info) == 0:
        return JSONResponse(content={"message": "No nutritional information found."}, status_code=404)
    return nutrition_info

# Gradio Interface
def gradio_interface(image_file):
    image = Image.open(image_file)
    food_name = identify_image(image)
    nutrition_info = get_calories(food_name)
    if len(nutrition_info) == 0:
        return "No nutritional information found."
    
    nutrition_data = nutrition_info[0]
    table = f"""
    <table border="1" style="width: 100%; border-collapse: collapse;">
        <tr><th colspan="4" style="text-align: center;"><b>Nutrition Facts</b></th></tr>
        <tr><td colspan="4" style="text-align: center;"><b>Food Name: {nutrition_data['name']}</b></td></tr>
        <tr>
            <td style="text-align: left;"><b>Calories</b></td><td style="text-align: right;">{nutrition_data['calories']}</td>
            <td style="text-align: left;"><b>Serving Size (g)</b></td><td style="text-align: right;">{nutrition_data['serving_size_g']}</td>
        </tr>
        <tr>
            <td style="text-align: left;"><b>Total Fat (g)</b></td><td style="text-align: right;">{nutrition_data['fat_total_g']}</td>
            <td style="text-align: left;"><b>Saturated Fat (g)</b></td><td style="text-align: right;">{nutrition_data['fat_saturated_g']}</td>
        </tr>
        <tr>
            <td style="text-align: left;"><b>Protein (g)</b></td><td style="text-align: right;">{nutrition_data['protein_g']}</td>
            <td style="text-align: left;"><b>Sodium (mg)</b></td><td style="text-align: right;">{nutrition_data['sodium_mg']}</td>
        </tr>
        <tr>
            <td style="text-align: left;"><b>Potassium (mg)</b></td><td style="text-align: right;">{nutrition_data['potassium_mg']}</td>
            <td style="text-align: left;"><b>Cholesterol (mg)</b></td><td style="text-align: right;">{nutrition_data['cholesterol_mg']}</td>
        </tr>
        <tr>
            <td style="text-align: left;"><b>Total Carbohydrates (g)</b></td><td style="text-align: right;">{nutrition_data['carbohydrates_total_g']}</td>
            <td style="text-align: left;"><b>Fiber (g)</b></td><td style="text-align: right;">{nutrition_data['fiber_g']}</td>
        </tr>
        <tr>
            <td style="text-align: left;"><b>Sugar (g)</b></td><td style="text-align: right;">{nutrition_data['sugar_g']}</td>
            <td></td><td></td>
        </tr>
    </table>
    """
    return table

iface = gr.Interface(
    fn=gradio_interface,
    inputs=gr.Image(type="filepath"),
    outputs="html",
    title="Food Identification and Nutrition Info",
    description="Upload an image of food to get nutritional information.",
    allow_flagging="never"  # Disable flagging
)

def run_gradio():
    iface.launch(share=True)

def run_fastapi():
    uvicorn.run(app, host="0.0.0.0", port=8000)

if __name__ == "__main__":
    # Run Gradio and FastAPI in separate threads
    gradio_thread = threading.Thread(target=run_gradio)
    fastapi_thread = threading.Thread(target=run_fastapi)

    gradio_thread.start()
    fastapi_thread.start()

    gradio_thread.join()
    fastapi_thread.join()
