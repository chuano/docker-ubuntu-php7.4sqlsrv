#Ubuntu 18.04 docker image with php7.4 and sqlsrv
##Build
```docker image build -t php74sqlsrv .```
##Run
```docker run -d -p 443:443 -v yourProjectDir:/var/www/html php74sqlsrv```