```bash
docker run -it \
    -v ./artifacts:/flusion-manuscript/artifacts \
    -v ./manuscript:/flusion-manuscript/manuscript \
    -v ./code:/flusion-manuscript/code \
    -v ./talks:/flusion-manuscript/talks \
    flusionmanu bash

Rscript talks/20240806_JSM_ELR_flusion/code/plot_forecasts_flusight.R
python3 talks/20240806_JSM_ELR_flusion/code/plot_hhs_national.py
python3 talks/20240806_JSM_ELR_flusion/code/plot_data.py
```
