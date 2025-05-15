#!/usr/bin/env python3
import re
from datetime import datetime
import pandas as pd
from BP_percentiles import Data, Patient

# Input and output files
data_file = 'Composite_sheet_cleaned.csv'
output_file = 'Composite_with_elevated_bp_group.csv'

# 1) Load percentile definitions + raw data
data = Data()
data.loader()
# instantiate Patient objects for each record
def_records = data.global_data
patients = [Patient(rec) for rec in def_records]

# 2) Helper: detect if any category ≥90th percentile
def is_above_90(cat_list):
    for c in cat_list:
        if not c:
            continue
        m = re.match(r"(\d+)", c)
        if m and int(m.group(1)) >= 90:
            return True
    return False

# 3) Compute age differences and classification flags
days_to_bp1 = []
years_to_bp1 = []
days_to_bp2 = []
years_to_bp2 = []
elevated_flags = []

for p in patients:
    # days & years from DOB to BP1 measurement
    if p.BP1_date:
        d1 = (p.BP1_date - p.DOB).days
        y1 = d1 / 365.25
    else:
        d1 = None
        y1 = None
    days_to_bp1.append(d1)
    years_to_bp1.append(y1)

    # days & years from DOB to BP2 measurement
    if p.BP2_date:
        d2 = (p.BP2_date - p.DOB).days
        y2 = d2 / 365.25
    else:
        d2 = None
        y2 = None
    days_to_bp2.append(d2)
    years_to_bp2.append(y2)

    # classification categories for BP1 and BP2
    bp1_cat, bp2_cat = p.percentile_calculation(data.percentile)
    # elevated if both readings have any ≥90th percentile
    flag = 'Yes' if (is_above_90(bp1_cat) and is_above_90(bp2_cat)) else 'No'
    elevated_flags.append(flag)

# 4) Append new columns to DataFrame and save

df = pd.read_csv(data_file, dtype=str)
df['days_from_DOB_to_BP1']   = days_to_bp1
df['years_from_DOB_to_BP1']  = years_to_bp1
df['days_from_DOB_to_BP2']   = days_to_bp2
df['years_from_DOB_to_BP2']  = years_to_bp2
df['elevated_bp_group']      = elevated_flags
df.to_csv(output_file, index=False)
print(f"✅ Wrote {len(elevated_flags)} rows to {output_file}")
