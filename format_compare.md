# Benchmarks

The HAPI CSV and binary formats use strings to represent time.  This representation provides an unambiguous time representation but has the possible penalty of requiring additional time to parse and interpret a response for use in a typical scientific analysis program.  In a typical scientific analysis program, time is represented as a floating point number representing, for example, a fractional day number relative to an epoch (e.g, 1 corresponds to Jan-1-0000 in MATLAB) or an integer number representing the number of time intervals from a reference time (e.g., milliseconds since 2001-01-01T00:00:00.000Z).  This numerical representation allows for interpolation and re-gridding of time arrays and the computation of average time stamp of valid data points in an averaging window.

Here we compare the time to read a HAPI-formatted file with time represented as a string into a double precison arrays against that for a "Fast" formatted file that contains time represented as a double precision number (in this test, the number of seconds since 1970-01-01). It is assumed that the reference time and the time increment would be obtained from a /info request from a HAPI server or it would be stored in the response header.

The benchmark test is to read a scalar time series with 86400 records (corrsesponding to a ~2-4 MB file size) from a server that provides HAPI CSV and binary responses as well as "Fast" CSV and binary responses.  To ensure that the transport time was not a factor and that only the read time was being measured, the outputs from the server were saved to a temporary file first and the timing only involves that required to these these temporary files from disk.

Table 1 contains a summary of the results produced by a run of [Code](https://github.com/hapi-server/matlab-client/blob/master/format_compare.m).  The results for individual methods (e.g., using the textscan and load functions, etc.) are shown in Table 2.

The overall result are 

1. the fastest read of the "Fast" formats is approximately 2-3 faster than the fastest read of the same information stored in the HAPI formats and
2. obtaining time efficient reads of HAPI-formatted files requires the use of lower-level functions in MATLAB and Python and programs with slightly more complexity (but overall typically only 10-20 lines of code).

Because
1. the read time of the "Fast" format is only 2-3x faster than that for the corresponding HAPI formats;
2. the HAPI format read times are comparable to the request/response/download time for the response; 
3. clients are or will be made available for most of the commonly used analysis languages (IDL/MATLAB/Python/Java) that incorporate a time efficient algorithm for reading HAPI responses; and
4. the advantage of having an unambiguous time represented in the HAPI data response
a re-definition or expansion of the standard HAPI response formats is not strongly justified.

# Results: MATLAB

[Code](https://github.com/hapi-server/matlab-client/blob/master/format_compare.m)

* Table 1 *
```
Best-Time Ratios
csv/fcsv:         2.5
bin/fbin:         2.1

csv/bin           9.4
fcsv/fbin:        7.8
```

* Table 2 *
```
fcsv (textscan)     0.1065s	# "Fast" CSV
fcsv (load)         0.4486s	# "Fast" CSV
csv (readtbl/tfmt)  1.4572s	# HAPI CSV
csv (textscan/tfmt) 1.4359s	# HAPI CSV
csv (textscan)      0.2671s	# HAPI CSV
csv (regex/str2num) 7.3747s	# HAPI CSV
fbin (fread)        0.0179s	# "Fast" binary (both doubles)
fbin (mmap)         0.0180s	# "Fast" binary (both doubles)
fbin w/ints (fread) 0.1008s	# "Fast" binary (time dbl, param int)
fbin w/ints (mmap)  0.2096s	# "Fast" binary (both doubles)
fbin (java.nio)     0.0136s	# "Fast" binary
bin (java.nio)      0.0675s	# HAPI binary
bin (kludge)        0.1579s	# HAPI binary
bin (memmap alt):   0.2208s	# HAPI binary
bin (memmap alt2):  0.0285s	# HAPI binary
bin (mmap/datastr)  1.7285s	# HAPI binary
```

## Results: Python

[Code](https://github.com/hapi-server/python-client/blob/master/format_compare.py)

