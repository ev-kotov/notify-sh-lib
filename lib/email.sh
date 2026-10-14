#!/usr/bin/env bash

if [ -n "${EMAIL_LOADED:-}" ]; then
    return 0
fi
EMAIL_LOADED=1

_NOTIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$_NOTIFY_DIR/email.env" ]; then
    echo "email.sh: not found $_NOTIFY_DIR/email.env" >&2
    return 1
fi

source "$_NOTIFY_DIR/email.env"

if [ -z "${EMAIL_SMTP_USER:-}" ]; then
    echo "email.sh: EMAIL_SMTP_USER is not set in email.env" >&2
    return 1
fi


# email_send <to> <subject> <body>
email_send() {
    local to="$1"
    local subject="$2"
    local body="${3:-}"

    if [ -z "$to" ] || [ -z "$subject" ]; then
        echo "Usage: email_send <to> <subject> <body>" >&2
        return 1
    fi

    # Headers via printf (no \n interpretation in args).
    # Body via echo -e (so \n in the text becomes real line breaks).
    {
        printf 'Content-Type: text/plain; charset=utf-8\n'
        printf 'Subject: %s\n' "$subject"
        printf 'From: %s\n' "$EMAIL_SMTP_USER"
        printf 'To: %s\n' "$to"
        echo
        echo -e "$body"
    } | msmtp \
            --host="$EMAIL_SMTP_HOST" \
            --port="$EMAIL_SMTP_PORT" \
            --auth=on \
            --tls=on \
            --tls-starttls=off \
            --user="$EMAIL_SMTP_USER" \
            --passwordeval="echo '$EMAIL_SMTP_PASS'" \
            --from="$EMAIL_SMTP_USER" \
            -- "$to"
}