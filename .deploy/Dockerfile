
# (step 1/15)
FROM node:16-alpine

# Mettre la dernière version de N8N(step 2)
ARG N8N_VERSION=0.198.2

# Vérifie si il existe une version de N8N dans le fichier actuel(step 3)
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

# Mise à jour et installation de toute les dépendance nécessaires (step 4)
RUN apk add --update graphicsmagick tzdata git tini su-exec

# # Mettre un autre nom que root (c'est un identifiant) (step 5)
USER root

# Installation de n8n et des package temporaires
# C'est nécessaire pour que cela s'installe correctement. (step 6)
ENV NODE_ENV=production
# (step 7)
RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'armv7') apk --no-cache add --virtual build-dependencies python3 build-base;; \
	esac && \
	npm install -g --omit=dev n8n@${N8N_VERSION} && \
	case "$apkArch" in \
		'armv7') apk del build-dependencies;; \
	esac && \
	find /usr/local/lib/node_modules/n8n -type f -name "*.ts" -o -name "*.js.map" -o -name "*.vue" | xargs rm && \
	rm -rf /root/.npm

# Installs latest Chromium (100) package. (step 8)
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.(step 9)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Puppeteer v13.5.0 works with Chromium 100.(step 10)
RUN yarn add puppeteer@13.5.0

# Add user so we don't need --no-sandbox.(step 11)
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Run everything after as non-privileged user. (step 12)
USER pptruser

# Install n8n-nodes-puppeteer
# RUN cd /usr/local/lib/node_modules/n8n && npm install n8n-nodes-puppeteer

# Install fonts (step 13)
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
