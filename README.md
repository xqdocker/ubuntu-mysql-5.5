# Ubuntu MySQL 5.5

MySQL 5.5 on Ubuntu System.

## How to use the MySQL images

There are some methods to use this image.


### Start MySQL service with a simple command.

1. Start MySQL service with default setting.

  ```
  $ docker run --name [my-mysql] -d xqdocker/ubuntu-mysql-5.5
  ```

2. Start MySQL service and bind to another point.

  ```
  $ docker run --name [my-mysql] -p 33306:3306 -d xqdocker/ubuntu-mysql-5.5
  ```

3. Start MySQL service and set customer root password.

  ```
  $ docker run --name [my-mysql] -e MYSQL_ROOT_PASSWORD=my-root-pwd -d xqdocker/ubuntu-mysql-5.5
  ```

4. Start MySQL service with customer config file.

  ```
  $ docker run --name [my-mysql] -v /my/mysql/conf.d/my.cnf:/etc/mysql/conf.d/my.cnf -d xqdocker/ubuntu-mysql-5.5
  ```

5. Start MySQL service and set customer data path.

  ```
  $ docker run --name [my-mysql] -v /my/mysql/data:/var/lib/mysql -d xqdocker/ubuntu-mysql-5.5
  ```

### Start MySQL service with Dockerfile.

* Step one: Create a simple Dockerfile like the following:

  ```
  FROM xqdocker/ubuntu-mysql-5.5

  ENV MYSQL_ROOT_PASSWORD my-root-pwd

  COPY /my/mysql/conf.d/my.cnf /etc/mysql/conf.d/my.cnf

  VOLUME /my/mysql/data /var/lib/mysql
  ```

* Step two: Build the docker image with this Dockerfile.

  ```
  $ docker build -t [my-ubuntu-mysql] .
  ```

* Run the docker image with the following command:

  ```
  $ docker run --name [my-mysql] -d [my-ubuntu-mysql]
  ```

### Start MySQL service with Docker-Compose

* Step one: Create a simple docker-compose.yml file:

  ```
  my-mysql:
    image: ubuntu-mysql-5.5
    volumes:
      - /my/mysql/conf.d/my.cnf:/etc/mysql/conf.d/my.cnf
      - /my/mysql/data:/var/lib/mysql
    ports:
      - "33306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=my-root-pwd
  ```

* Step two: Build and run this docker-compose.yml with Docker-Compose command.

  ```
  $ docker-compose run my-mysql
  ```

## Environment Variables

* **MYSQL_ROOT_PASSWORD**
This variable specifies a password that will be set for the MySQL root user. If you don't set this variable, mysql will using empty password.

* **MYSQL_DATABASE**
This variable is optional. It allows you to specify the name of a database to be created on image startup. If a user/password was supplied (see below) then that user will be granted superuser access to this database.

* **MYSQL_USER**, **MYSQL_PASSWORD**
These variables are optional. It allows you to specify a user name and user's password. This user will be granted superuser permission (see above) for the database by the `MYSQL_DATABASE` variable.


## License
Code is under the [MIT license](./LICENSE).
