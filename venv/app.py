from flask import Flask, request, jsonify
from flask_cors import CORS
from weather_api import WeatherAPI

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

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




# api_key = '773211ac46a8a3e591f72ae278de8280'