# sql - main working repo for Justin DeKock
- initially consolidated to one git repo 07/14/2026
- added submodules for existing repos before consolidating

# cleanup_csvs.py:
- moves all csvs in all sub directories to the z_out/ directory

# oracsv/oracsv.py: 
- pass a sql file as arg, runs query and writes response to a csv file
    - outputs write to ./z_out/ directory
    - output file inherits name of sql file plus timestamp
    - the first query in the file is the one that will be run
        - the file's content is split at the first semicolon. nothing past that is used
