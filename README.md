MySQL orzdba go version performance analyzer

![](https://github.com/lflxp/lflxp-orzdba/blob/master/asset/mysql.png)
![](https://github.com/lflxp/lflxp-orzdba/blob/master/asset/mysql2.png)

# Install

```
git clone https://github.com/lflxp/lflxp-orzdba
cd lflxp-orzdba
make install
lflxp-orzdba -h
```

## Feature

* 本地/远程连接
* Databases
* Variables
    * binlog_format
    * open_files_limit
    * ...
* dashboard
* test
    * GetHostAndIps 
    * GetShowDatabases   
    * GetShowGlobalVariables  
    * GetShowVariables           
    * GetShowStatus        
    * GetShowGlobalStatus     
* processlist
* status
    * innodb信息
    * CRUD信息
    * Net IO
    * Slave
    * Threads
    * Semi

## 使用

mysql是showme终端GUI显示，提供动态参数提示功能。

* lflxp-orzdba status -H 127.0.0.1 -p system -innodb -com -lazy
* lflxp-orzdba status -p $pwd -lazy -l -s -d -n -c

# Usage

`Format`

```
Usage of lflxp-orzdba:
  -B    Print Bytes received from/send to MySQL(Bytes_received,Bytes_sent).
  -H string
        Mysql连接主机，默认127.0.0.1 (default "127.0.0.1") (default "127.0.0.1")
  -L    Print to Logfile. (default "none")
  -N    打印网络详细信息
  -P string
        Mysql连接端口,默认3306 (default "3306") (default "3306")
  -S string
        mysql socket连接文件地址 (default "/tmp/mysql.sock") (default "/tmp/mysql.sock")
  -T    Print Threads Status(Threads_running,Threads_connected,Threads_created,Threads_cached).
  -c    打印Cpu info
  -com
        Print MySQL Status(Com_select,Com_insert,Com_update,Com_delete).
  -d    打印Disk info
  -db string
        Mysql 指定databases,默认：mysql (default "mysql")
  -hit
        Print Innodb Hit%.
  -innodb
        Print InnodbInfo(include -t,-innodb_pages,-innodb_data,-innodb_log,-innodb_status)
  -innodb_data
        Print Innodb Data Status(Innodb_data_reads/writes/read/written)
  -innodb_log
        Print Innodb Log  Status(Innodb_os_log_fsyncs/written)
  -innodb_pages
        Print Innodb Buffer Pool Pages Status(Innodb_buffer_pool_pages_data/free/dirty/flushed)
  -innodb_rows
        Print Innodb Rows Status(Innodb_rows_inserted/updated/deleted/read).
  -innodb_status
        Print Innodb Status from Command: 'Show Engine Innodb Status'
  -l    打印Load info
  -lazy
        Print Info  (include -t,-l,-c,-s,-com,-hit).
  -mysql
        Print MySQLInfo (include -t,-com,-hit,-T,-B).
  -n    打印net info
  -nocolor
        不显示颜
  -p string
        Mysql 密码 (default "system")
  -s    打印swap info
  -semi
        半同步监控
  -slave
        打印Slave info
  -t    打印当前时间
  -u string
        Mysql 用户名,默认: root (default "root"
```

`For Coder Demo`

```go
package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	"github.com/lflxp/lflxp-orzdba/pkg"
)

var (
	printByte     bool
	host          string
	log           bool
	port          string
	user          string
	pwd           string
	db            string
	sockpath      string
	thread        bool
	com           bool
	hit           bool
	nocolor       bool
	time          bool
	innodb        bool
	innodb_rows   bool
	innodb_pages  bool
	innodb_data   bool
	innodb_log    bool
	innodb_status bool
	mysql         bool
	lazy          bool
	semi          bool
	slave         bool
)

func init() {
	flag.Bool("l", false, "打印Load info")
	flag.Bool("c", false, "打印Cpu info")
	flag.Bool("s", false, "打印swap info")
	flag.Bool("d", false, "打印Disk info")
	flag.Bool("n", false, "打印net info")
	flag.Bool("N", false, "打印网络详细信息")
	flag.StringVar(&host, "H", "127.0.0.1", "Mysql连接主机，默认127.0.0.1 (default \"127.0.0.1\")")
	flag.StringVar(&port, "P", "3306", "Mysql连接端口,默认3306 (default \"3306\")")
	flag.StringVar(&user, "u", "root", "Mysql 用户名,默认: root")
	flag.StringVar(&pwd, "p", "system", "Mysql 密码")
	flag.StringVar(&db, "db", "mysql", "Mysql 指定databases,默认：mysql")
	flag.StringVar(&sockpath, "S", "/tmp/mysql.sock", "mysql socket连接文件地址 (default \"/tmp/mysql.sock\")")
	flag.BoolVar(&log, "L", false, "Print to Logfile. (default \"none\")")
	flag.BoolVar(&printByte, "B", false, "Print Bytes received from/send to MySQL(Bytes_received,Bytes_sent).")
	flag.BoolVar(&thread, "T", false, "Print Threads Status(Threads_running,Threads_connected,Threads_created,Threads_cached).")
	flag.BoolVar(&com, "com", false, "Print MySQL Status(Com_select,Com_insert,Com_update,Com_delete).")
	flag.BoolVar(&hit, "hit", false, "Print Innodb Hit%.")
	flag.BoolVar(&nocolor, "nocolor", false, "不显示颜")
	flag.BoolVar(&time, "t", false, "打印当前时间")
	flag.BoolVar(&innodb, "innodb", false, "Print InnodbInfo(include -t,-innodb_pages,-innodb_data,-innodb_log,-innodb_status)")
	flag.BoolVar(&innodb_rows, "innodb_rows", false, "Print Innodb Rows Status(Innodb_rows_inserted/updated/deleted/read).")
	flag.BoolVar(&innodb_pages, "innodb_pages", false, "Print Innodb Buffer Pool Pages Status(Innodb_buffer_pool_pages_data/free/dirty/flushed)")
	flag.BoolVar(&innodb_data, "innodb_data", false, "Print Innodb Data Status(Innodb_data_reads/writes/read/written)")
	flag.BoolVar(&innodb_log, "innodb_log", false, "Print Innodb Log  Status(Innodb_os_log_fsyncs/written)")
	flag.BoolVar(&innodb_status, "innodb_status", false, "Print Innodb Status from Command: 'Show Engine Innodb Status'")
	flag.BoolVar(&mysql, "mysql", false, "Print MySQLInfo (include -t,-com,-hit,-T,-B).")
	flag.BoolVar(&lazy, "lazy", false, "Print Info  (include -t,-l,-c,-s,-com,-hit).")
	flag.BoolVar(&semi, "semi", false, "半同步监控")
	flag.BoolVar(&slave, "slave", false, "打印Slave info")
	flag.Parse()
}

func main() {
	fmt.Println(fmt.Sprintf("mysql %s", strings.Join(os.Args[1:], " ")))
	err := pkg.BeforeRun(fmt.Sprintf("mysql %s", strings.Join(os.Args[1:], " ")))
	if err != nil {
		panic(err)
	}
}
```
