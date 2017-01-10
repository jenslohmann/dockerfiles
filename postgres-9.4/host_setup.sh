cat /etc/postgresql/9.4/main/pg_hba.conf | grep '^local' > /tmp/pg_hba.conf_orig
cat /etc/postgresql/9.4/main/pg_hba.conf | grep '^host' >> /tmp/pg_hba.conf_orig

cat /etc/postgresql/9.4/main/pg_hba.conf | grep -v '^local' | grep -v '^host' > /tmp/pg_hba.conf
echo "local   all         all                               trust" >> /tmp/pg_hba.conf
mv /tmp/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
chown postgres /etc/postgresql/9.4/main/pg_hba.conf

echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf

service postgresql start

# wait for postgres to come up
until `nc -z 127.0.0.1 5432`; do
    ps -fe|grep post
    echo "$(date) - waiting for postgres (localhost-only)..."
    sleep 1
done
echo "postgres ready"

createuser -U postgres -D wildflyas
createdb -U postgres -O wildflyas wildflydb "WildFly AS infrastructure database"
psql -U postgres -c "alter user wildflyas with password 'wildflyas'"
  
cat /etc/postgresql/9.4/main/pg_hba.conf | grep -v '^local' > /tmp/pg_hba.conf
cat /tmp/pg_hba.conf_orig >> /tmp/pg_hba.conf
echo "host    wildflydb       wildflyas       127.0.0.1/32            md5" >> /tmp/pg_hba.conf
echo "host    wildflydb       wildflyas       172.17.0.0/24           md5" >> /tmp/pg_hba.conf
echo "host    wildflydb       wildflyas       192.168.0.0/24          md5" >> /tmp/pg_hba.conf

mv /tmp/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
chown postgres /etc/postgresql/9.4/main/pg_hba.conf

