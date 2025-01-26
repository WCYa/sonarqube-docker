# sonarqube-docker
sonarqube with nginx using docker compose example.

## Version

- SonarQube: 9.9 LTS Community Edition
- PostgreSQL: 15
- Nginx: 1.25

## Notices

- If you are using Unix-like system, ensure that the `vm.max_map_count` value is greater than `262144`. You can temporarily change it by running:
   ```sh
   sudo sysctl -w vm.max_map_count=262144
   ```
   To make the change permanent, add `vm.max_map_count=262144` to the end of `/etc/sysctl.conf`. After editing, apply the changes immediately without rebooting using:
   ```sh
   sudo sysctl -p
   ```
- If you are not using a private CA, you must remove the following lines from your Dockerfile:
   ```
   ADD ./private-ca.crt /usr/local/share/ca-certificates/private-ca.crt
   RUN update-ca-certificates
   ```
- If your Nginx setup does not use TLS, you can rename the file `nginx/templates/ssl.conf.template` to `nginx/templates/ssl.conf.template.disable`, and restart the container:
   ```sh
   docker compose down proxy
   docker compose up -d proxy
   ```

## Manipulate

sonarqube default account/password: `admin/admin`

### PostgreSQL

Login PostgreSQL

```sh
# docker compose exec -it db psql -U <username> -d <dbname>
docker compose exec -it db psql -U sonarqube01 -d sonar
```

## Backup and Restore

### Backup PostgreSQL

1. Only PostgreSQL backup is required.
2. Elasticsearch just needs reindexing.

```sh
docker compose exec db pg_dumpall -U sonarqube01 --clean --if-exists > dumpfile.sql
```

### Restore

1. Stop all containers.
    ```sh
    docker compose down
    ```
2. If necessary, delete the PostgreSQL volumes.
    ```sh
    docker volume rm sonarqube_postgresql
    docker volume rm sonarqube_postgresql_data
    ```
3. Just start the PostgreSQL container.
    ```sh
    docker compose up -d db
    ```
4. Copy `dumpfile.sql` file to container, and drop the database created when the PostgreSQL data folder is empty.
    ```sh
    docker compose cp dumpfile.sql db:/
    docker compose exec db psql -U sonarqube01 -d postgres -c 'DROP DATABASE sonar;'
    ```
5. Restore PostgreSQL by `dumpfile.sql` file
    ```sh
    docker compose exec db psql -U sonarqube01 -f dumpfile.sql postgres
    ```
6. Drop the Elasticsearch all indexes.
    ```sh
    # find sonarqube_data volume location
    docker volume inspect sonarqube_data
    # delete contents of es7 directory
    rm -rf /var/lib/docker/volumes/sonarqube_data/_data/es7/*
    ```
7. Start sonarqube container to reindex.
    ```sh
    docker compose up -d
    ```
## Ansible

There're some playbooks for setting up custom configurations for SonarQube. To use them, you need to install the relevant packages by following these steps.
```sh
dnf install -y ansible-core python3.11-pip
ansible-galaxy collection install community.docker
pip3.11 install -r requirements.txt
```
