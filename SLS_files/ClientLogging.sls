syslog-ng:
  pkg.installed
syslog-ng.conf:
  file.managed:
    - name: /etc/syslog-ng/syslog-ng.conf
    - source: salt://syslog-ng/syslog-ng.conf
    - replace: true
service syslog-ng restart:
  cmd.run
