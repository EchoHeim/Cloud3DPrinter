
#!/bin/bash

# Clear /home/pi/control/logs files after 1 week
find /home/pi/control/logs -mtime +6 -type f -delete


# Clear journalctl logs after 1 week
journalctl --rotate
journalctl --vacuum-time=1w
