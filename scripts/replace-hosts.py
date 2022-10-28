#!/usr/bin/env python3

from argparse import ArgumentParser
import os.path

def replace():
    parser = ArgumentParser()
    parser.add_argument('--data-dir', '-d', help='data directory', default='data')
    parser.add_argument('--hosts-file', '-f', help='hosts-file', default='dns_hosts')
    parser.add_argument('--report-dir', '-r', help='report directory', default='reports')
    parser.add_argument('--report-name', '-n', help='report name', required=True)
    args = parser.parse_args()

    # Load our cross reference
    xref = {}
    with open(os.path.join(args.data_dir, args.hosts_file)) as hosts:
        for line in hosts:
            [host, ip] = line.strip().split(' ')
            xref[ip] = host

    # Now parse the input file
    with open(os.path.join(args.report_dir,args.report_name)) as report:
        for line in report:
            found = False
            for key in xref:
                if key in line:
                   found = True
                   print(line.rstrip().replace(key, xref[key]))
            if not found:
                print(line.rstrip())
       

if __name__ == '__main__':
    replace()
