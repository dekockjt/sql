from pathlib import Path
from datetime import datetime
import shutil

ftypes = ['.csv']
outdir_name = 'z_out'
outdir = f'{outdir_name}/csv_cleanup_{datetime.now().strftime('%m%d%Y_%H%M%S')}'

rootdir = Path(__file__).resolve().parent

for fpath in rootdir.rglob('*'):
    if fpath.suffix in ftypes and outdir_name not in fpath.parts:
        subdir = fpath.parts[len(fpath.parts) - 2]
        fname = fpath.parts[len(fpath.parts) - 1]
        subdir_dest = Path(f'{rootdir}/{outdir}/{subdir}')
        dest = Path(f'{subdir_dest}/{fname}')
        try:
            subdir_dest.mkdir(parents=True, exist_ok=True)
            shutil.move(fpath, dest)
            print(f'Successfully moved {fpath} to {dest}')
        except Exception as err: 
            print(f'Unexpected error occured attempting to move {fpath} to {dest}: {err}')
    
