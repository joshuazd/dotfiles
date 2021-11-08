let g:xmldata_sequence = {
      \ 'sequence': [
      \ b:xml_mediator_names,
      \ {'name': [], 'trace': ['enable', 'disable'], 'xmlns': ['http://ws.apache.org/ns/synapse'], 'onError': ['CustomErrorResponseSequence', 'CustomErrorXmlResponseSequence']}
      \ ]
      \ }

let g:xmldata_sequence = extend(g:xmldata_sequence, b:xmldata_mediators, 'keep')
