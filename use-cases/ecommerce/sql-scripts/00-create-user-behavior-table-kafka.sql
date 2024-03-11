CREATE TABLE user_behavior (
                               user_id BIGINT,
                               item_id BIGINT,
                               category_id BIGINT,
                               behavior STRING,
                               ts TIMESTAMP(3),
                               proctime AS PROCTIME(),   -- generates processing-time attribute using computed column
                               WATERMARK FOR ts AS ts - INTERVAL '5' SECOND  -- defines watermark on ts column, marks ts as event-time attribute
) WITH (
      'connector' = 'kafka',  -- using kafka connector
      'topic' = 'user_behavior',  -- kafka topic
      'scan.startup.mode' = 'earliest-offset',  -- reading from the beginning
      'properties.bootstrap.servers' = 'kafka:9094',  -- kafka broker address
      'format' = 'json'  -- the data format is json
      );