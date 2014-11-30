class String
  KNOWN_MAIL_ATTRIBUTES = ["Received:", "Date:", "From:", "Reply-To:", "To:", "Message-ID:",
                           "Subject:", "Delivered-To:", "X-PHP-Originating-Script:", "X-Mailer:", "X-Virus-Scanned:",
                           "Mime-Version:", "Content-Type:", "User-Agent:", "In-Reply-To:", "References:",
                           "X-Enigmail-Version:", "X-Forwarded-Message-Id:", "Content-Transfer-Encoding:", "Cc:",
                           "X-Greylist:", "X-Env-Sender:", "X-Msg-Ref:", "X-Originating-IP:", "X-StarScan-Received:",
                           "X-StarScan-Version:", "X-VirusChecked:", "Thread-Topic:", "Thread-Index:",
                           "Accept-Language:", "Content-Language:", "X-MS-Has-Attach:", "X-MS-TNEF-Correlator:",
                           "x-originating-ip:", "Content-Disposition:", "Organization:", "DKIM-Signature:",
                           "X-Priority:", "Disposition-Notification-To:", "X-MSMail-Priority:", "X-MimeOLE:",
                           "X-Asterisk-CallerID:", "X-TMN:", "X-Originating-Email:", "Importance:",
                           "X-OriginalArrivalTime:", "X-Received:", "X-Goomoji-Body:"]

  def decode
    Mail::Encodings.value_decode(self)
  end
  def rfc_to_html
    self.gsub!("<", "&lt")
    self.gsub!(">", "&gt")
    self.gsub!(/Return-Path:/, "<b>Return-Path:</b>")
    KNOWN_MAIL_ATTRIBUTES.each{|attr| self.gsub!("\n#{attr}", "\n<b>#{attr}</b>") }
    self.gsub!(/\t+/,'&nbsp;&nbsp;')
    self.gsub!(/[\r\n]+/,'<br />')
  end

  def to_utf8(charset=nil)
    charset = charset.downcase if charset
    (charset and self.encoding.to_s) != "UTF-8" ? self.encode("UTF-8", charset) : self
  end

  def body_to_html
    self.gsub!("\n", "<br />")
  end

  def print_and_flush(verbose=nil)
    if verbose
      print self
      $stdout.flush
    end
  end

  def charset_alias
    charset_alias={}
    charset_alias['ascii'] = "us-ascii"
    charset_alias['us-ascii'] = "us-ascii"
    charset_alias['ansi_x3.4-1968'] = "us-ascii"
    charset_alias['646'] = "us-ascii"
    charset_alias['iso-8859-1'] = "ISO-8859-1"
    charset_alias['iso-8859-2'] = "ISO-8859-2"
    charset_alias['iso-8859-3'] = "ISO-8859-3"
    charset_alias['iso-8859-4'] = "ISO-8859-4"
    charset_alias['iso-8859-5'] = "ISO-8859-5"
    charset_alias['iso-8859-6'] = "ISO-8859-6"
    charset_alias['iso-8859-6-i'] = "ISO-8859-6-I"
    charset_alias['iso-8859-6-e'] = "ISO-8859-6-E"
    charset_alias['iso-8859-7'] = "ISO-8859-7"
    charset_alias['iso-8859-8'] = "ISO-8859-8"
    charset_alias['iso-8859-8-i'] = "ISO-8859-8-I"
    charset_alias['iso-8859-8-e'] = "ISO-8859-8-E"
    charset_alias['iso-8859-9'] = "ISO-8859-9"
    charset_alias['iso-8859-10'] = "ISO-8859-10"
    charset_alias['iso-8859-11'] = "ISO-8859-11"
    charset_alias['iso-8859-13'] = "ISO-8859-13"
    charset_alias['iso-8859-14'] = "ISO-8859-14"
    charset_alias['iso-8859-15'] = "ISO-8859-15"
    charset_alias['iso-8859-16'] = "ISO-8859-16"
    charset_alias['iso-ir-111'] = "ISO-IR-111"
    charset_alias['iso-2022-cn'] = "ISO-2022-CN"
    charset_alias['iso-2022-cn-ext'] = "ISO-2022-CN"
    charset_alias['iso-2022-kr'] = "ISO-2022-KR"
    charset_alias['iso-2022-jp'] = "ISO-2022-JP"
    charset_alias['utf-16be'] = "UTF-16BE"
    charset_alias['utf-16le'] = "UTF-16LE"
    charset_alias['utf-16'] = "UTF-16"
    charset_alias['windows-1250'] = "windows-1250"
    charset_alias['windows-1251'] = "windows-1251"
    charset_alias['windows-1252'] = "windows-1252"
    charset_alias['windows-1253'] = "windows-1253"
    charset_alias['windows-1254'] = "windows-1254"
    charset_alias['windows-1255'] = "windows-1255"
    charset_alias['windows-1256'] = "windows-1256"
    charset_alias['windows-1257'] = "windows-1257"
    charset_alias['windows-1258'] = "windows-1258"
    charset_alias['ibm866'] = "IBM866"
    charset_alias['ibm850'] = "IBM850"
    charset_alias['ibm852'] = "IBM852"
    charset_alias['ibm855'] = "IBM855"
    charset_alias['ibm857'] = "IBM857"
    charset_alias['ibm862'] = "IBM862"
    charset_alias['ibm864'] = "IBM864"
    charset_alias['utf-8'] = "UTF-8"
    charset_alias['utf-7'] = "UTF-7"
    charset_alias['shift_jis'] = "Shift_JIS"
    charset_alias['big5'] = "Big5"
    charset_alias['euc-jp'] = "EUC-JP"
    charset_alias['euc-kr'] = "EUC-KR"
    charset_alias['gb2312'] = "GB2312"
    charset_alias['gb18030'] = "gb18030"
    charset_alias['viscii'] = "VISCII"
    charset_alias['koi8-r'] = "KOI8-R"
    charset_alias['koi8_r'] = "KOI8-R"
    charset_alias['cskoi8r'] = "KOI8-R"
    charset_alias['koi'] = "KOI8-R"
    charset_alias['koi8'] = "KOI8-R"
    charset_alias['koi8-u'] = "KOI8-U"
    charset_alias['tis-620'] = "TIS-620"
    charset_alias['t.61-8bit'] = "T.61-8bit"
    charset_alias['hz-gb-2312'] = "HZ-GB-2312"
    charset_alias['big5-hkscs'] = "Big5-HKSCS"
    charset_alias['gbk'] = "gbk"
    charset_alias['cns11643'] = "x-euc-tw"
    charset_alias['x-imap4-modified-utf7'] = "x-imap4-modified-utf7"
    charset_alias['x-euc-tw'] = "x-euc-tw"
    charset_alias['x-mac-ce'] = "x-mac-ce"
    charset_alias['x-mac-turkish'] = "x-mac-turkish"
    charset_alias['x-mac-greek'] = "x-mac-greek"
    charset_alias['x-mac-icelandic'] = "x-mac-icelandic"
    charset_alias['x-mac-croatian'] = "x-mac-croatian"
    charset_alias['x-mac-romanian'] = "x-mac-romanian"
    charset_alias['x-mac-cyrillic'] = "x-mac-cyrillic"
    charset_alias['x-mac-ukrainian'] = "x-mac-cyrillic"
    charset_alias['x-mac-hebrew'] = "x-mac-hebrew"
    charset_alias['x-mac-arabic'] = "x-mac-arabic"
    charset_alias['x-mac-farsi'] = "x-mac-farsi"
    charset_alias['x-mac-devanagari'] = "x-mac-devanagari"
    charset_alias['x-mac-gujarati'] = "x-mac-gujarati"
    charset_alias['x-mac-gurmukhi'] = "x-mac-gurmukhi"
    charset_alias['armscii-8'] = "armscii-8"
    charset_alias['x-viet-tcvn5712'] = "x-viet-tcvn5712"
    charset_alias['x-viet-vps'] = "x-viet-vps"
    charset_alias['iso-10646-ucs-2'] = "UTF-16BE"
    charset_alias['x-iso-10646-ucs-2-be'] = "UTF-16BE"
    charset_alias['x-iso-10646-ucs-2-le'] = "UTF-16LE"
    charset_alias['x-user-defined'] = "x-user-defined"
    charset_alias['x-johab'] = "x-johab"
    charset_alias['latin1'] = "ISO-8859-1"
    charset_alias['iso_8859-1'] = "ISO-8859-1"
    charset_alias['iso8859-1'] = "ISO-8859-1"
    charset_alias['iso8859-2'] = "ISO-8859-2"
    charset_alias['iso8859-3'] = "ISO-8859-3"
    charset_alias['iso8859-4'] = "ISO-8859-4"
    charset_alias['iso8859-5'] = "ISO-8859-5"
    charset_alias['iso8859-6'] = "ISO-8859-6"
    charset_alias['iso8859-7'] = "ISO-8859-7"
    charset_alias['iso8859-8'] = "ISO-8859-8"
    charset_alias['iso8859-9'] = "ISO-8859-9"
    charset_alias['iso8859-10'] = "ISO-8859-10"
    charset_alias['iso8859-11'] = "ISO-8859-11"
    charset_alias['iso8859-13'] = "ISO-8859-13"
    charset_alias['iso8859-14'] = "ISO-8859-14"
    charset_alias['iso8859-15'] = "ISO-8859-15"
    charset_alias['iso_8859-1:1987'] = "ISO-8859-1"
    charset_alias['iso-ir-100'] = "ISO-8859-1"
    charset_alias['l1'] = "ISO-8859-1"
    charset_alias['ibm819'] = "ISO-8859-1"
    charset_alias['cp819'] = "ISO-8859-1"
    charset_alias['csisolatin1'] = "ISO-8859-1"
    charset_alias['latin2'] = "ISO-8859-2"
    charset_alias['iso_8859-2'] = "ISO-8859-2"
    charset_alias['iso_8859-2:1987'] = "ISO-8859-2"
    charset_alias['iso-ir-101'] = "ISO-8859-2"
    charset_alias['l2'] = "ISO-8859-2"
    charset_alias['csisolatin2'] = "ISO-8859-2"
    charset_alias['latin3'] = "ISO-8859-3"
    charset_alias['iso_8859-3'] = "ISO-8859-3"
    charset_alias['iso_8859-3:1988'] = "ISO-8859-3"
    charset_alias['iso-ir-109'] = "ISO-8859-3"
    charset_alias['l3'] = "ISO-8859-3"
    charset_alias['csisolatin3'] = "ISO-8859-3"
    charset_alias['latin4'] = "ISO-8859-4"
    charset_alias['iso_8859-4'] = "ISO-8859-4"
    charset_alias['iso_8859-4:1988'] = "ISO-8859-4"
    charset_alias['iso-ir-110'] = "ISO-8859-4"
    charset_alias['l4'] = "ISO-8859-4"
    charset_alias['csisolatin4'] = "ISO-8859-4"
    charset_alias['cyrillic'] = "ISO-8859-5"
    charset_alias['iso_8859-5'] = "ISO-8859-5"
    charset_alias['iso_8859-5:1988'] = "ISO-8859-5"
    charset_alias['iso-ir-144'] = "ISO-8859-5"
    charset_alias['csisolatincyrillic'] = "ISO-8859-5"
    charset_alias['arabic'] = "ISO-8859-6"
    charset_alias['iso_8859-6'] = "ISO-8859-6"
    charset_alias['iso_8859-6:1987'] = "ISO-8859-6"
    charset_alias['iso-ir-127'] = "ISO-8859-6"
    charset_alias['ecma-114'] = "ISO-8859-6"
    charset_alias['asmo-708'] = "ISO-8859-6"
    charset_alias['csisolatinarabic'] = "ISO-8859-6"
    charset_alias['csiso88596i'] = "ISO-8859-6-I"
    charset_alias['csiso88596e'] = "ISO-8859-6-E"
    charset_alias['greek'] = "ISO-8859-7"
    charset_alias['greek8'] = "ISO-8859-7"
    charset_alias['sun_eu_greek'] = "ISO-8859-7"
    charset_alias['iso_8859-7'] = "ISO-8859-7"
    charset_alias['iso_8859-7:1987'] = "ISO-8859-7"
    charset_alias['iso-ir-126'] = "ISO-8859-7"
    charset_alias['elot_928'] = "ISO-8859-7"
    charset_alias['ecma-118'] = "ISO-8859-7"
    charset_alias['csisolatingreek'] = "ISO-8859-7"
    charset_alias['hebrew'] = "ISO-8859-8"
    charset_alias['iso_8859-8'] = "ISO-8859-8"
    charset_alias['visual'] = "ISO-8859-8"
    charset_alias['iso_8859-8:1988'] = "ISO-8859-8"
    charset_alias['iso-ir-138'] = "ISO-8859-8"
    charset_alias['csisolatinhebrew'] = "ISO-8859-8"
    charset_alias['csiso88598i'] = "ISO-8859-8-I"
    charset_alias['iso-8859-8i'] = "ISO-8859-8-I"
    charset_alias['logical'] = "ISO-8859-8-I"
    charset_alias['csiso88598e'] = "ISO-8859-8-E"
    charset_alias['latin5'] = "ISO-8859-9"
    charset_alias['iso_8859-9'] = "ISO-8859-9"
    charset_alias['iso_8859-9:1989'] = "ISO-8859-9"
    charset_alias['iso-ir-148'] = "ISO-8859-9"
    charset_alias['l5'] = "ISO-8859-9"
    charset_alias['csisolatin5'] = "ISO-8859-9"
    charset_alias['unicode-1-1-utf-8'] = "UTF-8"
    charset_alias['utf8'] = "UTF-8"
    charset_alias['x-sjis'] = "Shift_JIS"
    charset_alias['shift-jis'] = "Shift_JIS"
    charset_alias['ms_kanji'] = "Shift_JIS"
    charset_alias['csshiftjis'] = "Shift_JIS"
    charset_alias['windows-31j'] = "Shift_JIS"
    charset_alias['cp932'] = "Shift_JIS"
    charset_alias['sjis'] = "Shift_JIS"
    charset_alias['cseucpkdfmtjapanese'] = "EUC-JP"
    charset_alias['x-euc-jp'] = "EUC-JP"
    charset_alias['csiso2022jp'] = "ISO-2022-JP"
    charset_alias['iso-2022-jp-2'] = "ISO-2022-JP"
    charset_alias['csiso2022jp2'] = "ISO-2022-JP"
    charset_alias['csbig5'] = "Big5"
    charset_alias['cn-big5'] = "Big5"
    charset_alias['x-x-big5'] = "Big5"
    charset_alias['zh_tw-big5'] = "Big5"
    charset_alias['cseuckr'] = "EUC-KR"
    charset_alias['ks_c_5601-1987'] = "EUC-KR"
    charset_alias['iso-ir-149'] = "EUC-KR"
    charset_alias['ks_c_5601-1989'] = "EUC-KR"
    charset_alias['ksc_5601'] = "EUC-KR"
    charset_alias['ksc5601'] = "EUC-KR"
    charset_alias['korean'] = "EUC-KR"
    charset_alias['csksc56011987'] = "EUC-KR"
    charset_alias['5601'] = "EUC-KR"
    charset_alias['windows-949'] = "EUC-KR"
    charset_alias['gb_2312-80'] = "GB2312"
    charset_alias['iso-ir-58'] = "GB2312"
    charset_alias['chinese'] = "GB2312"
    charset_alias['csiso58gb231280'] = "GB2312"
    charset_alias['csgb2312'] = "GB2312"
    charset_alias['zh_cn.euc'] = "GB2312"
    charset_alias['gb_2312'] = "GB2312"
    charset_alias['x-cp1250'] = "windows-1250"
    charset_alias['x-cp1251'] = "windows-1251"
    charset_alias['x-cp1252'] = "windows-1252"
    charset_alias['x-cp1253'] = "windows-1253"
    charset_alias['x-cp1254'] = "windows-1254"
    charset_alias['x-cp1255'] = "windows-1255"
    charset_alias['x-cp1256'] = "windows-1256"
    charset_alias['x-cp1257'] = "windows-1257"
    charset_alias['x-cp1258'] = "windows-1258"
    charset_alias['windows-874'] = "windows-874"
    charset_alias['ibm874'] = "windows-874"
    charset_alias['dos-874'] = "windows-874"
    charset_alias['macintosh'] = "macintosh"
    charset_alias['x-mac-roman'] = "macintosh"
    charset_alias['mac'] = "macintosh"
    charset_alias['csmacintosh'] = "macintosh"
    charset_alias['cp866'] = "IBM866"
    charset_alias['cp-866'] = "IBM866"
    charset_alias['866'] = "IBM866"
    charset_alias['csibm866'] = "IBM866"
    charset_alias['cp850'] = "IBM850"
    charset_alias['850'] = "IBM850"
    charset_alias['csibm850'] = "IBM850"
    charset_alias['cp852'] = "IBM852"
    charset_alias['852'] = "IBM852"
    charset_alias['csibm852'] = "IBM852"
    charset_alias['cp855'] = "IBM855"
    charset_alias['855'] = "IBM855"
    charset_alias['csibm855'] = "IBM855"
    charset_alias['cp857'] = "IBM857"
    charset_alias['857'] = "IBM857"
    charset_alias['csibm857'] = "IBM857"
    charset_alias['cp862'] = "IBM862"
    charset_alias['862'] = "IBM862"
    charset_alias['csibm862'] = "IBM862"
    charset_alias['cp864'] = "IBM864"
    charset_alias['864'] = "IBM864"
    charset_alias['csibm864'] = "IBM864"
    charset_alias['ibm-864'] = "IBM864"
    charset_alias['t.61'] = "T.61-8bit"
    charset_alias['iso-ir-103'] = "T.61-8bit"
    charset_alias['csiso103t618bit'] = "T.61-8bit"
    charset_alias['x-unicode-2-0-utf-7'] = "UTF-7"
    charset_alias['unicode-2-0-utf-7'] = "UTF-7"
    charset_alias['unicode-1-1-utf-7'] = "UTF-7"
    charset_alias['csunicode11utf7'] = "UTF-7"
    charset_alias['csunicode'] = "UTF-16BE"
    charset_alias['csunicode11'] = "UTF-16BE"
    charset_alias['iso-10646-ucs-basic'] = "UTF-16BE"
    charset_alias['csunicodeascii'] = "UTF-16BE"
    charset_alias['iso-10646-unicode-latin1'] = "UTF-16BE"
    charset_alias['csunicodelatin1'] = "UTF-16BE"
    charset_alias['iso-10646'] = "UTF-16BE"
    charset_alias['iso-10646-j-1'] = "UTF-16BE"
    charset_alias['latin6'] = "ISO-8859-10"
    charset_alias['iso-ir-157'] = "ISO-8859-10"
    charset_alias['l6'] = "ISO-8859-10"
    charset_alias['csisolatin6'] = "ISO-8859-10"
    charset_alias['iso_8859-15'] = "ISO-8859-15"
    charset_alias['csisolatin9'] = "ISO-8859-15"
    charset_alias['l9'] = "ISO-8859-15"
    charset_alias['ecma-cyrillic'] = "ISO-IR-111"
    charset_alias['csiso111ecmacyrillic'] = "ISO-IR-111"
    charset_alias['csiso2022kr'] = "ISO-2022-KR"
    charset_alias['csviscii'] = "VISCII"
    charset_alias['zh_tw-euc'] = "x-euc-tw"
    charset_alias['iso88591'] = "ISO-8859-1"
    charset_alias['iso88592'] = "ISO-8859-2"
    charset_alias['iso88593'] = "ISO-8859-3"
    charset_alias['iso88594'] = "ISO-8859-4"
    charset_alias['iso88595'] = "ISO-8859-5"
    charset_alias['iso88596'] = "ISO-8859-6"
    charset_alias['iso88597'] = "ISO-8859-7"
    charset_alias['iso88598'] = "ISO-8859-8"
    charset_alias['iso88599'] = "ISO-8859-9"
    charset_alias['iso885910'] = "ISO-8859-10"
    charset_alias['iso885911'] = "ISO-8859-11"
    charset_alias['iso885912'] = "ISO-8859-12"
    charset_alias['iso885913'] = "ISO-8859-13"
    charset_alias['iso885914'] = "ISO-8859-14"
    charset_alias['iso885915'] = "ISO-8859-15"
    charset_alias['tis620'] = "TIS-620"
    charset_alias['cp1250'] = "windows-1250"
    charset_alias['cp1251'] = "windows-1251"
    charset_alias['cp1252'] = "windows-1252"
    charset_alias['cp1253'] = "windows-1253"
    charset_alias['cp1254'] = "windows-1254"
    charset_alias['cp1255'] = "windows-1255"
    charset_alias['cp1256'] = "windows-1256"
    charset_alias['cp1257'] = "windows-1257"
    charset_alias['cp1258'] = "windows-1258"
    charset_alias['x-gbk'] = "gbk"
    charset_alias['windows-936'] = "gbk"
    charset_alias['ansi-1251'] = "windows-1251"
    charset_alias[self.downcase] ? charset_alias[self.downcase] : self
  end
end

class Net::IMAP
  def gmail
    class << self.instance_variable_get("@parser")
      # monkey patch from ruby 2.1.2 net/imap.rb
      def msg_att(n)
        match(T_LPAR)
        attr = {}
        while true
          token = lookahead
          case token.symbol
            when T_RPAR
              shift_token
              break
            when T_SPACE
              shift_token
              next
          end
          case token.value
            when /\A(?:ENVELOPE)\z/ni
              name, val = envelope_data
            when /\A(?:FLAGS)\z/ni
              name, val = flags_data
            when /\A(?:INTERNALDATE)\z/ni
              name, val = internaldate_data
            when /\A(?:RFC822(?:\.HEADER|\.TEXT)?)\z/ni
              name, val = rfc822_text
            when /\A(?:RFC822\.SIZE)\z/ni
              name, val = rfc822_size
            when /\A(?:BODY(?:STRUCTURE)?)\z/ni
              name, val = body_data
            when /\A(?:UID)\z/ni
              name, val = uid_data

            # Gmail extension additions.
            when /\A(?:X-GM-LABELS)\z/ni
              name, val = flags_data
            when /\A(?:X-GM-MSGID)\z/ni
              name, val = uid_data
            when /\A(?:X-GM-THRID)\z/ni
              name, val = uid_data
            else
              parse_error("unknown attribute `%s' for {%d}", token.value, n)
          end
          attr[name] = val
        end
        return attr
      end
    end
  end
end
