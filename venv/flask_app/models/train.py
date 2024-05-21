import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.utils import shuffle
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
import joblib

class Train:
    def __init__(self):
        self.model = None

    # Step 2: Preparing the Data
    def preprocess_data(self, inventory_data, weather_data):
        # Extract relevant weather data
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
        
        # Create DataFrame from inventory and weather data
        weather_df = pd.DataFrame([weather_dict])
        df = pd.concat([inventory_data, weather_df], axis=1)
        
        # Randomize the dataset
        df = shuffle(df)

        print(df)

        # Handle missing values
        df.ffill(inplace=True)
        df.bfill(inplace=True)
        df = df.infer_objects()
        df.interpolate(method='linear', inplace=True)

        # Drop any rows with missing target values
        if 'Sales' not in df.columns:
            raise ValueError('Sales column not found in CSV data.')
        
        df.dropna(subset=['Sales'], inplace=True)

        # Convert data types if needed
        df = df.convert_dtypes()

        return df

    def visualize_data(self, df):
        # Pairplot to visualize relationships
        sns.pairplot(df)
        plt.show()

        # Correlation heatmap
        plt.figure(figsize=(12, 8))
        sns.heatmap(df.corr(), annot=True, cmap='coolwarm')
        plt.show()

    # Step 3: Choosing a Model
    def choose_model(self):
        return LinearRegression()

    # Step 4: Training the Model
    def train_model(self, model, X_train, y_train):
        model.fit(X_train, y_train)
        return model

    # Step 5: Evaluating the Model
    def evaluate_model(self, model, X_test, y_test):
        predictions = model.predict(X_test)
        mse = mean_squared_error(y_test, predictions)
        r2 = r2_score(y_test, predictions)
        return mse, r2, predictions

    # Step 6: Parameter Tuning
    def tune_model(self, model, X_train, y_train):
        parameters = {'fit_intercept': [True, False], 'normalize': [True, False]}
        grid_search = GridSearchCV(model, parameters, cv=5)
        grid_search.fit(X_train, y_train)
        return grid_search.best_estimator_

    # Step 7: Making Predictions
    def make_predictions(self, model, X_test):
        return model.predict(X_test)

    def preprocess_and_train(self, inventory_data, weather_data):
        # Preprocess the data
        preprocessed_data = self.preprocess_data(inventory_data, weather_data)
        
        # Visualize the data
        self.visualize_data(preprocessed_data)
        
        # Assuming the 'Sales' column exists in the CSV for training
        if 'Sales' in preprocessed_data.columns:
            # Features and target
            features = preprocessed_data[['temp', 'feels_like', 'humidity', 'pressure', 'visibility', 'wind_speed', 'rain', 'clouds']]
            target = preprocessed_data['Sales']
            
            # Split the data
            X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, random_state=42)
            
            # Print the shapes of the split data
            print("X_train shape:", X_train.shape)
            print("X_test shape:", X_test.shape)
            print("y_train shape:", y_train.shape)
            print("y_test shape:", y_test.shape)

            # Choose a model
            model = self.choose_model()
            
            # Train the model
            model = self.train_model(model, X_train, y_train)
            
            # Evaluate the model
            mse, r2, predictions = self.evaluate_model(model, X_test, y_test)
            print(f"Model Performance: MSE = {mse}, R2 = {r2}")
            
            # Tune the model
            model = self.tune_model(model, X_train, y_train)
            
            # Save the model
            joblib.dump(model, 'sales_prediction_model.pkl')

            return X_train, X_test, y_train, y_test, model
        else:
            return None, None, None, None, None

    def make_prediction(self, X_test):
        # Load the model
        model = joblib.load('sales_prediction_model.pkl')
        
        # Make predictions
        predictions = model.predict(X_test)
        
        # Here, we just return the predictions, but you might want to calculate accuracy or other metrics
        return predictions.tolist()

# For testing the class
if __name__ == "__main__":
    print("This file is intended to be imported and used as a module.")
