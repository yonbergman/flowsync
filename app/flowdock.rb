require './app/to_params'
require 'eventmachine'
require 'em-http'
require 'json'
require 'httpclient'

class Flowdock

  STREAM_URL = "https://stream.flowdock.com/flows"
  DOMAIN = "https://api.flowdock.com/"


  attr_reader :organization, :flows

  def initialize(organization, flows, main_token)
    @organization = organization
    @flows = flows
    @token = main_token
  end

  def stream(&block)
    stream_url = STREAM_URL + "?" + {:filter => build_stream_filter}.to_params

    http = EM::HttpRequest.new(stream_url, :keepalive => true, :connect_timeout => 0, :inactivity_timeout => 0)
    EventMachine.run do
      s = http.get(:head => { 'Authorization' => [@token, ''], 'accept' => 'application/json'})
      buffer = ""
      puts "listenting..."
      s.stream do |chunk|
        buffer << chunk
        while line = buffer.slice!(/.+\r\n/)
          yield(line)
        end
      end

      s.errback { puts "oops" }
    end
  end

  def post(user_token, content, flow)
    req = HTTPClient.new
    req.set_auth(DOMAIN, user_token, "SHIT")
    req.post("#{DOMAIN}v1/flows/#{@organization}/#{flow}/messages", {
        :event => "message",
        :content => content,
        :follow_redirects => true}
    )
  end

  def post_as_admin(content)
    post(@token, content, @flows.first)
  end

  def get_all_users
    users = {}
    @flows.each do |flow|
      users.merge!(get_flow_users(flow))
    end
    users
  end

  def get_flow_users(flow)
    users = {}
    req = HTTPClient.new
    req.set_auth(DOMAIN, @token, "SHIT")
    data = req.get("#{DOMAIN}v1/flows/#{@organization}/#{flow}", {:follow_redirects => true}).body
    data = JSON.parse(data)
    data["users"].each do |user|
      users[user["id"]] = user["name"]
    end
    users
  end

  class MessageParser
    def self.parse(line)
      @data = JSON.parse(line)
      @type = @data["event"]
      if @type == "message"
        return Message.new(@data)
      else
        return nil
      end
    end
  end

  class Message

    attr_reader :content, :user, :flow

    def initialize(json_data)
      @content = json_data["content"]
      @user = json_data["user"]
      @flow = json_data["flow"].split(":")[1]
    end

  end

  private

  def build_stream_filter
    flows.map{|flow| "#{organization}/#{flow}"}.join(',')
  end


end