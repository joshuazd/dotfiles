let g:xmldata_template = {
      \ 'template': [
      \ ['parameter', 'sequence'],
      \ {'name': [], 'xmlns': ['http://ws.apache.org/ns/synapse']}
      \ ],
      \ 'parameter': [
      \ [],
      \ {'name': []}
      \ ],
      \ 'sequence': [
      \ b:xml_mediator_names,
      \ {}
      \ ]
      \ }

let g:xmldata_template = extend(g:xmldata_template, b:xmldata_mediators, 'keep')
