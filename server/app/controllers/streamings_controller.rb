class StreamingsController < ApplicationController

  def parse
    puts message
    WebsocketRails[:text_channel].trigger "text", message
  end
end
