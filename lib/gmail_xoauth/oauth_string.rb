module GmailXoauth
  module OauthString
  
  private
    
    #
    # Builds the "oauth protocol parameter string". See http://code.google.com/apis/gmail/oauth/protocol.html#sasl
    # 
    #   +request_url+ https://mail.google.com/mail/b/user_name@gmail.com/{imap|smtp}/
    #   +oauth_params+ contains the following keys:
    #     * :consumer_key (default 'anonymous')
    #     * :consumer_secret (default 'anonymous')
    #     * :token (mandatory)
    #     * :token_secret (mandatory)
    def build_oauth_string(request_url, oauth_params = {})
      oauth_params[:consumer_key] ||= 'anonymous'
      oauth_params[:consumer_secret] ||= 'anonymous'
      
      oauth_request_params = {
        "oauth_consumer_key"     => oauth_params[:consumer_key],
        'oauth_nonce'            => OAuth::Helper.generate_key,
        "oauth_signature_method" => 'HMAC-SHA1',
        'oauth_timestamp'        => OAuth::Helper.generate_timestamp,
        "oauth_token"            => oauth_params[:token],
        'oauth_version'          => '1.0'
      }
      
      request = OAuth::RequestProxy.proxy(
         'method'     => 'GET',
         'uri'        => request_url,
         'parameters' => oauth_request_params
      )
      
      oauth_request_params['oauth_signature'] =
        OAuth::Signature.sign(
          request,
          :consumer_secret => oauth_params[:consumer_secret],
          :token_secret    => oauth_params[:token_secret]
        )
      
      # Inspired from OAuth::RequestProxy::Base#oauth_header
      oauth_request_params.map { |k,v| "#{k}=\"#{OAuth::Helper.escape(v)}\"" }.sort.join(',')
    end
    
    # See http://code.google.com/apis/gmail/oauth/protocol.html#sasl
    def build_sasl_client_request(request_url, oauth_string)
      'GET ' + request_url + ' ' + oauth_string
    end
    
  end
end