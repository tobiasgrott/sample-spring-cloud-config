# Spring Cloud Config Server Sample

## Prequisites
### Environment
- JDK 8
- Maven
- Spring Boot CLI (optional)
- Docker (optional)
#### Asynchronous Encryption
- OpenSSL (only for asynchronous Encryption)
- Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy File 
  http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html
   - copy both jars files to /JRE/lib/security
### Environment Variables
- JAVA_HOME
- OPENSSL_HOME
- SPRING_HOME
- MAVEN_HOME
- PATH=%PATH%;%JAVA_HOME%\bin;%OPENSSL_HOME%\bin;%SPRING_HOME%\bin;%MAVEN_HOME%\bin
- GIT_REPOSITORY_PATH=PATH TO CONFIG FILES
### Structure 
- config-client --> sample client
- config-repo --> sample repository
- config-server --> sample server

## Config

### Config-Server
#### Base 
###### pom.xml
```xml
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>
```
###### bootstrap.yml        
```yaml
server:
  port: 8888

spring:
  cloud:
    config:
      server:
        git:
          uri: ${GIT_REPOSITORY_PATH}
          clone-on-startup: true
```
##### Usage
```bash
mvn clean install
java -jar target\config-server-1.0-SNAPSHOT.jar
# Call Configuration
curl -X GET http://localhost:8888/{applicationname}/{profile}
# Refresh Config
curl -X POST http://localhost:8888/refresh
```
#### Secure Config Endpoints
###### pom.xml
```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
```
###### bootstrap.yml
```yaml
security:
  user:
    name: root
    password: s3cr3t
```
#### Synchronous Encryption (Serverside Encryption)
```yaml
encrypt:
  key: S3CR3T
```

#### Asynchronous Encryption (Serverside Decryption)
#### Create Keystore
```batch
SET KEY_ALIAS=config-server-key
SET FILE_NAME=config-server.jks
SET PUBLIC_KEY_FILENAME=publickey.pem
# KeyStore secrets
SET STORE_PASS=my-s3cr3t
# Key Issuer
SET ISSUER="CN=Config Service,OU=Spring Cloud,O=DEVELOPER"

SET OPENSSL_HOME=C:\Program Files (x86)\GnuWin32
SET PATH=%PATH%;%OPENSSL_HOME%\bin

keytool -genkeypair -alias %KEY_ALIAS% ^
       -keyalg RSA -keysize 4096 -sigalg SHA512withRSA ^
       -dname %ISSUER% ^
       -keystore %FILE_NAME% ^
       -storepass %STORE_PASS% ^
       -storetype pkcs12

openssl pkcs12 -in %FILE_NAME% -out server.pem -passin pass:%STORE_PASS% -passout pass:%STORE_PASS%
openssl rsa -in server.pem -passin pass:%STORE_PASS% -pubout > server.pub

copy %FILE_NAME% ..\config-server\src\main\resources\%FILE_NAME%
copy %FILE_NAME% ..\config-client\src\main\resources\%FILE_NAME%
```
Keystore is needed on decryption side
###### bootstrap.yml
```yaml
encrypt:
  key-store:
    location: classpath:/config-server.jks
    password: my-s3cr3t
    alias: config-server-key
    secret: my-s3cr3t
```
#### Disable Serverside decryption --> Client Side Decryption
###### bootstrap.yml
```yaml
spring:
  cloud:
    config:
      server:
        encrypt:
          enabled: true
```

### Config-Client
#### Base Configuration
###### pom.xml
```xml
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
```
###### bootstrap.yml
```yaml
spring:
  application:
    name: config-client
  profiles:
    active: development
  cloud:
    config:
      uri: http://localhost:8888
      username: root
      password: s3cr3t
      fail-fast: true
```

###### RestResource.java
```java
@RestController
// Needed for reload of config values after config refresh
@RefreshScope
public class MessageRestController {
    // Injects Property value
    @Value("${message:Hello default}")
    private String message;
}
```
#### Access Secured Config Server
###### bootstrap.yml
```yaml
security:
  user:
    name: root
    password: s3cr3t
```

###### pom.xml
```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
```

#### Client Side Decryption
###### pom.xml
```xml
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-rsa</artifactId>
        </dependency>
```
##### Synchronous Encryption
#### Synchronous Encryption (Serverside Encryption)
####### bootstrap.yml
```yaml
encrypt:
  key: S3CR3T
```
#### Asynchronous Encryption (KeyStore)
copy jks keystore to src/main/resources
###### bootstrap.yml
```yaml
encrypt:
  key-store:
    location: classpath:/config-server.jks
    password: my-s3cr3t
    alias: config-server-key
    secret: my-s3cr3t
```

### Repository
sample you find at sample-config
#### Create Synchronous encrypted Value
```bash
# create value
# spring boot cli
$ spring encrypt value --key S3CR3T
# rest endpoint
$ curl localhost:8888/encrypt -d S3CR3T value
```
Encrypted values have to be stored in yaml files in singlequotes with prefix `{cipher}`
#### Create Asynchronous encrypted Value

```bash
# create value
# spring boot cli
$ spring encrypt value --key @server.pub
# rest endpoint
$ curl localhost:8888/encrypt value
```
Encrypted values have to be stored in yaml files in singlequotes with prefix `{cipher}`
