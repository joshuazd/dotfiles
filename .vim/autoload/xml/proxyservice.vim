let g:xmldata_proxyservice = {
      \ 'proxy': [
      \ ['target'],
      \ {'name': [], 'transports': ['local', 'http', 'https'], 'startOnLoad': ['true', 'false'], 'trace': ['enable', 'disable'], 'xmlns': ['http://ws.apache.org/ns/synapse']}
      \ ],
      \ 'target': [
      \ ['inSequence', 'outSequence', 'faultSequence'],
      \ {}
      \ ],
      \ 'inSequence': [
      \ b:xml_mediator_names,
      \ {}
      \ ],
      \ 'outSequence': [
      \ b:xml_mediator_names,
      \ {}
      \ ],
      \ 'faultSequence': [
      \ b:xml_mediator_names,
      \ {},
      \ ]
      \ }
let g:xmldata_proxyservice = extend(g:xmldata_proxyservice, b:xmldata_mediators, 'keep')
