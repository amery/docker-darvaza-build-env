sed -i "s;^\($USER_NAME:.*\):/bin/sh\$;\1:/bin/bash;p" /etc/passwd
