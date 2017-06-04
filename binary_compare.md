# Proposal for CSV/Binary Format Change or Addition

Based on extensive testing in MATLAB and Python, I think that we need to define two new output formats: `fcsv` and `fbin` (`f` for "fast").  

Or re-define our current formats.

Given that we have not announced version 1.2, we should carefully consider re-defining the formats.  When we discussed the formats orginally, the [premature optimization](http://ubiquity.acm.org/article.cfm?id=1513451) cliche was used a justification for not worring about the obvious efficiency penalty of using IS0-8601 strings in the output formats.  This was unfortunate and I think that we should fix this.  

# Motivations

Using MATLAB (with many optimization tests), I found that at best (see [Benchmarks](#Benchmarks))
* to read 4 MB of HAPI CSV data from disk and put it in a form that can be sent to a plot requires ~10 seconds.  This is not acceptable; I regularly look at 100s of 1-second data files. If I needed to look at many days of data, I would probably just find the original files and write my own parser, which defeats part of the purpose of HAPI.
* to read 4 MB of HAPI binary takes ~3 seconds.  This is marginally acceptable.
* a simple format specification will lead to a ~50x speed-up for reading CSV and a ~100x speed-up for reading binary.

In Python (with many optimization tests), the issues and speed-ups are similar (see [Benchmarks](#Benchmarks)).

Of course, the rate limiter is the representation of time in HAPI CSV and Binary.  To do any analysis like creating a plot or subsetting based on a time constraint requires the ISO-8601 string be converted to a float or integer.  Parsing an ISO-8601 string is time consuming and having to do parsing prevents other efficient data reading methods in scripting languages from being used (e.g, need a iterate over records instead of using a vectorized read statement).

# "Fast" Format Specification

Time in CSV and binary are represented as an integer.  The epoch time and time unit is found from a `/info` request.  The units of time are either seconds, milliseconds, microseconds, etc.

Benchmark results are given in the following section.  They key result is that `fcsv` is ~50x faster to read and `fbin` is ~100x faster to read.

I could imagine excusing a factor of 5 or 10 for simplicity over speed.  However, the proposed fast output formats are equally as simple as the HAPI output formats.  The read code for the "fast" formats is simpler.  In MATLAB, it is one line: `data = load('filename)`.

The only real advantage of the existing HAPI CSV and Binary formats is that one can look at the file and see unambiguious time strings.  But the format is for machine-to-machine communication.  So why are we using ISO 8601 strings in the HAPI output?

The HAPI CSV reading clients are going to get very complicated as we try to work around the speed limitation. 

[TT2000](https://cdf.gsfc.nasa.gov/html/leapseconds_requirements.html) is an obvious candidate if we wanted to use a fixed epoch time.  The difficulty with this is that both the servers and the clients would need to use (and keep up-to-date) the leap second tables.

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
