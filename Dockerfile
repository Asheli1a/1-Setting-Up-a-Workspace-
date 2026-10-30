FROM nginx:alpine

LABEL org.opencontainers.image.title="Asheli1a Workspace Web"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
