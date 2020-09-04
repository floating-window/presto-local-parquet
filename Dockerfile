FROM prestosql/presto
USER root

# Use MinIO to serve local files through an S3-compatible API.
RUN curl -o /usr/local/bin/minio \
  https://dl.min.io/server/minio/release/linux-amd64/minio && \
  chmod +x /usr/local/bin/minio

# Entrypoint script.
COPY run-presto-local-parquet /usr/local/bin/run-presto-local-parquet

# Presto catalog config to use file-based Hive metastore.
#
# Note that whilst this implementation works here, it appears
# to be primarily intended for integration testing [of Presto]:
# https://github.com/prestodb/presto/issues/11943#issuecomment-440328597
COPY --chown=presto:presto hive.properties \
  /usr/lib/presto/default/etc/catalog/hive.properties

USER presto:presto
# Starts MinIO and Presto server, then runs a Presto shell.
ENTRYPOINT [ "run-presto-local-parquet" ]