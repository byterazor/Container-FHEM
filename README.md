# FHEM Home Automation System Container

This repository contains the source code to build a container image for running the FHEM home automation system using Buildah.

## Introduction

FHEM (Flexible Home Automation) is a Perl server for home automation. It is used to automate tasks in the household like switching lamps, shutters, heating, etc. and to log events like temperature, humidity, power consumption.

## Building the Container

To build the container image, we will use Buildah, a tool that facilitates building OCI container images.

```bash
buildah bud -t fhem .
```

This command builds the container image using the Containerfile in the current directory and tags the image as `fhem`.

## Running the Container

Once the image is built, you can run the FHEM container with the following command:

```bash
podman run -d -p 8083:8083 fhem
```

This command runs the container in the background, mapping port 8083 in the container to port 8083 on the host machine.

## Accessing FHEM

Once the container is running, you can access the FHEM web interface by navigating to `http://localhost:8083/fhem` in your web browser.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
