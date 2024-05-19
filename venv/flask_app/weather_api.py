import requests

class WeatherAPI:
    def __init__(self, api_key, base_url):
        self.api_key = api_key
        self.base_url = base_url

    def get_forecast(self, location):
        endpoint = f"{self.base_url}/forecast"
        params = {
            'q': location,
            'appid': self.api_key,
            'units': 'metric'
        }
        response = requests.get(endpoint, params=params)
        if response.status_code == 200:
            return response.json()
        else:
            return {'error': response.json()}

    # api_key = '773211ac46a8a3e591f72ae278de8280'