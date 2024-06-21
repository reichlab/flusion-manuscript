from data_pipeline.loader import FluDataLoader
from preprocess import create_features_and_targets
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import datetime
import fnmatch

# load data
fdl = FluDataLoader('../flusion/data-raw')

df = fdl.load_data(
    hhs_kwargs={'as_of': datetime.date.fromisoformat('2024-05-04')},
    ilinet_kwargs=None,
    flusurvnet_kwargs=None,
    sources=['hhs'],
    power_transform='4rt'
)

df, feat_names = create_features_and_targets(
    df = df,
    incl_level_feats=True,
    max_horizon=1,
    curr_feat_names=['inc_trans_cs', 'season_week', 'log_pop']
)

# keep only rows that are in-season
df = df.query("season_week >= 5 and season_week <= 45 and location == '26'")
df = df.loc[df['wk_end_date'] >= '2023-10-01']

# make plot
unlagged_feats = [f for f in feat_names if "lag" not in f]

def get_feat_readable(f):
    if f == 'inc_trans_cs':
        f_readable = 'NHSN admissions'
    elif 'rollmean' in f:
        f_readable = 'Rolling mean, w = ' + f[-1]
    elif 'taylor_d1' in f:
        f_readable = 'Taylor poly, d = 1, w = ' + f[-8]
    elif 'taylor_d2' in f:
        f_readable = 'Taylor poly, d = 2, w = ' + f[-8]
    else:
        raise ValueError('Unexpected feature name')
    
    return f_readable


level_feats = ['inc_trans_cs'] + \
              fnmatch.filter(unlagged_feats, '*taylor_d?_c0*') + \
              fnmatch.filter(unlagged_feats, '*inc_trans_cs_rollmean*')
level_feats_readable = { f: get_feat_readable(f) for f in level_feats }

slope_feats = fnmatch.filter(unlagged_feats, '*taylor_d?_c1*')
slope_feats_readable = { f: get_feat_readable(f) for f in slope_feats }

curv_feats = fnmatch.filter(unlagged_feats, '*taylor_d?_c2*')
curv_feats_readable = { f: get_feat_readable(f) for f in curv_feats }

palette = {
    'NHSN admissions': '#000000',
    'Taylor poly, d = 2, w = 4': '#e69f00',
    'Taylor poly, d = 2, w = 6': '#56b4e9',
    'Taylor poly, d = 1, w = 3': '#009e73',
    'Taylor poly, d = 1, w = 5': '#0072b2',
    'Rolling mean, w = 2': '#d55e00',
    'Rolling mean, w = 4': '#cc79a7'
}

minor_linewidth = 1.25
linewidths = {
    'NHSN admissions': 4,
    'Taylor poly, d = 2, w = 4': minor_linewidth,
    'Taylor poly, d = 2, w = 6': minor_linewidth,
    'Taylor poly, d = 1, w = 3': minor_linewidth,
    'Taylor poly, d = 1, w = 5': minor_linewidth,
    'Rolling mean, w = 2': minor_linewidth,
    'Rolling mean, w = 4': minor_linewidth
}

linestyles = {
    'NHSN admissions': 'solid',
    'Taylor poly, d = 2, w = 4': 'solid',
    'Taylor poly, d = 2, w = 6': 'dashed',
    'Taylor poly, d = 1, w = 3': 'dashdot',
    'Taylor poly, d = 1, w = 5': 'solid',
    'Rolling mean, w = 2': 'dashed',
    'Rolling mean, w = 4': 'dashdot'
}

# plot nhsn/hhs
fig, ax = plt.subplots(nrows=3, ncols=1, figsize=[8,5], sharex=True)
for f in level_feats:
    fr = level_feats_readable[f]
    ax[0].plot(
        'wk_end_date',
        f,
        data = df,
        label = fr,
        c = palette[fr],
        linewidth = linewidths[fr],
        linestyle = linestyles[fr]
    )

for f in slope_feats:
    fr = slope_feats_readable[f]
    ax[1].plot(
        'wk_end_date',
        f,
        data = df,
        label = fr,
        c = palette[fr],
        linewidth = linewidths[fr],
        linestyle = linestyles[fr]
    )

for f in curv_feats:
    fr = curv_feats_readable[f]
    ax[2].plot(
        'wk_end_date',
        f,
        data = df,
        label = fr,
        c = palette[fr],
        linewidth = linewidths[fr],
        linestyle = linestyles[fr]
    )

# vertical axis labels
ax[0].set_ylabel('Level')
ax[1].set_ylabel('Slope')
ax[2].set_ylabel('Curvature')

# horizontal axis label
ax[2].xaxis.set_major_formatter(mdates.DateFormatter("%b %Y"))
_ = plt.xticks(rotation=30, horizontalalignment='right', rotation_mode='anchor')
fig.text(0.39, 0.02, 'Date', ha='center', va='center', size=14)

# misc adjustments to alignment, fonts, axes
plt.subplots_adjust(bottom=0.15, left=0.11, top=0.95, right=0.99, hspace=0.2)
fig.align_ylabels(ax)

for i in range(3):
    ax[i].yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter('{x:,.3f}'))
    ax[i].yaxis.label.set_size(11)
    ax[i].grid('on', linestyle='-', color='lightgrey')
    ax[i].spines['right'].set_color('lightgrey')
    ax[i].spines['top'].set_color('lightgrey')
    box = ax[i].get_position()
    ax[i].set_position([box.x0, box.y0, box.width * 0.65, box.height])
    # ax[i].legend(loc='center left', bbox_to_anchor=(1, 0.5))

ax[0].legend(loc='center left', bbox_to_anchor=(1, -0.7))

# save to pdf
fig.savefig('artifacts/figures/features.pdf',
            format = 'pdf')
