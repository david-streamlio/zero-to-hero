# Website Activity Tracking Use Case

In this use case, I demonstrate how to integrate Kafka, MySQL, Elasticsearch, and Kibana with Flink SQL to analyze 
e-commerce user behavior in real-time. All exercises in this demo are performed in the Flink SQL CLI, and the entire 
process uses standard SQL syntax, without a single line of Java/Scala code.

If you haven't already started the streaming platform, please refer to this [document](../../README.md) for further details.
The rest of the steps assume that you have opened the Flink SQL client.

Create the User Behavior Table
--

When you started the Apache Pulsar containers, one of them contained launched a data generator process that writes events
into the persistent://public/default/clickstream-feed topic. This data contains the user behavior on the day of 
November 27, 2017 (behaviors include “click”, “like”, “purchase” and “add to shopping cart” events). 

Based upon [this](https://tianchi.aliyun.com/dataset/649) publicly available dataset, each row represents a user behavior event, with the user ID, product ID, 
product category ID, event type, and timestamp in JSON format. Each line represents a specific user-item interaction, 
which consists of user ID, item ID, item's category ID, behavior type and timestamp, separated by commas. The detailed 
descriptions of each field are as follows:


| Field	        | Explanation|
|---------------|------------|
| User ID       |	An integer, the serialized ID that represents a user|
| Item ID       |	An integer, the serialized ID that represents an item|
| Category ID   |	An integer, the serialized ID that represents the category which the corresponding item belongs to|
| Behavior type |	A string, enum-type from ('pv', 'buy', 'cart', 'fav')|
| Timestamp     |	An integer, the timestamp of the behavior|

Note that the dataset contains 4 different types of behaviors, they are

|Behavior	|Explanation|
|-----------|-----------|
|pv|	Page view of an item's detail page, equivalent to an item click|
|buy|	Purchase an item|
|cart|	Add an item to shopping cart|
|fav|	Favor an item|


1️⃣ Verify the source data set has been generated
---
Since this is the primary dataset used in our analysis, we must first confirm that the data exists and is in the proper 
format by running the following command to view the first 10 data entries:

```bash
docker exec broker-1 bash -c './bin/pulsar-client consume -n 10 -s my-sub -p Earliest persistent:public/default/clickstream-feed'
...
----- got message -----
key:[], properties:[], content:{"user_id":"952483","item_id":"310884","category_id":"4580532","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"794777","item_id":"5119439","category_id":"982926","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"875914","item_id":"4484065","category_id":"1320293","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"980877","item_id":"5097906","category_id":"149192","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"944074","item_id":"2348702","category_id":"3002561","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"973127","item_id":"1132597","category_id":"4181361","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"84681","item_id":"3505100","category_id":"2465336","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"732136","item_id":"3815446","category_id":"2342116","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"940143","item_id":"2157435","category_id":"1013319","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
----- got message -----
key:[], properties:[], content:{"user_id":"655789","item_id":"4945338","category_id":"4145813","behavior":"pv","ts":"2017-11-26T16:00:00Z"}
```

This confirms that the source data is available and in the expected format. Now we can proceed to the next step of 
creating an SQL table definition for this dataset.

2️⃣ Create a table definition for the click stream dataset
---

In order to make the events in the Pulsar topic accessible to Flink SQL, we run the following DDL statement inside the 
Flink SQL CLI to create a table that connects to the topic in the Pulsar cluster:

```sql
CREATE TABLE user_behavior (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    ts TIMESTAMP_LTZ(3),
    proctime AS PROCTIME(),   -- generates processing-time attribute using computed column
    WATERMARK FOR ts AS ts - INTERVAL '5' SECOND  -- defines watermark on ts column, marks ts as event-time attribute
) WITH (
    'connector' = 'pulsar',
    'topics' = 'persistent://public/default/clickstream-feed',
    'service-url' = 'pulsar://pulsar:6650',
    'source.start.message-id' = 'earliest' ,
    'format' = 'json',
    'json.timestamp-format.standard' = 'ISO-8601'
);
```

The above snippet declares five fields based on the data format I shared earlier. In addition, it uses the computed 
column syntax and built-in `PROCTIME()` function to declare a virtual column that generates the processing-time attribute. 
It also uses the `WATERMARK` syntax to declare the watermark strategy on the ts field (tolerate 5-seconds out-of-order). 
Therefore, the ts field becomes an event-time attribute, allowing us to perform time-based analysis on the dataset.

After creating the user_behavior table in the SQL CLI, run `SHOW TABLES;` and `DESCRIBE user_behavior;` to see registered 
tables and table details. You can also query the table to confirm the Pulsar connector is working as expected.

![00-Flink-Query-User-Behavior.png](images%2F00-Flink-Query-User-Behavior.png)


Hourly Trading Volume
--

Now that we have defined a database table for our streaming dataset, it is time to start doing some analysis. The first
thing we want to calculate is the number of buy events that occur over an hourly period. This information is useful in
helping us determine which hours are most profitable for our online business it also helps us model user buying patterns
that can be used to track the impact of future marketing campaigns over our "baseline" buying activity, etc.

3️⃣ Create the Hourly Trading Volume table using DDL
---

Let’s create an Elasticsearch result table in the SQL CLI. We need two columns in this case: hour_of_day and buy_cnt 
(trading volume).

```sql
CREATE TABLE buy_cnt_per_hour (
    hour_of_day BIGINT,
    buy_cnt BIGINT
) WITH (
    'connector' = 'elasticsearch-7', -- using elasticsearch connector
    'hosts' = 'http://elasticsearch:9200',  -- elasticsearch address
    'index' = 'buy_cnt_per_hour'  -- elasticsearch index name, similar to database table name
);
```

As you can see, this table has two fields, the hour_of_day, which ranges from 0 to 23, and buy_cnt, which sums up the number
of "buy" events that occurred during the corresponding hour of the day.

4️⃣ Submitting a Continuous Query to Populate the Hourly Trading Volume table
---

The hourly trading volume is the number of “buy” behaviors completed each hour. Therefore, we can use a `TUMBLE` window 
function to assign data into hourly windows. Then, we count the number of “buy” records in each window. To implement 
this, we can filter out the “buy” data first and then apply `COUNT(*)`.

```sql
INSERT INTO buy_cnt_per_hour
SELECT HOUR(TUMBLE_START(ts, INTERVAL '1' HOUR)), COUNT(*)
FROM user_behavior
WHERE behavior = 'buy'
GROUP BY TUMBLE(ts, INTERVAL '1' HOUR);
```

Here, we use the built-in `HOUR` function to extract the value for each hour in the day from a `TIMESTAMP` column. 
Use `INSERT INTO` to start a Flink SQL job that continuously writes results into the Elasticsearch `buy_cnt_per_hour` index. 
The Elasticearch result table can be thought of as a materialized view of the query.

After running the query in the Flink SQL CLI, you can observe the submitted task on the [Flink Web UI](http://localhost:8081). 
This task is a streaming task and therefore runs continuously.

![01-Flink-Running-Job.png](images%2F01-Flink-Running-Job.png)

You can double click on the Job in the UI to get an expanded view of the job, including the individual tasks that are 
executed as part of the query, the number of records processed, and the status of the job. In the event of a processing
error, you can view the exceptions from this screen as well.

![02-Flink-Job-Details.png](images%2F02-Flink-Job-Details.png)

5️⃣ Visualize the Hourly Trading Volume in Kibana
---

Since we are writing the results of this query to an Elasticsearch sink, we will need to go the 
[Kibana UI](http://localhost:5601/app/home#/) to visualize the results.

The first step is to create an index pattern in Kibana by navigating to the `Stack Management / index patterns` page and
creating an index named `buy_cnt_per_hour` (this has to match in the Elasticsearch index name we defined in the DDL)

![03-Kibana-create-buy-count-index-pattern.png](images%2F03-Kibana-create-buy-count-index-pattern.png)

When you finish creating the index pattern, you should see a screen like the following that shows all searchable fields 
on the index.

![04-Kibana-buy-count-index.png](images%2F04-Kibana-buy-count-index.png)

The next step is to create a visualization on the index we just created by navigating to the `Visualize` page and clicking
on the "Create New Visualization" button

![05-Create-Visualization.png](images%2F05-Create-Visualization.png)

Then select "area" from the choices shown and using the settings shown in the image below for the X and Y axes. For the 
Y-axis, we want to use the `MAX(buy_cnt)` and for the X-axis we want to bucket the results by `hour_of_day` and display
all 24 of them. Once you have finished creating the visualization, be sure to save it as "Hourly Trading Volume"

![06-Buy_Count_Visualization.png](images%2F06-Buy_Count_Visualization.png)

Cumulative Users
--
Another interesting metric we can calculate from the streaming dataset is the cumulative number of unique visitors (UV)
that visit our website every hour. This information is useful in helping us determine which hours of the day have the most
visitor traffic.

6️⃣ Create the Cumulative Unique Visitors table using DDL
---

Let’s create another Elasticsearch table in the SQL CLI to store the UV results. This table contains 3 columns: `date`, 
`time` and `cumulative UVs`. The `date_str` and `time_str` column are defined as primary key, the Elasticsearch sink will 
use them to calculate the document ID and work in upsert mode to update UV values under the document ID.

```sql
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
```

7️⃣ Submitting a Continuous Query to Populate the Cumulative Unique Visitors table
---

We can extract the date and time using `DATE_FORMAT` function based on the `ts` field. We only need to report every 10 
minutes. So, we can use `SUBSTR` and the string concat function `||` to convert the time value into a 10-minute interval
time string, such as `12:00`, `12:10`. Next, we group data by `date_str` and perform a `COUNT DISTINCT` aggregation on 
`user_id` to get the current cumulative UV in this day. Additionally, we perform a `MAX` aggregation on `time_str` 
field to get the current stream time: the maximum event time observed so far. As the maximum time is also a part of the 
primary key of the sink, the final result is that we will insert a new point into the elasticsearch every 10 minutes. 

```sql
INSERT INTO cumulative_uv
SELECT date_str, MAX(time_str), COUNT(DISTINCT user_id) as uv
FROM (
  SELECT
    DATE_FORMAT(ts, 'yyyy-MM-dd') as date_str,
    SUBSTR(DATE_FORMAT(ts, 'HH:mm'),1,4) || '0' as time_str,
    user_id
  FROM user_behavior)
GROUP BY date_str;
```

After submitting this query, you can observe the submitted task on the [Flink Web UI](http://localhost:8081). This task 
is a streaming task and therefore runs continuously. You can navigate into the Flink job details as you did with the previous
query and drill-down into the individual task-level view as shown below.

![07-Cumulative_UV-Query-Job-Details.png](images%2F07-Cumulative_UV-Query-Job-Details.png)

8️⃣ Visualize the Cumulative Unique Visitors Data in Kibana
---

After submitting this query, we create a cumulative_uv index pattern in Kibana. We then create a “Line” (line graph) on 
the dashboard, by selecting the cumulative_uv index, and drawing the cumulative UV curve according to the configuration 
on the left side of the following figure before finally saving the curve.

First, you will need to create an index named `cumulative_uv` in order to access the data being published to the 
Elasticsearch index from the Flink SQL query you submitted in the previous step. 

![08-Cumulatiive_Unique_Visitor-Index.png](images%2F08-Cumulatiive_Unique_Visitor-Index.png)

Next, you can create a new visualization in Kibana on the index we just created by navigating to the `Visualize` page 
and clicking on the "Create New Visualization" button. This time, choose the "line" type as shown.

![09-Create-New-Line-Visualization.png](images%2F09-Create-New-Line-Visualization.png)

For the Y-axis, we want to use the `MAX(uv)` and for the X-axis we want to bucket the results by `time_str.keyword` and 
display 150 of them. Once you have finished creating the visualization, be sure to save it as "Unique Visitors"

![10-Unique-Vistors-Visualization.png](images%2F10-Unique-Vistors-Visualization.png)

Top Categories
--
The last visualization represents the category rankings to inform us on the most popular categories in our e-commerce site. 
Since our data source offers events for more than 5,000 categories without providing any additional significance to our 
analytics, we would like to reduce it so that it only includes the top-level categories. 

9️⃣ Create a table in the SQL CLI to make the data in MySQL accessible to Flink SQL.
---

We will use the data in our MySQL database by joining it as a dimension table with our Kafka events to map sub-categories
to top-level categories.

```sql
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
```
The underlying JDBC connector implements the LookupTableSource interface, so the created JDBC table category_dim can be 
used as a temporal table (i.e. lookup table) out-of-the-box in the data enrichment.

🔟  Create an Elasticsearch table to store the category statistics.
---

In addition, create an Elasticsearch table to store the category statistics.

```sql
CREATE TABLE top_category (
    category_name STRING PRIMARY KEY NOT ENFORCED,
    buy_cnt BIGINT
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://elasticsearch:9200',
    'index' = 'top_category'
);
```

In order to enrich the category names, we use Flink SQL’s temporal table joins to join a dimension table.

1️⃣1️⃣ Create a Logical View
---
Additionally, we use the `CREATE VIEW` syntax to register the query as a logical view, allowing us to easily reference 
this query in subsequent queries and simplify nested queries. Please note that creating a logical view does not trigger 
the execution of the job and the view results are not persisted. Therefore, this statement is lightweight and does not 
have additional overhead.

```sql
CREATE VIEW rich_user_behavior AS
SELECT U.user_id, U.item_id, U.behavior, C.parent_category_name as category_name
FROM user_behavior AS U LEFT JOIN category_dim FOR SYSTEM_TIME AS OF U.proctime AS C
ON U.category_id = C.sub_category_id;
```

1️⃣2️⃣ Submit a Flink SQL query to populate the Top Categories Table
---
Finally, we group the dimensional table by category name to count the number of buy events and write the result to 
Elasticsearch’s top_category index.

```sql
INSERT INTO top_category
SELECT category_name, COUNT(*) buy_cnt
FROM rich_user_behavior
WHERE behavior = 'buy'
GROUP BY category_name;
```

After submitting this query, you can observe the submitted task on the [Flink Web UI](http://localhost:8081). This task
is a streaming task and therefore runs continuously.

![11-top-categories-flink-job.png](images%2F11-top-categories-flink-job.png)

1️⃣3️⃣ Visualize the Top Categories Data in Kibana 
---

After submitting the query, you can create a top_category index pattern in Kibana. 

![12-top-category-index.png](images%2F12-top-category-index.png)

Next, you can create a “Horizontal Bar”(bar graph) on the dashboard, by selecting the top_category index and drawing 
the category ranking according to the configuration on the left side of the following diagram before finally saving the list.

![13-Top-Categories-Visualization.png](images%2F13-Top-Categories-Visualization.png)

# Summary

In this example, we described how to use Flink SQL to integrate Kafka, MySQL, Elasticsearch, and Kibana to quickly build
a real-time analytics application. The entire process can be completed using standard SQL syntax, without a line of Java
or Scala code. This use case can serve as a pattern for your future real-time streaming applications.


