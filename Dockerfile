FROM node:20.15-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends dumb-init

USER node

WORKDIR /home/node/app

COPY --chown=node . .
# Building the production-ready application code - alias to 'nest build'
RUN npm install

RUN npm run build

FROM node:20.15-bookworm-slim

ENV NODE_ENV production

WORKDIR /home/node/app

COPY --from=builder /usr/bin/dumb-init /usr/bin/dumb-init

COPY --from=builder --chown=node /home/node/app/node_modules ./node_modules
# Copying the production-ready application code, so it's one of few required artifacts

COPY --from=builder --chown=node /home/node/app/dist ./dist

#COPY --from=builder --chown=node /home/node/app/public ./public
COPY --from=builder --chown=node /home/node/app/package.json .

EXPOSE 3000

USER node

CMD [ "dumb-init", "node", "dist/main.js" ]
