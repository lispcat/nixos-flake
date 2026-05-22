FROM ghcr.io/fletchto99/nicotine-plus-docker:latest

USER root

RUN apt-get update && apt-get install -y \
    librsvg2-common \
    && rm -rf /var/lib/apt/lists/*
