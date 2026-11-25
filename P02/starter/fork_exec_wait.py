"""POSIX-only illustration. On Windows use parent.py instead."""
import os
import sys
from pathlib import Path
if not hasattr(os, 'fork'):
    print('POSIX fork unavailable on Windows; run parent.py.')
    sys.exit(0)
pid = os.fork()
if pid == 0:
    os.execv(sys.executable, [sys.executable, str(Path(__file__).with_name('child.py'))])
else:
    child, status = os.waitpid(pid, 0)
    print(f'Child {child} exit code {os.waitstatus_to_exitcode(status)}')
