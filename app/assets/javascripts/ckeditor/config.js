CKEDITOR.editorConfig = function(config) {
  config.allowedContent = true;
  config.width = '100%';
  config.toolbar_full = [
    {
      name: 'links',
      items: [
        'Link',
        'Unlink'
      ]
    },
    {
      name: 'paragraph',
      groups: [
        'list',
        'indent',
        'blocks',
        'align',
        'bidi'
      ],
      items: [
        'NumberedList',
        'BulletedList',
        '-',
        'Outdent',
        'Indent',
        '-',
        'Blockquote'
      ]
    },
    {
      name: 'basicstyles',
      groups: [
        'basicstyles',
        'cleanup'
      ],
      items: [
        'Format',
        'Bold',
        'Italic',
        'Strike',
        '-',
        'RemoveFormat'
      ]
    }
  ];
  config.toolbar = 'full';
  return true;
};
