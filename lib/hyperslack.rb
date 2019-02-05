require "hyperslack/version"
require 'net/http'
require 'json'

module Hyperslack
  class Error < StandardError; end

  class Slack
    def oauth(client_id, client_secret, code, redirect_uri=nil)
      uri = URI("https://slack.com/api/oauth.access")
      body = {
        client_id: client_id,
        client_secret: client_secret,
        code: code
      }
      body[:redirect_uri] = redirect_uri unless redirect_uri.nil?

      uri.query = URI.encode_www_form(body)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri, {'Content-Type' =>'application/x-www-form-urlencoded'})

      res = http.request(req)
      return JSON.parse(res.body)
    end

    def send_message(url, message)
R     uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri, {'Content-Type' =>'application/json'})

      body = {
        "text": message
      }
      req.body = body.to_json
      res = http.request(req)
    end

    def request_drop_down(url, prompt, callback_id, action_name, dropdown_options,
                          is_grouped=false,
                          color="0277BD")

      body = create_drop_down prompt, callback_id, action_name, dropdown_options,
        is_grouped,
        color
      return make_request url, body
    end

    def make_request (url, body)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      headers = {'Content-Type' => 'application/json'}
      req = Net::HTTP::Post.new(uri, headers)
      req.body = body.to_json
      return http.request(req)
  end


  def create_drop_down(prompt, callback_id, action_name, dropdown_options,
                       is_grouped=false,
                       color="0277BD")
    body = {
      "attachments":  [
        {
          "text": prompt,
          "attachment_type": "default",
          "callback_id": "#{callback_id}",
          "actions": [
            {
              "name": action_name,
              "type": "select",
            }
          ]
        }
      ]
    }

    body[:attachments][0][:color] = color unless color.nil?
    body[:attachments][0][:actions][0][:options] = dropdown_options unless is_grouped
    body[:attachments][0][:actions][0][:option_groups] = dropdown_options if is_grouped

    return body
  end

end

end
