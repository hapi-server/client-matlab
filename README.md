# MATLAB client for accessing HAPI data

## Installation

In MATLAB, simply execute
```matlab
urlwrite('https://github.com/hapi-server/matlab-client/hapi.m','hapi.m'); % D/L and save hapi.m
help hapi
```

Or, download [the package](https://github.com/hapi-server/matlab-client/archive/master.zip).

```hapi.m``` automatically downloads a required java library from `https://github.com/hapi-server/matlab-client/` if needed (for parsing JSON; authored by http://json.org/).

```hapi.m``` automatically updates itself if a newer version is found in [the repository](https://github.com/hapi-server/matlab-client/).  See ```help hapi``` to turn of automatic updates.

## Examples

Example usage is given in [hapi_demo.m](https://github.com/hapi-server/matlab-client/hapi_demo.m)

To run examples, execute

```matlab
urlwrite('https://github.com/hapi-server/matlab-client/hapi_demo.m','hapi_demo.m'); % D/L hapi_demo.m
```

and then enter

```matlab
hapi_demo
```

## Development

```bash
git clone https://github.com/hapi-server/matlab-client.git
```

and set `OPTS.update_script = 0` in `hapi.m`.  Unset before committing changes.

## Contact

Bob Weigel <rweigel@gmu.edu>
