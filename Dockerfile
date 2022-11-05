
# (step 1/15)
FROM node:16-alpine

# Mettre la dernière version de N8N(step 2/15)
ARG N8N_VERSION=0.199.0

# Vérifie si il existe une version de N8N dans le fichier actuel(step 3/15)
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

# Mise à jour et installation de toute les dépendance nécessaires (step 4/15)
RUN apk add --update graphicsmagick tzdata git tini su-exec

# # Mettre un autre nom que root (c'est un identifiant) (step 5/15)
USER root

# Installation de n8n et des package temporaires
# C'est nécessaire pour que cela s'installe correctement. (step 6/15)
ENV NODE_ENV=production
RUN npm install n8n -g

# Installs latest Chromium (100) package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ttf-freefont \
      yarn

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
#ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true 
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install n8n-nodes-puppeteer
RUN cd /usr/local/lib/node_modules/n8n && npm install n8n-nodes-puppeteer

# Install fonts
RUN apk --no-cache add --virtual fonts msttcorefonts-installer fontconfig && \
	update-ms-fonts && \
	fc-cache -f && \
	apk del fonts && \
	find  /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \; \
	&& rm -rf /root /tmp/* /var/cache/apk/* && mkdir /root

ENV NODE_ICU_DATA /usr/local/lib/node_modules/full-icu

WORKDIR /data

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

EXPOSE 5678/tcp
