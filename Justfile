@serve:
    ./server/madns.rb --udp --port=5300 --bind='127.0.0.1' --dir=./samples

@syntax-check:
    #!/bin/sh
    for h in samples/*/*.hexit; do
        hexit -c $h
    done

core_types := "a aaaa caa cname eui48 eui64 hinfo loc mx naptr ns openpgpkey ptr soa srv sshfp tlsa txt uri"

check-against-dig-local:
    #!/bin/bash
    for qtype in {{core_types}}; do
        for sample in samples/$qtype/*.invalid.hexit; do
            echo -e "\n$sample:"
            dig @'127.0.0.1' -p 5300 +short +retry=0 +tries=1 +time=1 +noignore $qtype $(basename $sample .hexit)
        done
    done
