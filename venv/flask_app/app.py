from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
from io import StringIO
import logging
from train import Train
from waitress import serve # type: ignore
import numpy as np  # Add this import

app = Flask(__name__)
CORS(app)

# logging.basicConfig(level=logging.DEBUG)
api_key = "773211ac46a8a3e591f72ae278de8280"

@app.route('/upload', methods=['POST'])
def upload_and_predict():
    data = request.get_json()

    # Extract weather data and CSV data from request
    temperature = data['temperature']
    wind_speed = data['wind_speed']
    humidity = data['humidity']
    pressure = data['pressure']
    visibility = data['visibility']
    clouds = data['clouds']
    weather_main = data['weather_main']
    store_location = data['store_location']
    csv_data = data['csv_data']

    # Read CSV data
    csv_file = StringIO(csv_data)
    inventory_data = pd.read_csv(csv_file)

    weather_data = {
        'main': {'temp': temperature, 'feels_like': temperature, 'humidity': humidity, 'pressure': pressure},
        'visibility': visibility,
        'wind': {'speed': wind_speed},
        'clouds': {'all': clouds},
        'weather': [{'main': weather_main}]
    }

    try:
        train = Train()
        X_train, X_test, y_train, y_test, model = train.preprocess_and_train(inventory_data, weather_data)
        if X_train is not None:
            restock_suggestions = train.make_prediction(inventory_data, location=store_location)
            # Convert restock_suggestions to a JSON serializable format
            restock_suggestions = [{k: (int(v) if isinstance(v, (np.int64, np.int32)) else v) for k, v in suggestion.items()} for suggestion in restock_suggestions]
            return jsonify({'predicted_sales': restock_suggestions})
        else:
            return jsonify({'error': 'Training data is not sufficient.'}), 400
    except Exception as e:
        logging.error(f"Error during upload_and_predict: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/weather', methods=['GET'])
def get_weather():
    location = request.args.get('location')
    if not location:
        return jsonify({'error': 'Location is required'}), 400
    
    weather_url = f'http://api.openweathermap.org/data/2.5/weather?q={location}&appid={api_key}&units=metric'
    
    response = request.get(weather_url)
    if response.status_code == 200:
        weather_data = response.json()
        return jsonify(weather_data), 200
    else:
        return jsonify({'error': 'Error fetching weather data'}), response.status_code

if __name__ == '__main__':
    app.run(debug=True)
    serve(app, host="0.0.0.0", port=5000)
