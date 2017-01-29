Orchestrate
===========

### Overview
Orchestrate is a small shell script that handles all aspects of building and deploying universal Opine applications. An Opine application is an oppinionated PHP application that renders React on the front and backend.

### Installation
Orchestrate resides in a folder adjacent to the project it manages. The directory tree should look like this:

```sh
- project-name/
-- app/
-- orchestrator/
```
You can create this structure by:
```sh
mkdir MyProject
cd MyProject
git --git-dir=/dev/null clone git@github.com:ryan-mahoney/universal-react-php-app.git app
git --git-dir=/dev/null clone --depth=1 git@github.com:ryan-mahoney/orchestrate.git
```
### Commands
**Building**
*compose-backend [command]:* run php compose.
*build-backend [command]:* build cached aspects of Opine PHP project.
*build-frontend:* run webpack in foreground.

**Setup**
*init-local:* setup up orchestrator configuration directory.
*id-make [env]:* make an identity for accessing remote server.
*id-public [env]:* show public key.
*htpasswd:* set the password used by nginx for securing parts of site.
*set-remote-addr env ip:* set the remote IP address for an environment.
*init-remote [env]:* setup docker and orchestrator on a fresh remote cloud server.

**Deployment**
*deploy [env]:* deploy the application to an environment.
*versions:* show all historical deployments.
*current:* show the current deployment ID number.
