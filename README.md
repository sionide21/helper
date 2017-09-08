# H.E.L.P.eR.

A robot companion for command line tasks.

H.E.L.P.eR. maintains a persistent process that can be accessed over TCP from
any local application. This enables orchestration between CLI shells as well
as periodic tasks such as cache refresh.

## To Run

```
elixir --no-halt --erl '+C multi_time_warp' -S mix app.start
```
## Features (Wish List)

### Cache and periodically refresh results of a slow lookup

Instead of caching to disk and repaying the refresh cost inline when it expires,
tell H.E.L.P.eR. to maintain the cache and it will refresh the results
periodically so that there is always a copy available.

#### Example

Run `awssh --list` and then refresh the result every 10 minutes.

```
helper maintain --refresh 10m awssh --list
```

Subsequent runs of this command will immediately return with the latest known results.
