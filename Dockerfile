FROM centos/httpd:latest
COPY index.html /var/www/html/
EXPOSE 80
CMD ["httpd", "-DFOREGROUND"]
