CREATE TABLE buy_cnt_per_hour (
                                  hour_of_day BIGINT,
                                  buy_cnt BIGINT
) WITH (
      'connector' = 'elasticsearch-7', -- using elasticsearch connector
      'hosts' = 'http://elasticsearch:9200',  -- elasticsearch address
      'index' = 'buy_cnt_per_hour'  -- elasticsearch index name, similar to database table name
      );