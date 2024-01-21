---
lang: EN_US
---

# FHEM Home Automation System Container Image

## Description

[FHEM (Flexible Home Automation)](https://fhem.de)  is a Perl server for home automation. It is used to automate 
tasks in the household like switching lamps, shutters, heating, etc. and to log events like 
temperature, humidity, power consumption.

###  Attention
This image is intended for my personal use in the first place. 

If you find it usefull I am happy but I will not devide from my personal goals 
to support other people.

## Security

- fhem is runing as the fhem user in the container
- the root filesystem within the container can be mounted read-only (no updates from within fhem possible)
- image updates also update all fhem related files 
- use of *configDB* and *logDB* is mandatory

## Supported Architectures

- amd64
- arm64

## External Modules

I am using some external modules. As you can not add remote repositories at runtime I am including them 
within the image.

* https://gitea.federationhq.de/byterazor/FHEM-NTFY
* https://gitea.federationhq.de/byterazor/FHEM-NEWSISPM

## Updates

I am trying to update the image weekly as long as my private kubernetes cluster is available. So I do not promise anything and do **not** rely 
your business on this image.

## Prerequisities

A container runtime like

* docker 
* podman
* kubernetes


## Container Parameters

* `CONFIG_DATABASE_ENGINE` - which database engine to use for configDB (supported: sqlite and mysql)
* `CONFIG_DATABASE` - the database name (in case of sqlite the path to the db file)
* `CONFIG_DATABASE_USER` - the username required to login to the database server (in case of sqlite ignored)
* `CONFIG_DATABASE_PASS` - the password requried to login to the database server (in case of sqlite ignored)
* `LOG_DATABASE_ENGINE` - the database engine to use for logDB (supported: sqlite and mysql)
* `LOG_DATABASE` - the database name (in case of sqlite the path to the db file)
* `LOG_DATABASE_USER` - the username required to login to the database server (in case of sqlite ignored)
* `LOG_DATABASE_PASS` - the password requried to login to the database server (in case of sqlite ignored)


## Volumes
In case you want to use sqlite you have to mount a volume at */mnt/* within the container and use 
it as the directory for you database.
 
## Source Repository

* https://gitea.federationhq.de/Container/fhem.git

## Authors

* **Dominik Meyer** - *Initial work* 

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
