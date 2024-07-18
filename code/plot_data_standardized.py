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

fig, ax = plt.subplots(3, 2)
fig.set_layout_engine('constrained')
fig.set_size_inches(8, 5)

min_pop = combined_dat['pop'].min()
max_pop = combined_dat['pop'].max()
cmap = mpl.colormaps['viridis_r']
norm = mpl.colors.LogNorm(vmin=min_pop, vmax=max_pop)

hhs_to_plot = combined_dat \
    .loc[(combined_dat['source'] == 'hhs') & (combined_dat['season_week'] >= 10) & (combined_dat['season_week'] <= 40)] \
    .assign(season_loc = lambda x: x['season'] + '_' + x['location'])
hhs_to_plot_low = hhs_to_plot.query('agg_level == "state"')
hhs_to_plot_high = hhs_to_plot.query('agg_level != "state"')
g = sns.lineplot(data=hhs_to_plot_low,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='pop',
             palette=cmap,
             hue_norm=norm,
             legend=False,
             estimator=None,
             ci=None,
             ax=ax[0, 0])
# g.legend_.remove()
# g.legend_.set_title('log(population)')
# g.legend_.set_loc('upper right')
g.set_xlabel('')
g.set_ylabel('Standardized\nNHSN admissions')
g.set_title('State Level')
ax[0, 0].set_ylim([-0.3, 0.75])
ax[0, 0].yaxis.label.set_size(11)
ax[0, 0].tick_params(labelbottom=False)
ax[0, 0].grid('on', linestyle='-', color='lightgrey')
ax[0, 0].spines['right'].set_color('lightgrey')
ax[0, 0].spines['top'].set_color('lightgrey')


g = sns.lineplot(data=hhs_to_plot_high,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='pop',
             palette=cmap,
             hue_norm=norm,
             legend=False,
             estimator=None,
             ci=None,
             ax=ax[0, 1])

legend_pop_vals = [1e6, 5e6, 1e7, 5e7, 1e8]
legend_pop_labels = ['1e6', '5e6', '1e7', '5e7', '1e8']
legend_lines = [Line2D([], [], color=cmap(norm(pop)), label=lbl) \
                    for pop, lbl in zip(legend_pop_vals, legend_pop_labels)]
ax[0, 1].legend(handles=legend_lines, title='population', loc='center right')
g.set_xlabel('')
g.set_ylabel('')
g.set_title('National/Regional Level')
ax[0, 1].set_ylim([-0.3, 0.75])
ax[0, 1].yaxis.label.set_size(11)
ax[0, 1].tick_params(labelbottom=False, labelleft=False)
ax[0, 1].grid('on', linestyle='-', color='lightgrey')
ax[0, 1].spines['right'].set_color('lightgrey')
ax[0, 1].spines['top'].set_color('lightgrey')



flusurv_to_plot = combined_dat \
    .loc[(combined_dat['source'] == 'flusurvnet') & (combined_dat['season_week'] >= 10) & (combined_dat['season_week'] <= 40)] \
    .assign(season_loc = lambda x: x['season'] + '_' + x['location'])
flusurv_to_plot_low = flusurv_to_plot.query('agg_level == "state"')
flusurv_to_plot_high = flusurv_to_plot.query('agg_level != "state"')

g = sns.lineplot(data=flusurv_to_plot_low,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='pop',
             palette=cmap,
             hue_norm=norm,
             legend=False,
             estimator=None,
             ci=None,
             ax=ax[1, 0])
# g.legend_.remove()
g.set_xlabel('')
g.set_ylabel('Standardized\nFluSurv rate')
ax[1, 0].set_ylim([-0.4, 0.75])
ax[1, 0].yaxis.label.set_size(11)
ax[1, 0].tick_params(labelbottom=False)
ax[1, 0].grid('on', linestyle='-', color='lightgrey')
ax[1, 0].spines['right'].set_color('lightgrey')
ax[1, 0].spines['top'].set_color('lightgrey')

g = sns.lineplot(data=flusurv_to_plot_high,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='pop',
             palette=cmap,
             hue_norm=norm,
             legend=False,
             estimator=None,
             ci=None,
             ax=ax[1, 1])
# g.legend_.remove()
g.set_xlabel('')
g.set_ylabel('')
ax[1, 1].set_ylim([-0.4, 0.75])
ax[1, 1].yaxis.label.set_size(11)
ax[1, 1].tick_params(labelbottom=False, labelleft=False)
ax[1, 1].grid('on', linestyle='-', color='lightgrey')
ax[1, 1].spines['right'].set_color('lightgrey')
ax[1, 1].spines['top'].set_color('lightgrey')


ili_to_plot = combined_dat \
    .loc[(combined_dat['source'] == 'ilinet') & (combined_dat['season_week'] >= 10) & (combined_dat['season_week'] <= 40)] \
    .assign(season_loc = lambda x: x['season'] + '_' + x['location'])
ili_to_plot_low = ili_to_plot.query('agg_level == "state"')
ili_to_plot_high = ili_to_plot.query('agg_level != "state"')

g = sns.lineplot(data=ili_to_plot_low,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='pop',
             palette=cmap,
             hue_norm=norm,
             legend=False,
             estimator=None,
             ci=None,
             ax=ax[2, 0])
# g.legend_.remove()
g.set_xlabel('Week of Season')
g.set_ylabel('Standardized\nILI+')
ax[2, 0].set_ylim([-0.4, 1])
ax[2, 0].yaxis.label.set_size(11)
# ax[1].set_title('ILI+', pad=0)
ax[2, 0].grid('on', linestyle='-', color='lightgrey')
ax[2, 0].spines['right'].set_color('lightgrey')
ax[2, 0].spines['top'].set_color('lightgrey')

g = sns.lineplot(data=ili_to_plot_high,
             x='season_week',
             y='inc_trans_cs',
             units='season_loc',
             hue='pop',
             palette=cmap,
             hue_norm=norm,
             legend=False,
             estimator=None,
             ci=None,
             ax=ax[2, 1])
# g.legend_.remove()
g.set_xlabel('Week of Season')
g.set_ylabel('')
ax[2, 1].set_ylim([-0.4, 1])
ax[2, 1].yaxis.label.set_size(11)
# ax[1].set_title('ILI+', pad=0)
ax[2, 1].tick_params(labelleft=False)
ax[2, 1].grid('on', linestyle='-', color='lightgrey')
ax[2, 1].spines['right'].set_color('lightgrey')
ax[2, 1].spines['top'].set_color('lightgrey')

fig.align_ylabels(ax[:, 0])

# save to pdf
fig.savefig('artifacts/figures/data_standardized.pdf',
            format = 'pdf')
