from data_pipeline.loader import FluDataLoader
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt

fdl = FluDataLoader('../flusion/data-raw')

ilinet_adj = fdl.load_ilinet(scale_to_positive=True, drop_pandemic_seasons=False)
ilinet_unadj = fdl.load_ilinet(scale_to_positive=False, drop_pandemic_seasons=False)

ilinet_adj.query("season == '1997/98'")['location'].unique()

{
  season: ilinet_adj.query(f"season == '{season}'")['location'].unique() \
  for season in ilinet_adj['season'].unique()
}

#locs = flusurv_unadj['location'].unique()
locs = ['National', 'Region 1', 'California', 'Connecticut']
nloc = len(locs)


fig, ax = plt.subplots(nrows=nloc, ncols=1, squeeze=True, sharex=True, figsize=(10, 5))

for i, loc in enumerate(locs):
  ax[i].plot(
    'wk_end_date',
    'inc',
    '-',
    data = ilinet_unadj.query(f'location == "{loc}"'))
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
fig.text(0.02, 0.5, 'ILINet: Influenza-like illness',
         ha='center', va='center', rotation='vertical', size=14)

plt.subplots_adjust(bottom=0.1, left=0.07, top=0.95, right=0.99, hspace=0.3)
# plt.subplots_adjust(bottom=0.05, left=0.07, top=0.95, right=0.99, hspace=0.3)
fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/ilinet_overview.pdf',
            format = 'pdf')



fig = plt.figure(figsize=[10,5])
ax = plt.subplot(111)

loc = 'National'
ax.plot(
  'wk_end_date',
  'inc',
  data = ilinet_unadj.query(f'location == "{loc}"'),
  label = 'Unadjusted: ILI')
ax.plot(
  'wk_end_date',
  'inc',
  data = ilinet_adj.query(f'location == "{loc}"'),
  linestyle = '--',
  label = 'Adjusted: ILI+')


ax.legend(loc='upper left')
# ax.set_xlim(0, 250)
# ax.set_ylim(0, 800000)
ax.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
ax.set_xlabel('Date')
ax.xaxis.label.set_size(14)
ax.set_ylabel('ILINet: Weekly ILI and ILI+')
ax.yaxis.label.set_size(14)
ax.grid('on', linestyle='-', color='lightgrey')
ax.spines['right'].set_color('lightgrey')
ax.spines['top'].set_color('lightgrey')

fig.set_tight_layout(True)


fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/ilinet_inc_adjust_line.pdf',
            format = 'pdf')


plt.show()




