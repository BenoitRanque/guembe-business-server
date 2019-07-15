FROM node:12-alpine

# Create app directory
WORKDIR /usr/app

# set app directoy ownership to user node of group node
RUN chown -R node:node .

# change user
USER node

# build time argument to add tools for development
ARG NODE_ENV=production

# root level operations start here
USER root

# COPY always copies files as root. change owner after copy
COPY ./ssr .
RUN chown -R node:node ./*

USER node

RUN yarn install
