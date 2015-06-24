# Configure Postfix email relay
myhostname=${myhostname:-smtp.maestrano.io}
smtpd_helo_restrictions=${smtpd_helo_restrictions:-permit_sasl_authenticated, permit_mynetworks}
smtpd_recipient_restrictions=${smtpd_recipient_restrictions:-reject_unknown_sender_domain, reject_unknown_recipient_domain, reject_unauth_pipelining, permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination, reject_invalid_hostname, reject_non_fqdn_sender}

postconf -e "myhostname = $myhostname"
postconf -e "smtpd_helo_restrictions = $smtpd_helo_restrictions"
postconf -e "smtpd_recipient_restrictions = $smtpd_recipient_restrictions"

# Configure relay if specified
if [ -n "$RELAY" ]; then
  postconf -e "relayhost = [$RELAY]"
fi

# Configure relay SASL authentication if specified
# A RELAYKEY looks like: USERNAME:API_KEY
# E.g. setup for mandrill:
# https://mandrill.zendesk.com/hc/en-us/articles/205582187-Can-I-configure-Postfix-to-send-through-Mandrill-
if [ -n "$RELAY" ] && [ -n "$RELAYKEY" ]; then
  cat <<EOF > /etc/postfix/sasl_passwd
[$RELAY] $RELAYKEY
EOF

postmap /etc/postfix/sasl_passwd

fi

function start_all() {
    service rsyslog start
    service spamassassin start
    service postfix start
    sleep 2
    tail -f /var/log/mail.log
}

function reload_all() {
    echo "Reloading..."
    service spamassassin reload
    service postfix reload
}

function stop_all() {
    echo "Shutting down..."
    service postfix stop
    service spamassassin stop
    service rsyslog stop
}

trap stop_all EXIT
trap reload_all SIGHUP

start_all
