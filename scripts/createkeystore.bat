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