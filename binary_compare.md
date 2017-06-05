# Benchmarks

The test was is read a scalar time series with 86400 records (~2-4 MB file size).  To ensure that the transport time was not a factor and that only the read time was being measured, the outputs were saved to a file and the files were read from disk.

Note that the tests were run using a "fast" format where the epoch time and time unit were specified in the first 22 bytes of the binary file.  The results will be similar when the above-specified new format is used instead.

## MATLAB
[Code](https://github.com/hapi-server/matlab-client/blob/master/format_compare.m)
```
csv total:         10.6454s	# HAPI CSV
fcsv total:        0.3619s	# Proposed CSV
fbin total:        0.0108s	# Proposed binary (time and parameter doubles)
fbin w/ints total: 0.0966s	# Proposed binary (time is double, parameter is integer)
bin total:         2.1891s	# HAPI binary
  (bin memmap:        0.0033s)
  (bin extract data:  0.2264s)
  (bin extract time:  0.1318s)
  (bin datenum:       1.8277s)

Time Ratios
csv/fcsv:          29.4
csv/bin:           4.9
bin/fbin:          203.5
bin/(fbin w/ints): 22.7
```

## Python
[Code](https://github.com/hapi-server/python-client/blob/master/format_compare.py)
```
csv total:         8.1194s	# HAPI CSV
fcsv total:        0.1187s	# Proposed fast CSV
fbin total:        0.0088s	# Proposed binary (all doubles)
fbin w/ints total: 0.0053s	# Proposed binary (time dbl, param int)
bin total:         0.6889s	# HAPI binary
  (bin memmap:        0.0073s)
  (bin extract time:  0.6813s)
  (bin extract data:  0.0003s)

Time Ratios
csv/fcsv         : 68.3981
csv/bin          : 11.7865
bin/fbin         : 78.0398
bin/(fbin w/ints): 128.8103
```
Note that in MATLAB, having both time and the parameters represented as a double as a signifcant benefit (10x) over having time as doubles and parameters as integers.  In Python, the mixed case is actually ~2x faster.
