#!/bin/sh

# Wait 60 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

DBSTATUS="1"
ERRCODE="1"
i=0

# Give SQL server a few seconds to begin booting before we start hammering it
sleep 5


while { [ "$DBSTATUS" != "0" ] || [ "$ERRCODE" != "0" ]; } && [ "$i" -lt 60 ]; do
    # POSIX-compliant math
    i=$((i + 1))
    
    # Capture the output and discard the error stream (2>/dev/null)
    RAW_STATUS=$(/opt/mssql-tools18/bin/sqlcmd -h -1 -t 1 -U sa -P $MSSQL_SA_PASSWORD -No -C -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
    ERRCODE=$?
    
    # If the command succeeded, strip out whitespace/carriage returns so the string is strictly "0"
    if [ "$ERRCODE" = "0" ]; then
        DBSTATUS=$(echo "$RAW_STATUS" | tr -d '[:space:]')
    fi
    
    sleep 1
done

if [ "$DBSTATUS" != "0" ] || [ "$ERRCODE" != "0" ]; then 
    echo "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state."
    exit 1
fi

echo "SQL Server is ready. Running setup script..."

# Run the setup script to create the DB and the schema in the DBs
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -No -C -d master -i /usr/config/create-db.sql

echo "Setup complete."