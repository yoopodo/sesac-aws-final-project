
curl -LO https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.32-winx64.zip


mkdir mysql
unzip mysql-8.0.32-winx64.zip -d ./mysql

cd C:\Users\user\Desktop\플젝\mysql\mysql-8.0.32-winx64\bin mysql -u admin -pIt12345! -h admin.clprkh42cbck.ap-northeast-2.rds.amazonaws.com -P 3306

create database Wordpress;
exit