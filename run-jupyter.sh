#!/bin/bash

jupyter-notebook \
  --allow-root \
  --ip=0.0.0.0 \
  --config=${WORKDIR}/jupyter_notebook_config.py \
  --notebook-dir=/work \
  --NotebookApp.iopub_data_rate_limit=10000000 \
  --NotebookApp.token=""
