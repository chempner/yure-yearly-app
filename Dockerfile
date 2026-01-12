FROM nginx:alpine

# Install curl and fcgiwrap for CGI support
RUN apk add --no-cache curl fcgiwrap spawn-fcgi

# Copy the fetch script
COPY fetch-calendars.sh /usr/local/bin/fetch-calendars.sh
RUN chmod +x /usr/local/bin/fetch-calendars.sh

# Create CGI script for manual refresh
RUN mkdir -p /usr/share/nginx/cgi-bin && \
    echo '#!/bin/sh' > /usr/share/nginx/cgi-bin/refresh.cgi && \
    echo 'echo "Content-Type: application/json"' >> /usr/share/nginx/cgi-bin/refresh.cgi && \
    echo 'echo ""' >> /usr/share/nginx/cgi-bin/refresh.cgi && \
    echo '/usr/local/bin/fetch-calendars.sh > /dev/null 2>&1' >> /usr/share/nginx/cgi-bin/refresh.cgi && \
    echo 'cat /usr/share/nginx/html/data/status.json' >> /usr/share/nginx/cgi-bin/refresh.cgi && \
    chmod +x /usr/share/nginx/cgi-bin/refresh.cgi

# Copy the web app
COPY index.html /usr/share/nginx/html/index.html

# Create data directory
RUN mkdir -p /usr/share/nginx/html/data

# Nginx config with CGI support
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 80;' >> /etc/nginx/conf.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location /cgi-bin/ {' >> /etc/nginx/conf.d/default.conf && \
    echo '        gzip off;' >> /etc/nginx/conf.d/default.conf && \
    echo '        fastcgi_pass unix:/var/run/fcgiwrap.socket;' >> /etc/nginx/conf.d/default.conf && \
    echo '        include fastcgi_params;' >> /etc/nginx/conf.d/default.conf && \
    echo '        fastcgi_param SCRIPT_FILENAME /usr/share/nginx/cgi-bin/$fastcgi_script_name;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

# Add cron job to fetch calendars every 30 minutes
RUN echo "*/30 * * * * /usr/local/bin/fetch-calendars.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo '/usr/local/bin/fetch-calendars.sh' >> /start.sh && \
    echo 'spawn-fcgi -s /var/run/fcgiwrap.socket -u nginx -g nginx /usr/bin/fcgiwrap' >> /start.sh && \
    echo 'chmod 777 /var/run/fcgiwrap.socket' >> /start.sh && \
    echo 'crond' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
