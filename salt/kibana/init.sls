kibana:
  pkg.installed

/etc/kibana/kibana.yml:
  file.managed:
    - source: salt://kibana/kibana.yml
    - template: jinja
    - context:
      kibana_port: 5601
      server_ip: 172.28.175.21

kibana:
  service.running:
    - watch:
      - file: /etc/kibana/kibana.yml