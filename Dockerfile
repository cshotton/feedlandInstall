# build with: 
# docker build -t feedland .
#  -or-
# docker buildx build --push --tag $REPO/$IMAGE --platform=linux/amd64,linux/arm/v7,linux/arm64/v8 .
#
# run with something like:
#   docker run --rm -it --name feedland -p 1452:1452 -p 1462:1462 -v ./my_config.json:/project/config.json -v ./privateFiles:/project/privateFiles feedland
# or edit compose.yml and run with docker compose up
FROM node:22

WORKDIR /project

COPY feedland.js /project/
COPY emailtemplate.html /project/
COPY docker_cmd.sh  /project
COPY package.json  /project
RUN cd /project \
  && npm install --yes --loglevel verbose \
  && mkdir ./privateFiles

  # Expose ports 1452 and 1462
EXPOSE 1452
EXPOSE 1462

CMD ["npm", "run", "docker_cmd"]