import pandas as pd

# Load inventory data
inventory_data = pd.read_csv('inventory_data.csv')

# Sample weather data for illustration purposes
weather_data = {
    'Date': ['2024-05-14', '2024-05-15', '2024-05-16', '2024-05-17', '2024-05-18'],
    'Temperature': [14.5, 13.4, 16.2, 12.8, 15.3],
    'Rain': [0.3, 0.0, 0.5, 1.2, 0.8],
    'Wind Speed': [3.8, 4.5, 2.9, 3.2, 4.1],
}

weather_df = pd.DataFrame(weather_data)

# Create a sample combined dataset
combined_data = {
    'Item Name': ['Chicken Wings', 'Burger', 'French Fries', 'Soda', 'Ice Cream'],
    'Date': ['2024-05-14', '2024-05-14', '2024-05-15', '2024-05-16', '2024-05-17'],
    'Temperature': [14.5, 14.5, 13.4, 16.2, 12.8],
    'Rain': [0.3, 0.3, 0.0, 0.5, 1.2],
    'Wind Speed': [3.8, 3.8, 4.5, 2.9, 3.2],
    'Sales': [100, 150, 200, 250, 300]  # Example sales data
}

combined_df = pd.DataFrame(combined_data)

# Save combined dataset to CSV for training
combined_df.to_csv('combined_data.csv', index=False)
