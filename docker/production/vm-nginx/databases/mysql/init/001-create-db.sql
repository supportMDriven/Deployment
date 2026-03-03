/* These are created from the variables
CREATE DATABASE IF NOT EXISTS mdriven_db;

CREATE USER IF NOT EXISTS 'mdriven'@'%' IDENTIFIED BY '123456';
*/
GRANT ALL PRIVILEGES ON mdriven_db.* TO 'mdriven'@'%';
FLUSH PRIVILEGES;