USE mysql;
FLUSH PRIVILEGES ;

DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS `epgstation` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

GRANT ALL ON `epgstation`.* to 'epgstation'@'localhost' IDENTIFIED BY 'epgstation';
GRANT SELECT ON `epgstation`.* to 'grafana'@'localhost' IDENTIFIED BY 'grafana';
FLUSH PRIVILEGES ;
