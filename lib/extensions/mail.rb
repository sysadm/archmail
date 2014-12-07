module EncodingExtension
  def pick_encoding(enc)
    case enc
      when /ansi_x3.110-1983/i
        'ISO-8859-1'
      when /windows-?1258/i
        'Windows-1252'
      else
        super
    end
  end
end
class << Mail::Ruby19
  prepend EncodingExtension
end
