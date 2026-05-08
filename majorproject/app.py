"""
Retail Analytics & AI-Powered Sales Forecasting System
Run: python app.py
Then open http://localhost:5000 in your browser
"""

from flask import Flask, render_template, jsonify, request
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import json
import os
import warnings
warnings.filterwarnings('ignore')

app = Flask(__name__)

# ─── Load & preprocess data ───────────────────────────────────────────────────

DATA_FILE = "Retail_Sales_Data_Unlox.csv"
df_global = None

def load_data():
    global df_global
    if not os.path.exists(DATA_FILE):
        return None, f"❌ '{DATA_FILE}' not found. Place it in the same folder as app.py."
    try:
        df = pd.read_csv(DATA_FILE)
        df.columns = df.columns.str.strip()
        # Parse date
        df['Date'] = pd.to_datetime(df['Date'], dayfirst=True, errors='coerce')
        df = df.dropna(subset=['Date'])
        df['Year'] = df['Date'].dt.year
        df['Month'] = df['Date'].dt.month
        df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)
        df['Quarter'] = df['Date'].dt.quarter
        df['Revenue'] = pd.to_numeric(df['Revenue'], errors='coerce').fillna(0)
        df['Units_Sold'] = pd.to_numeric(df['Units_Sold'], errors='coerce').fillna(0)
        df['Discount_Percentage'] = pd.to_numeric(df['Discount_Percentage'], errors='coerce').fillna(0)
        df['Store_Rating'] = pd.to_numeric(df['Store_Rating'], errors='coerce').fillna(0)
        df_global = df
        return df, None
    except Exception as e:
        return None, str(e)

# ─── Analytics helpers ────────────────────────────────────────────────────────

def get_kpis(df):
    total_rev = df['Revenue'].sum()
    total_units = df['Units_Sold'].sum()
    num_stores = df['Store_ID'].nunique()
    num_products = df['Product_ID'].nunique()
    avg_discount = df['Discount_Percentage'].mean()
    avg_rating = df['Store_Rating'].mean()

    # YoY growth
    rev_2023 = df[df['Year'] == 2023]['Revenue'].sum()
    rev_2024 = df[df['Year'] == 2024]['Revenue'].sum()
    yoy = ((rev_2024 - rev_2023) / rev_2023 * 100) if rev_2023 > 0 else 0

    return {
        "total_revenue": round(total_rev / 1e7, 2),         # in Crores
        "total_units": int(total_units),
        "num_stores": num_stores,
        "num_products": num_products,
        "avg_discount": round(avg_discount, 1),
        "avg_rating": round(avg_rating, 2),
        "yoy_growth": round(yoy, 1)
    }

def monthly_revenue(df):
    monthly = df.groupby('YearMonth')['Revenue'].sum().reset_index()
    monthly = monthly.sort_values('YearMonth')
    return monthly['YearMonth'].tolist(), (monthly['Revenue'] / 1e6).round(2).tolist()

def revenue_by_category(df):
    cat = df.groupby('Product_Category')['Revenue'].sum().sort_values(ascending=False)
    return cat.index.tolist(), (cat.values / 1e6).round(2).tolist()

def revenue_by_region(df):
    reg = df.groupby('Region')['Revenue'].sum().sort_values(ascending=False)
    return reg.index.tolist(), (reg.values / 1e6).round(2).tolist()

def top_stores(df, n=8):
    stores = df.groupby(['Store_ID', 'Store_Location'])['Revenue'].sum().reset_index()
    stores = stores.sort_values('Revenue', ascending=False).head(n)
    labels = (stores['Store_ID'] + ' (' + stores['Store_Location'] + ')').tolist()
    values = (stores['Revenue'] / 1e6).round(2).tolist()
    return labels, values

def seasonal_trends(df):
    month_names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    seasonal = df.groupby(['Year','Month'])['Revenue'].sum().reset_index()
    result = {}
    for yr in sorted(df['Year'].unique()):
        row = seasonal[seasonal['Year'] == yr].set_index('Month')['Revenue']
        result[str(yr)] = [(row.get(m, 0) / 1e6) for m in range(1, 13)]
    return month_names, result

def customer_segments(df):
    seg = df.groupby('Customer_Type')['Revenue'].sum()
    return seg.index.tolist(), (seg.values / 1e6).round(2).tolist()

def payment_distribution(df):
    pay = df.groupby('Payment_Mode')['Revenue'].sum().sort_values(ascending=False)
    return pay.index.tolist(), (pay.values / 1e6).round(2).tolist()

def promotion_impact(df):
    promo = df.groupby('Promotion_Applied').agg(
        Revenue=('Revenue', 'sum'),
        Units=('Units_Sold', 'sum'),
        AvgDiscount=('Discount_Percentage', 'mean')
    ).reset_index()
    return promo.to_dict('records')

def holiday_impact(df):
    holiday = df.groupby('Holiday_Flag')['Revenue'].mean().reset_index()
    labels = ['Non-Holiday' if x == 0 else 'Holiday' for x in holiday['Holiday_Flag']]
    values = (holiday['Revenue'] / 1000).round(2).tolist()
    return labels, values

def subcategory_analysis(df, category=None):
    if category and category != 'All':
        sub_df = df[df['Product_Category'] == category]
    else:
        sub_df = df
    sub = sub_df.groupby('Product_Subcategory')['Revenue'].sum().sort_values(ascending=False).head(10)
    return sub.index.tolist(), (sub.values / 1e6).round(2).tolist()

def brand_analysis(df):
    brand = df.groupby('Brand')['Revenue'].sum().sort_values(ascending=False).head(12)
    return brand.index.tolist(), (brand.values / 1e6).round(2).tolist()

# ─── Forecasting ──────────────────────────────────────────────────────────────

def forecast_revenue(df, months_ahead=6):
    monthly = df.groupby('YearMonth')['Revenue'].sum().reset_index()
    monthly = monthly.sort_values('YearMonth').reset_index(drop=True)
    monthly['t'] = np.arange(len(monthly))

    X = monthly[['t']].values
    y = monthly['Revenue'].values

    # Add seasonal features
    periods = monthly['YearMonth'].tolist()
    month_nums = [int(p.split('-')[1]) for p in periods]
    sin_feat = np.sin(2 * np.pi * np.array(month_nums) / 12)
    cos_feat = np.cos(2 * np.pi * np.array(month_nums) / 12)
    X_full = np.column_stack([X, sin_feat, cos_feat])

    model = LinearRegression()
    model.fit(X_full, y)

    # Build future periods
    last_t = monthly['t'].max()
    last_period = pd.Period(monthly['YearMonth'].iloc[-1], 'M')
    future_periods = [(last_period + i + 1).strftime('%Y-%m') for i in range(months_ahead)]
    future_months = [(last_period + i + 1).month for i in range(months_ahead)]
    future_t = np.arange(last_t + 1, last_t + 1 + months_ahead)
    future_sin = np.sin(2 * np.pi * np.array(future_months) / 12)
    future_cos = np.cos(2 * np.pi * np.array(future_months) / 12)
    X_future = np.column_stack([future_t, future_sin, future_cos])

    forecast = model.predict(X_future)

    # Historical for chart
    hist_labels = monthly['YearMonth'].tolist()
    hist_values = (monthly['Revenue'] / 1e6).round(2).tolist()
    fore_values = (np.maximum(forecast, 0) / 1e6).round(2).tolist()

    return hist_labels, hist_values, future_periods, fore_values

# ─── Store Segmentation ───────────────────────────────────────────────────────

def store_segmentation(df):
    store_stats = df.groupby('Store_ID').agg(
        Total_Revenue=('Revenue', 'sum'),
        Total_Units=('Units_Sold', 'sum'),
        Avg_Rating=('Store_Rating', 'mean'),
        Avg_Discount=('Discount_Percentage', 'mean'),
        Num_Transactions=('Revenue', 'count'),
        Num_Categories=('Product_Category', 'nunique')
    ).reset_index()

    features = ['Total_Revenue', 'Total_Units', 'Avg_Rating', 'Avg_Discount', 'Num_Transactions']
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(store_stats[features])

    kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
    store_stats['Cluster'] = kmeans.fit_predict(X_scaled)

    # Rank clusters by revenue
    cluster_rev = store_stats.groupby('Cluster')['Total_Revenue'].mean().rank(ascending=False)
    label_map = {c: f"Tier {int(r)}" for c, r in cluster_rev.items()}
    store_stats['Segment'] = store_stats['Cluster'].map(label_map)

    # Scatter data: Revenue vs Units
    scatter_data = []
    colors = {'Tier 1': '#ef4444', 'Tier 2': '#f97316', 'Tier 3': '#3b82f6', 'Tier 4': '#22c55e'}
    for _, row in store_stats.iterrows():
        scatter_data.append({
            'x': round(row['Total_Revenue'] / 1e6, 2),
            'y': int(row['Total_Units']),
            'label': row['Store_ID'],
            'segment': row['Segment'],
            'color': colors.get(row['Segment'], '#888'),
            'rating': round(row['Avg_Rating'], 2)
        })

    seg_summary = store_stats.groupby('Segment').agg(
        Stores=('Store_ID', 'count'),
        Avg_Revenue=('Total_Revenue', 'mean'),
        Avg_Rating=('Avg_Rating', 'mean')
    ).reset_index().sort_values('Segment')

    summary_list = []
    for _, r in seg_summary.iterrows():
        summary_list.append({
            'segment': r['Segment'],
            'stores': int(r['Stores']),
            'avg_revenue': round(r['Avg_Revenue'] / 1e6, 2),
            'avg_rating': round(r['Avg_Rating'], 2)
        })

    return scatter_data, summary_list

# ─── Routes ───────────────────────────────────────────────────────────────────

@app.route('/')
def index():
    df, err = load_data()
    if err:
        return f"<h2 style='color:red;font-family:sans-serif;padding:40px'>{err}</h2>"
    return render_template('index.html')

@app.route('/api/overview')
def api_overview():
    df = df_global
    kpis = get_kpis(df)
    ml, mv = monthly_revenue(df)
    cl, cv = revenue_by_category(df)
    rl, rv = revenue_by_region(df)
    sl, sv = top_stores(df)
    mn, seasonal = seasonal_trends(df)
    cust_l, cust_v = customer_segments(df)
    pay_l, pay_v = payment_distribution(df)
    promo = promotion_impact(df)
    hol_l, hol_v = holiday_impact(df)
    bl, bv = brand_analysis(df)

    categories = ['All'] + sorted(df['Product_Category'].unique().tolist())

    return jsonify({
        'kpis': kpis,
        'monthly': {'labels': ml, 'values': mv},
        'category': {'labels': cl, 'values': cv},
        'region': {'labels': rl, 'values': rv},
        'top_stores': {'labels': sl, 'values': sv},
        'seasonal': {'months': mn, 'data': seasonal},
        'customer': {'labels': cust_l, 'values': cust_v},
        'payment': {'labels': pay_l, 'values': pay_v},
        'promotion': promo,
        'holiday': {'labels': hol_l, 'values': hol_v},
        'brands': {'labels': bl, 'values': bv},
        'categories': categories
    })

@app.route('/api/forecast')
def api_forecast():
    months = int(request.args.get('months', 6))
    hl, hv, fl, fv = forecast_revenue(df_global, months)
    return jsonify({'hist_labels': hl, 'hist_values': hv, 'fore_labels': fl, 'fore_values': fv})

@app.route('/api/segmentation')
def api_segmentation():
    scatter, summary = store_segmentation(df_global)
    return jsonify({'scatter': scatter, 'summary': summary})

@app.route('/api/subcategory')
def api_subcategory():
    cat = request.args.get('category', 'All')
    l, v = subcategory_analysis(df_global, cat)
    return jsonify({'labels': l, 'values': v})

if __name__ == '__main__':
    print("\n🚀 Retail Analytics System starting...")
    print("📂 Make sure 'Retail_Sales_Data_Unlox.csv' is in this folder.")
    print("🌐 Open http://localhost:5000 in your browser\n")
    app.run(debug=False, port=5000)
