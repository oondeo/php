# php
Docker php image with basic utils and libs, apc, opcache, redis and xdebug.

All parameters in php.ini can be configured with envionment variables, for example OPCACHE__ENABLED is opcache.enable.

To disable XDEBUG set XDEBUG=0

To host diferent domains use:
```
php_admin_value[open_basedir] = "/tmp:/opt/app-root/src:/usr/local/lib/php"
php_admin_value[session.save_path] = "/tmp"
php_admin_value[soap.wsdl_cache_dir] = "/tmp"
php_admin_value[sys_temp_dir] = "/tmp"
php_admin_value[upload_tmp_dir] = "/var/tmp"
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
```
MYSQL 8: sql_mode = STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION

# openshift