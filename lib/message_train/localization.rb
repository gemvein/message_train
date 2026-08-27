# String Extension
module StringExtension
  def localize(*args)
    sym = if args.first.is_a? Symbol
            args.shift
          else
            underscore.tr(' ', '_').gsub(/[^a-z0-9_]+/i, '').to_sym
          end
    options = args.first.is_a?(Hash) ? args.first : {}
    I18n.t(sym, **options, default: self).html_safe
  end
  alias l localize
end
String.send :include, StringExtension

# Symbol Extension
module SymbolExtensionCustom
  def localize_with_debugging(*args)
    options = args.first.is_a?(Hash) ? args.first : {}
    localized_sym = I18n.translate(self, **options)
    localized_sym.is_a?(String) ? localized_sym.html_safe : localized_sym
  end
  alias l localize_with_debugging
  def l_with_args(*args)
    l(*args).html_safe
  end
end
Symbol.send :include, SymbolExtensionCustom
