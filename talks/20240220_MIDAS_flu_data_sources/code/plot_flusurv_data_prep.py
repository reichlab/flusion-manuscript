from data_pipeline.loader import FluDataLoader
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt

fdl = FluDataLoader('../flusion/data-raw')

flusurv_adj = fdl.load_flusurv_rates()
flusurv_unadj = fdl.load_flusurv_rates(burden_adj = False)


#locs = flusurv_unadj['location'].unique()
locs = ['Entire Network', 'California', 'Connecticut']
nloc = len(locs)


fig, ax = plt.subplots(nrows=nloc, ncols=1, squeeze=True, sharex=True, figsize=(10, 5))

for i, loc in enumerate(locs):
  ax[i].plot(
    'wk_end_date',
    'inc',
    '-',
    data = flusurv_unadj.query(f'location == "{loc}"'))
  ax[i].set_title(loc, pad=0)
  # ax[i].text(0.01,0.94,loc,size=12,ha='left',va='top',transform=ax[i].transAxes,
  #            backgroundcolor='white',
  #            bbox=dict(facecolor='white', edgecolor='gray'))
            #  bbox=dict(facecolor='white', edgecolor='gray', boxstyle='round'))
  
  ax[i].set_ylim(0, 25)
  ax[i].yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
  ax[i].grid('on', linestyle='-', color='lightgrey')
  ax[i].spines['right'].set_color('lightgrey')
  ax[i].spines['top'].set_color('lightgrey')

fig.text(0.5, 0.02, 'Date', ha='center', va='center', size=14)
fig.text(0.02, 0.5, 'FluSurv-NET: Influenza hospitalizations',
         ha='center', va='center', rotation='vertical', size=14)

plt.subplots_adjust(bottom=0.1, left=0.07, top=0.95, right=0.99, hspace=0.3)
# plt.subplots_adjust(bottom=0.05, left=0.07, top=0.95, right=0.99, hspace=0.3)
fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/flusurv_overview.pdf',
            format = 'pdf')


fdl.calc_hosp_burden_adj()




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


fig = plt.figure(figsize=[6,6])
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
  '^',
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

fig.set_tight_layout(True)

fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/flusurv_cum_adjust_scatter.pdf',
            format = 'pdf')





fig = plt.figure(figsize=[10,5])
ax = plt.subplot(111)

loc = 'Entire Network'
ax.plot(
  'wk_end_date',
  'inc',
  data = flusurv_unadj.query(f'location == "{loc}"'),
  label = 'Unadjusted')
ax.plot(
  'wk_end_date',
  'inc',
  data = flusurv_adj.query(f'location == "{loc}"'),
  linestyle = '--',
  label = 'Adjusted')


ax.legend(loc='upper left')
# ax.set_xlim(0, 250)
# ax.set_ylim(0, 800000)
ax.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
ax.set_xlabel('Date')
ax.xaxis.label.set_size(14)
ax.set_ylabel('FluSurv-NET: Weekly hospitalization rate')
ax.yaxis.label.set_size(14)
ax.grid('on', linestyle='-', color='lightgrey')
ax.spines['right'].set_color('lightgrey')
ax.spines['top'].set_color('lightgrey')

fig.set_tight_layout(True)


fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/flusurv_inc_adjust_line.pdf',
            format = 'pdf')


plt.show()




