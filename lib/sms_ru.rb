require "sms_ru/version"
require "net/http"

module SmsRu
  class SMS
    def initialize(params)
      @api_id = params[:api_id]
      @login = params[:login]
      @password = params[:password]
      @auth_token_expire = nil
      @from = params[:from]
    end

    def send_sms(params = {})
      params[:from] ||= @from

      query_params = params.map do |key, value|
        "&#{key.to_s}=#{CGI.escape(value.to_s.to_str)}"
      end.join('')

      if @api_id.nil?
        require 'digest/sha2'
        hash = Digest::SHA512.hexdigest(@password+auth_token+@api_id)
        uri = URI.parse("http://sms.ru/sms/send?api_id=#@api_id#{query_params}")
      else
        uri = URI.parse("http://sms.ru/sms/send?api_id=#@api_id#{query_params}")
        response = Net::HTTP.get_response(uri)
        return response.body.split("\n")
      end
    end

    def auth_token
      if @auth_token_expire < Time.now
        renew_auth_token
      else
        @auth_token
      end
    end

    private
    def renew_auth_token
      @auth_token_expire = Time.now + 10.minutes
      @auth_token = Net::HTTP.get_response(URI.parse("http://sms.ru/auth/get_token")).body.strip
    end
  end
end
