#!/usr/bin/env python3

import re
import pandas as pd
from BP_percentiles_updated import Data, Patient

# Input and output paths
data_file   = 'Composite_sheet_cleaned.csv'
output_file = '3_2_updates.csv'

# 1) Load percentile definitions + raw data
data = Data()
data.loader()

# 2) Instantiate Patient objects for each record
patients = Patient.create_objects(data.global_data)

# 3) Helper to detect any category ≥90th percentile
def is_above_90(cat_list):
    for c in cat_list:
        if not c:
            continue
        m = re.match(r"(\d+)", c)
        if m and int(m.group(1)) >= 90:
            return True
    return False

# 4) Compute elevated‐BP flag and not_pediatric flag for each patient
elevated_flags       = []
not_pediatric_flags  = []

for p in patients:
    result = p.percentile_calculation(data.percentile)

    # detect "Patient is not pediateric"
    if isinstance(result, str) and 'not pediateric' in result.lower():
        not_ped = 1
        bp1_cat, bp2_cat = [], []
    else:
        not_ped = 0
        # unpack categories
        if isinstance(result, tuple):
            bp1_cat, bp2_cat = result
        else:
            bp1_cat, bp2_cat = result, []

    # elevated if both readings have any ≥90th percentile
    flag = 'Yes' if (is_above_90(bp1_cat) and is_above_90(bp2_cat)) else 'No'

    elevated_flags.append(flag)
    not_pediatric_flags.append(not_ped)

# 5) Load original data, append new columns, and write out
df = pd.read_csv(data_file, dtype=str)
df['elevated_bp_group'] = elevated_flags
df['not_pediatric']     = not_pediatric_flags

df.to_csv(output_file, index=False)
print(f"✅ Wrote {len(elevated_flags)} rows to {output_file}")
