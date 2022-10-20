# Security scanning guide

## Pentest procedure

### Collect IP addresses of interest

The `collect-ips.sh` script interrogates AWS Route53 and records one ip address per host
for the purpose of scanning.  While multiple ips may exist they are usually load balancers
and don't affect the scanning, apart from slowing it down.

Output is two files, `dns_hosts` and `dns_ips`.  The first is a host/ip pair list,
which may include duplicates due to different hostnames for the same instance, and
non-routable hosts.

the second just the unique remotely addressable ip addresses.

Note that this script requires AWS authentication and may need to be run
separately and supplied to the scanning service

### Discovery scanning

Run nmap via metasploit to do initial scanning

```
msfconsole -o /reports/gather_report -x "db_nmap -A -oA /reports/nmap_scan -iL /root/dns_ips; exit"
```

This both populates the metasploit database and creates a scan report in
multiple formats.  The XML format is useful for automation.

### Common ports

Check common ports in metasploit database:

mfsconsole -o /reports/port_report -x "services; exit"

### Check for interesting services

Wordpress : wpscan

OpenVPN :
RDS (Postgres) :

### Check API limits/functionality

Tool: locust, scripts in `locust/`, Run:  TEST=filname-less-extension docker-compose up

Tool: artillery
