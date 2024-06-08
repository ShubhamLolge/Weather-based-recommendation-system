import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.utils import shuffle
import matplotlib
matplotlib.use('Agg')  # Use Agg backend for non-GUI environments
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import requests

api_key = "773211ac46a8a3e591f72ae278de8280"


class Train:
    REORDER_LEVEL = 50
    MIN_REORDER_QUANTITY = 100

    def __init__(self):
        self.model = None

    # Step 2: Preparing the Data
    def preprocess_data(self, inventory_data, weather_data):
        weather_dict = {
            'temp': weather_data['main']['temp'],
            'feels_like': weather_data['main']['feels_like'],
            'humidity': weather_data['main']['humidity'],
            'pressure': weather_data['main']['pressure'],
            'visibility': weather_data['visibility'],
            'wind_speed': weather_data['wind']['speed'],
            'rain': weather_data.get('rain', {}).get('1h', 0),
            'clouds': weather_data['clouds']['all'],
            'weather': weather_data['weather'][0]['main']
        }

        weather_df = pd.DataFrame([weather_dict])
        df = pd.concat([inventory_data, weather_df], axis=1)
        df = shuffle(df)
        df.fillna(method='ffill', inplace=True)
        df.fillna(method='bfill', inplace=True)
        df.interpolate(method='linear', inplace=True)
        df.dropna(subset=['Sales'], inplace=True)
        df = df.convert_dtypes()
        numeric_df = df.select_dtypes(include=['number'])

        return numeric_df

    def visualize_data(self, df):
        sns.pairplot(df)
        plt.savefig('pairplot.png')  # Save plot as an image
        plt.close()
        plt.figure(figsize=(12, 8))
        sns.heatmap(df.corr(), annot=True, cmap='coolwarm')
        plt.savefig('heatmap.png')  # Save plot as an image
        plt.close()

    def choose_model(self):
        return RandomForestRegressor(n_estimators=100, random_state=42)

    def train_model(self, model, X_train, y_train):
        model.fit(X_train, y_train)
        self.model = model  # Store the model
        return model

    def evaluate_model(self, model, X_test, y_test):
        predictions = model.predict(X_test)
        mse = mean_squared_error(y_test, predictions)
        r2 = r2_score(y_test, predictions)
        return mse, r2, predictions

    def tune_model(self, model, X_train, y_train):
        parameters = {'n_estimators': [50, 100, 200], 'max_depth': [None, 10, 20, 30]}
        grid_search = GridSearchCV(model, parameters, cv=5)
        grid_search.fit(X_train, y_train)
        self.model = grid_search.best_estimator_  # Store the best estimator
        return grid_search.best_estimator_

    def preprocess_and_train(self, inventory_data, weather_data):
        preprocessed_data = self.preprocess_data(inventory_data, weather_data)
        self.visualize_data(preprocessed_data)

        if 'Sales' in preprocessed_data.columns:
            features = preprocessed_data[['temp', 'feels_like', 'humidity', 'pressure', 'visibility', 'wind_speed', 'rain', 'clouds']]
            target = preprocessed_data['Sales']

            X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, random_state=42)
            model = self.choose_model()
            model = self.train_model(model, X_train, y_train)
            mse, r2, predictions = self.evaluate_model(model, X_test, y_test)
            print(f"Model Performance: MSE = {mse}, R2 = {r2}")
            model = self.tune_model(model, X_train, y_train)
            joblib.dump(model, 'sales_prediction_model.pkl')
            return X_train, X_test, y_train, y_test, model
        else:
            return None, None, None, None, None

    def get_weather_data(self, location):
        url = f"http://api.openweathermap.org/data/2.5/weather?q={location}&appid={api_key}&units=metric"
        response = requests.get(url)
        weather_data = response.json()
        return weather_data


    def make_prediction(self, inventory_data, location):
        # Load the model
        model = joblib.load('sales_prediction_model.pkl')

        # Get weather data
        weather_data = self.get_weather_data(location)

        # Extract relevant weather information
        weather_info = {
            'temp': weather_data['main']['temp'],
            'feels_like': weather_data['main']['feels_like'],
            'humidity': weather_data['main']['humidity'],
            'pressure': weather_data['main']['pressure'],
            'visibility': weather_data['visibility'],
            'wind_speed': weather_data['wind']['speed'],
            'rain': weather_data.get('rain', {}).get('1h', 0),
            'clouds': weather_data['clouds']['all'],
            'weather': weather_data['weather'][0]['main']
        }

        # Ensure that only numeric columns are used for prediction
        numeric_columns = ['temp', 'feels_like', 'humidity', 'pressure', 'visibility', 'wind_speed', 'rain', 'clouds']

        # Prepare data for prediction
        prediction_data = []
        for _, row in inventory_data.iterrows():
            item_data = [weather_info[col] for col in numeric_columns]
            prediction_data.append(item_data)

        prediction_data = pd.DataFrame(prediction_data, columns=numeric_columns)

        # Debug: Print the first few rows of prediction_data to ensure correctness
        # print("Prediction data sample:")
        # print(prediction_data.head())

        # Make predictions
        predictions = model.predict(prediction_data)

        # Generate restock suggestions
        restock_suggestions = []
        for i, pred in enumerate(predictions):
            item_name = inventory_data.iloc[i]['Item Name']
            item_id = int(i)
            current_stock = inventory_data.iloc[i]['Quantity']
            predicted_demand = pred
            
            restock_quantity = max(0, self.MIN_REORDER_QUANTITY - current_stock) if current_stock < self.REORDER_LEVEL else 0
            
            if restock_quantity > 0:
                restock_suggestions.append({
                    'item_name': item_name,
                    'item_id': item_id,
                    'current_stock': int(current_stock),
                    'predicted_demand': float(pred),
                    'restock_quantity': int(restock_quantity)
                })

        return restock_suggestions

if __name__ == "__main__":
    print("This file is intended to be imported and used as a module.")
