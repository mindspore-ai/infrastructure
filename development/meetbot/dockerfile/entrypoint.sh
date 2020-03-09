#!/bin/sh
set -e
set -x
chown meetbot:meetbot -R /logs
chown meetbot:meetbot -R /data
chown meetbot:meetbot -R /app

set_config() {
    escaped=$(echo "$2" | sed 's/\//\\\//g' | sed 's/\ /\\\ /g')
    /bin/gosu meetbot \
        sed -i "s/$1:.*$/$1:\ $escaped/g" conf/meetbot.conf
}

set_config supybot.nick "${NICK}"
set_config supybot.ident "${IDENT}"
set_config supybot.user "${USERNAME}"
set_config supybot.networks.network.password "${IRC_PASSWORD}"
set_config supybot.networks.network.servers "${IRC_SERVERS}"
set_config supybot.networks.network.channels "${IRC_CHANNELS}"
set_config supybot.networks.network.channels.key "${IRC_CHANNELS_KEYS}"
set_config supybot.networks.network.ssl "${IRC_SERVER_SSL}"
set_config supybot.plugins.MeetBot.MeetBotInfoURL "${URL_INFO}"
set_config supybot.plugins.MeetBot.filenamePattern "${LOG_PATTERN}"
set_config supybot.plugins.MeetBot.logFileDir "${LOG_DIR}"
set_config supybot.plugins.MeetBot.logUrlPrefix "${LOG_URL_PREFIX}"

exec "$@"
