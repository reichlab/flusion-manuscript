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

combined_dat = fdl.load_data(hhs_kwargs={'rates': True})

fig, ax = plt.subplots(3, 1)
fig.set_layout_engine('constrained')
fig.set_size_inches(8, 5)

hhs_to_plot = combined_dat \
    .loc[(combined_dat['source'] == 'hhs') & (combined_dat['season_week'] >= 10) & (combined_dat['season_week'] <= 40)] \
    .assign(season_loc = lambda x: x['season'] + '_' + x['location'])
g = sns.lineplot(data=hhs_to_plot,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='log_pop',
             estimator=None,
             ci=None,
             ax=ax[0])

g.legend_.set_title('log(population)')
g.legend_.set_loc('upper right')
g.set_xlabel('')
g.set_ylabel('Standardized\nNHSN admissions')
ax[0].yaxis.label.set_size(11)
ax[0].tick_params(labelbottom=False)
ax[0].grid('on', linestyle='-', color='lightgrey')
ax[0].spines['right'].set_color('lightgrey')
ax[0].spines['top'].set_color('lightgrey')

flusurv_to_plot = combined_dat \
    .loc[(combined_dat['source'] == 'flusurvnet') & (combined_dat['season_week'] >= 10) & (combined_dat['season_week'] <= 40)] \
    .assign(season_loc = lambda x: x['season'] + '_' + x['location'])

g = sns.lineplot(data=flusurv_to_plot,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='log_pop',
             estimator=None,
             ci=None,
             ax=ax[1])
g.legend_.remove()
g.set_xlabel('')
g.set_ylabel('Standardized\nFluSurv rate')
ax[1].yaxis.label.set_size(11)
ax[1].tick_params(labelbottom=False)
ax[1].grid('on', linestyle='-', color='lightgrey')
ax[1].spines['right'].set_color('lightgrey')
ax[1].spines['top'].set_color('lightgrey')


ili_to_plot = combined_dat \
    .loc[(combined_dat['source'] == 'ilinet') & (combined_dat['season_week'] >= 10) & (combined_dat['season_week'] <= 40)] \
    .assign(season_loc = lambda x: x['season'] + '_' + x['location'])
g = sns.lineplot(data=ili_to_plot,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='log_pop',
             estimator=None,
             ci=None,
             ax=ax[2])
g.legend_.remove()
g.set_xlabel('Week of Season')
g.set_ylabel('Standardized\nILI+')
ax[2].yaxis.label.set_size(11)
# ax[1].set_title('ILI+', pad=0)
ax[2].grid('on', linestyle='-', color='lightgrey')
ax[2].spines['right'].set_color('lightgrey')
ax[2].spines['top'].set_color('lightgrey')

# save to pdf
fig.savefig('artifacts/figures/data_standardized.pdf',
            format = 'pdf')
