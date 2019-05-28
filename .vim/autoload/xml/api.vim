let g:xmldata_api = {
      \ 'api': [
      \ ['resource'],
      \ {'xmlns': ['http://ws.apache.org/ns/synapse'], 'name': [], 'context': []}
      \ ],
      \ 'resource': [
      \ ['inSequence', 'outSequence', 'faultSequence'],
      \ {'methods': ['POST', 'PUT', 'GET', 'DELETE', 'PATCH'], 'faultSequence': ['CustomErrorXmlResponseSequence', 'CustomErrorResponseSequence'], 'url-mapping': []}
      \ ],
      \ 'inSequence': [
      \ b:xml_mediator_names,
      \ {}
      \ ],
      \ 'outSequence': [
      \ b:xml_mediator_names,
      \ {}
      \ ]
      \ }

let g:xmldata_api = extend(g:xmldata_api, b:xmldata_mediators)
