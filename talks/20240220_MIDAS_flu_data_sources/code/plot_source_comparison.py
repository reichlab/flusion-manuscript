from data_pipeline.loader import FluDataLoader
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib.dates as mdates
from matplotlib.lines import Line2D
import seaborn as sns

fdl = FluDataLoader('../flusion/data-raw')

ilinet_adj = fdl.load_ilinet(scale_to_positive=True, drop_pandemic_seasons=True)

hhs = fdl.load_hhs(rates=True, drop_pandemic_seasons=True) \
  .query('agg_level == "national"')

flusurv_adj = fdl.load_flusurv_rates() \
  .query('location == "Entire Network"')

fig = plt.figure(figsize=[10,5])
ax = plt.subplot(111)

ax.plot(
  'wk_end_date',
  'scaled_inc',
  '-',
  data = hhs.query('season == "2022/23" and wk_end_date >= "2022-09-01" and wk_end_date < "2023-04-01"') \
            .assign(scaled_inc = lambda x: x.inc),
  label = 'NHSN Admissions / 100k pop')

ax.plot(
  'wk_end_date',
  'scaled_inc',
  '--',
  data = ilinet_adj \
    .query('location == "National" and season == "2022/23" and wk_end_date >= "2022-09-01" and wk_end_date < "2023-04-01"') \
    .assign(scaled_inc = lambda x: x.inc * 4),
  label = 'ILI+ * 4')

ax.plot(
  'wk_end_date',
  'scaled_inc',
  linestyle = 'dashdot',
  data = flusurv_adj.query('season == "2022/23" and wk_end_date >= "2022-09-01" and wk_end_date < "2023-04-01"') \
            .assign(scaled_inc = lambda x: x.inc / 2.5),
  label = 'FluSurv-NET Rate / 2.5')

# ax.set_ylim(0, 25)
ax.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
ax.legend(loc='upper left')
ax.set_xlabel('Date')
ax.xaxis.label.set_size(14)
ax.set_ylabel('Influenza Activity')
ax.yaxis.label.set_size(14)
ax.grid('on', linestyle='-', color='lightgrey')
ax.spines['right'].set_color('lightgrey')
ax.spines['top'].set_color('lightgrey')

fig.set_tight_layout(True)

# plt.show()

fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/source_comparison_national.pdf',
            format = 'pdf')


# State level plot
combined_dat = fdl.load_data(hhs_kwargs={'rates': True})
fips_mappings = fdl.load_fips_mappings()

state_dat = combined_dat.query('agg_level == "state" and season == "2022/23" and wk_end_date >= "2022-09-01" and wk_end_date < "2023-04-01"') \
  .merge(fips_mappings, how='left', on='location')

locs = state_dat.query('source == "flusurvnet"')['abbreviation'].unique()
nloc = len(locs)



# fig, ax = plt.subplots(nrows=3, ncols=5, squeeze=True, sharex=True, sharey=True, figsize=(10, 5))

fig = plt.figure(layout="constrained", figsize=[10,5])
gs = GridSpec(3, 5, figure=fig)

ax_not_in_layout = []

for i, loc in enumerate(locs):
  row, col = np.unravel_index(i, (3, 5))
  ax = fig.add_subplot(gs[row, col])
  
  ax.plot(
    'wk_end_date',
    'scaled_inc',
    '-',
    color='C0',
    data = state_dat \
      .query(f'abbreviation == "{loc}" and season == "2022/23" and source == "hhs"') \
      .assign(scaled_inc = lambda x: x.inc),
    label = 'NHSN Admissions / 100k pop')
  
  ax.plot(
    'wk_end_date',
    'scaled_inc',
    '--',
    color='C1',
    data = state_dat \
      .query(f'abbreviation == "{loc}" and source == "ilinet"') \
      .assign(scaled_inc = lambda x: x.inc),
    label = 'ILI+ * 4')
  
  ax.plot(
    'wk_end_date',
    'scaled_inc',
    linestyle = 'dashdot',
    color = 'C2',
    data = state_dat \
      .query(f'abbreviation == "{loc}" and season == "2022/23" and source == "flusurvnet"') \
      .assign(scaled_inc = lambda x: x.inc),
    label = 'FluSurv-NET Rate / 2.5')
  
  ax.set_title(loc, pad=0)
  ax.xaxis.set_major_locator(mdates.MonthLocator(bymonth=(2, 4, 10, 12)))
  ax.xaxis.set_minor_locator(mdates.MonthLocator())
  # if row == 2 or (row == 1 and col >= 3):
  if row == 2:
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
  else:
    ax.xaxis.set_major_formatter(mdates.DateFormatter(''))
  # Rotates and right-aligns the x labels so they don't crowd each other.
  for label in ax.get_xticklabels(which='major'):
      label.set(rotation=30, horizontalalignment='right')
  # ax.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
  ax.grid('on', linestyle='-', color='lightgrey')
  ax.spines['right'].set_color('lightgrey')
  ax.spines['top'].set_color('lightgrey')
  
  if row == 1 and col >= 3:
    # ax.set_in_layout(False)
    ax_not_in_layout.append(ax)


legend_elements = [Line2D([0], [0], linestyle='-', color='C0', label='NHSN Admissions / 100k pop'),
                   Line2D([0], [0], linestyle='--', color='C1', label='ILI+ * 4'),
                   Line2D([0], [0], linestyle = 'dashdot', color='C2', label = 'FluSurv-NET Rate / 2.5')]

ax = fig.add_subplot(gs[2, 3:5])
ax.axis('off')
ax.legend(handles=legend_elements, loc='lower center')
# ax.legend(handles=legend_elements, loc='lower right')

fig.canvas.draw()

for ax in ax_not_in_layout:
  ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
  # ax.set_in_layout(True)

fig.set_layout_engine('none')

fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/source_comparison_state.pdf',
            format = 'pdf')




fig, ax = plt.subplots(3, 1)
fig.set_layout_engine('constrained')
fig.set_size_inches(8, 7)

hhs_to_plot = combined_dat.loc[combined_dat['source'] == 'hhs'].assign(season_loc = lambda x: x['season'] + '_' + x['location'])
g = sns.lineplot(data=hhs_to_plot,
             x='season_week',
             y='inc_4rt_cs',
             units='season_loc',
             hue='log_pop',
             estimator=None,
             ci=None,
             ax=ax[0])

g.legend_.set_title('log(population)')
g.legend_.set_loc('upper right')
g.set_xlabel('Week of Season')
g.set_ylabel('Standardized Incidence')
ax[0].set_title('NHSN Admissions', pad=0)
ax[0].grid('on', linestyle='-', color='lightgrey')
ax[0].spines['right'].set_color('lightgrey')
ax[0].spines['top'].set_color('lightgrey')

ili_to_plot = combined_dat.loc[combined_dat['source'] == 'ilinet'].assign(season_loc = lambda x: x['season'] + '_' + x['location'])
g = sns.lineplot(data=ili_to_plot,
             x='season_week',
             y='inc_4rt_cs',
             units='season_loc',
             hue='log_pop',
             estimator=None,
             ci=None,
             ax=ax[1])
g.legend_.remove()
g.set_xlabel('Week of Season')
g.set_ylabel('Standardized Incidence')
ax[1].set_title('ILI+', pad=0)
ax[1].grid('on', linestyle='-', color='lightgrey')
ax[1].spines['right'].set_color('lightgrey')
ax[1].spines['top'].set_color('lightgrey')

flusurv_to_plot = combined_dat.loc[combined_dat['source'] == 'flusurvnet'].assign(season_loc = lambda x: x['season'] + '_' + x['location'])
g = sns.lineplot(data=flusurv_to_plot,
             x='season_week',
             y='inc_4rt_cs',
             units='season_loc',
             hue='log_pop',
             estimator=None,
             ci=None,
             ax=ax[2])
g.legend_.remove()
g.set_xlabel('Week of Season')
g.set_ylabel('Standardized Incidence')
ax[2].set_title('FluSurv-NET', pad=0)
ax[2].grid('on', linestyle='-', color='lightgrey')
ax[2].spines['right'].set_color('lightgrey')
ax[2].spines['top'].set_color('lightgrey')

# plt.show()

fig.savefig('talks/20240220_MIDAS_flu_data_sources/plots/source_comparison_all_scales_by_source.pdf',
            format = 'pdf')
