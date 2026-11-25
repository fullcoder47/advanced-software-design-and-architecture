# Actual assistant environment smoke test

Run on Linux with Python 3.13; not a student Windows session.

```text
PARENT: starting child with this Python runtime: /opt/pyvenv/bin/python
PARENT: child PID is 990; waiting for it to exit.
CHILD: started
CHILD: PID=990 PPID=980
CHILD: platform=Linux Python=3.13.5
CHILD: CPU phase for 0.75 seconds...
CHILD: CPU phase complete (10345645 loop iterations).
CHILD: press Enter to continue and write synthetic lab output: CHILD: wrote synthetic data to output/child-result.txt
CHILD: exiting with code 7.
PARENT: wait() returned; child exit code was 7.
PARENT: non-zero is intentional in this lab; the parent reports it and exits normally.
```

Parent process returned 0; child intentionally returned 7.
