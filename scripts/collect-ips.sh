#!/bin/bash

# Collects IP addresses of interest from running instances, load balancers and DNS
# Requires a domain name to interrogate
if (( $# == 0 )); then
  echo "You must supply a domain name"
fi

domain="$1"

# First running instances
#aws ec2 describe-instances --query 'Reservations[].Instances[].PublicIpAddress' \
#  --output text | tr -s '\t' '\n' > iplist

# Load balancers
#aws elbv2 describe-load-balancers --query 'LoadBalancers[].DNSName' --output text \
#  | xargs -n 1 host | sed -n '/has address/s/^.*address\s//p' >> iplist

# DNS, note we don't want records that point to assets we don't control
aws route53 list-resource-record-sets --hosted-zone-id $(aws route53 list-hosted-zones \
  --query "HostedZones[?Name == '${domain%.}.'].Id" --output text) \
  --query "ResourceRecordSets[?(Type == 'A' || Type == 'CNAME')].Name" \
  --output text|tr -s '\t' '\n' |grep -Ev '(^_|mail|domainkey|dkim|em[0-9]|link|mail|status)' \
  > hostnames

# For each hostname get one IP address if possible
for host in $(< hostnames); do
  addr=$(host ${host} | grep 'has address' | head -1)
  if [[ -n ${addr} ]]; then
     read dns has address ip <<!
${addr}
!
     echo "${host%.} ${ip}"
  fi
done > dns_hosts

# Now make sure we only have a single IP address for each
cut -d\  -f2 dns_hosts | grep -Ev '^(10\.|172\.3[12])' | sort -u > dns_ips

