# sqlline

Very simple packaging of [sqlline](https://github.com/julianhyde/sqlline) with a set of drivers.

Demonstrates:

1. Packaging zip containing program and drivers
2. Configure the META-INF/MANIFEST.MF to reference the libraries and the main class
3. Allows packaging multiple different drivers by changing the pom.xml

Build the module with

```
$ mvn package
```

Unpack the zip file in target.

```
$ java -jar sqlline.jar -n sa -p changeit -u 'jdbc:sqlserver://localhost;trustServerCertificate=true' -e 'SELECT @@VERSION AS VERSION'
+---------------------------------------------------------------------------+
|                                  VERSION                                  |
+---------------------------------------------------------------------------+
| Microsoft SQL Server 2022 (RTM-CU12-GDR) (KB5036343) - 16.0.4120.1 (X64)
        Mar 18 2024 12:02:14
        Copyright (C) 2022 Microsoft Corporation
        Express Edition (64-bit) on Linux (Ubuntu 22.04.4 LTS) <X64> |
+---------------------------------------------------------------------------+
1 row selected (0.063 seconds)
sqlline version 1.12.0
```

```
$ java -jar sqlline.jar -n scott -p tiger -u 'jdbc:oracle:thin:@localhost:1521' -e 'SELECT * FROM V$VERSION'
Transaction isolation level TRANSACTION_REPEATABLE_READ is not supported. Default (TRANSACTION_READ_COMMITTED) will be used instead.
+---------------------------------------------------------------------------+
|                                  BANNER                                   |
+---------------------------------------------------------------------------+
| Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production |
| PL/SQL Release 11.2.0.2.0 - Production                                    |
| CORE  11.2.0.2.0      Production                                                |
| TNS for Linux: Version 11.2.0.2.0 - Production                            |
| NLSRTL Version 11.2.0.2.0 - Production                                    |
+---------------------------------------------------------------------------+
5 rows selected (0.059 seconds)
sqlline version 1.12.0
```

```
$ java -jar sqlline.jar -n postgres -p postgres -u 'jdbc:postgresql://localhost/' -e 'SELECT VERSION()'
+---------------------------------------------------------------------------------------------------------------------+
|                                                       version                                                       |
+---------------------------------------------------------------------------------------------------------------------+
| PostgreSQL 16.3 (Debian 16.3-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit |
+---------------------------------------------------------------------------------------------------------------------+
1 row selected (0.007 seconds)
sqlline version 1.12.0
```

```
$ java -jar sqlline.jar -n root -p mysql -u 'jdbc:mysql://localhost/mysql' -e 'SELECT VERSION()'
+-----------+
| VERSION() |
+-----------+
| 8.4.0     |
+-----------+
1 row selected (0.01 seconds)
sqlline version 1.12.0
```

```
+ java -jar sqlline.jar -n foo -p bar -u 'jdbc:sqlite:test.db' -e 'SELECT SQLITE_VERSION()'
Transaction isolation level TRANSACTION_REPEATABLE_READ is not supported. Default (TRANSACTION_SERIALIZABLE) will be used instead.
+------------------+
| SQLITE_VERSION() |
+------------------+
| 3.48.0           |
+------------------+
1 row selected (0.006 seconds)
sqlline version 1.12.0
```
