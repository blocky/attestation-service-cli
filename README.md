> :exclamation: The BLOCKY Attestation Service Demo is provided with no
> guarantees. By trying out this demo or invoking the `bky-as` executable you
> agree to not hold BLOCKY responsible for any problems, mishaps,
> adverse effects, or frustrations.

# BLOCKY Attestation Service

BLOCKY Attestation Service (BLOCKY-AS) allows you to create attestations over
responses from web APIs. BLOCKY-AS attestations allow you to prove to a third
party that a specific API returned specific data at a particular point in time.

## Quick Start

To request and inspect your first attestation, follow these steps:

1. Install the BLOCKY-AS CLI

```bash
curl -s https://raw.githubusercontent.com/blocky/attestation-service-demo/main/install.sh | bash
```

2. Request an attestation with a API request template. Here we are creating an
   attestation over a trivia question and answer from
   [Open Trivia Database](https://opentdb.com/).

```bash
echo '[{ "template": { "method": "GET", "url": "https://opentdb.com/api.php?amount=1" } }]' | \
	./bky-as attest-api-call > out.json
```

3. Inspect the attested API response

```bash
jq '.api_calls[0].claims.response.body | @base64d | fromjson' out.json
```

If you see a `"response_code": 5`, it means you hit the rate limit of the
[Open Trivia Database](https://opentdb.com/) API. Thanks for trying the demo
multiple times!

**NOTE:** This quick start demo started a **local instance** of the BLOCKY-AS
server,
which does __NOT__ run in a TEE. For access to BLOCKY-AS deployed on
production TEE servers, reach out to
[info@blocky.rocks](mailto:info@blocky.rocks).
