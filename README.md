# jboss-eap-6.4-docker-image
Creates a Docker image of a clean JBoss EAP 6.4 server


## Prerequisite
Create a folder called "distribution" in the same directory as this project. Put JBoss EAP installation files (jboss-eap-6.4.0.zip and any patches) in the distribution folder.

## Usage
Build the image
```
cd <path to this project>
docker build -t <name of your docker image> .
```

To run it,
```
docker run -P -it --rm --name <name of your container> <name of your docker image> bash
```

This will start an interactive bash prompt as user "jboss" inside the container. The admin console can be accessed via port 9990.
