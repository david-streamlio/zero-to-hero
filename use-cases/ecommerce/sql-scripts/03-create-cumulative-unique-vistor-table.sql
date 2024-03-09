CREATE TABLE cumulative_uv (
                               date_str STRING,
                               time_str STRING,
                               uv BIGINT,
                               PRIMARY KEY (date_str, time_str) NOT ENFORCED
) WITH (
      'connector' = 'elasticsearch-7',
      'hosts' = 'http://elasticsearch:9200',
      'index' = 'cumulative_uv'
      );