###############################################################################
# BASE
###############################################################################
FROM node:12 as base

# Install latest chrome dev package for headless chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /src/*.deb

# Set the work directory to the app folder within the node user's home directory
WORKDIR /home/node/app

# Ensure the node user owns the work directory
RUN chown -R node:node /home/node/app

# Run like CI environment
ENV CI=true

# Grab package.json and package-lock.json and install dependencies
COPY package*.json ./

# Limit privilege to the node user
USER node

# Install dependencies
RUN npm ci

# Copy application code
COPY --chown=node:node . .

###############################################################################
# TEST
###############################################################################
FROM base as test

# Pre-build a test build
RUN node_modules/.bin/ember build -e test -o test-build

# Use `ember exam` command as entrypoint, with the test-build as build
ENTRYPOINT ["node_modules/.bin/ember", "exam", "--path=test-build"]

# Set a default command
CMD ["--split=4",  "--parallel=1", "--random"]


###############################################################################
# PRODUCTION BUILD
###############################################################################
FROM base as prodbuild

# Pre-build a production build
RUN node_modules/.bin/ember build -e production

###############################################################################
# PRODUCTION SERVER
###############################################################################
FROM node:12-alpine as production

# Set the work directory to the app folder within the node user's home directory
# Switch to node user and ensure the node user owns the files
WORKDIR /home/node/app
RUN chown -R node:node /home/node/app
USER node

# Copy server package.json files
COPY --chown=node:node ./server/package*.json ./
RUN npm ci

# Copy server script
COPY --chown=node:node ./server/index.js ./

# Copy static files
COPY --from=prodbuild --chown=node:node /home/node/app/dist/ /home/node/app/dist/

CMD node index.js
