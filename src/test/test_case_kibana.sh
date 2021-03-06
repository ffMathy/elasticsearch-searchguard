#!/usr/bin/env bash

general_status=0

echo -n "TEST if kibana status endpoint is returning HTTP 200..."
count=0
httpStatusCode=""
while [[ "${httpStatusCode,,}" != "200" && count -lt 150 ]]; do
  sleep 1
  httpStatusCode=$(curl -X GET -LI "http://localhost:5601/status" -o /dev/null -w '%{http_code}\n' -s)
  echo -n "."
  ((count++))
done
if [ "${httpStatusCode,,}" != "200" ]; then
  echo "failed: HTTP status code is \"${httpStatusCode}\""
  ((general_status++))
else
  echo "OK"
fi

echo -n "TEST if kibana overall state is green..."
overall_status="dummy"
itterations=0
while [[ "${overall_status,,}" != "green" && $itterations -lt 20 ]]; do
  sleep 1
  overall_status=$(curl -X GET --silent -f -u "kibana:kibana" "http://localhost:5601/api/status" | jq -r .status.overall.state)
  echo -n "."
  ((itterations++))
done
if [ "${overall_status,,}" != "green" ]; then
  echo "failed: overall state is \"${overall_status}\""
  ((general_status++))
else
  echo "OK"
fi

exit ${general_status}
