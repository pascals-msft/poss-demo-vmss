# must be run as root

# while ( ! (find /var/log/azure/Microsoft.OSTCExtensions.LinuxDiagnostic/*/extension.log | xargs grep "Start mdsd"));
# do
#   sleep 5 
# done 


# --- NGINX

cd /tmp
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

echo deb http://nginx.org/packages/debian/ xenial nginx >> /etc/apt/sources.list
echo deb-src http://nginx.org/packages/debian/ xenial nginx >> /etc/apt/sources.list

apt-get -y update
apt-get -y install nginx

cat << 'END' > /etc/nginx/sites-available/default
server {
	listen 80;
	location / {
		proxy_pass http://localhost:5004/;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection keep-alive;
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;
	}
	location /api/products {
		proxy_pass http://localhost:5001/api/products;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection keep-alive;
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;
	}
	location /api/ratings {
		proxy_pass http://localhost:5002/api/ratings;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection keep-alive;
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;
	}
	location /api/recommandations {
		proxy_pass http://localhost:5003/api/recommandations;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection keep-alive;
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;
	}
}
END

nginx -s reload

# --- .NET Core (https://www.microsoft.com/net/core#ubuntu) + tools

echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
apt-get -y update
apt-get -y install dotnet-dev-1.0.0-preview2-003131
# apt-get -y install dotnet-dev-1.0.0-preview2.1-003155
apt-get -y install nodejs-legacy
apt-get -y install npm
npm install npm
npm install -g gulp bower

# --- Application

cd /var
git clone https://github.com/jcorioland/CloudArchi-Samples.git
cd /var/CloudArchi-Samples
git checkout parisoss

cd /var/CloudArchi-Samples/src/ProductsApi
dotnet restore
dotnet build
dotnet publish

cd /var/CloudArchi-Samples/src/RatingsApi
dotnet restore
dotnet build
dotnet publish

cd /var/CloudArchi-Samples/src/RecommandationsApi/
dotnet restore
dotnet build
dotnet publish

cd /var/CloudArchi-Samples/src/ShopFront
dotnet restore
dotnet build
dotnet publish

cd /tmp

# --- services

cat << 'EOF' > /etc/systemd/system/kestrel-ProductsApi.service
[Unit]
Description=Sample ProductsApi

[Service]
ExecStart=/usr/bin/dotnet /var/CloudArchi-Samples/src/ProductsApi/bin/Debug/netcoreapp1.0/publish/ProductsApi.dll
Restart=always
RestartSec=10
SyslogIdentifier=ProductsApi
User=www-data
Environment="ASPNETCORE_ENVIRONMENT=Production" "SHOP_PRODUCTS_API_PORT=5001" "SHOP_RATINGS_API_PORT=5002" "SHOP_RECOMMANDTIONS_API_PORT=5003" "SHOP_FRONT_PORT=5004"

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /etc/systemd/system/kestrel-RatingsApi.service
[Unit]
Description=Sample RatingsApi

[Service]
ExecStart=/usr/bin/dotnet /var/CloudArchi-Samples/src/RatingsApi/bin/Debug/netcoreapp1.0/publish/RatingsApi.dll
Restart=always
RestartSec=10
SyslogIdentifier=RatingsApi
User=www-data
Environment="ASPNETCORE_ENVIRONMENT=Production" "SHOP_PRODUCTS_API_PORT=5001" "SHOP_RATINGS_API_PORT=5002" "SHOP_RECOMMANDTIONS_API_PORT=5003" "SHOP_FRONT_PORT=5004"

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /etc/systemd/system/kestrel-RecommandationsApi.service
[Unit]
Description=Sample RecommandationsApi

[Service]
ExecStart=/usr/bin/dotnet /var/CloudArchi-Samples/src/RecommandationsApi/bin/Debug/netcoreapp1.0/publish/RecommandationsApi.dll
Restart=always
RestartSec=10
SyslogIdentifier=RecommandationsApi
User=www-data
Environment="ASPNETCORE_ENVIRONMENT=Production" "SHOP_PRODUCTS_API_PORT=5001" "SHOP_RATINGS_API_PORT=5002" "SHOP_RECOMMANDTIONS_API_PORT=5003" "SHOP_FRONT_PORT=5004"

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /etc/systemd/system/kestrel-ShopFront.service
[Unit]
Description=Sample ShopFront

[Service]
ExecStart=/bin/sh -c /var/CloudArchi-Samples/ShopFront.sh
Restart=always
RestartSec=10
SyslogIdentifier=ShopFront
User=www-data
Environment="ASPNETCORE_ENVIRONMENT=Production" "SHOP_PRODUCTS_API_PORT=5001" "SHOP_RATINGS_API_PORT=5002" "SHOP_RECOMMANDTIONS_API_PORT=5003" "SHOP_FRONT_PORT=5004"

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /var/CloudArchi-Samples/ShopFront.sh
export ASPNETCORE_ENVIRONMENT=Production
export SHOP_FRONT_PORT=5004
cd /var/CloudArchi-Samples/src/ShopFront/bin/Debug/netcoreapp1.0/publish/
/usr/bin/dotnet ShopFront.dll
EOF
chmod +x /var/CloudArchi-Samples/ShopFront.sh

systemctl enable kestrel-ProductsApi.service
systemctl enable kestrel-RatingsApi.service
systemctl enable kestrel-RecommandationsApi.service
systemctl enable kestrel-ShopFront.service

systemctl start kestrel-ProductsApi.service
systemctl start kestrel-RatingsApi.service
systemctl start kestrel-RecommandationsApi.service
systemctl start kestrel-ShopFront.service

# systemctl status kestrel-ProductsApi.service
# systemctl status kestrel-RatingsApi.service
# systemctl status kestrel-RecommandationsApi.service
# systemctl status kestrel-ShopFront.service
