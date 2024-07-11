from data_pipeline.loader import FluDataLoader
import pandas as pd

fdl = FluDataLoader('../flusion/data-raw')

df = fdl.calc_hosp_burden_adj()
df.to_csv('artifacts/flusurv_burden_adj.csv', index=False)
