import os
import sys
import csv
import argparse
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

import oracledb
oracledb.init_oracle_client(lib_dir="/Users/dekockjt/oracle/instantclient_23_26")

load_dotenv() # load DB env vars in .env
ORA_USER=os.environ['ORA_USER']
ORA_PSWD=os.environ['ORA_PASS']
ORA_PORT = os.environ['ORA_PORT']
ORA_HOST = os.environ['ORA_HOST']
ORA_NAME = os.environ['ORA_NAME']

OUT_DIR='/Users/dekockjt/sql/z_out/'

def connectToDB() -> oracledb.Connection:
    return oracledb.connect(user=ORA_USER, password=ORA_PSWD, dsn=f'{ORA_HOST}:{ORA_PORT}/{ORA_NAME}')

def setupParser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser('run a .sql query and write results to a csv')
    parser.add_argument('input', help='Path for .sql file containing query')
    return parser

# read a query from a .sql file
def getQueryFromFile(file_path) -> str:
    with open(file_path, 'r') as f:
        content = f.read()

    # remove commented lines, split at semicolons, only return the first statement in the file
    return stripComments(content).split(';')[0].strip()


def stripComments(content: str) -> str:
    return '\n'.join([line for line in content.splitlines() if not line.strip().startswith('--')])

def main():
    parser = setupParser()
    args = parser.parse_args()

    sql_path = Path(args.input)
    query = getQueryFromFile(sql_path)

    dt = datetime.now().strftime('%m%d%Y_%H%M%S')
    out_path = f'{OUT_DIR}{sql_path.stem}_{dt}.csv'

    with connectToDB() as conn:
        with conn.cursor() as cur:
            cur.execute(query)
            columns = [col[0] for col in cur.description]

            rc = 0
            with open(out_path, 'w', newline='') as f:
                writer = csv.writer(f, quoting=csv.QUOTE_ALL)
                writer.writerow(columns)
                for row in cur:
                    writer.writerow(row)
                    rc += 1

    print(f'Wrote {rc} rows ({Path(out_path).stat().st_size} bytes) to {out_path}')



if __name__ == '__main__':
    main()