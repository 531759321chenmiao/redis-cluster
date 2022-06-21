# Redis 最佳配置说明

+ 限制最大内存占用
+ 配置数据备份策略
+ 内存 **OMM**, 配置 key 的淘汰策略

#### 内存(unit byte)
```conf
maxmemory = 536870912
```

#### 淘汰策略

+ noeviction: 返回错误，不删除任何键值
+ allkeys-lru: 尝试回收最少使用的键值（LRU算法）
+ volatile-lru: 尝试回收最少使用的键值，但仅限于在过期键值集合中
+ allkeys-random: 回收随机的键值
+ volatile-random: 回收随机的键值，但仅限于在过期键值集合中
+ volatile-ttl: 回收过期集合的键值，并优先回收存活时间较短的键值
+ allkeys-lfu: 回收最少使用频次的键值（LFU算法）
+ volatile-lfu: 回收最少使用频次的键值（LFU算法），但仅限于在过期键值集合中

```conf
maxmemory-policy allkeys-lfu
```

#### 持久化
```conf
appendonly yes

appendfilename "appendonly.aof"

# PVC mount name
appenddirname "/data"

# appendfsync always
appendfsync everysec
```

#### 碎片整理相关
```conf
# Active defragmentation is disabled by default
activedefrag yes

# Minimum amount of fragmentation waste to start active defrag
active-defrag-ignore-bytes 100mb

# Minimum percentage of fragmentation to start active defrag
active-defrag-threshold-lower 10

# Maximum percentage of fragmentation at which we use maximum effort
active-defrag-threshold-upper 100

# Minimal effort for defrag in CPU percentage, to be used when the lower
# threshold is reached
active-defrag-cycle-min 5

# Maximal effort for defrag in CPU percentage, to be used when the upper
# threshold is reached
active-defrag-cycle-max 75

# Maximum number of set/hash/zset/list fields that will be processed from
# the main dictionary scan
active-defrag-max-scan-fields 1000
```
## 扩容需要修改的配置
+ 需要修改配置文件对应的 **maxmemory** 占用真实分配的内存的 **90%**
+ 修改申请的 PVC 的大小, 大小为分配的物理内存的 3 倍
