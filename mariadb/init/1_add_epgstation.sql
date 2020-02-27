USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by 'epgstation' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('epgstation');

DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS `epgstation` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

GRANT ALL ON `epgstation`.* to 'epgstation'@'localhost' IDENTIFIED BY 'epgstation';
GRANT SELECT ON `epgstation`.* to 'grafana'@'localhost' IDENTIFIED BY 'grafana';
FLUSH PRIVILEGES ;
