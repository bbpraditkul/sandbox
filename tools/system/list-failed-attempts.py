#!/usr/bin/env python
import re
import os
from collections import defaultdict

"""
The following script is a quick hack to review the secure log and roughly summarize:
    1) failed logins
    2) origins
    3) date/time
"""
file_name = '/var/log/secure'

os.system('uname -a')

all_failed_users = defaultdict(list)

for log_line in open(file_name):
    m = re.search('^(\S+\s\d{2}\s\d{2}:\d{2}:\d{2}).*Failed password.*user\s+(\S+)\sfrom\s(\d+\.\d+\.\d+\.\d+).*', log_line)
    if m:
        all_failed_users[m.group(2) + ' ' + m.group(3)].append(m.group(1))

print "%30s %6s %s" % ("USER", "FAILS", "DATE")
for key, value in all_failed_users.items():
    print "%30s %6d %s" % (key, len(value), value)
