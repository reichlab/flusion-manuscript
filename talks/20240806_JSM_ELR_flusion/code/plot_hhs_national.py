from data_pipeline.loader import FluDataLoader

import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt

fdl = FluDataLoader('../flusion/data-raw')

hhs = fdl.load_hhs(rates=False, drop_pandemic_seasons=False) \
    .query('agg_level == "national"')


fig = plt.figure(figsize=[8,4])
ax = plt.subplot(111)

ax.plot(
    'wk_end_date',
    'inc',
    '-',
    data = hhs)

season_start_ends = {
    season: {
        'start': hhs.loc[hhs.season == season]['wk_end_date'].min(),
        'end': hhs.loc[hhs.season == season]['wk_end_date'].max(),
    } \
    for season in hhs['season'].unique()
}

for season in list(season_start_ends.keys())[1::2]:
    plt.axvline(season_start_ends[season]['start'], alpha=0.7, c='black', linestyle='--')
    plt.axvline(season_start_ends[season]['end'], alpha=0.7, c='black', linestyle='--')

#   plt.axvspan(season_start_ends[season]['start'],
#               season_start_ends[season]['end'],
#               facecolor='0.2', alpha=0.3)

for season in list(season_start_ends.keys())[1:]:
    plt.annotate(season,
                 (season_start_ends[season]['start'] + pd.Timedelta(15, 'w'), 28000))


# ax.set_xlim(0, 250)
ax.set_ylim(0, 30000)
ax.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
ax.set_xlabel('Date')
ax.xaxis.label.set_size(14)
ax.set_ylabel('NHSN: Influenza hospitalizations')
ax.yaxis.label.set_size(14)
ax.grid('on', linestyle='-', color='lightgrey')
ax.spines['right'].set_color('lightgrey')
ax.spines['top'].set_color('lightgrey')

fig.set_tight_layout(True)

fig.savefig('talks/20240806_JSM_ELR_flusion/figures/hhs_national.pdf',
            format = 'pdf')
#plt.show()

