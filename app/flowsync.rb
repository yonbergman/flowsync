require './app/flowdock'

class Flowsync

  def initialize
    raise "Please fill configuration" if Config::TOKEN.nil? or Config::ORGANIZATION.nil? or Config::FLOWS.empty?
    @bot_said = []
    @user_tokens = Config::USERS
    @flows = Config::FLOWS
    @flowdock = Flowdock.new(Config::ORGANIZATION, @flows, Config::TOKEN)
  end


  def print_instructions
    users = @flowdock.get_all_users
    lines = []
    lines << "# Copy this text into your config file and override the USERS param"
    lines << "# replace each users token with his api token"
    lines << "# Users can find their api_token here:  https://www.flowdock.com/account/tokens"
    lines << "USERS = {"
    lines += users.map {|id, name| "\t\"#{id}\" => \"USER_TOKEN_HERE\", # #{name}" }
    lines << "}"
    content = lines.map{|x| "\t"+x}.join("\n")
    @flowdock.post_as_admin(content)
  end

  def start
    print_instructions and return if @user_tokens.empty?
    @flowdock.stream do |line|
      message = Flowdock::MessageParser.parse(line)
      unless message.nil?
        if should_repost?(message)
          @flows.reject{|flow| flow == message.flow}.each do |flow|
            repost(message, flow)
          end
        end
      end
    end
  end

  private

  def repost(message, to_flow)
    post_as(message.user, message.content, to_flow)
  end

  def post_as(user, content, flow)
    user_token = @user_tokens[user]
    return if user_token.nil?
    remember_bot_said(user, content, flow)
    @flowdock.post(user_token, content, flow)
  end

  def remember_bot_said(user, content, flow)
    @bot_said << tokenize(user,content,flow)
  end

  def did_bot_say?(user, content, flow)
    @bot_said.include? tokenize(user,content,flow)
  end

  def tokenize(user, content, flow)
    "#{user}__#{content}__#{flow}__#{Time.now.to_i / 60}"
  end

  def should_repost?(message)
    not private_message?(message.content) and not did_bot_say?(message.user, message.content, message.flow)
  end

  def private_message?(content)
    content.include? "#private"
  end


end