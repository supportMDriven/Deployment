#!/bin/sh

# Start the script to create the DB and user
/bin/sh /usr/config/configure-db.sh  &

# Starting SQL Server
/opt/mssql/bin/launch_sqlservr.sh /opt/mssql/bin/sqlservr 


