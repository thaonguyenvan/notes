# Cài đặt Nukeviet trên CentOS 7

- Cài đặt LAMP

- Tải về nukeviet

`yum install wget unzip -y`

Tải nukeviet [tại đây](https://nukeviet.vn/download/)

`wget https://github.com/nukeviet/nukeviet/releases/download/4.3.07/nukeviet4.3.07setup.zip`

Giải nén rồi move vào thư mục `/var/www/html`

```
unzip nukeviet4.3.07setup.zip
mv ./nukeviet/* /var/www/html
chown -R apache:apache /var/www/html
rm -f /var/www/html/index.html
```

- chỉnh lại rewrite trong file `/etc/httpd/conf/httpd.conf`

```
<Directory "/var/www/html">
  AllowOverride All
</Directory>
```
