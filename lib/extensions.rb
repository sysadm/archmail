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
