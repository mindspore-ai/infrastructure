FROM alpine
MAINTAINER freesky-edward <freesky-edward@gmail.com>

ENV NICK "openeuler-ci-bot"
ENV IDENT "openeuler-ci-bot"
ENV USERNAME "openeuler-ci-bot"
ENV IRC_PASSWORD ""
ENV IRC_SERVERS "irc.freenode.net:6667"
ENV IRC_CHANNELS "#openeuler-meeting"
ENV IRC_CHANNELS_KEYS ""
ENV IRC_SERVER_SSL "False"
ENV URL_INFO "https://openeuler.org/en/meetings.html"
ENV LOG_URL_PREFIX "https://meetings.openeuler.org/"
ENV LOG_DIR "/data/public_html/"
ENV LOG_PATTERN "%(meetingname)s/%%Y/%(meetingname)s.%%F-%%H.%%M"

ENV APPLICATION_ROOT /app/

RUN apk update && apk add python openssl
RUN adduser meetbot -s /bin/sh -h ${APPLICATION_ROOT} -D

RUN wget -O /bin/gosu https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64
RUN chmod +x /bin/gosu

RUN wget http://downloads.sourceforge.net/project/supybot/supybot/Supybot-0.83.4.1/Supybot-0.83.4.1.zip
RUN wget https://opendev.org/opendev/meetbot/archive/master.zip
RUN unzip Supybot-0.83.4.1.zip
RUN unzip master.zip
RUN mv meetbot/ircmeeting meetbot/MeetBot/
RUN cd Supybot-0.83.4.1/ && python setup.py install
RUN mv meetbot/MeetBot /usr/lib/python2.7/site-packages/supybot/plugins/
RUN rm -rf /root/meetbot && rm -rf /root/Supybot-0.83.4.1

WORKDIR ${APPLICATION_ROOT}
COPY conf ${APPLICATION_ROOT}/conf

COPY entrypoint.sh ${APPLICATION_ROOT}
RUN chmod +x ${APPLICATION_ROOT}/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["/bin/gosu", "meetbot", "supybot", "/app/conf/meetbot.conf"]
