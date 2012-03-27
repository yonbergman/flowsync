require 'cgi'

class Hash
  def to_params
    self.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")
  end
end