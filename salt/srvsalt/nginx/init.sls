apache2-utils:
  pkg.installed

nginx:
  pkg.installed
    
/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default_nossl
    - template: jinja
    - context:
##    server_ip: {{salt['network.interface_ip']('eno1')}} 
      server_ip: pillar.get('server_ip','')
      nginx_port: pillar.get('nginx_port','80')
      kibana_ip: pillar.get('kibana_ip','localhost')
      kibana_port: pillar.get('kibana_port','5601')

nginx.service:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/sites-available/default
