# Proposal Output Formats

Based on testing in MATLAB and Python, I think that we need to define two new output formats: fcsv and fbin (f for fast).

# Motivations

Using MATLAB (with many optimization efforts), I found that at best
* to read 4 MB of HAPI CSV data from disk and put it in a form that can be sent to a plot requires ~10 seconds.  This is not acceptable.
* to do the same with HAPI binary takes ~3 seconds.  This is marginally acceptable.
* a simple format specification will lead to a 30x speed-up for CSV and a 300x speed-up for binary.

In Python, the speed-up is similar.

Of course, the rate limiter is the representation of time in HAPI CSV and Binary.

# Format Specification

Time in CSV is represented as an integer.  Time in binary is represented as a integer cast to a double. The ordinal time and time unit is found from a /info request.  The units of time are either seconds, milliseconds, microseconds, etc.

Typical results for [a benchmark script in MATLAB](https://github.com/hapi-server/matlab-client/blob/master/binary_compare.m) are in the table below. The results are similar for [Python](https://github.com/hapi-server/python-client/blob/master/binary_compare.md).

Note that in MATLAB, having time represented as a double as a signifcant benefit.  In Python, the benefit is less pronounced.

The test was to read a scalar time series with 86400 records (~2-4 MB file size).  
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
