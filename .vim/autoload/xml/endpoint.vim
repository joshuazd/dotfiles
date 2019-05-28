let endpoint_params = ['timeout', 'suspendOnFailure', 'markForSuspension']
let g:xmldata_endpoint = {
      \ 'endpoint': [
      \ ['http', 'address'],
      \ {'name': [], 'xmlns': ['http://ws.apache.org/ns/synapse']}
      \ ],
      \ 'http': [
      \ endpoint_params,
      \ b:xmldata_endpoint['http'][1]
      \ ],
      \ 'address': [
      \ endpoint_params + ['enableSec'],
      \ b:xmldata_endpoint['address'][1]
      \ ],
      \ 'timeout': [
      \ ['duration', 'responseAction'],
      \ {}
      \ ],
      \ 'suspendOnFailure': [
      \ ['errorCodes', 'initialDuration', 'progressionFactor', 'maximumDuration'],
      \ {}
      \ ],
      \ 'markForSuspension': [
      \ ['errorCodes'],
      \ {}
      \ ],
      \ 'enableSec': b:xmldata_endpoint['enableSec']
      \ }
