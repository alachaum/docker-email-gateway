FROM ubuntu:latest

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y postfix libsasl2-modules spamassassin spamc && \
    groupadd spamd && \
    useradd -g spamd -s /bin/false -d /var/lib/spamassassin spamd && \
    mkdir /var/log/spamassassin && \
    chown spamd:spamd /var/lib/spamassassin && \
    mkdir -p /var/spool/postfix/spamassassin && \
    touch /var/log/mail.log

COPY etc/ /etc
COPY entrypoint.sh /

# Update Spamassassin rules
RUN sa-update

VOLUME ["/var/mail", "/var/lib/spamassassin", "/var/log"]

EXPOSE 25 143 993 587

CMD ["/entrypoint.sh"]
    

