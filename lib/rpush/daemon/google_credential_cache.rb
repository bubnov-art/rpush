require 'singleton'
module Rpush
  module Daemon
    class GoogleCredentialCache
      include Singleton
      include Loggable

      # Assuming tokens are valid for 1 hour
      TOKEN_VALID_FOR_SEC = 60 * 59

      def initialize
        @credentials_cache = {}
      end

      def access_token(scope, json_key)
        # puts json_key
        # puts "----------start access_token-------------------"
        # puts '============================='
        # puts scope 
        # puts json_key
        # puts '============================='
        key = hash_key(scope, json_key)
        
        # puts key
        # puts @credentials_cache
        # puts "start if creds"
        if @credentials_cache[key].nil? || Time.now > @credentials_cache[key][:expires_at]
          # puts '------start creds -------'
          token = fetch_fresh_token(scope, json_key)
          # puts "#{token}" 
          expires_at = Time.now + TOKEN_VALID_FOR_SEC
          @credentials_cache[key] = { token: token, expires_at: expires_at }
          
          # puts @credentials_cache[key]

        end
        # puts 'P----end ----P'
        @credentials_cache[key][:token]
      end

      private

      def fetch_fresh_token(scope, json_key)
        json_key_io = json_key ? StringIO.new(json_key) : nil
        # log_debug("json keu us #{json_key}")
        log_debug("FCM - Obtaining access token.")
        authorizer = Google::Auth::ServiceAccountCredentials.make_creds(scope: scope, json_key_io: json_key_io)
        
        token = authorizer.fetch_access_token
        # puts token 
        token
      end

      def hash_key(scope, json_key)
        # puts scope.hash
        scope.hash ^ json_key.hash
      end
    end
  end
end
