
# (step 1/15)
FROM node:16-alpine

#Install Chromium
FROM zenika/alpine-chrome:with-node

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
WORKDIR /usr/src/app
COPY --chown=chrome package.json package-lock.json ./
RUN npm install
COPY --chown=chrome . ./
ENTRYPOINT ["tini", "--"]
CMD ["node", "/usr/src/app/src/pdf"]

# Mettre la dernière version de N8N(step 2)
ARG N8N_VERSION=0.198.2

# Vérifie si il existe une version de N8N dans le fichier actuel(step 3)
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

# Mise à jour et installation de toute les dépendance nécessaires (step 4)
RUN apk add --update graphicsmagick tzdata git tini su-exec

# # Mettre un autre nom que root (c'est un identifiant) (step 5)
USER root

# (step 6)
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
	





# Install fonts
RUN apk --no-cache add --virtual fonts msttcorefonts-installer fontconfig && \
	update-ms-fonts && \
	fc-cache -f && \
	apk del fonts && \
	find  /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \; \
	&& rm -rf /root /tmp/* /var/cache/apk/* && mkdir /root

ENV NODE_ICU_DATA /usr/local/lib/node_modules/full-icu

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.(step 10)
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true \
#	PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Installs latest Chromium (100) package. (step 7)
RUN apk update && apk add --no-cache nmap && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn

# Install n8n-nodes-puppeteer
# RUN cd /usr/local/lib/node_modules/n8n && npm install n8n-nodes-puppeteer


#step 14
WORKDIR /data

#step 15
COPY docker-entrypoint.sh /docker-entrypoint.sh

#step 16
RUN chmod +x /docker-entrypoint.sh

#step 17
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

#step 18
EXPOSE 5678/tcp

# Run everything after as non-privileged user. (step 19)
# USER pptruser
