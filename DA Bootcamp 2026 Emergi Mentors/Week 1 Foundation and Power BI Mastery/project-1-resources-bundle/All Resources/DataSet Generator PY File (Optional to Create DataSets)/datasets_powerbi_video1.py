"""
FreshMarket Australia - ETL Dataset Generator
==============================================

Generates realistic Australian retail data with intentional quality issues
for Power BI ETL training (Video 1).

Author: Data Analytics Training
Date: December 2024
Version: 1.0

Description:
------------
This script creates enterprise-realistic data for a fictional 50-store 
Australian grocery chain called "FreshMarket Australia" across NSW, VIC, QLD.

Data Sources Generated:
-----------------------
1. CSV - Daily POS transactions (messy: duplicates, nulls, mixed casing)
2. Excel - Finance budgets & forecasts (merged cells, nulls)
3. SQL Server - Dimension tables (clean master data)
4. SharePoint - Marketing campaign files (inconsistent schemas)
5. Web API - Supplier product catalog (JSON, nested structure)

Intentional Quality Issues:
---------------------------
- 5% duplicate transactions (for deduplication practice)
- 3% null GST values (for calculation practice)
- 1% zero/negative quantities (for filtering practice)
- 0.5% revenue outliers (for outlier detection)
- 2% invalid dates (for error handling)
- Mixed casing in state names (for standardization practice)
- Inconsistent column names across files (for schema mapping)

Australian Business Context:
---------------------------
- GST: 10% of revenue (Australian tax)
- States: NSW, VIC, QLD, WA, SA, TAS, NT, ACT
- Postcodes: 4 digits (preserve leading zeros)
- Financial Year: July 1 - June 30 (EOFY = June 30)
- Loyalty Tiers: Bronze, Silver, Gold (FreshRewards program)

Usage:
------
1. Install dependencies:
   pip install pandas numpy faker openpyxl

2. Run script:
   python datasets.py

3. Output location:
   C:\PowerBI-Training\FreshMarket-ETL\data\

4. Import SQL files to SQL Server using SSMS Import Wizard

Dependencies:
-------------
- pandas: Data manipulation
- numpy: Random number generation
- faker: Australian names, addresses, companies
- openpyxl: Excel file creation

License: MIT
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from faker import Faker
import random
import os
import json
import warnings

# Suppress warnings for clean output
warnings.filterwarnings('ignore')

# Initialize Faker with Australian locale for realistic Australian names/addresses
fake = Faker('en_AU')

# Set random seeds for reproducibility
Faker.seed(42)
np.random.seed(42)
random.seed(42)

# =============================================================================
# CONFIGURATION
# =============================================================================

# Output path
BASE_PATH = r'C:\PowerBI-Training\FreshMarket-ETL\data'

# Date range (Australian Financial Years)
START_DATE = datetime(2022, 7, 1)   # FY2023 start
END_DATE = datetime(2024, 6, 30)    # FY2024 end

# Data volumes
NUM_STORES = 50
NUM_PRODUCTS = 2000
NUM_CUSTOMERS = 20000
NUM_TRANSACTIONS = 50000

# Australian States and Postcode Ranges
STATES = {
    'NSW': {
        'postcodes': (2000, 2999),
        'metro_split': 0.6,  # 60% metro, 40% regional
        'num_stores': 20
    },
    'VIC': {
        'postcodes': (3000, 3999),
        'metro_split': 0.6,
        'num_stores': 18
    },
    'QLD': {
        'postcodes': (4000, 4999),
        'metro_split': 0.58,
        'num_stores': 12
    },
    'WA': {
        'postcodes': (6000, 6999),
        'metro_split': 0.65,
        'num_stores': 0  # Not used in this scenario
    },
    'SA': {
        'postcodes': (5000, 5999),
        'metro_split': 0.7,
        'num_stores': 0  # Not used in this scenario
    },
    'TAS': {
        'postcodes': (7000, 7999),
        'metro_split': 0.5,
        'num_stores': 0  # Not used in this scenario
    },
    'NT': {
        'postcodes': (800, 899),
        'metro_split': 0.4,
        'num_stores': 0  # Not used in this scenario
    },
    'ACT': {
        'postcodes': (2600, 2699),
        'metro_split': 1.0,
        'num_stores': 0  # Not used in this scenario
    }
}

# Product Categories (Grocery Retail)
CATEGORIES = {
    'Fresh Produce': ['Vegetables', 'Fruits', 'Salads', 'Herbs'],
    'Dairy & Eggs': ['Milk', 'Cheese', 'Yoghurt', 'Eggs'],
    'Meat & Seafood': ['Beef', 'Chicken', 'Pork', 'Seafood'],
    'Bakery': ['Bread', 'Cakes', 'Pastries'],
    'Pantry': ['Canned Goods', 'Pasta & Rice', 'Oils & Sauces', 'Breakfast'],
    'Frozen': ['Frozen Meals', 'Ice Cream', 'Frozen Vegetables'],
    'Beverages': ['Soft Drinks', 'Juice', 'Water', 'Coffee & Tea'],
    'Health & Beauty': ['Personal Care', 'Vitamins', 'Cosmetics']
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def create_folders():
    """Create folder structure for data files"""
    folders = [
        os.path.join(BASE_PATH, 'csv'),
        os.path.join(BASE_PATH, 'excel'),
        os.path.join(BASE_PATH, 'sql'),
        os.path.join(BASE_PATH, 'sharepoint')
    ]
    
    for folder in folders:
        os.makedirs(folder, exist_ok=True)
    
    print(f"✅ Folder structure created at: {BASE_PATH}")
    print()

def print_section_header(title):
    """Print formatted section header"""
    print("=" * 80)
    print(f" {title}")
    print("=" * 80)
    print()

# =============================================================================
# DIMENSION TABLE GENERATORS
# =============================================================================

def generate_dim_store():
    """
    Generate store dimension with Australian locations
    
    Returns:
        pd.DataFrame: Store dimension table with columns:
            - StoreID (e.g., STR001)
            - StoreName
            - State (NSW, VIC, QLD)
            - Postcode (4 digits)
            - Region (Metro/Regional)
            - ManagerName
            - OpenDate
            - StoreSize (Small/Medium/Large)
    """
    print("📍 Generating DimStore...")
    
    stores = []
    store_id = 1
    
    for state, config in STATES.items():
        num_stores_state = config['num_stores']
        
        if num_stores_state == 0:
            continue
            
        # Calculate metro vs regional split
        num_metro = int(num_stores_state * config['metro_split'])
        num_regional = num_stores_state - num_metro
        
        # Generate metro stores
        for i in range(num_metro):
            # Metro postcodes are in lower range
            postcode = random.randint(
                config['postcodes'][0], 
                config['postcodes'][0] + 100
            )
            
            stores.append({
                'StoreID': f'STR{store_id:03d}',
                'StoreName': f"FreshMarket {fake.city()} {random.choice(['Central', 'Plaza', 'Mall', 'Square'])}",
                'State': state,
                'Postcode': str(postcode).zfill(4),
                'Region': 'Metro',
                'ManagerName': fake.name(),
                'OpenDate': fake.date_between(start_date='-10y', end_date='-1y'),
                'StoreSize': random.choice(['Small', 'Medium', 'Large'])
            })
            store_id += 1
        
        # Generate regional stores
        for i in range(num_regional):
            # Regional postcodes are in higher range
            postcode = random.randint(
                config['postcodes'][0] + 500, 
                config['postcodes'][1]
            )
            
            stores.append({
                'StoreID': f'STR{store_id:03d}',
                'StoreName': f"FreshMarket {fake.city()} {random.choice(['Town', 'Centre', 'Market'])}",
                'State': state,
                'Postcode': str(postcode).zfill(4),
                'Region': 'Regional',
                'ManagerName': fake.name(),
                'OpenDate': fake.date_between(start_date='-10y', end_date='-1y'),
                'StoreSize': random.choice(['Small', 'Medium'])
            })
            store_id += 1
    
    df_store = pd.DataFrame(stores)
    print(f"   ✓ Generated {len(df_store)} stores")
    print(f"   ✓ States: {df_store['State'].value_counts().to_dict()}")
    print()
    
    return df_store

def generate_dim_product():
    """
    Generate product dimension
    
    Returns:
        pd.DataFrame: Product dimension table
    """
    print("🛒 Generating DimProduct...")
    
    products = []
    product_id = 1
    
    for category, subcategories in CATEGORIES.items():
        products_per_category = NUM_PRODUCTS // len(CATEGORIES)
        
        for _ in range(products_per_category):
            subcategory = random.choice(subcategories)
            
            # Generate realistic product names
            if category == 'Fresh Produce':
                product_name = random.choice(['Organic', 'Fresh', 'Premium']) + ' ' + fake.word().title()
            elif category == 'Dairy & Eggs':
                product_name = random.choice(['Full Cream', 'Low Fat', 'Greek']) + ' ' + subcategory
            else:
                product_name = fake.catch_phrase()[:50]
            
            products.append({
                'ProductID': f'PRD{product_id:05d}',
                'ProductName': product_name,
                'Category': category,
                'Subcategory': subcategory,
                'Supplier': fake.company(),
                'UnitCost': round(random.uniform(0.50, 50.00), 2),
                'Brand': random.choice(['FreshMarket Own', 'Premium Brand', 'Budget Brand']),
                'PackSize': random.choice(['Single', '2-pack', '6-pack', '12-pack', 'Bulk'])
            })
            product_id += 1
    
    df_product = pd.DataFrame(products)
    print(f"   ✓ Generated {len(df_product)} products")
    print(f"   ✓ Categories: {len(CATEGORIES)} ({', '.join(CATEGORIES.keys())})")
    print()
    
    return df_product

def generate_dim_customer():
    """
    Generate customer dimension
    
    Returns:
        pd.DataFrame: Customer dimension table
    """
    print("👥 Generating DimCustomer...")
    
    customers = []
    
    for i in range(NUM_CUSTOMERS):
        # Select state (weighted toward NSW/VIC)
        state = random.choices(
            ['NSW', 'VIC', 'QLD'],
            weights=[0.4, 0.36, 0.24]
        )[0]
        
        postcode_range = STATES[state]['postcodes']
        
        customers.append({
            'CustomerID': f'CUST{i+1:06d}',
            'CustomerName': fake.name(),
            'Email': fake.email(),
            'State': state,
            'Postcode': str(random.randint(postcode_range[0], postcode_range[1])).zfill(4),
            'LoyaltyTier': random.choices(
                ['Bronze', 'Silver', 'Gold'],
                weights=[0.6, 0.3, 0.1]
            )[0],
            'JoinDate': fake.date_between(start_date='-5y', end_date='today'),
            'DateOfBirth': fake.date_of_birth(minimum_age=18, maximum_age=80)
        })
    
    df_customer = pd.DataFrame(customers)
    print(f"   ✓ Generated {len(df_customer)} customers")
    print(f"   ✓ Loyalty Tiers: {df_customer['LoyaltyTier'].value_counts().to_dict()}")
    print()
    
    return df_customer

def generate_dim_channel():
    """
    Generate sales channel dimension
    
    Returns:
        pd.DataFrame: Channel dimension table
    """
    print("📱 Generating DimChannel...")
    
    channels = [
        {'ChannelID': 'CH001', 'ChannelName': 'In-Store', 'ChannelType': 'Physical'},
        {'ChannelID': 'CH002', 'ChannelName': 'Online', 'ChannelType': 'Digital'},
        {'ChannelID': 'CH003', 'ChannelName': 'Click & Collect', 'ChannelType': 'Hybrid'}
    ]
    
    df_channel = pd.DataFrame(channels)
    print(f"   ✓ Generated {len(df_channel)} channels")
    print()
    
    return df_channel

def generate_dim_date():
    """
    Generate date dimension with Australian FY
    
    Returns:
        pd.DataFrame: Date dimension table with Australian FY columns
    """
    print("📅 Generating DimDate...")
    
    # Generate dates from 2022-2025 (covers all transaction dates)
    date_range = pd.date_range(start='2022-01-01', end='2025-12-31', freq='D')
    dates = []
    
    for date in date_range:
        # Calculate Australian FY (July 1 - June 30)
        if date.month >= 7:
            fy_year = date.year + 1
        else:
            fy_year = date.year
        
        dates.append({
            'Date': date,
            'Year': date.year,
            'FY': f'FY{fy_year}',
            'Quarter': f'Q{(date.month-1)//3 + 1}',
            'Month': date.month,
            'MonthName': date.strftime('%B'),
            'MonthYear': date.strftime('%b-%Y'),
            'DayOfWeek': date.day_name(),
            'DayOfMonth': date.day,
            'IsWeekend': 1 if date.dayofweek >= 5 else 0,
            'IsEOFY': 1 if (date.month == 6 and date.day == 30) else 0
        })
    
    df_date = pd.DataFrame(dates)
    print(f"   ✓ Generated {len(df_date)} dates (2022-2025)")
    print(f"   ✓ Financial Years: {sorted(df_date['FY'].unique())}")
    print()
    
    return df_date

# =============================================================================
# FACT TABLE GENERATOR
# =============================================================================

def generate_fact_sales(df_store, df_product, df_customer, df_channel):
    """
    Generate sales fact table with intentional quality issues
    
    Args:
        df_store: Store dimension
        df_product: Product dimension
        df_customer: Customer dimension
        df_channel: Channel dimension
    
    Returns:
        pd.DataFrame: Fact sales table with quality issues
    """
    print("💰 Generating FactSales...")
    
    transactions = []
    
    for i in range(NUM_TRANSACTIONS):
        # Random date within FY range
        sale_date = START_DATE + timedelta(
            days=random.randint(0, (END_DATE - START_DATE).days)
        )
        
        # Select random entities
        store = df_store.sample(1).iloc[0]
        product = df_product.sample(1).iloc[0]
        
        # 90% have customer (loyalty member), 10% anonymous
        customer = df_customer.sample(1).iloc[0] if random.random() > 0.1 else None
        
        channel = df_channel.sample(1).iloc[0]
        
        # Calculate transaction amounts
        quantity = random.randint(1, 10)
        unit_price = round(product['UnitCost'] * random.uniform(1.3, 2.5), 2)
        
        # Apply discount (60% no discount, 40% various discounts)
        discount = round(random.choices(
            [0, 0.05, 0.10, 0.15, 0.20], 
            weights=[0.6, 0.15, 0.15, 0.05, 0.05]
        )[0], 2)
        
        revenue = round(quantity * unit_price * (1 - discount), 2)
        cost = round(quantity * product['UnitCost'], 2)
        gst = round(revenue * 0.10, 2)  # 10% GST (Australian tax)
        
        transaction = {
            'TransactionID': f'TXN{i+1:08d}',
            'TransactionDate': sale_date.strftime('%Y-%m-%d'),
            'StoreID': store['StoreID'],
            'ProductID': product['ProductID'],
            'CustomerID': customer['CustomerID'] if customer is not None else None,
            'ChannelID': channel['ChannelID'],
            'Quantity': quantity,
            'UnitPrice': unit_price,
            'Discount': discount,
            'Revenue': revenue,
            'Cost': cost,
            'GST': gst,
            'TransactionTime': f"{random.randint(6,22):02d}:{random.randint(0,59):02d}:00"
        }
        
        transactions.append(transaction)
    
    df_sales = pd.DataFrame(transactions)
    
    # =========================================================================
    # INTRODUCE INTENTIONAL QUALITY ISSUES (for training purposes)
    # =========================================================================
    
    print("   🔧 Adding data quality issues for training...")
    
    # 1. Create duplicates (5%)
    num_duplicates = int(len(df_sales) * 0.05)
    duplicate_indices = random.sample(range(len(df_sales)), num_duplicates)
    duplicates = df_sales.iloc[duplicate_indices].copy()
    df_sales = pd.concat([df_sales, duplicates], ignore_index=True)
    print(f"      ✓ Added {num_duplicates} duplicate transactions ({len(duplicates)} total duplicates)")
    
    # 2. Set GST to null (3%)
    null_gst_indices = random.sample(range(len(df_sales)), int(len(df_sales) * 0.03))
    df_sales.loc[null_gst_indices, 'GST'] = None
    print(f"      ✓ Set {len(null_gst_indices)} GST values to NULL (3%)")
    
    # 3. Zero/negative quantities (1%)
    bad_qty_indices = random.sample(range(len(df_sales)), int(len(df_sales) * 0.01))
    for idx in bad_qty_indices:
        df_sales.loc[idx, 'Quantity'] = random.choice([0, -1, -2])
    print(f"      ✓ Set {len(bad_qty_indices)} quantities to zero/negative (1%)")
    
    # 4. Revenue outliers (0.5%)
    outlier_indices = random.sample(range(len(df_sales)), int(len(df_sales) * 0.005))
    for idx in outlier_indices:
        df_sales.loc[idx, 'Revenue'] = round(random.uniform(10000, 50000), 2)
    print(f"      ✓ Created {len(outlier_indices)} revenue outliers (0.5%)")
    
    print()
    print(f"   ✅ Generated {len(df_sales)} total transactions")
    print(f"      Clean transactions: ~{NUM_TRANSACTIONS}")
    print(f"      Quality issues: ~{len(duplicates) + len(null_gst_indices) + len(bad_qty_indices) + len(outlier_indices)}")
    print()
    
    return df_sales

# =============================================================================
# MESSY FILE GENERATORS (CSV, Excel, SharePoint)
# =============================================================================

def create_messy_csv(df_sales, df_store):
    """
    Create messy CSV file with casing and formatting issues
    
    Args:
        df_sales: Sales fact table
        df_store: Store dimension (to get State)
    """
    print("📄 Creating messy CSV file (daily_transactions.csv)...")
    
    # Sample transactions for daily export (~10,000 rows)
    daily_sales = df_sales.sample(n=min(10000, len(df_sales))).copy()
    
    # Merge with store to get State column
    daily_sales = daily_sales.merge(
        df_store[['StoreID', 'State']], 
        on='StoreID', 
        how='left'
    )
    
    # =========================================================================
    # INTRODUCE CASING ISSUES (for cleaning practice)
    # =========================================================================
    
    def randomize_case(val):
        """Randomly change casing of a string"""
        if pd.isna(val) or not isinstance(val, str):
            return val
        
        cases = [
            val.upper(),           # NSW
            val.lower(),           # nsw
            val.title(),           # Nsw
            val                    # NSW (original)
        ]
        return random.choice(cases)
    
    # Apply random casing to State column
    daily_sales['State'] = daily_sales['State'].apply(randomize_case)
    
    # Introduce some malformed dates (2%)
    malformed_indices = random.sample(range(len(daily_sales)), int(len(daily_sales) * 0.02))
    for idx in malformed_indices:
        # Invalid date formats
        daily_sales.loc[idx, 'TransactionDate'] = random.choice([
            '2024-13-45',      # Invalid month/day
            '2024-00-01',      # Invalid month
            '99/99/9999',      # Wrong format
            'INVALID'          # Not a date
        ])
    
    # Save to CSV
    csv_path = os.path.join(BASE_PATH, 'csv', 'daily_transactions.csv')
    daily_sales.to_csv(csv_path, index=False)
    
    print(f"   ✓ Saved: {csv_path}")
    print(f"   ✓ Rows: {len(daily_sales)}")
    print(f"   ✓ Quality issues: Mixed case states, {len(malformed_indices)} invalid dates")
    print()
    
    return daily_sales

def create_excel_workbook():
    """
    Create Excel workbook with multiple sheets and formatting issues
    """
    print("📊 Creating Excel workbook (finance_budgets_FY2024.xlsx)...")
    
    # Generate budget data for FY2024 (July 2023 - June 2024)
    months = pd.date_range('2023-07-01', '2024-06-30', freq='MS')
    
    # Select sample products
    products_sample = [f'PRD{i:05d}' for i in range(1, 6)]
    
    budget_data = []
    
    for month in months:
        for product in products_sample:
            budget_data.append({
                'Month': month.strftime('%Y-%m'),
                'ProductID': product,
                'BudgetRevenue': round(random.uniform(5000, 50000), 2),
                'BudgetUnits': random.randint(100, 1000),
                'ForecastRevenue': round(random.uniform(5000, 50000), 2),
                'ForecastUnits': random.randint(100, 1000)
            })
    
    df_budget = pd.DataFrame(budget_data)
    
    # =========================================================================
    # INTRODUCE NULLS IN FORECAST COLUMNS (10%)
    # =========================================================================
    
    null_indices = random.sample(range(len(df_budget)), int(len(df_budget) * 0.1))
    df_budget.loc[null_indices, 'ForecastRevenue'] = None
    df_budget.loc[null_indices, 'ForecastUnits'] = None
    
    # Create notes sheet
    notes_data = {
        'Note': [
            'Budget based on FY2023 actuals + 10% growth assumption',
            'Forecast updated quarterly by store managers',
            'Some forecast values pending final store manager input',
            'All values in AUD (Australian Dollars)',
            'GST exclusive - add 10% for GST inclusive amounts'
        ]
    }
    df_notes = pd.DataFrame(notes_data)
    
    # Save to Excel with multiple sheets
    excel_path = os.path.join(BASE_PATH, 'excel', 'finance_budgets_FY2024.xlsx')
    
    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        df_budget.to_excel(writer, sheet_name='Budget', index=False)
        df_notes.to_excel(writer, sheet_name='Notes', index=False)
    
    print(f"   ✓ Saved: {excel_path}")
    print(f"   ✓ Sheet 'Budget': {len(df_budget)} rows, {len(null_indices)} null forecasts (10%)")
    print(f"   ✓ Sheet 'Notes': {len(df_notes)} rows (documentation)")
    print()
    
    return df_budget

def save_sql_tables(df_store, df_product, df_customer, df_channel, df_date, df_sales):
    """
    Save dimension and fact tables as CSV for SQL Server import
    """
    print("💾 Saving SQL Server load files...")
    
    sql_path = os.path.join(BASE_PATH, 'sql')
    
    tables = {
        'dim_store.csv': df_store,
        'dim_product.csv': df_product,
        'dim_customer.csv': df_customer,
        'dim_channel.csv': df_channel,
        'dim_date.csv': df_date,
        'fact_sales.csv': df_sales
    }
    
    for filename, df in tables.items():
        filepath = os.path.join(sql_path, filename)
        df.to_csv(filepath, index=False)
        print(f"   ✓ Saved {filename} ({len(df):,} rows)")
    
    print()
    print(f"   ℹ️  Import these files into SQL Server database 'FreshMarket_Source'")
    print(f"      using SSMS Import Wizard (Tasks → Import Flat File)")
    print()

def create_sharepoint_files():
    """
    Create SharePoint marketing campaign files with inconsistent schemas
    """
    print("📁 Creating SharePoint marketing files...")
    
    sharepoint_path = os.path.join(BASE_PATH, 'sharepoint')
    
    # Define marketing campaigns across seasons
    campaigns = [
        {'name': 'summer_campaign_2022', 'start': '2022-12-01', 'end': '2023-02-28'},
        {'name': 'autumn_campaign_2023', 'start': '2023-03-01', 'end': '2023-05-31'},
        {'name': 'winter_campaign_2023', 'start': '2023-06-01', 'end': '2023-08-31'},
        {'name': 'spring_campaign_2023', 'start': '2023-09-01', 'end': '2023-11-30'},
        {'name': 'summer_campaign_2023', 'start': '2023-12-01', 'end': '2024-02-29'},
        {'name': 'autumn_campaign_2024', 'start': '2024-03-01', 'end': '2024-05-31'}
    ]
    
    for campaign in campaigns:
        # Generate daily campaign data
        dates = pd.date_range(campaign['start'], campaign['end'], freq='D')
        
        data = []
        for date in dates:
            data.append({
                # Inconsistent column casing (intentional for training)
                'campaign_date': date.strftime('%Y-%m-%d'),     # lowercase
                'Campaign_Name': campaign['name'],              # Title Case
                'PRODUCT_ID': f"PRD{random.randint(1, 2000):05d}",  # UPPERCASE
                'spend': round(random.uniform(100, 5000), 2),   # lowercase
                'impressions': random.randint(1000, 100000),
                'Clicks': random.randint(10, 1000)              # Title Case
            })
        
        df_campaign = pd.DataFrame(data)
        
        # Save as CSV
        filename = f"marketing_{campaign['name']}.csv"
        filepath = os.path.join(sharepoint_path, filename)
        df_campaign.to_csv(filepath, index=False)
        
        print(f"   ✓ Saved {filename} ({len(df_campaign)} rows)")
    
    print()
    print(f"   ℹ️  Note: Column names intentionally inconsistent across files")
    print(f"      (simulates user uploads to SharePoint by different people)")
    print()

def create_web_api_simulation():
    """
    Create JSON file simulating web API response (supplier catalog)
    """
    print("🌐 Creating Web API simulation (supplier_catalog_api.json)...")
    
    # Sample product catalog from supplier
    products = []
    
    for i in range(100):
        products.append({
            'product_id': f'PRD{i+1:05d}',
            'supplier_name': fake.company(),
            'current_price': round(random.uniform(1.0, 100.0), 2),
            'stock_status': random.choice(['In Stock', 'Low Stock', 'Out of Stock']),
            'last_updated': datetime.now().isoformat()
        })
    
    # Wrap in API response structure
    api_response = {
        'status': 'success',
        'timestamp': datetime.now().isoformat(),
        'data': products
    }
    
    # Save as JSON
    json_path = os.path.join(BASE_PATH, 'csv', 'supplier_catalog_api.json')
    
    with open(json_path, 'w') as f:
        json.dump(api_response, f, indent=2)
    
    print(f"   ✓ Saved: {json_path}")
    print(f"   ✓ Records: {len(products)}")
    print(f"   ✓ Structure: Nested JSON (status, timestamp, data array)")
    print()

# =============================================================================
# DATA PROFILING
# =============================================================================

def create_data_profile_report(df_store, df_product, df_customer, df_sales):
    """
    Create data profile summary showing row counts and quality metrics
    """
    print("📈 Creating data profile report...")
    
    profile = {
        'Table': [],
        'Rows': [],
        'Columns': [],
        'Null_Count': [],
        'Duplicate_Count': []
    }
    
    tables = {
        'DimStore': df_store,
        'DimProduct': df_product,
        'DimCustomer': df_customer,
        'FactSales': df_sales
    }
    
    for name, df in tables.items():
        profile['Table'].append(name)
        profile['Rows'].append(len(df))
        profile['Columns'].append(len(df.columns))
        profile['Null_Count'].append(int(df.isnull().sum().sum()))
        profile['Duplicate_Count'].append(int(df.duplicated().sum()))
    
    df_profile = pd.DataFrame(profile)
    
    # Save profile report
    profile_path = os.path.join(BASE_PATH, 'data_profile_report.csv')
    df_profile.to_csv(profile_path, index=False)
    
    print(f"   ✓ Saved: {profile_path}")
    print()
    print("   📊 DATA PROFILE SUMMARY:")
    print("   " + "=" * 76)
    print(df_profile.to_string(index=False))
    print("   " + "=" * 76)
    print()

# =============================================================================
# MAIN EXECUTION
# =============================================================================

def main():
    """Main execution function"""
    
    print_section_header("FRESHMARKET AUSTRALIA - DATASET GENERATOR")
    print("Power BI ETL Training - Video 1")
    print("Generating realistic Australian retail data with quality issues...")
    print()
    
    # Create folder structure
    create_folders()
    
    # =========================================================================
    # STEP 1: Generate Dimension Tables
    # =========================================================================
    
    print_section_header("STEP 1: GENERATING DIMENSION TABLES")
    
    df_store = generate_dim_store()
    df_product = generate_dim_product()
    df_customer = generate_dim_customer()
    df_channel = generate_dim_channel()
    df_date = generate_dim_date()
    
    # =========================================================================
    # STEP 2: Generate Fact Table
    # =========================================================================
    
    print_section_header("STEP 2: GENERATING FACT TABLE")
    
    df_sales = generate_fact_sales(df_store, df_product, df_customer, df_channel)
    
    # =========================================================================
    # STEP 3: Create Messy Source Files
    # =========================================================================
    
    print_section_header("STEP 3: CREATING SOURCE FILES")
    
    create_messy_csv(df_sales, df_store)
    create_excel_workbook()
    save_sql_tables(df_store, df_product, df_customer, df_channel, df_date, df_sales)
    create_sharepoint_files()
    create_web_api_simulation()
    
    # =========================================================================
    # STEP 4: Create Data Profile Report
    # =========================================================================
    
    print_section_header("STEP 4: CREATING DATA PROFILE")
    
    create_data_profile_report(df_store, df_product, df_customer, df_sales)
    
    # =========================================================================
    # COMPLETION
    # =========================================================================
    
    print_section_header("✅ DATASET GENERATION COMPLETE!")
    
    print(f"📁 Output Location: {BASE_PATH}")
    print()
    print("📋 Next Steps:")
    print("   1. Import SQL files into SQL Server (SSMS → Import Flat File)")
    print("   2. Open Power BI Desktop")
    print("   3. Follow the playbook (Video1_ETL_Playbook.md)")
    print("   4. Connect to all 5 data sources")
    print("   5. Build staging → clean query pattern")
    print()
    print("📊 Data Quality Summary:")
    print("   • Total transactions: {:,}".format(len(df_sales)))
    print("   • Clean transactions: {:,}".format(NUM_TRANSACTIONS))
    print("   • Quality issues: ~{:,}".format(len(df_sales) - NUM_TRANSACTIONS))
    print("   • Stores: {} across NSW ({}), VIC ({}), QLD ({})".format(
        len(df_store),
        len(df_store[df_store['State']=='NSW']),
        len(df_store[df_store['State']=='VIC']),
        len(df_store[df_store['State']=='QLD'])
    ))
    print("   • Products: {:,} across {} categories".format(len(df_product), len(CATEGORIES)))
    print("   • Customers: {:,} with FreshRewards loyalty".format(len(df_customer)))
    print()
    print("🎓 Training Focus:")
    print("   ✓ Remove ~5% duplicates")
    print("   ✓ Calculate ~3% missing GST values")
    print("   ✓ Standardize state codes (15+ variations → 8 standard)")
    print("   ✓ Filter ~1% invalid quantities")
    print("   ✓ Handle ~2% malformed dates")
    print()
    print("=" * 80)
    print()

if __name__ == "__main__":
    main()
