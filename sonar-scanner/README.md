# How to scan

Login SonarQube and create project manually.

Modify docker compose env file.

```sh
cp env_template .env
vim .env
```

- SCAN_SOURCE_DIR : Repository directory path to be analyzed
- SCAN_CACHE_DIR : Scan cache directory path
- SONAR_TOKEN : Token generated from SonarQube
- SONAR_SCANNER_OPTS : sonar-scanner cli options
    - -Dsonar.projectKey : Input your project key from SonarQube

Build and start scanning.

```sh
docker compose up
```
