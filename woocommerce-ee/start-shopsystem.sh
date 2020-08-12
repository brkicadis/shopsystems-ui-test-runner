#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
export WOOCOMMERCE_CONTAINER_NAME=woo_commerce
export WOOCOMMERCE_PATH="shopsystems-ui-test-runner/woocommerce-ee"

for ARGUMENT in "$@"; do
  KEY=$(echo "${ARGUMENT}" | cut -f1 -d=)
  VALUE=$(echo "${ARGUMENT}" | cut -f2 -d=)

  case "${KEY}" in
  NGROK_URL) NGROK_URL=${VALUE} ;;
  SHOP_VERSION) SHOP_SYSTEM_VERSION=${VALUE} ;;
  PHP_VERSION) PHP_VERSION=${VALUE} ;;
  USE_SPECIFIC_EXTENSION_RELEASE) USE_SPECIFIC_EXTENSION_RELEASE=${VALUE} ;;
  SPECIFIC_RELEASED_SHOP_EXTENSION_VERSION) SPECIFIC_RELEASED_SHOP_EXTENSION_VERSION=${VALUE} ;;
  *) ;;
  esac
done

if [[ ${USE_SPECIFIC_EXTENSION_RELEASE}  == "1" ]]; then
  git checkout tags/"${SPECIFIC_RELEASED_SHOP_EXTENSION_VERSION}"
fi

${WOOCOMMERCE_PATH}/generate-release-package.sh

export WOOCOMMERCE_ADMIN_USER=admin
export WOOCOMMERCE_ADMIN_PASSWORD=password

# clean up images
docker rmi wirecard/woocommerce-ci:wordpress-5.4.2_php-74

git clone https://"${GITHUB_TOKEN}":@github.com/wirecard-cee/docker-images.git

cd docker-images/woocommerce-ci

#run shop system in the background
SHOP_VERSION=5.4.2 WIRECARD_PLUGIN_VERSION=3.3.0 PHP_VERSION=74 INSTALL_WIRECARD_PLUGIN=true ./run.xsh ${WOOCOMMERCE_CONTAINER_NAME} --non-interactive -d

docker ps

#while ! $(curl --output /dev/null --silent --head --fail "${NGROK_URL}/wp-admin/install.php"); do
#    echo "Waiting for docker container to initialize"
#    sleep 5
#    ((c++)) && ((c == 50)) && break
#done

sleep 20
echo "Change hostname"
docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} /opt/wirecard/apps/woocommerce/bin/hostname-changed.xsh a299ee48a91a.ngrok.io

#install wordpress
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp core install --allow-root --url="${NGROK_URL}" --admin_password="${WOOCOMMERCE_ADMIN_PASSWORD}" --title=test --admin_user=${WOOCOMMERCE_ADMIN_USER} --admin_email=test@test.com

#activate woocommerce
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp plugin activate woocommerce --allow-root

#activate woocommerce-ee
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp plugin activate wirecard-woocommerce-extension --allow-root

#install wordpress-importer
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp plugin install wordpress-importer --activate --allow-root

#import sample product
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp import /var/www/html/wp-content/plugins/woocommerce/sample-data/sample_products.xml --allow-root --authors=create

#activate storefront theme
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp theme install storefront --activate --allow-root

#install shop pages
#docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} wp wc tool run install_pages --user=admin --allow-root

echo "Change PayPal ID"
#make PayPal order number unique
docker exec -i ${WOOCOMMERCE_CONTAINER_NAME} bash -c "sed -i 's/ = \$this->orderNumber\;/ = \$this->orderNumber . md5(time())\;/' /var/www/html/wp-content/plugins/wirecard-woocommerce-extension/vendor/wirecard/payment-sdk-php/src/Transaction/PayPalTransaction.php"

