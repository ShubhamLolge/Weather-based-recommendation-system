import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import joblib

# Load combined data
data = pd.read_csv('combined_data.csv')

# Features and target
features = data[['Temperature', 'Rain', 'Wind Speed']]
target = data['Sales']

# Split the data
X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, random_state=42)

# Train the model
model = LinearRegression()
model.fit(X_train, y_train)

# Save the model
joblib.dump(model, 'sales_prediction_model.pkl')
