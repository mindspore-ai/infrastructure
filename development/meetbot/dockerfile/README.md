# docker-meetbot

This is based on edacore-infra's meetbot docker definition: https://github.com/edacore-infra/docker-meetbot.

This is a docker container to get [meetbot](https://wiki.debian.org/MeetBot) running and only needing your specific configurations.

## Installation

Pull the latest version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future.

```
docker pull swr.cn-north-1.myhuaweicloud.com/openeuler/meetbot:v0.0.2
```

## Quick Start

Run the image

```
docker run --name="meetbot-running" -d -p 80:80/tcp \
   --env-file ./openeuler.env \
   -v /data:/data -v /var/log:/logs meetbot:v0.0.2
```

It has  a `meetbot.conf` in the repo that'll connect to freenode

When you are ready for this bot to connect and you start using it i suggest
you pull down the main [meetbot](https://wiki.debian.org/MeetBot) code, and
run the _Configuring SupyBot_ section. Grab the files that are outputted, copy
them into the directory you want to use as your `/conf` directory and rename the
_<your_bot_name.conf>_ to `meetbot.conf`

You should see your bot in the IRC channel of your choosing in a few seconds.
