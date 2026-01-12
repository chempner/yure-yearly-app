FROM nginx:alpine

# Install curl for fetching calendars
RUN apk add --no-cache curl

# Copy the fetch script
COPY fetch-calendars.sh /usr/local/bin/fetch-calendars.sh
RUN chmod +x /usr/local/bin/fetch-calendars.sh

# Copy the web app
COPY index.html /usr/share/nginx/html/index.html

# Create data directory
RUN mkdir -p /usr/share/nginx/html/data

# Add cron job to fetch calendars every 30 minutes
RUN echo "*/30 * * * * /usr/local/bin/fetch-calendars.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo '/usr/local/bin/fetch-calendars.sh' >> /start.sh && \
    echo 'crond' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
