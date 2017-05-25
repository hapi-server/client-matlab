# MATLAB client for accessing HAPI data

## Installation

In MATLAB, simply execute
```matlab
urlwrite('https://github.com/hapi-server/matlab-client/hapi.m','hapi.m'); % D/L and save hapi.m
help hapi
```

Or, download https://github.com/hapi-server/matlab-client/archive/master.zip

```hapi.m``` automatically downloads a required java library automatically if needed.

```hapi.m``` automatically updates itself if a newer version is found in repository.  See ```help hapi``` to turn of automatic updates.

## Examples

Example usage is given in [https://github.com/hapi-server/matlab-client/hapi_demo.m](hapi_demo.m)

To run examples, execute

```matlab
urlwrite('https://github.com/hapi-server/matlab-client/hapi_demo.m','hapi_demo.m'); % D/L hapi_demo.m
```

and then enter

```matlab
hapi_demo
```
## Contact

Bob Weigel <rweigel@gmu.edu>
