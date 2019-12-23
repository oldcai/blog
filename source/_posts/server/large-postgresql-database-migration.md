---
title: Better Way to Migrate an In-Production PostgreSQL Database to a Different Data Center or Cloud
date: 2018-11-28 01:05:00
categories:
  - Server
tags:
  - postgresql
---

    To practice this guide, PostgreSQL version should be at least 9.6
    
## TL;DR:
First, setup a master-slave replication for PostgreSQL.
Then switch the slave server to master.
    
## Longer Story



### Situation

In our case, the database is almost 300GB, it would take at least 3 hours to migrate to a new server, including export, transfer and import time.

Sometimes, it's acceptable to shutdown sites or apps for a short time to do some maintain, but what if the data grows and the migration may takes days or weeks?

For services in-production, you would expect it always online.

Yes, we hope we can keep the service online while transferring data and switch it in minutes.

### Struggles

I have checked [How to Set-Up Master-Slave Replication for PostgreSQL 9.6 on Ubuntu 16.04](https://www.howtoforge.com/tutorial/how-to-set-up-master-slave-replication-for-postgresql-96-on-ubuntu-1604/) and tried many times of making replicas on the new server but always fail.
It reports the same error: `requested WAL segment 00000001000001CD00000055 has already been removed` every time.

After did some research and I found that's because my database is too large, transfer would take too much time, and the `wal_keep_segments` is not enough for that long time of transferring files.

### Quick Fix

Maybe it can be fixed by increasing `wal_keep_segments` to a greater number, but that introduces another problem: we need to calculate the proper number, enough keeping WAL files after the long and unsure time of data transferring, and not too big that would slow down the running service.
Of course, that's not **the best solution**.

### Better Solutions

Later, I found a more reliable and more robust solution [in PostgreSQL's mail list](https://www.postgresql.org/message-id/8154f0c1-5ac3-8769-d0b6-81c65c666dd7%40dalibo.com):
> You could use `-X stream` instead of `--xlog` (which is an alias for `-X fetch`). This consumes two wal senders instead of one, but greatly reduce the probability of having this error.
> The only way to really prevent this error is using replication slots, but the support for pg_basebackup is only available in 9.6.

I would show you how to use `replication slots` and use stream to transfer the transaction log files(WAL files) below.

## Step 1 - Enable Replication Slots
PostgreSQL disabled replication slots by default, we need to setup by adding lines to the bottom of `/var/lib/pgsql/9.6/data/postgresql.conf` below:

```
synchronous_standby_names = 'slave001'
wal_level = replica
hot_standby = on
max_wal_senders = 2
wal_keep_segments = 10
max_replication_slots = 2
synchronous_commit = local
```

Then restart the PostgreSQL service by `service postgresql-9.6 restart`.

## Step 2 - Creating a Replication Slot

Connect to master PostgreSQL by `sudo -u postgres psql`
Then execute
```
select pg_create_physical_replication_slot('slot_for_migration', true);
```
We can check the progress by selecting:
```
select * from pg_replication_slots;
```

If you want to delete this slot later after migration, you can use this command:
```
'select pg_drop_replication_slot('slot_for_migration');
```
Use it after remove the initial prime if you know what this command would do.

## Step 3 - Create a User for Replication

Run commands with psql as user postgres on the master side:

```
CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'your password here';
```

Add these lines below to master's pg_hba.conf

```
# Localhost
host    replication     replica          127.0.0.1/32              md5
 
# PostgreSQL Master IP address
host    replication     replica          10.10.10.10/32            md5
 
# PostgreSQL SLave IP address
host    replication     replica          10.10.10.11/32            md5
```

Then restart the PostgreSQL server.

## Step 4 - Transfer Data From Another Data Center

Now, run on the slave server:
```
pg_basebackup -h 10.10.10.10 -p 5432 -S slot_for_migration -U replica -D /var/lib/pgsql/9.6/data --checkpoint=fast -R -P -X stream
```

It would ask you to type password.
Now, you need to wait until it finishes syncing. This step is very time consuming, usually takes hours or even days.

## Step 5 - Restart The Slave PostgreSQL Server

After syncing finished, run `service postgresql-9.6 restart`, there should be a sync before the standby server up and run, wouldn't take too much time if you didn't leave the console too long after step 4.

We are almost there. Now, we can connect to the server by psql and do some check, make sure our data are the latest.

## Step 6 - Promote the Slave to Master Like a King

Finally, we still need to promote our slave postgresql server to master before we finish our database migration.

```
pg_ctl promote -D
```