# PG Stats Aggregator

Read stats collected by PostgreSQL over time and report them to Librato Metrics.

## Deploy to Heroku

```bash
$ git clone https://github.com/lmarburger/pg_stats_aggregator
Cloning into 'pg_stats_aggregator'...
...

$ cd pg_stats_aggregator
$ heroku apps:create
autoupdating
Creating damp-wave-1398... done, stack is cedar
http://damp-wave-1398.herokuapp.com/ | git@heroku.com:damp-wave-1398.git
Git remote heroku added

$ git push heroku master
Counting objects: 7, done.
...

$ heroku addons:remove heroku-postgresql:dev
 !    WARNING: Destructive Action
 !    This command will affect the app: damp-wave-1398
 !    To proceed, type "damp-wave-1398" or re-run this command with --confirm damp-wave-1398
> damp-wave-1398

$ heroku config:add \
  DATABASE_URL=postgres:///database \
  LIBRATO_METRICS_USER=you@email.com \
  LIBRATO_METRICS_TOKEN=abc123
Setting config vars and restarting damp-wave-1398...

$ heroku scale clock=1
Scaling clock processes... done, now running 1
```
