from flask import Flask, render_template, request, jsonify
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)

# Load the trained model
model = joblib.load('crop_yield_model.pkl')

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get form data
        data = {
            'Area': request.form['area'],
            'Crop': request.form['crop'],
            'Soil_Type': request.form['soil_type'],
            'Temperature': float(request.form['temperature']),
            'Humidity': float(request.form['humidity']),
            'PH': float(request.form['ph']),
            'Annual_Rainfall': float(request.form['rainfall'])
        }
        
        # Make prediction
        input_df = pd.DataFrame([data])
        prediction = model.predict(input_df)[0]
        
        return render_template('result.html', 
                             prediction=round(prediction, 2),
                             input_data=data)
    except Exception as e:
        return render_template('error.html', error=str(e))

if __name__ == '__main__':
    app.run(debug=True)
Step 2: Create HTML Templates
Create a templates/ folder with these files:
templates/index.html:
html<!DOCTYPE html>
<html>
<head>
    <title>Crop Yield Predictor</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }
        form { background: #f4f4f4; padding: 20px; border-radius: 10px; }
        input, select { width: 100%; padding: 10px; margin: 5px 0; border: 1px solid #ddd; border-radius: 5px; }
        button { background: #007bff; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>🌾 Crop Yield Predictor</h1>
    <form method="POST" action="/predict">
        <label>Area:</label>
        <input type="text" name="area" required placeholder="e.g., Punjab">
        
        <label>Crop:</label>
        <input type="text" name="crop" required placeholder="e.g., Wheat">
        
        <label>Soil Type:</label>
        <input type="text" name="soil_type" required placeholder="e.g., Loamy">
        
        <label>Temperature (°C):</label>
        <input type="number" name="temperature" step="0.1" required placeholder="e.g., 27.5">
        
        <label>Humidity (%):</label>
        <input type="number" name="humidity" step="0.1" required placeholder="e.g., 60.2">
        
        <label>pH Level:</label>
        <input type="number" name="ph" step="0.1" required placeholder="e.g., 6.5">
        
        <label>Annual Rainfall (mm):</label>
        <input type="number" name="rainfall" step="0.1" required placeholder="e.g., 850">
        
        <button type="submit">Predict Yield</button>
    </form>
</body>
</html>
templates/result.html:
html<!DOCTYPE html>
<html>
<head>
    <title>Prediction Result</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }
        .result { background: #d4edda; padding: 20px; border-radius: 10px; margin: 20px 0; }
        .input-summary { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; }
        a { color: #007bff; text-decoration: none; }
    </style>
</head>
<body>
    <h1>🎯 Prediction Result</h1>
    
    <div class="result">
        <h2>Predicted Yield: {{ prediction }} tons/hectare</h2>
    </div>
    
    <div class="input-summary">
        <h3>Input Parameters:</h3>
        <ul>
            <li><strong>Area:</strong> {{ input_data.Area }}</li>
            <li><strong>Crop:</strong> {{ input_data.Crop }}</li>
            <li><strong>Soil Type:</strong> {{ input_data.Soil_Type }}</li>
            <li><strong>Temperature:</strong> {{ input_data.Temperature }}°C</li>
            <li><strong>Humidity:</strong> {{ input_data.Humidity }}%</li>
            <li><strong>pH:</strong> {{ input_data.PH }}</li>
            <li><strong>Rainfall:</strong> {{ input_data.Annual_Rainfall }}mm</li>
        </ul>
    </div>
    
    <a href="/">← Make Another Prediction</a>
</body>
</html>
Option 2: Streamlit App (Easiest)
Create streamlit_app.py:
pythonimport streamlit as st
import joblib
import pandas as pd
import numpy as np

# Load model
@st.cache_resource
def load_model():
    return joblib.load('crop_yield_model.pkl')

model = load_model()

st.title('🌾 Crop Yield Predictor')
st.write('Enter the parameters below to predict crop yield:')

# Input fields
area = st.text_input('Area', placeholder='e.g., Punjab')
crop = st.text_input('Crop', placeholder='e.g., Wheat')
soil_type = st.text_input('Soil Type', placeholder='e.g., Loamy')
temperature = st.number_input('Temperature (°C)', min_value=0.0, max_value=50.0, value=25.0)
humidity = st.number_input('Humidity (%)', min_value=0.0, max_value=100.0, value=50.0)
ph = st.number_input('pH Level', min_value=0.0, max_value=14.0, value=7.0)
rainfall = st.number_input('Annual Rainfall (mm)', min_value=0.0, value=800.0)

if st.button('Predict Yield'):
    if area and crop and soil_type:
        input_data = {
            'Area': area,
            'Crop': crop,
            'Soil_Type': soil_type,
            'Temperature': temperature,
            'Humidity': humidity,
            'PH': ph,
            'Annual_Rainfall': rainfall
        }
        
        input_df = pd.DataFrame([input_data])
        prediction = model.predict(input_df)[0]
        
        st.success(f'🎯 Predicted Yield: {prediction:.2f} tons/hectare')
        
        # Show input summary
        st.subheader('Input Summary:')
        st.write(input_data)
    else:
        st.error('Please fill in all required fields!')
