madns
=====

A dummy DNS server with pre-programmed deliberately-incorrect responses.

**For more information, see [the madns website](https://madns.binarystar.systems/).**


Options
-------

```
  -b, --bind=ADDR     Network address to bind to
  -p, --port=PORT     Port to serve on
      --tcp           Serve over TCP
      --udp           Serve over UDP
  -d, --dir=DIR       Path to the samples directory
  -h, --help          Prints this help
```

The `--port`, `--bind`, and `--dir` arguments, along with one of `--tcp` or `--udp`, are mandatory.


Technical details
-----------------

madns is written in Ruby and Hexit.

The server is written in Ruby using the networking facilities in the standard library. It uses no third-party gems.

The DNS packet samples are written in [Hexit](https://github.com/ogham/hexit), a mini-language specifically constructed for writing network packets and other binary data while still being readable to those seeing it for the first time. The Ruby server invokes a `hexit` command, so you will need to have the binary somewhere in your `$PATH`.

For example, here’s the code to generate the response to a query for `a.example`, which exists in the `a.example.hexit` file in the `a` folder in the samples directory:

```hexit
# DNS header
# (minus transaction ID)
Flags: 81 80
Counts: be16[1]  be16[1]  be16[0]  be16[0]

# Question
Domain: 01 "a" 07 "example" 00
Type: be16(DNS_A)
Class: be16(DNS_IN)

# Answer
Domain: c0 0c
Type: be16(DNS_A)
Class: be16(DNS_IN)
TTL: be32[600]
Length: be16[4]
IP: [127.0.0.1]
```

It starts with the DNS flags (standard query, response, no error) and contains 1 question and 1 answer. The domain and record type in the question needs to match up with the name of the file and the directory it’s in; the domain has been segment-encoded in the way DNS clients expect. The answer is the interesting part: it refers back to the original domain using DNS compression, and the type and class must match up too. This A record responds with the `127.0.0.1` IP address.

Note that the transaction ID is _not_ present in the Hexit code. Because this is the only part of the response that varies between queries, it is instead handled by the Ruby server and gets tacked on at the front before the response is sent.

Responses that _must_ vary between queries, such as the random data or transaction ID ones, are handled entirely by the Ruby server.


Licence
-------

madns is dual-licenced under the [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/) and [MIT](https://opensource.org/licenses/MIT) licences.

