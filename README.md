
# presto-local-parquet

Single-node Presto cluster configured to query local Parquet files.

To run queries over `/home/user/SomeData/DataSet1/file_<n>.parquet`

```shell
docker run -it --rm --mount source=/home/user/SomeData/,destination=/parquet,type=bind presto-local-parquet
```

This will start a Presto server and local S3 server, then run a Presto shell.

The schema for the Parquet files needs to be defined before you can run queries,
an example is provided in the shell.

Exit the shell with `Ctrl+D`.

# Run Options

## Single-use 

Any schemas defined will be lost when the container exits.

```shell
docker run -it --rm --mount source=/<data-dir>/,destination=/parquet,type=bind presto-local-parquet
```

### With Presto Web UI

The Web UI shows the status of Presto, access at http://127.0.0.1:8080 with
username `admin` (no password required).

```shell
docker run -it --rm -p 8080:8080 --mount source=/<data-dir>/,destination=/parquet,type=bind presto-local-parquet
```

## Named  

Keep the container, and save schemas for re-use later.

Exit shell with `Ctrl+D`

### First startup

```shell
docker run -it --mount source=/<data-dir>/,destination=/parquet,type=bind --name presto-lp presto-local-parquet
```

### First startup, with Presto Web UI

See above for details on accessing the UI.

```shell
docker run -it -p 8080:8080 --mount source=/<data-dir>/,destination=/parquet,type=bind --name presto-lp presto-local-parquet
```

### Subsequent startup

```shell
docker start -i presto-lp
```

### Removing the container

```shell
docker container rm presto-lp
```

## Separate server/client

Leave the server running in the background and run (and quit) the shell
independently.

> The server will not start if a `.minio.sys` directory already exists. This
must be deleted manually before starting the server in detached mode.

### Server 

```shell
docker run -d --mount source=/<data-dir>/,destination=/parquet,type=bind --name presto-lp presto-local-parquet
```

### Server, with Presto Web UI

See above for details on accessing the UI.

```shell
docker run -d -p 8080:8080 --mount source=/<data-dir>/,destination=/parquet,type=bind --name presto-lp presto-local-parquet
```

### Client

Exit shell with `Ctrl+D`

```shell
docker exec -it presto-lp presto
```

### Stopping the Server

```shell
docker stop presto-lp
```

### Removing the container
```shell
docker container rm presto-lp
```

# Building

```shell
docker build . -t presto-local-parquet
```