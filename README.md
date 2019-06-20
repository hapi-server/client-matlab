# MATLAB client for accessing HAPI data

## Installation

In MATLAB, simply execute

```matlab
% D/L and save hapi.m
urlwrite('https://github.com/hapi-server/client-matlab/hapi.m','hapi.m');
help hapi
```

Or, download [the package](https://github.com/hapi-server/client-matlab/archive/master.zip).

## Examples

Example usage is given in [hapi_demo.m](https://github.com/hapi-server/client-matlab/hapi_demo.m).

The console and figure output of this script is viewable at [hapi_demo.md](https://github.com/hapi-server/client-matlab/hapi_demo.md).

To run examples, execute

```matlab
% Download hapi.m
urlwrite('https://github.com/hapi-server/client-matlab/hapi.m','hapi.m'); 
% Download hapi_demo.m
urlwrite('https://github.com/hapi-server/client-matlab/hapi_demo.m','hapi_demo.m');
hapi_demo % Execute hapi_demo script
```

## Development

```bash
git clone https://github.com/hapi-server/client-matlab.git
```

TODO:

1. Generalize time parsing in `hapi.m`.
2. Finish binary reader.

## Contact

Submit bug reports and feature requests on the [repository issue tracker](https://github.com/hapi-server/client-matlab/issues).

Bob Weigel <rweigel@gmu.edu>
