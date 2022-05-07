#! /bin/bash

source 0-setenv.sh

#echo "Clean up logs..."
#rm -r logs/pycryptobot-*.log
echo "Clean up markets..."
rm -r market/config-*.json
echo "Clean up graphs..."
rm -r graphs/*.png

echo "Copy docker-compose.yaml..."
cp -rf templates/docker-compose-base.yaml docker-compose.yaml

while IFS=, read -r live base_currency quote_currency; do
  echo "Prepare $base_currency$quote_currency..."
  #touch logs/pycryptobot-$base_currency$quote_currency.log
  cp templates/config-template.json market/config-$base_currency$quote_currency.json

  sed -i "" "s/%api_key%/$BINANCE_KEY/g" market/config-$base_currency$quote_currency.json
  sed -i "" "s/%api_secret%/$BINANCE_SECRET/g" market/config-$base_currency$quote_currency.json
  sed -i "" "s/%token%/$TELEGRAM_TOKEN/g" market/config-$base_currency$quote_currency.json
  sed -i "" "s/%client_id%/$TELEGRAM_CLIENT_ID/g" market/config-$base_currency$quote_currency.json
  
  sed -i "" "s/%base_currency%/$base_currency/g" market/config-$base_currency$quote_currency.json
  sed -i "" "s/%quote_currency%/$quote_currency/g" market/config-$base_currency$quote_currency.json
  sed -i "" "s/%live%/$live/g" market/config-$base_currency$quote_currency.json

  cat templates/docker-compose-market.yaml >> docker-compose.yaml
  sed -i "" "s/%MARKET%/$base_currency$quote_currency/g" docker-compose.yaml
  docker_service_name=`echo $base_currency$quote_currency | tr "[:upper:]" "[:lower:]"`
  sed -i "" "s/%MARKET-DOCKER-SERVICE%/$docker_service_name/g" docker-compose.yaml

  sed -i "" "s/%PORTAINER_PASSWORD%/$PORTAINER_PASSWORD/g" docker-compose.yaml

  if [[ $live = 1 ]]
  then
    sed -i "" "s/%LIVE%/LIVE/g" docker-compose.yaml
  else
    sed -i "" "s/%LIVE%/TEST/g" docker-compose.yaml
  fi
done < markets.csv

ls -la market
cat docker-compose.yaml
