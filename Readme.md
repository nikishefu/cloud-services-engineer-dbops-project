# dbops-project
Проектная работа дисциплины DBOps

### Запросы, выполненные для подготовки базы данных store
```sql
CREATE DATABASE store;
CREATE USER nikita WITH PASSWORD '*****';
GRANT ALL PRIVILEGES ON DATABASE store TO nikita;
ALTER DATABASE store OWNER TO nikita;
\c store
GRANT USAGE, CREATE ON SCHEMA public TO nikita;
ALTER SCHEMA public OWNER TO nikita;
```

### Запрос для получения количества проданных сосисок за каждый день предыдущей недели
```sql
SELECT
    o.date_created,
    SUM(op.quantity) AS total_sausages_daily
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created
ORDER BY o.date_created;
```

Время выполнения без индексов: ~39 секунд `Time: 39050.734 ms (00:39.051)`
```
 Finalize GroupAggregate  (cost=266218.08..266241.13 rows=91 width=12) (actual time=35965.613..35973.927 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=266218.08..266239.31 rows=182 width=12) (actual time=35965.578..35973.888 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=265218.05..265218.28 rows=91 width=12) (actual time=35945.188..35945.192 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=265214.18..265215.09 rows=91 width=12) (actual time=35945.163..35945.168 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=148376.73..264675.22 rows=107793 width=8) (actual time=18698.689..35925.589 rows=85190 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.13 rows=4166613 width=12) (actual time=0.944..16169.944 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=147029.29..147029.29 rows=107795 width=12) (actual time=18697.059..18697.060 rows=85190 loops=3)
                                 Buckets: 262144  Batches: 1  Memory Usage: 14048kB
                                 ->  Parallel Seq Scan on orders o  (cost=0.00..147029.29 rows=107795 width=12) (actual time=15.575..18653.620 rows=85190 loops=3)
                                       Filter: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Rows Removed by Filter: 3248143
 Planning Time: 0.342 ms
 JIT:
   Functions: 54
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 4.094 ms, Inlining 0.000 ms, Optimization 1.274 ms, Emission 30.057 ms, Total 35.425 ms
 Execution Time: 35974.782 ms
(29 rows)

Time: 36016.514 ms (00:36.017)
```

Время выполнения после создания индексов: ~1.3 секунды `Time: 1377.172 ms (00:01.377)`
```
 Finalize GroupAggregate  (cost=188588.52..188611.57 rows=91 width=12) (actual time=11754.906..11764.313 rows=7 loops=1)
   Group Key: o.date_created
   ->  Gather Merge  (cost=188588.52..188609.75 rows=182 width=12) (actual time=11754.875..11764.278 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Sort  (cost=187588.49..187588.72 rows=91 width=12) (actual time=11724.455..11724.460 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=187584.62..187585.53 rows=91 width=12) (actual time=11724.418..11724.423 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Parallel Hash Join  (cost=70746.48..187045.65 rows=107794 width=8) (actual time=8303.400..11702.763 rows=85190 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.67 rows=4166667 width=12) (actual time=0.029..2244.660 rows=3333333 loops=3)
                           ->  Parallel Hash  (cost=69399.06..69399.06 rows=107794 width=12) (actual time=8301.784..8301.786 rows=85190 loops=3)
                                 Buckets: 262144  Batches: 1  Memory Usage: 14080kB
                                 ->  Parallel Bitmap Heap Scan on orders o  (cost=3548.18..69399.06 rows=107794 width=12) (actual time=30.125..8266.490 rows=85190 loops=3)
                                       Recheck Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Heap Blocks: exact=21612
                                       ->  Bitmap Index Scan on orders_status_date_idx  (cost=0.00..3483.50 rows=258706 width=0) (actual time=34.832..34.832 rows=255570 loops=1)
                                             Index Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
 Planning Time: 3.540 ms
 JIT:
   Functions: 57
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 3.207 ms, Inlining 0.000 ms, Optimization 1.397 ms, Emission 33.058 ms, Total 37.662 ms
 Execution Time: 11765.482 ms
(31 rows)

Time: 11892.957 ms (00:11.893)
```

Время выполнения запроса сократилось примерно в 28 раз.
