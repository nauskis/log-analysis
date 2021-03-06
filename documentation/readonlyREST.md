# Limiting access to Elasticsearch with login and password with [readonlyREST](https://readonlyrest.com/download/) module.

I found and old post written by my teacher, [Tero Karvinen](http://terokarvinen.com/2016/elasticsearch-password-authentication-with-free-software) and I will be using it as my primary source as I setup my Elasticsearch with additional security.

Firstly, I went through my usual [setup](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/Installations.md) for updates, Java and Elasticsearch installation.

Next, I enabled firewall, because by default, Elasticsearch has no security.  
`sudo ufw enable`

After enabling firewall, I made few changes to the *Elasticsearch.yml* file. I Uncommented and replaced lines regarding IP address and http port. Making changes into the configuration also requires a restart.  
`sudo service elasticsearch restart`

Next, I wanted to know if Elasticsearch is running properly so I used *Curl* to find out. I had to install it first though.  
```  
sudo apt-get install -y curl  
curl localhost:9200  
```  
![kuva1](https://i.imgur.com/gkdoI18.png)  

Next, I need to install the *readonlyREST* plugin. Tero's command didn't work for me, and even if it did, it would still have outdated version. So, lets find out which version we need.  
In readonlyREST [download page](https://readonlyrest.com/download/) you need to fill out the wanted product (elasticsearch plugin), elasticsearch version and your email address, to which the site will send a download link for the plugin. This was kinda off putting, but I didn't find an easy alternative so lets just go with it. Our elasticsearch version is currently 6.4.2 (We found this out in the previous step where we curled the localhost port 9200).  

I opened downloaded the zip file from the link sent to my email and followed the steps in the email to some degree.  
![kuva3](https://i.imgur.com/QLC01pK.png)  

First, I moved to my download folder and ran the command  
`/absolute/path/elasticsearch-plugin install file:///absolute/path/readonlyrest-1.16.28_es6.4.2.zip`  

This seemed to work properly. However, a question about permissions rose up, because this is the exact same looking thing that crashed my ElasticSearch when I tried to install SearchGuard.
![kuva2](https://i.imgur.com/EZPLz4O.png)

The plugin can be removed with:  
`sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove readonlyrest`

~~Now, according to Tero's post, we should add *readonlyREST* configuration into the *elasticsearch.yml*.~~
This is outdated, and doesn't work in newer versions (from 6.1 onwards if I'm not mistaken). Instead of adding the configuration into the *elasticsearch.yml* file, you should create a new file called *readonlyrest.yml* to the same folder and add the configuration there.  
```
readonlyrest:
 enable: true
 response_if_req_forbidden: Sorry, your request is forbidden.
 access_control_rules:
 - name: Full access with HTTP auth
   auth_key: yourpassword
   type: allow
```

Opensource ElasticSearch (without x-pack and some other plugins which we currently have no use for anyway):  
https://www.elastic.co/downloads/elasticsearch-oss  
I still have no idea how to get the oss version of elasticsearch with apt-get installation. I'll look into it later.

### I got the plugin running for the first time! Here are my steps so far: ###  
**1) Installing java**  
```
sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk
```
**2) Installing Elasticsearch**  
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update
sudo apt-get install elasticsearch
```
**3) Installing readonlyREST**  
By curling localhost:9200 to see if elasticsearch is running, you also find out the version you installed. Mine is 6.4.2.  
Next, I got the download link from [readonlyREST web page](https://readonlyrest.com/download/).

**UPDATED**  
As stated earlier in the post, you can now download the installation file from our github [downloads folder](https://github.com/jisosomppi/log-analysis/blob/master/downloads/readonlyrest-1.16.28_es6.4.2.zip) if you don't wish to get an email link.  
`wget https://github.com/jisosomppi/log-analysis/raw/master/downloads/readonlyrest-1.16.28_es6.4.2.zip`  
should also work.

After I downloaded the plugin zip, I installed it using abosute paths:  
`sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install file:///home/xubuntu/Downloads/readonlyrest-1.16.28_es6.4.2.zip`

**4) Setting up readonlyrest.yml to /etc/elasticsearch**
Previously, I tried to run elasticsearch after installing the plugin and received a lot of errors. Not one installation guide told me to actually create the configuration file before starting the program. If I understood correctly, since ElasticSearch version 6.1 you have to create *readonlyrest.yml* instead of putting the configurations into *elasticsearch.yml*.

I found and example of *readonlyrest.yml* from https://mpolinowski.github.io/securing-elasticsearch-readonlyrest/. This link seems to have some strange syntax, so I used Tero's post as a base.  
```
sudo nano /etc/elasticsearch/readonlyrest.yml


readonlyrest:
  enable: true
  response_if_req_forbidden: Access denied.
  access_control_rules:
  - name: Full access with HTTP auth
    auth_key: user:pass
    type: allow
```
In this case the username used to log in is user, and password is pass.

This is where I ran into another problem. `sudo service elasticsearch restart` and `sudo service elasticsearch status` tell me that the service is active and running, but nothing is actually running in port 9200 and the service hasn't properly started.

I tried to remove the plugin and see if elasticsearch runs without it. It did. I am currently unsure what causes this mess.

Found solution from https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md.
I had a feeling that x-pack and readonlyREST cannot run simultaneously, but x-pack wasn't listed in active plugins and I didn't really think it would have be the cause of my headache.

The solution was to add the following line into *elasticsearch.yml* configuration file:  
`xpack.security.enabled: false`  

![it-works](https://i.imgur.com/6X6I62A.png)




  error_log   /var/log/nginx/kibana.error.log;
  access_log  /var/log/nginx/kibana.access.log;

}

server {

    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;

 location / {
    rewrite ^/(.*) /$1 break;
    proxy_ignore_client_abort on;
    proxy_pass http://localhost:5601;
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  Host $http_host;
  }
}

```

**Enable changes in Nginx**

`sudo nginx -t`  
If configuration is a OK, restart the service:  
`sudo service nginx restart`

Test encryption by visiting your IP --> `https://your_IP`

When signing your own certificate, it is normal, that your browser warns you about the connection not being secure. I'm not sure how you can add the exception when using Chrome, but it's fairly easy on Firefox.


Sources:  
https://www.digitalocean.com/community/tutorials/how-to-set-up-let-s-encrypt-with-nginx-server-blocks-on-ubuntu-16-04 (This tutorial requires a dns server)    
https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04 (server blocks)  
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04 (Self-signing certs)  

