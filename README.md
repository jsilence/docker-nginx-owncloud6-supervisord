# docker-nginx-owncloud6-superviserord


A Dockerfile for running Owncloud 6 on nginx in a docker instance maintained by supervisord.

This installation builds upon the said to be stable an reliable stackbrew image of Ubuntu 13.10. 

## Installation

You might want to check the Owncloud website for a current version of owncloud and edit the Dockerfile accordingly.

```
$ git clone https://github.com/jsilence/docker-nginx-owncloud6-supervisord.git
$ cd docker-nginx-owncloud6-supervisord
```

For simplicity the sqlite3 backend is used. For using MySQL or MariaDB edit the Dockerfile to include the appropriate php-mysql package.

It is recommended to use Owncloud over https, so you'll have to provide a valid ssl certificate. You can either generate a self signed certificate, buy one at your favourite CA or get one for free at StartSSL. Remember that you need to remove the password from the key and that you'll have to concatenate the ca.pem and the intermediate certificate together with the certificate of your site into a joined certificate file for nginx. If you run into problems with nginx not accepting the certificate and check for the correct line endings between these three certificates.

In the end you need to have ssl.key and ssl.crt in this directory for the next step.

Create the container like this:

```bash
$ sudo docker build -t="nginx-owncloud" .
```

## Usage

To spawn a new instance of Owncloud:

```bash
$ sudo docker run -p 443 -d nginx-owncloud
```

You can the visit the following URL in a browser on your host machine to get started:

```
https://127.0.0.1/
```


### Injecting a directory outside of the container for the data

It does make sense to keep all the files and user data outside of the container for easier backup and for separating service from content.

When /mnt/storage/owncloud-data is the place outside the container where you'd like to store the files, run the container like this:

```bash
$ sudo docker run -p 443 -d -v /mnt/storage/owncloud-data:/var/www/owncloud/data  nginx-owncloud
```


### Redirecting traffic with an nginx proxy

If you have several different dockerized services running on your machine it might make sense to access them through an nginx proxy which redirects http on port 80 to https and then forwards the requests to the appropriate container.

You'd then run the owncloud container on a different port, listening to localhost only:

```bash
$ sudo docker run -p 127.0.0.1:8080:8080 -d nginx-owncloud
```

A sample nginx configuration for directing the traffic to the right container might look like this:

```
# redirecting http to https
server {
        listen 80;
        server_name owncloud.example.com;
        return 301 https://$server_name$request_uri;  # enforce https
}

server {
       listen 443 ssl;
       server_name owncloud.example.com;

       ssl_certificate /etc/nginx/StartSSL/ssl.crt;
       ssl_certificate_key /etc/nginx/StartSSL/ssl.key;

        # Proxying the connections connections
       location / {
            proxy_pass         https://localhost:8080;  # redirect to the port that you are using for the owncloud docker container
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
        }
}
```

