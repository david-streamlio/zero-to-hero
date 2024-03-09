CREATE TABLE category_dim (
                              sub_category_id BIGINT,
                              parent_category_name STRING
) WITH (
      'connector' = 'jdbc',
      'url' = 'jdbc:mysql://mysql:3306/flink',
      'table-name' = 'category',
      'username' = 'root',
      'password' = '123456',
      'lookup.cache.max-rows' = '5000',
      'lookup.cache.ttl' = '10min'
      );