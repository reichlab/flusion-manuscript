from data_pipeline.loader import FluDataLoader
import matplotlib as mpl
import matplotlib.pyplot as plt

fdl = FluDataLoader('../flusion/data-raw')

flusurv_adj = fdl.load_flusurv_rates()
flusurv_unadj = fdl.load_flusurv_rates(burden_adj = False)


adj_cum_rate = flusurv_adj \
  .query(f'location == "Entire Network"') \
  .groupby('season') \
  .sum('inc') \
  .reset_index() \
  .drop('season_week', axis=1) \
  .rename(columns={'inc': 'adj_cum_rate'})

cum_rates = flusurv_unadj \
  .query(f'location == "Entire Network"') \
  .groupby('season') \
  .sum('inc') \
  .reset_index() \
  .drop('season_week', axis=1) \
  .rename(columns={'inc': 'unadj_cum_rate'}) \
  .merge(
    fdl.load_hosp_burden(),
    on='season'
  ) \
  .merge(
    adj_cum_rate,
    on='season'
  )


fig = plt.figure(figsize=[7,5])
ax = plt.subplot(111)

ax.plot(
  'unadj_cum_rate',
  'hosp_burden',
  'o',
  data = cum_rates,
  label = 'Unadjusted')
ax.plot(
  'adj_cum_rate',
  'hosp_burden',
  'o',
  data = cum_rates,
  label = 'Adjusted')


ax.legend(loc='upper left')
ax.set_xlim(0, 250)
ax.set_ylim(0, 800000)
ax.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
ax.set_xlabel('FluSurv-NET: Seasonal cumulative hospitalization rate')
ax.xaxis.label.set_size(14)
ax.set_ylabel('CDC: Seasonal hospital burden estimate')
ax.yaxis.label.set_size(14)
ax.grid('on', linestyle='-', color='lightgrey')
ax.spines['right'].set_color('lightgrey')
ax.spines['top'].set_color('lightgrey')
plt.show()



unadj_cum_rate = unadj_cum_rate.merge(
  burden, on='season'
)

plt.plot()

loc = 'Entire Network'
plt.plot(
  'wk_end_date',
  'inc',
  data = flusurv_adj.query(f'location == "{loc}"'))
plt.plot(
  'wk_end_date',
  'inc',
  data = flusurv_unadj.query(f'location == "{loc}"'))
plt.show()




