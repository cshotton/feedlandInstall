# Using Feedland with Docker and Docker Compose
** IMPORTANT: ** This is not a tutorial on how to use Docker and Docker Compose. It's detailed instructions for users who are already familiar
with Docker to quickly get a containerized version.

This read-me file documents a specific way to run a traditional node.js app and associated tools (MySQL) as an integrated docker compose stack. 
There are many other ways to do this, but here are motivations for this method and the steps that work.

First, the goal is to minimize any changes needed to the baseline Javascript code. This forked repository only modifies `package.json` from
the original Scripting.Com distribution. It also adds some convenience scripts along with the Docker-related config files.

## Building the Docker Images
If you are building a Docker image for local use, you can use a simple command issued from the feedlandInstall folder like:
`docker build -t feedland .`

If you'd like to build for multiple architectures and push the resulting images to a Docker repository like Docker Hub or AWS ECR (or your own registry), use a command like:
`docker buildx build --push --tag $REPO/$IMAGE --platform=linux/amd64,linux/arm/v7,linux/arm64/v8 .`

Be sure to replace $REPO and $IMAGE with proper values for your repository

## Running the Feedland Image
You can run Feedland on a local Docker instance with something like:
`docker run --rm -it --name feedland -p 1452:1452 -p 1462:1462 -v ./my_config.json:/project/config.json -v ./privateFiles:/project/privateFiles feedland`

A few comments on this command line:
  * ports 1452 and 1462 need to be exposed
  * the Feedland `config.json` file is NOT included by the default Dockerfile. The assumption is that you will edit this file (or a copy, e.g., my_config.json)
  and customize it with your specific settings, credentials, etc. The first `-v` flag injects your config.json file into the running Docker image.
  * Feedland creates several private files/folders that you may want to persist in your local file system. The second `-v` flag mounts a local folder for
  Feedland to store these data files in. (note that stats.json is not saved outside of the container in this configuration.)

## Launching with Docker Compose
The Docker Compose file is intended to provide a self-contained way to get Feedland and its dependencies (MySQL) up and running with minimal effort. By using Docker Compose, you can 
easily move your configuration between machines, or start/stop Feedland and associated services without having to install or uninstall a lot of separate components in your local 
operating system.

The `docker-compose.yml` file should be modified to suit your specific configuration. In particular, you need to adjust values for MySQL, including ports (that should match your Feedland
config.json file) and credentials.

If you are using a Docker extension like Portainer to manage your compose stacks, be sure to set the environment variable for FEEDLAND_CONFIG appropriately.

## Configuring Database and New Users

On first run using Docker Compose, the MySQL database will still need to be configured. With that container running, you can use any SQL client tool to load the `setup.sql`
script from the `docs` folder, and build the necessary database and tables in MySQL. Then quit/restart the compose stack to get Feedland fully on the air.

### Feedland E-Mail Validation
Some users running a local Feedland instance may not have the ability or desire to connect Feedland with an email service. As a shortcut to getting a new user added to the system, you can
do the following:

  * Sign up for a new user, and enter a username and email address
    * Feedland will report an error sending email, but still create a new record in its `pendingConfirmations` table
  * Open the MySQL feedland database with an appropriate SQL client and find the new record in the `pendingConfirmations` table
  * Copy the `magicString` value for the new, pending user, and insert it into a URL that looks like: `http://localhost:1452/userconfirms?emailConfirmCode=MAGIC_STRING_HERE`
  * Submit that URL in your browser and enjoy!

### Credits
 Docker mods and instructions written by [Chuck Shotton](https://github.com/cshotton)