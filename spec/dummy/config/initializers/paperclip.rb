Paperclip::Attachment.default_options[:path] =
  ':rails_root/public/system/:rails_env/:class/:attachment/:id_partition/'\
    ':style/:filename'
Paperclip::Attachment.default_options[:url] =
  '/system/:rails_env/:class/:attachment/:id_partition/:style/:filename'
