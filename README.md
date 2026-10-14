# notify-sh-lib

Sh notification library.

## Requirments

- `msmtp`

## Usage

```bash
source "$HOME/projects/notify-sh-lib/lib/email.sh"
email_send "boss@ya.ru" "Backup OK" "Backup completed on $(hostname)"
```