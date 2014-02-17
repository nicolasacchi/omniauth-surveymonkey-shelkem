require 'omniauth/strategies/oauth2'
require 'net/http'
require 'net/https'
require 'json'

module OmniAuth
  module Strategies
    class Surveymonkey < OmniAuth::Strategies::OAuth2

      option :name, "surveymonkey"

      option :client_options, {
        :site => "https://api.surveymonkey.com",
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      }

      option :authorize_options, [:api_key]

      uid { fetch_uid }

      def fetch_uid
        url = "https://api.surveymonkey.net/v2/user/get_user_details?api_key=#{options[:api_key]}"
        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true
        req = Net::HTTP::Post.new(uri.request_uri)
        req["Authorization"] = "bearer #{access_token.token}"
        req["Content-Type"] = "application/json"
        res = https.request(req)
        JSON.parse(res.body)["data"]["user_details"]["username"] rescue nil
      end

      def callback_phase
        options[:client_options][:token_url] = "/oauth/token?api_key=#{options[:api_key]}"
        super
      end

    end
  end
end
