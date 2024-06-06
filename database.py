# This will reset, re-setup, and re-run the sample insert statements
# In the sql folder

import os
import mysql.connector

# List of SQL files to execute
sql_file_names = ['reset.sql', 'setup.sql', 'sample_inserts.sql']

# Directory containing SQL files
sql_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sql')

# Establish a connection to the MySQL server
connection = mysql.connector.connect(
    host="localhost",
    user="matthew",
    password="",
    database="poker"
)

# Create a cursor to execute queries
cursor = connection.cursor()

# Open and read the SQL file
for file_name in sql_file_names:
    with open(os.path.join(sql_dir, file_name), 'r') as file:
        sql_queries = file.read()
        # Split the SQL file content into individual queries
        queries = sql_queries.split(';')

        # Iterate over the queries and execute them
        for query in queries:
            try:
                if query.strip() != '':
                    cursor.execute(query)
                    connection.commit()
                    print(query)
            except Exception as e:
                print("Error executing query:", str(e))

# Close the cursor and the database connection
cursor.close()
connection.close()