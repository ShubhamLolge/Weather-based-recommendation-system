from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
from io import StringIO
import logging
import sys
import os

# Add the models directory to the sys.path to import Train class
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), 'models')))
from models.train import Train

app = Flask(__name__)
CORS(app)

# Setup logging
logging.basicConfig(level=logging.DEBUG)

@app.route('/upload', methods=['POST'])
def upload_and_predict():
    try:
        data = request.get_json()
        logging.debug(f"Received data: {data}")

        # Extract weather data and CSV data from request
        location = data['location']
        temperature = data['temperature']
        rain = data['rain']
        wind_speed = data['wind_speed']
        csv_data = data['csv_data']
        
        # Construct the weather data from received data
        weather_data = {
            'main': {'temp': temperature, 'feels_like': temperature, 'humidity': data.get('humidity', 50), 'pressure': data.get('pressure', 1012)}, 
            'visibility': data.get('visibility', 10000), 
            'wind': {'speed': wind_speed}, 
            'rain': {'1h': rain}, 
            'clouds': {'all': data.get('clouds', 40)},
            'weather': [{'main': data.get('weather_main', 'Clear')}]
        }

        # Read CSV data
        csv_file = StringIO(csv_data)
        inventory_data = pd.read_csv(csv_file, delimiter=',', quotechar='"')
        logging.debug(f"Inventory Data:\n{inventory_data}")

        # Create an instance of the Train class
        train_instance = Train()

        # Preprocess the data and make prediction
        X_train, X_test, y_train, y_test, model = train_instance.preprocess_and_train(inventory_data, weather_data)
        
        if X_train is None or y_train is None:
            return jsonify({'error': 'Sales column not found in CSV data.'}), 400

        # Make prediction
        prediction = train_instance.make_prediction(X_test)
        
        return jsonify({'predicted_sales': prediction})
    
    except Exception as e:
        logging.error(f"Error during upload_and_predict: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/forecast', methods=['GET'])
def get_forecast():
    location = request.args.get('location')
    if not location:
        return jsonify({'error': 'Location parameter is required'}), 400
    forecast_data = weather_api.get_forecast(location)
    return jsonify(forecast_data)

if __name__ == '__main__':
    app.run(debug=True)
