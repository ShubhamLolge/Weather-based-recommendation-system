from flask import Flask, request, jsonify
from flask_cors import CORS # type: ignore
import pandas as pd
from io import StringIO
from weather_api import WeatherAPI


app = Flask(__name__)
CORS(app)

@app.route('/upload', methods=['POST'])
def upload_and_predict():
    data = request.get_json()

    # Extract weather data and CSV data from request
    location = data['location']
    temperature = data['temperature']
    rain = data['rain']
    wind_speed = data['wind_speed']
    csv_data = data['csv_data']

    # Read CSV data
    csv_file = StringIO(csv_data)
    inventory_data = pd.read_csv(csv_file)

    # Print received data in the console
    print("Location:", location)
    print("Temperature:", temperature)
    print("Rain:", rain)
    print("Wind Speed:", wind_speed)
    print("Inventory Data:\n", inventory_data)

    # Dummy prediction response
    prediction = [100]  # Replace with actual prediction logic

    return jsonify({'predicted_sales': prediction})

if __name__ == '__main__':
    app.run(debug=True)



# app = Flask(__name__)
# CORS(app)  # This will enable CORS for all routes

api_key = '773211ac46a8a3e591f72ae278de8280'
base_url = 'http://api.openweathermap.org/data/2.5'
weather_api = WeatherAPI(api_key, base_url)

@app.route('/forecast', methods=['GET'])
def get_forecast():
    location = request.args.get('location')
    if not location:
        return jsonify({'error': 'Location parameter is required'}), 400
    forecast_data = weather_api.get_forecast(location)
    return jsonify(forecast_data)

if __name__ == '__main__':
    app.run(debug=True)

## api_key = '773211ac46a8a3e591f72ae278de8280'
