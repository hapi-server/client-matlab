Having strings for time in CSV makes sense because it is easily readable and its parsing time is comparable to the parsing time of other elements in each record.

For binary, parsing and interpreting the time string is a significant fraction of time.  

Based on testing with MATLAB, if we used doubles for time instead of string, the time to have data in a form for plotting is ~75x faster. Typical results for [a benchmark script](https://github.com/hapi-server/matlab-client/binary_compare.m) are:

```
fbin total time:       0.0336
bin memmap time:       0.0025
bin extract data time: 0.1569
bin extract time time: 0.0897
bin datenum time:      1.4137
```

This corresponds to a speed-up of 74 = (1.41 + 0.9 + 0.16 + 0.0025)/0.0336 (this varies between 25 and 300 on my machine).  I get similar results using [a python benchmark script](https://github.com/hapi-server/python-client/binary_compare.py).

Therefore our specification for binary somewhat defeats the purpose of binary (speed). We could either define a new binary output (e.g., "sensiblebinary") or modify the existing.

Suggestion for modification of existing binary or new "sensiblebinary" output option: 

A short header that indicates that time values are interpreted as, e.g., "seconds since 2001-01-01:T00:00:00".  For example,

If the CSV output is
```
2001-01-01T00:00:00, 11.0
2001-01-01T00:01:00, 12.0
```

"sensible binary" would be 

```Byte 1 (char) = 0``` (0,1,2,3) time unit corresponding to (seconds, milli, micro, nano)

```Bytes 2-21 (chars) = 2001-01-01T00:00:00\0``` zero time

```Bytes 22-(22+8*4) (doubles) = (0.0, 11.0, 1.0, 12.0)```

Sensible binary has been implemented in [https://github.com/hapi-server/matlab-client](https://github.com/hapi-server/matlab-client) and [https://github.com/hapi-server/python-client](https://github.com/hapi-server/python-client).

Note that the header information could be specified in an ```/info``` response if we did not want to have a header.
