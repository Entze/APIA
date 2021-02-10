FROM jupyter/minimal-notebook
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        gringo \
        clasp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER jovyan
