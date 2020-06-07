FROM nginx:1.15.7-alpine
LABEL maintainer="Rajesh Iyer <iyerajesh@gmail.com"

ENV APP_ROOT /home/iyerajesh.com
ENV SRC_DIR ./node_modules ./public ./src
ENV NGINX_STATIC /usr/share/nginx/html/
ENV NGINX_CONF /etc/nginx/

# Install nvm with node and npm
RUN apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main libuv \
    && apk add --no-cache --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main nodejs=12.18.0-r2 nodejs-npm=12.18.0-r2 \
    && apk add --no-cache --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community yarn=1.22.4-r0 \
    && echo "NodeJS Version:" "$(node -v)" \
    && echo "NPM Version:" "$(npm -v)" \
    && echo "Yarn Version:" "$(yarn -v)"

WORKDIR $APP_ROOT
COPY . $APP_ROOT

RUN node -v \
    && npm -v \
    && yarn -v \
    && yarn config set registry https://registry.npmjs.com/ \
    && yarn config get registry \
    && yarn install --verbose \
    && yarn build \
    && cp -r nginx/* $NGINX_CONF \
    && cp -r build/* $NGINX_STATIC \
    && rm -rf $SRC_DIR

EXPOSE 8080
RUN nginx -t

CMD ["nginx","-g","daemon off;"]
