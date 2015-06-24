FROM ubuntu:latest

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y postfix libsasl2-modules spamassassin spamc && \
    groupadd spamd && \
    useradd -g spamd -s /bin/false -d /var/lib/spamassassin spamd && \
    mkdir /var/log/spamassassin && \
    chown spamd:spamd /var/lib/spamassassin

COPY etc/ /etc
COPY entrypoint.sh /

# Update Spamassassin rule
RUN sa-update && mkdir -p /var/spool/postfix/spamassassin && touch /var/log/mail.log

# Main postfix configuration
RUN postconf -e 'mydestination = localhost' && \
    postconf -e 'smtpd_banner = $myhostname ESMTP' && \
    postconf -e 'smtpd_helo_required = yes' && \
    postconf -e 'smtpd_sender_restrictions = reject_unknown_sender_domain, reject_sender_login_mismatch' && \
    postconf -e 'smtpd_sender_login_maps = $virtual_mailbox_maps' && \
    postconf -e 'unknown_address_reject_code = 550' && \
    postconf -e 'unknown_hostname_reject_code = 550' && \
    postconf -e 'unknown_client_reject_code = 550' && \
    postconf -e 'smtpd_tls_ask_ccert = yes' && \
    postconf -e 'smtpd_tls_CAfile = /etc/ssl/certs/ca-certificates.crt' && \
    postconf -e 'smtpd_tls_ciphers = high' && \
    postconf -e 'smtpd_tls_loglevel = 1' && \
    postconf -e 'smtpd_tls_security_level = may' && \
    postconf -e 'smtpd_tls_session_cache_timeout = 3600s' && \
    postconf -e 'message_size_limit = 30720000'

VOLUME ["/var/mail", "/var/lib/spamassassin", "/var/log"]

EXPOSE 25 143 993 587

CMD ["/entrypoint.sh"]
    

