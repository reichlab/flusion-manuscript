all: manuscript/flusion-manuscript.pdf manuscript/flusion-supplement.pdf manuscript/epidemics-submission/sub2/flusion-manuscript-diff.tex manuscript/epidemics-submission/sub2/review-response.pdf

manuscript/epidemics-submission/sub2/review-response.pdf: manuscript/epidemics-submission/sub2/review-response.Rnw
	R -e "setwd('manuscript/epidemics-submission/sub2'); knitr::knit2pdf('review-response.Rnw', bib_engine='biber')"

manuscript/epidemics-submission/sub2/flusion-manuscript-diff.tex: manuscript/flusion-manuscript.pdf
	latexdiff manuscript/epidemics-submission/sub1/flusion-manuscript.tex manuscript/flusion-manuscript.tex > manuscript/epidemics-submission/sub2/flusion-manuscript-diff.tex

manuscript/flusion-manuscript.pdf: manuscript/flusion-manuscript.Rnw manuscript/flusion.bib code/utils.R artifacts/figures/data_overview.pdf artifacts/figures/data_standardized.pdf artifacts/figures/forecasts_flusight.pdf artifacts/figures/scores_flusight.pdf artifacts/scores/scores_by_model_flusight_all.csv artifacts/scores/scores_by_model_flusion_components.csv artifacts/scores/scores_by_model_joint_training.csv artifacts/scores/scores_by_model_flusion_data_adj.csv 
	R -e "setwd('manuscript'); knitr::knit2pdf('flusion-manuscript.Rnw', bib_engine='biber')"

manuscript/flusion-supplement.pdf: manuscript/flusion-supplement.Rnw artifacts/figures/features.pdf artifacts/figures/feature_importance.pdf artifacts/flusurv_burden_adj.csv artifacts/figures/scores_flusight_wis_by_horizon.pdf
	R -e "setwd('manuscript'); knitr::knit2pdf('flusion-supplement.Rnw', bib_engine='biber')"

clean:
	rm manuscript/flusion-manuscript.pdf manuscript/flusion-supplement.pdf artifacts/figures/*.pdf artifacts/scores/*.csv

# plot data overview
artifacts/figures/data_overview.pdf: code/plot_data.py
	python3 code/plot_data.py

# plot standardized data
artifacts/figures/data_standardized.pdf: code/plot_data_standardized.py
	python3 code/plot_data_standardized.py

# plot featurized data
artifacts/figures/features.pdf: code/plot_features.py
	python3 code/plot_features.py

# plot feature importance
artifacts/figures/feature_importance.pdf: code/plot_importance.R artifacts/target_data.csv artifacts/initial_target_data.csv 
	Rscript code/plot_importance.R

# plot forecasts
artifacts/figures/forecasts_flusight.pdf: code/plot_forecasts_flusight.R artifacts/target_data.csv artifacts/initial_target_data.csv 
	Rscript code/plot_forecasts_flusight.R

# plot scores
artifacts/figures/scores_flusight.pdf: code/plot_scores_flusight.R code/utils.R artifacts/scores/scores_by_model_horizon_flusight_all.csv artifacts/scores/scores_by_model_horizon_reference_date_flusight_all.csv artifacts/target_data.csv
	Rscript code/plot_scores_flusight.R

# plot WIS by horizon; used in supplement
artifacts/figures/scores_flusight_wis_by_horizon.pdf: code/plot_scores_flusight_wis_by_horizon.R code/utils.R artifacts/scores/scores_by_model_horizon_flusight_all.csv
	Rscript code/plot_scores_flusight_wis_by_horizon.R

# compute scores
artifacts/scores/scores_by_model_%.csv \
	artifacts/scores/scores_by_model_%_without_revisions.csv \
	artifacts/scores/scores_by_model_horizon_%.csv \
	artifacts/scores/scores_by_model_horizon_%_without_revisions.csv \
	artifacts/scores/scores_by_model_horizon_reference_date_%.csv \
	artifacts/scores/scores_by_model_horizon_reference_date_%_without_revisions.csv: \
	code/compute_scores_%.R artifacts/target_data.csv
	Rscript $<

# csv with burden adjustments for FluSurv-NET
artifacts/flusurv_burden_adj.csv: code/save_flusurv_burden_table.py
	python3 code/save_flusurv_burden_table.py
