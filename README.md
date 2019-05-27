# Example Dockerized Ember application

## Running development servers

The following will start up the development and test server and will watch live
for changes:
```sh
docker-compose up
```

## Tests

First build the test build to prepare for testing:
```sh
docker build --target test -t example-app-test
```

Then you can run your tests by running the container:
```sh
docker run example-app-test
```

It's running `ember exam` behind the scenes, so you can split your tests across
multiple nodes:
```sh
docker run example-app-test --split=4 --partition=1 --parrallel=1 --random
docker run example-app-test --split=4 --partition=2 --parrallel=1 --random
docker run example-app-test --split=4 --partition=3 --parrallel=1 --random
docker run example-app-test --split=4 --partition=4 --parrallel=1 --random
```

## Production server

This creates a production build of the Ember application and bootstraps it into
a tiny express server in a Docker container.

First build:
```sh
docker build --target production -t example-app-production
```

Then run:
```sh
docker run --rm -p 8080:8080 example-app-build
```
