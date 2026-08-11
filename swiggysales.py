import pandas as pd

orders = pd.read_csv("C:\\Users\\HP\\OneDrive\\datasets\\swiggy_sales_orders.csv", parse_dates=["order_date"])
restaurants = pd.read_csv("C:\\Users\\HP\\OneDrive\\datasets\\swiggy_restaurants.csv")

# Check missing values
print("Missing values in orders:", orders.isnull().sum())
print("Missing values in restaurants:", restaurants.isnull().sum())

# Check for duplicate order IDs
print("Duplicate orders:", orders.duplicated("order_id").sum())

# Check data types
print("Data types:", orders.info())
print("Data types:", restaurants.info())

#
# Add useful helper columns for later analysis
orders["month"] = orders["order_date"].dt.month
orders["day_of_week"] = orders["order_date"].dt.day_name()
orders["hour"] = orders["order_date"].dt.hour
print(orders)

# Check for any negative or invalid values (basic sanity checks)
print("Negative final_amount rows:", (orders["final_amount"] < 0).sum())


# Check unique values in categorical columns (spot inconsistent labels)
print("Order status values:", orders["order_status"].unique())
print("Payment mode values:", orders["payment_mode"].unique())
#
print("Cleaned orders shape:", orders.shape)
print(orders.head())

# Outlier detection using IQR method (final_amount)
Q1 = orders["final_amount"].quantile(0.25)
Q3 = orders["final_amount"].quantile(0.75)
IQR = Q3 - Q1
lower_limit= Q1 - 1.5 * IQR
upper_limit = Q3 + 1.5 * IQR
print(lower_limit, upper_limit)

outliers = len(orders[(orders["final_amount"] < lower_limit) | (orders["final_amount"] > upper_limit)])
print(outliers)

# Flag outliers instead of deleting them (safer — keep for now, decide later)
orders["is_outlier"] = ((orders["final_amount"] < lower_limit) | (orders["final_amount"] > upper_limit))
print(orders)
