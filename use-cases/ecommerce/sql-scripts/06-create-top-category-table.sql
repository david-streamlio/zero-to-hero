CREATE TABLE top_category (
                              category_name STRING PRIMARY KEY NOT ENFORCED,
                              buy_cnt BIGINT
) WITH (
      'connector' = 'elasticsearch-7',
      'hosts' = 'http://elasticsearch:9200',
      'index' = 'top_category'
      );