from data_pipeline.loader import FluDataLoader
import matplotlib as mpl
import matplotlib.pyplot as plt
import datetime

# load data
fdl = FluDataLoader('../flusion/data-raw')

hhs = fdl.load_hhs(rates=False, drop_pandemic_seasons=False) \
  .query('agg_level == "national"')

flusurv_adj = fdl.load_flusurv_rates()
flusurv_unadj = fdl.load_flusurv_rates(burden_adj = False)

ilinet_adj = fdl.load_ilinet(scale_to_positive=True, drop_pandemic_seasons=False)
ilinet_unadj = fdl.load_ilinet(scale_to_positive=False, drop_pandemic_seasons=False)

# make plot
fig, ax = plt.subplots(nrows=3, ncols=1, figsize=[8,5], sharex=True)

# plot nhsn/hhs
ax[0].plot(
  'wk_end_date',
  'inc',
  data = hhs)
ax[0].set_ylabel('NHSN')

# plot flusurvnet
loc = 'Entire Network'
ax[1].plot(
    'wk_end_date',
    'inc',
    data = flusurv_adj.query(f'location == "{loc}"'),
    label = 'Adjusted')
ax[1].plot(
    'wk_end_date',
    'inc',
    data = flusurv_unadj.query(f'location == "{loc}"'),
    linestyle = '--',
    label = 'Unadjusted')
ax[1].set_ylabel('FluSurv-NET')

# plot ilinet
loc = 'National'
ax[2].plot(
    'wk_end_date',
    'inc',
    data = ilinet_adj.query(f'location == "{loc}"'),
    label = 'Adjusted')
ax[2].plot(
    'wk_end_date',
    'inc',
    data = ilinet_unadj.query(f'location == "{loc}"'),
    linestyle = '--',
    label = 'Unadjusted')
ax[2].set_ylabel('ILINet')

# shade pandemic seasons
for i in range(3):
    ax[i].axvspan(datetime.date.fromisoformat('2020-06-01'),
                  datetime.date.fromisoformat('2022-09-01'),
                  facecolor='0.2', alpha=0.3)

ax[2].axvspan(datetime.date.fromisoformat('2008-06-01'),
              datetime.date.fromisoformat('2010-09-01'),
              facecolor='0.2', alpha=0.3)


# horizontal axis label
fig.text(0.5, 0.02, 'Date', ha='center', va='center', size=14)

# misc adjustments to alignment, fonts, axes
plt.subplots_adjust(bottom=0.1, left=0.11, top=0.95, right=0.99, hspace=0.2)
fig.align_ylabels(ax)

for i in range(3):
    ax[i].yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.0f}'))
    ax[i].yaxis.label.set_size(11)
    ax[i].grid('on', linestyle='-', color='lightgrey')
    ax[i].spines['right'].set_color('lightgrey')
    ax[i].spines['top'].set_color('lightgrey')

# save to pdf
fig.savefig('artifacts/figures/data_overview.pdf',
            format = 'pdf')
