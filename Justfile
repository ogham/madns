# Start a local UDP development server.
@serve-udp:
    ./server/madns.rb --udp --port={{default_port}} --bind='127.0.0.1' --dir=./samples

# Start a local TCP development server.
@serve-tcp:
    ./server/madns.rb --tcp --port={{default_port}} --bind='127.0.0.1' --dir=./samples

# Checks the syntax of all the Hexit files.
@syntax-check:
    #!/bin/sh
    for h in samples/*/*.hexit; do
        hexit -c $h || exit 1
    done

# See how dig fares when trying to parse every response. Requires a running server.
check-against-dig-local:
    #!/bin/bash
    for qtype in {{core_types}}; do
        for sample in samples/$qtype/*.invalid.hexit; do
            echo -e "\n$sample:"
            dig @'127.0.0.1' -p {{default_port}} +short +retry=0 +tries=1 +time=1 +noignore $qtype $(basename $sample .hexit)
        done
    done

# Runs Rubocop through Docker to lint the server code.
lint-using-docker:
    docker run --rm --volume "$PWD/server:/madns-server:ro" pipelinecomponents/rubocop \
        rubocop /madns-server -E --only Lint,Migration,Naming,Security,Style/UnpackFirst


# ---- configuration ----

# Space-separated list of known record types
core_types := "a aaaa caa cname eui48 eui64 hinfo loc mx naptr ns openpgpkey ptr soa srv sshfp tlsa txt uri"

# The port to run the development server on
default_port := "5301"
