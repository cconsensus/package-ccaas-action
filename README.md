# package-ccaas-action

Github Action to create a Chaincode as an external service package


# Package Chaincode as an external service GitHub action

This action create a ccaas package which can be used with the [Chaincode as an external service](https://hyperledger-fabric.readthedocs.io/en/release-2.2/cc_service.html)

## Inputs

## `chaincode-label`

**Required** The chaincode label.

## `chaincode-image`

**Required** The chaincode docker image name.

## `chaincode-address`

**Required** The chaincode address eg.: '{{.peername}}-ccaas-<cc_name>:9999'.

## Outputs

None.

## Example usage

```yaml
uses: cconsensus/package-ccaas-action@<Commit SHA>
with:
  chaincode-label: cc-idauth
  chaincode-image: ghcr.io/cconsensus/cconsensus_identity/cc-idauth
  chaincode-address: '{{.peername}}-ccaas-<cc_name>:9999'
```
